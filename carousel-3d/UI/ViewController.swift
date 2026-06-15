import UIKit

class ViewController: UIViewController, CarouselViewDelegate {
    
    enum LunchType {
        case basic
        case nice
    }
    
    var carouselView: CarouselView!
    var titleLabel: UILabel!
    var basicLunchButton: UIButton!
    var niceLunchButton: UIButton!
    var lunchTypeButtonUnderlineView: UIView!
    
    var lobsterView: UILabel!
    
    var config: ScreenConfig = screenConfig_iPad
    var selectedTheme = 0
    
    var isBurgerAndLobsterDay = false
    var selectedLunchType = LunchType.basic

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCarouselView()
        initTitleLabel()
        initLunchTypeButtons()
        initLunchTypeButtonUnderlineView()
        
        lobsterView = UILabel()
    
        applyTheme(theme: themes[selectedTheme])
        
//        let holidays = getAllHolidays(year: 2023)
//        for holiday in holidays {
//            print(holiday)
//        }
    }
    
    private func initCarouselView() {
        carouselView = CarouselView(
            frame: CGRect(
                x: 0,
                y: config.carouselYOffset,
                width: view.bounds.width,
                height: view.bounds.height - config.carouselYOffset
            ),
            config: config.carouselConfig,
            restaurants: basicRestaurants
        )
        view.addSubview(carouselView)
        carouselView.delegate = self
    }
    
    private func initTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "As a user, I want a"
        applyConfigToTitleLabel(titleLabel, config: config)
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTapped)))
        view.addSubview(titleLabel)
    }
    
    private func initLunchTypeButtons() {
        basicLunchButton = UIButton()
        basicLunchButton.setTitle("BASIC LUNCH", for: .normal)
        applyConfigToLunchTypeButton(basicLunchButton, isUnderlined: true, config: config, isLeftButton: true)
        basicLunchButton.addTarget(self, action: #selector(basicLunchButtonTapped), for: .primaryActionTriggered)
        view.addSubview(basicLunchButton)
        
        niceLunchButton = UIButton()
        niceLunchButton.setTitle("NICE LUNCH™", for: .normal)
        applyConfigToLunchTypeButton(niceLunchButton, isUnderlined: false, config: config, isLeftButton: false)
        niceLunchButton.addTarget(self, action: #selector(niceLunchButtonTapped), for: .primaryActionTriggered)
        view.addSubview(niceLunchButton)
        
    }
    
    private func initLunchTypeButtonUnderlineView() {
        let underlineWidth: CGFloat = basicLunchButton.frame.width - 6
        let underlineHeight: CGFloat = 1
        // The "- 0.5" at the end of underlineXPos expression is just some pixel polishing. It looks visually more pleasing if the line
        // is a little more towards the left side probably because of the shape of the characters in the buttons. This is very specific
        // to the current font, font size, and the actual text, so wouldn't necessarily make sense if any of these three changes.
        let underlineXPos: CGFloat = basicLunchButton.frame.midX - underlineWidth / 2 - 0.5
        let underlineYPos: CGFloat = basicLunchButton.frame.maxY - 10
        lunchTypeButtonUnderlineView = UIView(frame: CGRect(x: underlineXPos, y: underlineYPos, width: underlineWidth, height: underlineHeight))
        lunchTypeButtonUnderlineView.backgroundColor = config.lunchTypeButtonSelectedFontColor
        lunchTypeButtonUnderlineView.isUserInteractionEnabled = false
        view.addSubview(lunchTypeButtonUnderlineView)
    }
    
    @objc private func basicLunchButtonTapped(_ button: UIButton) {
        setLunchType(.basic)
    }
    
    @objc private func niceLunchButtonTapped(_ button: UIButton) {
        setLunchType(.nice)
    }
    
    @objc private func titleTapped(_ rec: UITapGestureRecognizer) {
        selectedTheme = (selectedTheme + 1) % themes.count
        applyTheme(theme: themes[selectedTheme])
    }
    
    func carouselView(_ carouselView: CarouselView, didChooseRestaurant restaurant: String) {
        if isBurgerAndLobsterDay {
            if restaurant != "Burger & Lobster" {
                bringOutTheLobster()
            }
        }
    }
    
    func setLunchType(_ type: LunchType) {
        switch type {
        case .basic:
            selectedLunchType = .basic
            carouselView.setRestaurants(restaurants: basicRestaurants)
            applyConfigToLunchTypeButton(basicLunchButton, isUnderlined: true, config: config, isLeftButton: true)
            applyConfigToLunchTypeButton(niceLunchButton, isUnderlined: false, config: config, isLeftButton: false)
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                self.lunchTypeButtonUnderlineView.transform = CGAffineTransformIdentity
            }
        case .nice:
            selectedLunchType = .nice
            carouselView.setRestaurants(restaurants: niceRestaurants)
            applyConfigToLunchTypeButton(basicLunchButton, isUnderlined: false, config: config, isLeftButton: true)
            applyConfigToLunchTypeButton(niceLunchButton, isUnderlined: true, config: config, isLeftButton: false)
            // The 1.05 multiplier is because we're just dividing by number of characets, but of course, this is not preceise
            // in a non-monospace font, since characters can be different width. So it's impreciese and kinda adjusted for this
            // exact text and font :shrug:
            let widthOfTMCharacter: CGFloat = niceLunchButton.frame.width / CGFloat(niceLunchButton.titleLabel?.text?.count ?? 11) * 1.05
            let distance = niceLunchButton.frame.minX - basicLunchButton.frame.minX - (widthOfTMCharacter / 2)
            let scale = (niceLunchButton.frame.width - widthOfTMCharacter) / basicLunchButton.frame.width
            // Move the underline from BASIC LUNCH to NICE LUNCH button. Sprint damping 0.5 adds some spring effect.
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                self.lunchTypeButtonUnderlineView.transform = self.lunchTypeButtonUnderlineView.transform.translatedBy(x: distance, y: 0)
            }
            // Make the underline narrower to match the "NICE LUNCH" button width. Spring damping 1.0 means no spring effect.
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5) {
                self.lunchTypeButtonUnderlineView.transform = self.lunchTypeButtonUnderlineView.transform.scaledBy(x: scale, y: 1)
            }
        }
    }
}

// MARK: - Theme and configuration

extension ViewController {
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        themes[selectedTheme].statusBarStyle
//    }
    
    private func applyTheme(theme: Theme) {
        config.screenBackgroundColor = theme.screenBackgroundColor
        config.titleLabelFontColor = theme.titleLabelFontColor
        config.lunchTypeButtonSelectedFontColor = theme.lunchTypeButtonSelectedFontColor
        config.lunchTypeButtonDeselectedFontColor = theme.lunchTypeButtonDeselectedFontColor
        config.carouselConfig.cardBackgroundColor = theme.cardBackgroundColor
        config.carouselConfig.carouselBackgroundColor = theme.screenBackgroundColor
        config.carouselConfig.cardFontColor = theme.cardTextColor
        UIView.animate(withDuration: 2.0, delay: 0, options: .transitionCrossDissolve) {
            self.applyConfig(self.config)
        }
    }
    
    private func applyConfig(_ config: ScreenConfig) {
        view.backgroundColor = config.screenBackgroundColor
        lunchTypeButtonUnderlineView.backgroundColor = config.lunchTypeButtonSelectedFontColor
        applyConfigToTitleLabel(titleLabel, config: config)
        applyConfigToLunchTypeButton(basicLunchButton, isUnderlined: selectedLunchType == .basic, config: config, isLeftButton: true)
        applyConfigToLunchTypeButton(niceLunchButton, isUnderlined: selectedLunchType == .nice, config: config, isLeftButton: false)
        applyConfigToCarousel(carouselView, config: config)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func applyConfigToCarousel(_ carousel: CarouselView, config: ScreenConfig) {
        carousel.frame = CGRect(
            x: 0,
            y: config.carouselYOffset,
            width: view.bounds.width,
            height: view.bounds.height - config.carouselYOffset
        )
        carousel.applyTheme(
            backgroundColor: config.carouselConfig.carouselBackgroundColor,
            cardColor: config.carouselConfig.cardBackgroundColor,
            textColor: config.carouselConfig.cardFontColor
        )
    }
    
    private func applyConfigToTitleLabel(_ label: UILabel, config: ScreenConfig) {
        label.font = UIFont(name: config.titleLabelFontName, size: config.titleLabelFontSize)!
        
        animateTextColor(label: label, color: config.titleLabelFontColor, duration: 2)

        let textSize = label.font.getSize(for: label.text!)
        label.frame = CGRect(
            x: view.bounds.width * config.titleLabelXCenterInParent - textSize.width / 2,
            y: config.titleLabelYPosition,
            width: textSize.width,
            height: textSize.height * 2
        )
    }
    
    private func animateButtonColor(button: UIButton, color: UIColor, duration: TimeInterval) {
        
        let changeColor = CATransition()
        changeColor.duration = duration

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            button.titleLabel?.layer.add(changeColor, forKey: nil)
            
            button.setTitleColor(color, for: .normal)
        }

        button.setTitleColor(color, for: .normal)

        CATransaction.commit()
    }
    
    private func animateTextColor(label: UILabel, color: UIColor, duration: TimeInterval) {
        let changeColor = CATransition()
        changeColor.duration = duration

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            label.layer.add(changeColor, forKey: nil)
            label.textColor = color
        }

        label.textColor = color

        CATransaction.commit()
    }
    
    private func applyConfigToLunchTypeButton(_ button: UIButton, isUnderlined: Bool, config: ScreenConfig, isLeftButton: Bool) {
        button.titleLabel?.font = UIFont(name: config.lunchTypeButtonFontName, size: config.lunchTypeButtonFontSize)!
        animateButtonColor(button: button, color: isUnderlined ? config.lunchTypeButtonSelectedFontColor : config.lunchTypeButtonDeselectedFontColor, duration: 2)
        let textSize = button.titleLabel!.font.getSize(for: button.title(for: .normal)!)
        button.frame = CGRect(
            x: view.bounds.width * (isLeftButton ? config.basicLunchButtonXCenterInParent : config.niceLunchButtonXCenterInParent) - textSize.width / 2,
            y: config.lunchTypeButtonYPosition,
            width: textSize.width,
            height: textSize.height * 2
        )
    }
}
