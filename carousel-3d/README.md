#  Reaktor Restaurant Picker -- 3D Carousel Version

## To Do
* Make a logo
* Change the app name
* Add confetti animation or like burger and lobster emojis flying -- with fanfare sounds
* Fix potential crash: let depthScalar = iPadCardSizingForNumCards[restaurants.count]!.depthScalar
* Add transition animation for the restaurant cards when changing between BASIC and NICE lunch
* Optimize CarouselView -- like things like calculating "cardAngleDelta" is useless every time, because it stays the same
* Show proper error messages instead of fatalError so that I can debug the problem if it happens on the iPad
* Come up with better carousel sounds


## Doing
* If it's a payday, whenever you spin, a lobster comes out and fixes the wheel at Burger & Lobster

## Done
* Long restaurant name word wrap "Excellent Dumpling House"
* Refactor
* Implement changing themes
* Find a better way to snap to nearest card when done spinning
* Implement Basic / Nice lunch button underline
* Adjust the wheel size for various number of restaurants, at least 8 to 18 (ended up having fixed number of cards and mapping variable number of restaurants to them)

