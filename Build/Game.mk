#
include $(RTSDK_ROOT)/Build/Common.mk

GAME_MK     := $(RTSDK_ROOT)/Build/Game.mk
PLATFORM_MK := $(RTSDK_ROOT)/Build/$(TARGET).mk

all: dev

gen_cc_json:
	echo "Generate Compile Commands"
	$(GENERATE_COMPILE_COMMANDS)

ship:
	$(MAKE) -f $(GAME_MK) start TARGET=$(TARGET) BUILD_TYPE=Shipping

dev: 
	$(MAKE) -f $(GAME_MK) start TARGET=$(TARGET) BUILD_TYPE=Development

start:
	$(MAKE) -f $(PLATFORM_MK) prebuild  TARGET=$(TARGET) BUILD_TYPE=$(BUILD_TYPE)
	$(MAKE) -f $(PLATFORM_MK) -j build  TARGET=$(TARGET) BUILD_TYPE=$(BUILD_TYPE)
	$(MAKE) -f $(PLATFORM_MK) postbuild TARGET=$(TARGET) BUILD_TYPE=$(BUILD_TYPE)
	$(MAKE) -f $(GAME_MK) gen_cc_json   TARGET=$(TARGET) BUILD_TYPE=$(BUILD_TYPE)

run: dev
	$(MAKE) -f $(PLATFORM_MK) run TARGET=$(TARGET) BUILD_TYPE=Development

clean:
	echo "Cleaning Everything"
	rm -f compile_commands.json
	rm -rf .cache
	rm -rf Binaries
	rm -rf Intermediate