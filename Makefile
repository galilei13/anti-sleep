# AntiSleep — build & packaging automation
# Usage: make build | make run | make archive | make dmg | make clean

PROJECT      := AntiSleep.xcodeproj
SCHEME       := AntiSleep
APP_NAME     := AntiSleep
CONFIG       := Release
BUILD_DIR    := build
DERIVED      := $(BUILD_DIR)/DerivedData
EXPORT_DIR   := $(BUILD_DIR)/export
APP_PATH     := $(EXPORT_DIR)/$(APP_NAME).app
DMG_PATH     := $(BUILD_DIR)/$(APP_NAME).dmg

.PHONY: all build run archive export dmg clean

all: build

## Compile the app (Release) into local DerivedData.
build:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-derivedDataPath $(DERIVED) \
		CODE_SIGNING_ALLOWED=NO \
		build

## Build and launch the app from the latest build products.
run: build
	open "$(DERIVED)/Build/Products/$(CONFIG)/$(APP_NAME).app"

## Copy the freshly built .app into the export dir for packaging.
export: build
	mkdir -p "$(EXPORT_DIR)"
	rm -rf "$(APP_PATH)"
	cp -R "$(DERIVED)/Build/Products/$(CONFIG)/$(APP_NAME).app" "$(APP_PATH)"

## Bundle the compiled .app into a distributable .dmg.
dmg: export
	./scripts/make_dmg.sh "$(APP_PATH)" "$(DMG_PATH)" "$(APP_NAME)"

clean:
	rm -rf $(BUILD_DIR)
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean || true
