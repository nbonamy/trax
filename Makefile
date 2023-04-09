
release:
	flutter build macos

install deploy: release
	sudo rm -rf /Applications/foto.app
	sudo cp -rf ./build/macos/Build/Products/Release/foto.app /Applications
