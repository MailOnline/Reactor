all: iOS9

iOS9:
	set -o pipefail && xcodebuild test -scheme Reactor-iOS -sdk iphonesimulator -enableCodeCoverage YES | xcpretty
