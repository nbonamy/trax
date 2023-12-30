
release:
	flutter build macos

install deploy: release
	sudo rm -rf /Applications/trax.app
	sudo cp -rf ./build/macos/Build/Products/Release/trax.app /Applications

tag = $(filter-out $@,$(MAKECMDGOALS))
publish:
	@[ "${tag}" ] && echo "Publishing version ${tag}" || ( echo "Usage: make publish <tag>"; exit 1 )
	@-cd ./build/macos/Build/Products/Release/ &&  rm trax.zip > /dev/null 2>&1
	@cd ./build/macos/Build/Products/Release/ &&  zip -q -r trax.zip trax.app
	cd ./build/macos/Build/Products/Release/ &&  gh release create $(tag) --notes "" --repo nbonamy/trax ./trax.zip

%:
	@:
