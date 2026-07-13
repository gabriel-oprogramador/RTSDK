
# Project File
include Build/Project.mk
include $(RTSDK_ROOT)/Build/Common.mk

CC := $(ZIG_DIR)/zig cc
CX := $(ZIG_DIR)/zig c++
LD := $(ZIG_DIR)/zig c++

DEFINES  += -DPLATFORM_WINDOWS -DUSE_LIBTYPE_SHARED
FLAGS_CC += -std=c11
FLAGS_CX += -std=c++17
FLAGS    += -target x86_64-windows-gnu
INCLUDES += -isystem$(RTSDK_ROOT)/Include
FLAGS_LD += $(LIBS) -L$(RTSDK_ROOT)/Lib/$(TARGET) -lRTSDK

ifeq ($(BUILD_TYPE), Development)
DEFINES += -DDEV_MODE
FLAGS += -O0 -g
OUTPUT_NAME := $(PROJECT_NAME).exe
else ifeq ($(BUILD_TYPE), Shipping)
DEFINES += -DSHIP_MODE
FLAGS += -O3 -g0
OUTPUT_NAME := $(GAME_NAME).exe
PACKAGE := cp -rf ./Assets $(BIN_OUTPUT)
endif

prebuild:
	echo "Start Build Project:$(PROJECT_NAME), Target:$(TARGET), Type:$(BUILD_TYPE)"
	mkdir -p $(BIN_OUTPUT)
	mkdir -p $(DIRS)

build: $(OBJ)
	echo "Linking -> $(BIN_OUTPUT)/$(OUTPUT_NAME)"
	llvm-rc $(PROJECT_RESOURCES)/WinRes.rc -o$(PROJECT_RESOURCES)/WinRes.res
	$(LD) $(OBJ) $(FLAGS) $(FLAGS_LD) $(PROJECT_RESOURCES)/WinRes.res -o$(BIN_OUTPUT)/$(OUTPUT_NAME)

postbuild:
	cp $(RTSDK_ROOT)/Lib/$(TARGET)/RTSDK.dll $(BIN_OUTPUT)
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