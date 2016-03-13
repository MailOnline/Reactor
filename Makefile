all: iOS9

iOS9:
	xcodebuild clean test -project Reactor.xcodeproj -scheme Reactor-iOS -sdk iphonesimulator -destination 'OS=9.2,name=iPhone 6' -enableCodeCoverage YES | xcpretty