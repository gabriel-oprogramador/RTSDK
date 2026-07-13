
# Project File
include Build/Project.mk
include $(RTSDK_ROOT)/Build/Common.mk

CC := $(EMSCRIPTEN_DIR)/emcc
CX := $(EMSCRIPTEN_DIR)/em++
LD := $(EMSCRIPTEN_DIR)/em++
RN := $(EMSCRIPTEN_DIR)/emrun

DEFINES  += -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES3
FLAGS_CC += -std=gnu11
FLAGS_CX += -std=gnu++17
FLAGS    +=
INCLUDES += -isystem$(RTSDK_ROOT)/Include
FLAGS_LD += $(LIBS) -L$(RTSDK_ROOT)/Lib/$(TARGET) -lRTSDK
FLAGS_LD    += -sUSE_WEBGL2=1 -sFULL_ES3 -sUSE_GLFW=3 -sWASM=1 -sASYNCIFY 
FLAGS_LD    += -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,requestFullscreen
FLAGS_LD    += --preload-file Assets@/Assets/ -sALLOW_MEMORY_GROWTH=1 -sINITIAL_MEMORY256mb
OUTPUT_NAME := index.html

ifeq ($(BUILD_TYPE), Development)
DEFINES += -DDEV_MODE
FLAGS += -O0 -g
else ifeq ($(BUILD_TYPE), Shipping)
DEFINES += -DSHIP_MODE
FLAGS += -O3 -g0
endif

prebuild:
	echo "Start Build Project:$(PROJECT_NAME), Target:$(TARGET), Type:$(BUILD_TYPE)"
	mkdir -p $(BIN_OUTPUT)
	mkdir -p $(DIRS)

build: $(OBJ)
	echo "Linking -> $(BIN_OUTPUT)/$(OUTPUT_NAME)"
	$(LD) $(OBJ) $(FLAGS) $(FLAGS_LD) -o$(BIN_OUTPUT)/$(OUTPUT_NAME) -Wl,-rpath,'$$ORIGIN'

postbuild:
	cp $(PROJECT_RESOURCES)/WebEntrypoint.html $(BIN_OUTPUT)/index.html
	cp $(PROJECT_RESOURCES)/AppIcon.ico $(BIN_OUTPUT)
	$(PACKAGE) 

run:
	echo "Running -> $(BIN_OUTPUT)/$(OUTPUT_NAME)"
	$(RN) ./$(BIN_OUTPUT)/index.html

$(OBJ_OUTPUT)/%.o: Source/%.c
	echo "Compiling > $<..."
	$(CC) -MJ$@.json $< $(FLAGS_CC) $(FLAGS) $(DEFINES) $(INCLUDES) -c -o$@ -MMD

$(OBJ_OUTPUT)/%.o: Source/%.cpp
	echo "Compiling > $<..."
	$(CX) -MJ$@.json $< $(FLAGS_CX) $(FLAGS) $(DEFINES) $(INCLUDES) -c -o$@ -MMD

-include $(DEPS)