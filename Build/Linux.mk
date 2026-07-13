
# Project File
include Build/Project.mk
include $(RTSDK_ROOT)/Build/Common.mk

CC := $(ZIG_DIR)/zig cc
CX := $(ZIG_DIR)/zig c++
LD := $(ZIG_DIR)/zig c++

DEFINES  += -DPLATFORM_LINUX -DUSE_LIBTYPE_SHARED
FLAGS_CC += -std=gnu11
FLAGS_CX += -std=gnu++17
FLAGS    += -target x86_64-linux-gnu.$(LINUX_GLIBC_VERSION)
INCLUDES += -isystem$(RTSDK_ROOT)/Include
FLAGS_LD += $(LIBS) -L$(RTSDK_ROOT)/Lib/$(TARGET) -lRTSDK

ifeq ($(BUILD_TYPE), Development)
DEFINES += -DDEV_MODE
FLAGS += -O0 -g
OUTPUT_NAME := $(PROJECT_NAME)
else ifeq ($(BUILD_TYPE), Shipping)
DEFINES += -DSHIP_MODE
FLAGS += -O3 -g0
OUTPUT_NAME := $(GAME_NAME)
PACKAGE := cp -rf ./Assets $(BIN_OUTPUT)
endif

prebuild:
	echo "Start Build Project:$(PROJECT_NAME), Target:$(TARGET), Type:$(BUILD_TYPE)"
	mkdir -p $(BIN_OUTPUT)
	mkdir -p $(DIRS)

build: $(OBJ)
	echo "Linking -> $(BIN_OUTPUT)/$(OUTPUT_NAME)"
	$(LD) $(OBJ) $(FLAGS) $(FLAGS_LD) -o$(BIN_OUTPUT)/$(OUTPUT_NAME) -Wl,-rpath,'$$ORIGIN'

postbuild:
	cp $(RTSDK_ROOT)/Lib/$(TARGET)/libRTSDK.so $(BIN_OUTPUT)
	cp $(PROJECT_RESOURCES)/AppIcon.png $(BIN_OUTPUT)
	$(PACKAGE)

run:
	echo "Running -> $(BIN_OUTPUT)/$(OUTPUT_NAME)"
	./$(BIN_OUTPUT)/$(OUTPUT_NAME)

$(OBJ_OUTPUT)/%.o: Source/%.c
	echo "Compiling > $<..."
	$(CC) -MJ$@.json $< $(FLAGS_CC) $(FLAGS) $(DEFINES) $(INCLUDES) -c -o$@ -MMD

$(OBJ_OUTPUT)/%.o: Source/%.cpp
	echo "Compiling > $<..."
	$(CX) -MJ$@.json $< $(FLAGS_CX) $(FLAGS) $(DEFINES) $(INCLUDES) -c -o$@ -MMD

-include $(DEPS)