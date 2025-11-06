PROJECT = Smbc

buildServer.json:	Build
	xcode-build-server config -scheme "$(PROJECT)" -project *.xcodeproj

Build:	$(PROJECT).xcodeproj/project.pbxproj
	xcodebuild -scheme $(PROJECT)

$(PROJECT).xcodeproj/project.pbxproj:	project.yml
	xcodegen -c

# Unit tests (none exist right now and UI tests require a physical device)
# test:
# 	xcodebuild -scheme $(PROJECT) test | tee .test.out | xcbeautify

# force project file rebuild
proj:
	xcodegen

# remove files created during the build process
# do **not** use the -d option to git clean without excluding .jj
clean:
	test -d $(PROJECTF).xcodeproj && xcodebuild clean || true
	jj status
	git clean -dfx -e .jj -e notes
