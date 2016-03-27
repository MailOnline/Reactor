all: iOS9

iOS9:
	xcodebuild test -scheme Reactor-iOS -sdk iphonesimulator -enableCodeCoverage YES | xcpretty