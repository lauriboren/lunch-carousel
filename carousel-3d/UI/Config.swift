import UIKit

let basicRestaurants = [
    "Summer Salt",
    "Bombay Sandwich",
    "Glur",
    "Daily Provisions",
    "Oramen",
    "Thai Vila",
    "Taïm",
    "Little Beet",
    "Inday",
    "Tappo",
    "Zero Otto Nove",
    "Milu",
    "Sugarfish",
    "Sushi Burrito Yummy Stick",
    "Naya",
    "Hole In The Wall",
    "Burger & Lobster",
]

let niceRestaurants = [
    "Casa Mono",
    "Pranakhon",
    "Boucherie",
    "Rezdôra",
    "SUGARFISH",
    "Gramercy Tavern",
    "L’Express",
    "ilili",
    "Excellent Dumpling House",
]

let themes = [
    theme_white,
    theme_black,
    theme_beige,
    theme_green,
]

struct Theme {
    var screenBackgroundColor: UIColor
    var titleLabelFontColor: UIColor
    var lunchTypeButtonSelectedFontColor: UIColor
    var lunchTypeButtonDeselectedFontColor: UIColor
    var cardBackgroundColor: UIColor
    var cardTextColor: UIColor
//    var statusBarStyle: UIStatusBarStyle
}

var theme_white = Theme(
    screenBackgroundColor: UIColor(hex: "#F5F5F5")!,
    titleLabelFontColor: .black,
    lunchTypeButtonSelectedFontColor: .black,
    lunchTypeButtonDeselectedFontColor: UIColor(hex: "#666666")!,
    cardBackgroundColor: .white,
    cardTextColor: .black
//    statusBarStyle: .darkContent
)

var theme_black = Theme(
    screenBackgroundColor: UIColor(hex: "#111111")!,
    titleLabelFontColor: .white,
    lunchTypeButtonSelectedFontColor: .white,
    lunchTypeButtonDeselectedFontColor: UIColor(hex: "#666666")!,
    cardBackgroundColor: UIColor(hex: "#303030")!,
    cardTextColor: .white
//    statusBarStyle: .lightContent
)

var theme_green = Theme(
    screenBackgroundColor: UIColor(hex: "#005221")!,
    titleLabelFontColor: UIColor(hex: "#00A341")!,
    lunchTypeButtonSelectedFontColor: UIColor(hex: "#00E95D")!,
    lunchTypeButtonDeselectedFontColor: UIColor(hex: "#00A341")!,
    cardBackgroundColor: UIColor(hex: "#00A341")!,
    cardTextColor: UIColor(hex: "#FFFFFF")!
//    statusBarStyle: .darkContent
)

var theme_beige = Theme(
    screenBackgroundColor: UIColor(hex: "#E7E2D2")!,
    titleLabelFontColor: UIColor(hex: "#676459")!,
    lunchTypeButtonSelectedFontColor: UIColor(hex: "#676459")!,
    lunchTypeButtonDeselectedFontColor: UIColor(hex: "#999999")!,
    cardBackgroundColor: UIColor(hex: "#F8F4E7")!,
    cardTextColor: UIColor(hex: "#56534A")!
//    statusBarStyle: .darkContent
)

struct ScreenConfig {
    var screenBackgroundColor: UIColor = UIColor(hex: "#F5F5F5")!
    
    var titleLabelFontName: String = "PPEditorialNew-Regular"
    var titleLabelFontSize: CGFloat = 48
    var titleLabelFontColor: UIColor = .black
    var titleLabelYPosition: CGFloat = 60
    var titleLabelXCenterInParent: CGFloat = 1/2 // 1/2 means it center of label will be centered in parent. 1/3 means it will be in 1/3 of parent's width
    
    var lunchTypeButtonFontName: String = "Inter-Regular"
    var lunchTypeButtonFontSize: CGFloat = 24
    var lunchTypeButtonSelectedFontColor: UIColor = .black
    var lunchTypeButtonDeselectedFontColor: UIColor = .black
    var lunchTypeButtonYPosition: CGFloat = 180
    var basicLunchButtonXCenterInParent: CGFloat = 1/3
    var niceLunchButtonXCenterInParent: CGFloat = 2/3
    
    var carouselYOffset: CGFloat = 100 // offset of carousel from the top of the screen. It will be centered between this point and bottom of the screen
    var carouselConfig: CarouselViewConfig = carouselViewConfig_iPad
}

struct CarouselViewConfig {
    var cardWidth: CGFloat = 200
    var cardHeight: CGFloat = 300
    var cardBorderWidth: CGFloat = 5
    var cardCornerRadius: CGFloat = 10
    var cardBackgroundColor: UIColor = .white
    var cardBorderColor: UIColor = .black
    var cardPadding: CGFloat = 40
    var carouselBackgroundColor: UIColor = UIColor(hex: "F5F5F5")!
    var depthScalar: CGFloat = 1400 // Larger number moves the cards further away from the view
    var cardSpread: CGFloat = 500   // Larger number positions the cards further apart from each other
    var decelerationScalar: CGFloat = 0.95 // Rotation spin is multiplied by this. 1 - spin forever, 0 - instant stop
    var snapToCardAnimationDuration: CFTimeInterval = 0.3
    var cardFontName: String = "Inter-Medium"
    var cardFontSizeToCardWidthRatio: CGFloat = 0.09 // The resulting formula: fontSize = card.width * cardFontSizeToCardWidthRatio
    var cardFontColor: UIColor = .black
}

let carouselViewConfig_iPad = CarouselViewConfig(
    cardWidth: 307,
    cardHeight: 412,
    cardBorderWidth: 0,
    cardCornerRadius: 12,
    cardBackgroundColor: .white,
    cardBorderColor: .black,
    carouselBackgroundColor: UIColor(hex: "#F5F5F5")!,
    depthScalar: 2400,
    cardSpread: 445,
    decelerationScalar: 0.98,
    snapToCardAnimationDuration: 0.4,
    cardFontName: "Inter-Medium",
    cardFontSizeToCardWidthRatio: 0.08,
    cardFontColor: .black
)

let screenConfig_iPad = ScreenConfig()
let screenConfig_iPhone = ScreenConfig(
    titleLabelFontSize: 36,
    titleLabelYPosition: 80,
    lunchTypeButtonFontSize: 18,
    basicLunchButtonXCenterInParent: 2/7,
    niceLunchButtonXCenterInParent: 5/7,
    carouselYOffset: 160,
    carouselConfig: CarouselViewConfig(
        cardWidth: 168,
        cardHeight: 288,
        cardBorderWidth: 0,
        cardCornerRadius: 12,
        cardBackgroundColor: .white,
        cardBorderColor: .black,
        carouselBackgroundColor: UIColor(hex: "#F5F5F5")!,
        depthScalar: 700,
        cardSpread: 240,
        decelerationScalar: 0.96,
        snapToCardAnimationDuration: 0.3,
        cardFontName: "Inter-Medium",
        cardFontSizeToCardWidthRatio: 0.08,
        cardFontColor: .black
    )
)
