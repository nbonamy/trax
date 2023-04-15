
release:
	flutter build macos

install deploy: release
	sudo rm -rf /Applications/trax.app
	sudo cp -rf ./build/macos/Build/Products/Release/trax.app /Applications
