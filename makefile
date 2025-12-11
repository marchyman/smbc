PROJECT = Smbc
YEAR = 2026

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

# Update the json data files in the project from the current values
# on the smbc web site. Only works on snafu machines

json:
	cp /Users/www/smbc/restaurants.json SharedModules/Sources/Schedule
	cp /Users/www/smbc/schedule/schedule-${YEAR}.json SharedModules/Sources/Schedule/schedule.json
	cp /Users/www/smbc/schedule/trips.json SharedModules/Sources/Schedule
	cp /Users/www/smbc/gallery.json AppModules/Sources/Gallery
	sed -i '' -E -e "s/[0-9]{4}$$/${YEAR}/" SharedModules/Sources/Schedule/ScheduleState.swift

# remove files created during the build process
# do **not** use the -d option to git clean without excluding .jj
clean:
	test -d $(PROJECTF).xcodeproj && xcodebuild clean || true
	jj status
	git clean -dfx -e .jj -e notes
