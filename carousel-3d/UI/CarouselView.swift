import AVFoundation
import UIKit

// Here's a little overview of how the restaurant names are placed on the cards.
// There are exactly 8 cards, arranged in a circular formation, looking like this from the top:
//      _
//   /     \
//  |       |
//   \     /
//      -
//
// The number of restaurants varies. It can be 4, it can be 20. So we need a way to map those restaurant
// names onto the cards as the wheel is spinning.
//
// You might wonder, why not just have as many cards as there are restaurants and call it a day? The problem is then
// our wheel might either be very small, or very big (mostly very big, we have many restaurants), and the shape would not be
// optimal anymore. In case of having 20 restaurants, the wheel would be so large that when viewed on the screen, it would just appear
// as if it's just a horizontally scrolling list instead of a wheel. Kinda like why Earth's horizont looks flat, even though Earth is a
// globe.

// So anyway, we need to place restaurant names onto cards as the cards are spinning around, and the number of cards is likely different
// than the number of restaurants.

// So what we do here is, first, we take all the cards that are facing the camera (basically half of the circle) and map restaurants onto them.
// Then as the cards are rotating, and a new card becomes visible, we need to put the next restaurant name onto it. How do we know what
// restaurant name it should get? We just look at the its neighboring card (one that's already visible) and what restaurant index that one
// has and pick the next index.

// We keep track of which cards display which restaurants using the `visibleCardToRestaurantMap` dictionary. Whenever the wheel rotates,
// we update this dictionary with a map of visibleCardIndex to restaurantIndex.
// Then the rendering method takes puts the appropriate restaurant name to the card based on `visibleCardToRestaurantMap`.

// EXAMPLE
// Say we have 8 cards and 10 restaurants.
// Say we have 3 cards visible: C7, C0, C1. C6 and C2 are just off the sides, so they are not visible yet.
// We will assign restaurants to the visible ones:
//     C6
// ----------------
//     C7  -  R9
//     C0  -  R0
//     C1  -  R1
// ----------------
//     C2

// Then user starts rotating the cards:
//
//     C5
// ----------------
//     C6
//     C7  -  R9
//     C0  -  R0
//     C1  -  R1
// ----------------
//     C2
//
// * C6 becomes visible
// * Look at the dictionary: C5 is not in it, C7 is.
// * Since C6 is smaller than C7, the restaurant must be C7R - 1 = 7-1 = R6
//      We should also make sure it's not negative and mod: (restaurants.count + C7R - 1) % restaurants.count
// * Update the dictionary to add C6 - R6

//
//     C5
// ----------------
//     C6  -  R8
//     C7  -  R9
//     C0  -  R0
// ----------------
//     C1  -  R1
//
// * C1 becomes invisible
// * Look at the dictionary: does it have C1? Yes
// * Remove C1 from the dictionary

//
//     C5
// ----------------
//     C6  -  R6
//     C7  -  R7
//     C0  -  R0
// ----------------
//     C1
//

// We might wanna limit the max rotation speed of the wheel, to avoid situations where we jump to where all previously visible cards are suddenly
// invisible and there's a gap between last visible and first invisible card. 🤷‍♂️ Haven't done that.

//
//
// ===========================================================================================================================
//
// Here's how snapping to a given card works (once spinning stops and we need to snap to one card automatically):

// Say we want to animate in 500 ms
// Say we have distance of 15 degrees
// Easing functions take values from 0.0 to 1.0 and distribute it differently.
// Say we have a timeline:
//
//   0        100       200       300       400       500 ------- milliseconds
//   |         |         |         |         |         |
//   ---------------------------------------------------
//
//   0         3         6         9         12        15 ------- degrees
//
// timeToDegrees: (time_ms) -> degrees
// timeNorm = time_ms / total_time_ms
// degrees = total_degrees * timeNorm
//
// if we want to add easing, we can apply an easing function to timeNorm
// degrees = total_degrees * easing(timeNorm)

private let numCards = 8
private let segmentWidth = 360.0 / CGFloat(numCards)

enum CarouselState {
    case idle
    case userDragging
    case snappingToCard
    case decelerating
}

protocol CarouselViewDelegate: AnyObject {
    func carouselView(_ carouselView: CarouselView, didChooseRestaurant restaurant: String)
}

class CarouselView: UIView {
    
    weak var delegate: CarouselViewDelegate? = nil
    
    private let transformLayer = CATransformLayer()
    private var displayLink: CADisplayLink!
    private var audioPlayer: AudioPlayer!
    private var cardTextSizing: CardTextSizing!
    
    private var restaurants: [String] = []
    
    private var config: CarouselViewConfig = carouselViewConfig_iPad
    
    private var currentAngle: CGFloat = 0
    private var prevCarouselDrawAngle: CGFloat = 0
    private var rotationVelocity: CGFloat = 0
    // Number of touch history items affects how flicks are interpreted.
    // Many of them (like 8) will give a more accurate "average" speed filtering out any accidental jerky motions, but also
    // will remember intial "wrong" direction, for example if finger moved a bit left before moing right, the small left movtion will affect the
    // average speed, which might seem wrong. Something like 3 items seems to work fine.
    private var touchHistory: [(time: CFTimeInterval, xLocation: CGFloat)] = [
        (0, 0), (0, 0), (0, 0)
    ]
    private var touchHistoryCount = 0
    private var prevDisplayLinkUpdateTime: CFTimeInterval = 0
    private var prevDisplayLinkUpdateAngle: CGFloat = 0
    private var carouselState = CarouselState.idle
    private var snapToCardStartTime: CFTimeInterval = 0
    private var snapToCardEasingFunction: (CGFloat) -> CGFloat = easeInOutSine(x:)
    private var snapToCardStartAngle: CGFloat = 0
    private var snapToCardTargetAngle: CGFloat = 0
    private var snapToCardDuration: CGFloat = 0
    private var cardCenterAngles: [CGFloat] = []
    private var layerIds: [CALayer: Int] = [:]
    private var textLayers: [Int: CATextLayer] = [:]
    /// `visibleCardToRestaurantMap` maps visible card indices to restaurant indices. As the carousel rotates, cards
    /// become visible, and then hidden again. We map the restaurant names onto the visible cards. This is the map that
    /// holds that currently visible card to restaurant mapping information. This is then used when decided what text
    /// to place into text labels on the screen.
    private var visibleCardToRestaurantMap = [Int:Int]()
    
    init(frame: CGRect, config: CarouselViewConfig, restaurants: [String]) {
        super.init(frame: frame)
        
        let fontSize = config.cardWidth * config.cardFontSizeToCardWidthRatio
        cardTextSizing = CardTextSizing(
            font: UIFont(name: config.cardFontName, size: fontSize)!,
            containerSize: CGSize(width: config.cardWidth, height: config.cardHeight),
            containerPadding: CGSize(width: config.cardPadding, height: config.cardPadding)
        )
        
        self.restaurants = restaurants
        self.config = config
        
        transformLayer.frame = bounds
        layer.addSublayer(transformLayer)
        
        for i in 0..<numCards {
            initCardLayer(forCardIndex: i)
            cardCenterAngles.append(CGFloat((360 / numCards * i)))
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .default)
        
        layer.backgroundColor = config.carouselBackgroundColor.cgColor
        
        audioPlayer = AudioPlayer()
        
        // Calling drawCarousel to render the cards for the first time
        drawCarousel()
    }
    
    private func initCardLayer(forCardIndex idx: Int) {
        let cardSize = CGSize(width: config.cardWidth, height: config.cardHeight)
        
        let cardLayer = CALayer()
        cardLayer.frame = CGRect(
            x: frame.size.width / 2 - cardSize.width / 2,
            y: frame.size.height / 2 - cardSize.height / 2,
            width: cardSize.width,
            height: cardSize.height
        )
        cardLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        cardLayer.backgroundColor = config.cardBackgroundColor.cgColor
        cardLayer.isDoubleSided = false
        
        cardLayer.borderColor = config.cardBorderColor.cgColor
        cardLayer.borderWidth = config.cardBorderWidth
        cardLayer.cornerRadius = config.cardCornerRadius
        
        let text = restaurants[idx % restaurants.count]
        let textLayer = CATextLayer()
        textLayer.isWrapped = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = config.cardWidth * config.cardFontSizeToCardWidthRatio
        textLayer.font = CTFontCreateWithName(config.cardFontName as CFString, textLayer.fontSize, nil)
        let textLayerSize = cardTextSizing.measure(text)
        textLayer.frame = CGRect(size: textLayerSize, centeredWithin: cardLayer.bounds.size)
        textLayer.string = text
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = config.cardFontColor.cgColor
        cardLayer.addSublayer(textLayer)
        layerIds[cardLayer] = idx
        textLayers[idx] = textLayer
        
        transformLayer.addSublayer(cardLayer)
    }
    
    func applyTheme(backgroundColor: UIColor, cardColor: UIColor, textColor: UIColor) {
        layer.backgroundColor = backgroundColor.cgColor
        for cardLayer in layerIds.keys {
//            cardLayer.backgroundColor = cardColor.cgColor
            animateCardColor(layer: cardLayer, color: cardColor, duration: 2)
        }
        for textLayer in textLayers.values {
//            textLayer.foregroundColor = textColor.cgColor
            animateTextColor(textLayer: textLayer, color: textColor, duration: 2)
        }
    }
    
    private func animateCardColor(layer: CALayer, color: UIColor, duration: TimeInterval) {
        let changeColor = CATransition()
        changeColor.duration = duration

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            layer.add(changeColor, forKey: nil)
            layer.backgroundColor = color.cgColor
        }

        CATransaction.commit()
    }
    private func animateTextColor(textLayer: CATextLayer, color: UIColor, duration: TimeInterval) {
        let changeColor = CATransition()
        changeColor.duration = duration

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            textLayer.add(changeColor, forKey: nil)
            textLayer.foregroundColor = color.cgColor
        }

        CATransaction.commit()
    }
    
    
    
    func setRestaurants(restaurants: [String]) {
        self.restaurants = restaurants
        drawCarousel()
    }
    
    func spinTo(restaurant: String, duration: TimeInterval) {
        let currentCardIndex = frontMostCardIndex()
        let currentRestaurant = restaurantForCard(currentCardIndex)!
        let currentRestaurantIndex = Int(restaurants.firstIndex(of: currentRestaurant)!)
        let targetRestaurantIndex = Int(restaurants.firstIndex(of: restaurant)!)
        let segmentDelta = targetRestaurantIndex - currentRestaurantIndex
        let overshootAmout = segmentWidth / 4
        let angleDelta = CGFloat(segmentDelta + restaurants.count) * segmentWidth + overshootAmout
        snapToAngle(targetAngle: currentAngle - angleDelta, diration: duration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func update(displayLink: CADisplayLink) {
        let timeNow = CACurrentMediaTime()
        
        switch carouselState {
        case .idle:
            // In case not snapped to a card, snap
            if (CGFloat(frontMostCardIndex()) * segmentWidth != currentAngle) {
                snapToCard(cardIndex: frontMostCardIndex())
            }
            break
        case .userDragging:
            // The user is dragging the carousel with their finger. No need to calcualte anything, we're just gonna call
            // the `drawCarousel` method if angle has changed since last draw.
            // The `drawCarousel` is called at the end of this method, because it's needed for all the code paths.
            // So nothing more to do in this if block.
            break
        case .snappingToCard:
            // The carousel is currently doing the snap-to-card animation.
            
            let timePassed = timeNow - snapToCardStartTime
            if timePassed > snapToCardDuration {
                // We reched over the end of planned animation time. Just set the final angle to the target angle and we're done.
                carouselState = .idle
                currentAngle = normalizeAngle(snapToCardTargetAngle)
                if let restaurant = restaurantForCard(frontMostCardIndex()) {
                    delegate?.carouselView(self, didChooseRestaurant: restaurant)
                }
            } else {
                // On each render cycle, we take the current time and find what the current angle should be.
                let timeProgress = timePassed / snapToCardDuration // This is value between 0.0 and 1.0 (0% to 100% time)
                let targetDistance = snapToCardTargetAngle - snapToCardStartAngle
                let currentDistance = targetDistance * snapToCardEasingFunction(timeProgress)
                currentAngle = normalizeAngle(snapToCardStartAngle + currentDistance)
            }
        case .decelerating:
            // So the user is not dragging, the carousel is not snapping to card, but we have some velocity.
            // That means that likely the user dragged the carousel and let go, and now we're spinning.
            // This means we need to decelerate.
            
            // If the touch ended after the "prevDisplayLinkUpdateTime", then we should use that in our delta calculation instead
            let prevTime = max(prevDisplayLinkUpdateTime, touchHistory[touchHistory.count - 1].time)
            let timePassed = timeNow - prevTime
            prevDisplayLinkUpdateTime = timeNow
            let rotationDelta = rotationVelocity * timePassed
            currentAngle = normalizeAngle(currentAngle + rotationDelta)
            rotationVelocity *= config.decelerationScalar // Slow rotation down
            if abs(rotationVelocity) < 5.0 {
                // We're below minimum velocity, time to stop completely
                rotationVelocity = 0
                // And then snap to nearest card
                snapToCard(cardIndex: frontMostCardIndex())
            }
        }
        
        guard currentAngle != prevDisplayLinkUpdateAngle else {
            // Angle didn't change at all since last draw:
            // - no need to play sounds
            // - no need to redraw
            return
        }
        
        // Play sound effects if needed
        if carouselState != .idle {
            // Playing sound every time we pass a center of any card. To do that, we just check if center of any card
            // angle is between past and current update angles.
            if cardCenterAngles.contains(where: { $0.isBetweenOrEqualTo(prevDisplayLinkUpdateAngle, currentAngle) }) {
                audioPlayer.play()
            }
        }
        
        // Redraw
        drawCarousel()
        
        prevDisplayLinkUpdateAngle = currentAngle
    }
    
    private func drawCarousel() {
        guard let transformLayerSublayers = transformLayer.sublayers else { return }
        
        var visibleCards = [Int]()
        var invisibleCards = [Int]()
        var cardAngle = currentAngle
        
        CATransaction.setAnimationDuration(0) // instant animation
        
        for layer in transformLayerSublayers {
            var transform = CATransform3DIdentity
            transform.m34 = -1 / config.depthScalar // the closer this is to 0 the deeper our perspective gets
            transform = CATransform3DRotate(transform, degreeToRadians(deg: cardAngle), 0, 1, 0) // rotate around the Y axis
            transform = CATransform3DTranslate(transform, 0, 0, config.cardSpread) // translate in Z axis
            layer.transform = transform
            
            // Place card into visible or invisible array. If angle is between 0 and 90 or between 270 and 360 --> visible
            let cardIdx = layerIds[layer]!
            if (cardAngle >= 0 && cardAngle <= 90) || (cardAngle >= 270 && cardAngle <= 360) {
                visibleCards.append(cardIdx)
            } else {
                invisibleCards.append(cardIdx)
            }
            
            cardAngle = normalizeAngle(cardAngle - segmentWidth)
        }
        
        // Place restaurant names onto visible cards
        updateCardToRestaurantMap(visibleCards: visibleCards, invisibleCards: invisibleCards)
        for (cardId, restaurantId) in visibleCardToRestaurantMap {
            let text = restaurants[restaurantId]
            let textLayer = textLayers[cardId]!
            let textLayerSize = cardTextSizing.measure(text)
            textLayer.frame = CGRect(size: textLayerSize, centeredWithin: CGSize(width: config.cardWidth, height: config.cardHeight))
            textLayer.string = text
        }
        
        prevCarouselDrawAngle = currentAngle
    }
    
    private func restaurantForCard(_ cardIndex: Int) -> String? {
        if let restaurantIndex = visibleCardToRestaurantMap[cardIndex] {
            return restaurants[restaurantIndex]
        } else {
            return nil
        }
    }
    
    /// This function keeps `visibleCardToRestaurantMap` up to date.
    private func updateCardToRestaurantMap(visibleCards: [Int], invisibleCards: [Int]) {
        var cardsToAdd = visibleCards
        
        if visibleCardToRestaurantMap.isEmpty {
            // Looks like this is the first time we're adding cards, so our dictionary is empty.
            // Add the first card manually, and map it to restaurant index 0:
            visibleCardToRestaurantMap[visibleCards[0]] = 0
            cardsToAdd.removeFirst()
        }
        
        // Add visible cards to the map
        var maxAttempts = cardsToAdd.count
        while cardsToAdd.count > 0 {
            var addedCards = [Int]()
            
            for thisCardIdx in cardsToAdd {
                // See if left or right neighbor card is already in the map, and infer this card's restaurant index based on that.
                let leftNeighborIdx = (numCards + (thisCardIdx - 1)) % numCards // avoiding negative numbers and keeping in range
                let rightNeighborIdx = (numCards + (thisCardIdx + 1)) % numCards
                if let leftNeighborRestaurantIdx = visibleCardToRestaurantMap[leftNeighborIdx] {
                    // Left neighbor card is visible and has a restaurant mapped to it. This means that current card should have
                    // restaurant index = neighbor card's restaurant index - 1
                    let thisRestaurantIdx = (restaurants.count + (leftNeighborRestaurantIdx - 1)) % restaurants.count
                    visibleCardToRestaurantMap[thisCardIdx] = thisRestaurantIdx
                    addedCards.append(thisCardIdx)
                } else if let rightNeighborRestaurantIdx = visibleCardToRestaurantMap[rightNeighborIdx] {
                    // Right neighbor card is visible and has a restaurant mapped to it. This means that current card should have
                    // restaurant index = neighbor card's restaurant index - 1
                    let thisRestaurantIdx = (restaurants.count + (rightNeighborRestaurantIdx + 1)) % restaurants.count
                    visibleCardToRestaurantMap[thisCardIdx] = thisRestaurantIdx
                    addedCards.append(thisCardIdx)
                } else {
                    // There was no visible neighbor to infer the restaurant index from. This is normal when multiple cards
                    // become visible in between rendering cycles, and we haven't gone through all those new cards yet.
                    // In that case, we'll just skip this card for now, and will come back to it in the outer `while` loop, when
                    // we have more visible cards in the map, and then we might have a neighbor card.
                    maxAttempts -= 1
                    // Limit the number of times we try to map card to restaurant
                    if maxAttempts == 0 {
                        // Basically we somehow ended up in a situation where we can't find a neighboring card so we don't know what
                        // restaurant index is next. There's no good way to recover.
                        // We'll just map it to restaurant index 0, a kind of a reset
                        print("ERROR mapping card to restaurant. Couldn't find a neighboring card to decide what restaurant is next")
                        visibleCardToRestaurantMap[thisCardIdx] = 0
                        addedCards.append(thisCardIdx)
                    }
                }
            }
            
            // We've added all or some cards to the map (hopefully). Remove them from `cardsToAdd`.
            // Most of the time all cards would be added at once, so this would only run once.
            // But simetimes it might happen that we weren't able to add all cards, so we'll come back to this
            // again in the next `while` loop iteration.
            // This might happen when multiple cards become visible at once between rendering cycles, and we're not
            // able to find any visible neighbors for a given card on first pass.
            for addedCard in addedCards {
                cardsToAdd.removeAll(where: { $0 == addedCard })
            }
        }
        
        // Remove any cards that are no longer visible from the map
        for thisCardIdx in invisibleCards {
            // In case card not found in map, the removeValue will just return nil, so we can call it on all invisible cards without worry
            visibleCardToRestaurantMap.removeValue(forKey: thisCardIdx)
        }
    }
    
    private func snapToAngle(targetAngle: CGFloat, diration: TimeInterval) {
        carouselState = .snappingToCard
        snapToCardStartTime = CACurrentMediaTime()
        snapToCardStartAngle = currentAngle
        snapToCardDuration = diration
        snapToCardEasingFunction = easeOutCirc(x:)
        
        let targetCardAngle = targetAngle
        let angleDelta = targetCardAngle - snapToCardStartAngle
        snapToCardTargetAngle = currentAngle + angleDelta
    }
    
    private func snapToCard(cardIndex: Int) {
        carouselState = .snappingToCard
        snapToCardStartTime = CACurrentMediaTime()
        snapToCardStartAngle = currentAngle
        snapToCardDuration = config.snapToCardAnimationDuration
        snapToCardEasingFunction = easeInOutSine(x:)
        
        let targetCardAngle = CGFloat(cardIndex) * segmentWidth
        var angleDelta = targetCardAngle - snapToCardStartAngle
        if abs(angleDelta) > 180 {
            // Looks like we went from close to 0 to close to 360.
            if snapToCardStartAngle > 300 {
                angleDelta = 360 - snapToCardStartAngle
            }
        }
        snapToCardTargetAngle = currentAngle + angleDelta
    }
    
    private func frontMostCardIndex() -> Int {
        var cardIdx = Int((currentAngle + segmentWidth / 2) / segmentWidth)
        
        // Handle going from 360 to 0 degree on a circle
        if cardIdx == numCards {
            cardIdx = 0
        }
        
        return cardIdx
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentLocation = touches.first?.location(in: self).x else { return }
        carouselState = .userDragging
        updateTouchHistory(currentLocation)
        touchHistoryCount = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentLocation = touches.first?.location(in: self).x else { return }
        let previousLocation = touchHistory[touchHistory.count - 1].xLocation
        let touchDelta = currentLocation - previousLocation
        let touchDeltaToWheelAngleRatio = 0.12 // Making this smaller makes the wheel spin slower in relation to finger movement
        currentAngle = normalizeAngle(currentAngle + touchDelta * touchDeltaToWheelAngleRatio)
        
        updateTouchHistory(currentLocation)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches)
    }
    
    private func updateTouchHistory(_ xLocation: CGFloat) {
        for i in 0..<touchHistory.count - 1 {
            touchHistory[i] = touchHistory[i + 1]
        }
        
        touchHistory[touchHistory.count - 1] = (time: CACurrentMediaTime(), xLocation: xLocation)
        touchHistoryCount = min((touchHistoryCount + 1), touchHistory.count)
    }
    
    private func endTouches(_ touches: Set<UITouch>) {
        guard let currentLocation = touches.first?.location(in: self).x else { return }
        
        updateTouchHistory(currentLocation)
        
        // Take the last N touches and calcualte average velocity of those touches
        let locationStart = touchHistory[touchHistory.count - touchHistoryCount].xLocation
        let locationEnd = touchHistory[touchHistory.count - 1].xLocation
        let locationDelta = locationEnd - locationStart
        
        guard abs(locationDelta) >= 2 else {
            // If the touch moved less than 2 pixels, don't consider it dragging
            rotationVelocity = 0
            carouselState = .idle
            return
        }
        
        let timeStart = touchHistory[touchHistory.count - touchHistoryCount].time
        let timeEnd = touchHistory[touchHistory.count - 1].time
        let timeDelta = timeEnd - timeStart
        
        rotationVelocity = locationDelta / timeDelta * 0.4
        
        carouselState = .decelerating
    }
}
