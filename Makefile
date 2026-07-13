.SILENT:
include Build/Common.mk

define SRC
Source/Raylib/rcore.c
Source/Raylib/rtext.c
Source/Raylib/raudio.c
Source/Raylib/rshapes.c
Source/Raylib/rmodels.c
Source/Raylib/rtextures.c
endef



OBJ       = $(patsubst Source/Raylib/%.c,$(OBJ_OUTPUT)/%.o,$(SRC))
DIRS      = $(dir $(OBJ))
INCLUDES += -ISource/Raylib/external/glfw/include
FLAGS    += -Wno-tautological-compare

ifeq ($(TARGET), Windows)
CX           := $(ZIG_DIR)/zig c++
CC           := $(ZIG_DIR)/zig cc
LD           := $(ZIG_DIR)/zig cc
OUTPUT_NAME  := RTSDK.dll
SRC          += Source/Raylib/rglfw.c
FLAGS        += -target x86_64-windows-gnu -std=gnu11 -fPIC
DEFINES      += -DPLATFORM_WINDOWS -DPLATFORM_DESKTOP -DGRAPHICS_API_OPENGL_33 -DBUILD_LIBTYPE_SHARED
LIBS         += -lwinmm -lkernel32 -luser32 -lgdi32 -lopengl32 -lshell32
LINKER_RTSDK  = $(LD) -shared $(OBJ) $(FLAGS) $(LIBS) -o $(BIN_OUTPUT)/$(OUTPUT_NAME) -Wl,--out-implib,$(BIN_OUTPUT)/$(OUTPUT_NAME:.dll=.lib)
LINKER_GAME   = $(CX) Source/Launcher/Main.cpp -DPLATFORM_WINDOWS -isystemSource/Raylib -L$(BIN_OUTPUT) -lRTSDK -o$(BIN_OUTPUT)/Game.exe
RUN_GAME      = ./$(BIN_OUTPUT)/Game

else ifeq ($(TARGET), Linux)
CX           := $(ZIG_DIR)/zig c++
CC           := $(ZIG_DIR)/zig cc
LD           := $(ZIG_DIR)/zig cc
OUTPUT_NAME  := libRTSDK.so
SRC          += Source/Raylib/rglfw.c
FLAGS        += -target x86_64-linux-gnu.$(LINUX_GLIBC_VERSION) -std=gnu11 -fPIC
DEFINES      += -DPLATFORM_LINUX -DPLATFORM_DESKTOP -D_GLFW_X11 -DGRAPHICS_API_OPENGL_33 -DBUILD_LIBTYPE_SHARED
INCLUDES     += -isystem/usr/include
LIBS         += -lpthread -lGL -lm -ldl -lrt -lX11 -L/usr/lib/x86_64-linux-gnu
LINKER_RTSDK  = $(LD) -shared $(OBJ) $(FLAGS) $(LIBS) -o $(BIN_OUTPUT)/$(OUTPUT_NAME) -Wl,-soname,$(OUTPUT_NAME)
LINKER_GAME   = $(CX) Source/Launcher/Main.cpp -DPLATFORM_LINUX -isystemSource/Raylib -L$(BIN_OUTPUT) -lRTSDK -o$(BIN_OUTPUT)/Game -Wl,-rpath,'$$ORIGIN'
RUN_GAME      = ./$(BIN_OUTPUT)/Game

else ifeq ($(TARGET), Web)
CC := $(EMSCRIPTEN_DIR)/emcc
CX := $(EMSCRIPTEN_DIR)/em++
LD := $(EMSCRIPTEN_DIR)/emar
OUTPUT_NAME  := libRTSDK.a
FLAGS        += -std=gnu11
DEFINES      += -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES3
LINKER_RTSDK  = $(LD) rcs $(BIN_OUTPUT)/$(OUTPUT_NAME) $(OBJ)
LINKER_GAME   = $(CX) Source/Launcher/Main.cpp -DPLATFORM_WEB -isystemSource/Raylib -L$(BIN_OUTPUT) -lRTSDK -o$(BIN_OUTPUT)/index.html -sUSE_WEBGL2=1 -sFULL_ES3 -sUSE_GLFW=3 -sWASM=1 -sASYNCIFY 
RUN_GAME      = $(EMSCRIPTEN_DIR)/emrun ./$(BIN_OUTPUT)/index.html
endif

# Build Type
BUILD_TYPE ?= Development
ifeq ($(BUILD_TYPE), Development)
FLAGS   += -O0 -g
DEFINES += -DDEBUG
else ifeq ($(BUILD_TYPE), Shipping)
FLAGS   += -O3 -g0
DEFINES += -DNDEBUG
BIN_OUTPUT = $(RTSDK_OUTPUT)/Lib/$(TARGET)
LINKER_GAME =

else 
$(error Build Type:$(BUILD_TYPE) not valid)
endif

all: dev

dev:
	$(MAKE) start TARGET=$(TARGET) BUILD_TYPE=Development

ship:
	$(MAKE) start TARGET=$(TARGET) BUILD_TYPE=Shipping

start:
	echo "Start Build Project RTSDK-$(RTSDK_VER), Target:$(TARGET), Type:$(BUILD_TYPE)"
	$(MAKE) prebuild  TARGET=$(TARGET) BUILD_TYPE=$(BUILD_TYPE)
	$(MAKE) -j build  TARGET=$(TARGET) BUILD_TYPE=$(BUILD_TYPE)
	$(MAKE) postbuild TARGET=$(TARGET) BUILD_TYPE=$(BUILD_TYPE)

prebuild:
	mkdir -p $(BIN_OUTPUT)
	mkdir -p $(DIRS)

build: $(OBJ)
	echo "Linking -> $(BIN_OUTPUT)/$(OUTPUT_NAME)"
	$(LINKER_RTSDK)
	$(LINKER_GAME)

postbuild:
	echo "Generate Compile Commands"
	$(GENERATE_COMPILE_COMMANDS)

run: dev
	echo "Running -> $(BIN_OUTPUT)/Game"
	$(RUN_GAME)

clean:
	echo "Cleaning Everything"
	rm -f compile_commands.json
	rm -rf .cache
	rm -rf Binaries
	rm -rf Intermediate

make_sdk:
	mkdir -p $(RTSDK_OUTPUT)/Include
	cp -f $(wildcard Source/Raylib/*.h) $(RTSDK_OUTPUT)/Include
	cp -rf ./Build $(RTSDK_OUTPUT)/Build
	cp -rf ./Scripts $(RTSDK_OUTPUT)/Scripts
	cp -rf ./Template $(RTSDK_OUTPUT)/Template

$(OBJ_OUTPUT)/%.o: Source/Raylib/%.c
	echo "Compiling >> $<"
	$(CC) -MJ$@.json  $< $(FLAGS) $(DEFINES) $(INCLUDES) -c -o $@ -MMD