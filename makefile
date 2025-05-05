PROJECT = smbc

default:	$(PROJECT).xcodeproj Build buildServer.json

# force regeneration of $(PROJECT).xcodeproj
project:
	xcodegen -c

# force build
xcodebuild:
	xcodebuild -scheme $(PROJECT)

$(PROJECT).xcodeproj:	project

Build:
	xcodebuild -scheme $(PROJECT)

buildServer.json:	Build
	buildserver $(PROJECT)

clean:
	git clean -fdx
