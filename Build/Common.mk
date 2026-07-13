.SILENT:
.PHONY: all dev start prebuild build postbuild clean
MAKEFLAGS += --no-print-directory
LINUX_GLIBC_VERSION := 2.29

# Setup Host
UNAME := $(shell uname -s | tr A-Z a-z)
ifeq ($(OS), Windows_NT)
TARGET ?= Windows
USER_DATA_DIR := $(subst \,/,$(LOCALAPPDATA))
else ifeq ($(UNAME), linux)
TARGET ?= Linux
USER_DATA_DIR := $(if $(XDG_DATA_HOME),$(XDG_DATA_HOME),$(HOME)/.local/share)
else 
$(error Host not supported)
endif

# Raylib Template Software Development Kit
RTSDK_VER    := 1.0.0
RTSDK_OUTPUT := SDK/RTSDK-$(RTSDK_VER)

RTSDK_ROOT ?= $(CURDIR)
TOOLCHAIN  := $(RTSDK_ROOT)/Toolchain

ZIG_DIR        := $(TOOLCHAIN)/zig/0.15.2
EMSCRIPTEN_DIR := $(TOOLCHAIN)/emsdk/upstream/emscripten

# Outputs
BIN_OUTPUT = Binaries/$(TARGET)/$(BUILD_TYPE)
OBJ_OUTPUT = Intermediate/Build/$(TARGET)/$(BUILD_TYPE)

# Project Files
SRC_CC = $(shell find Source -type f -name "*.c")
SRC_CX = $(shell find Source -type f -name "*.cpp")
OBJ_CC = $(patsubst Source/%.c,$(OBJ_OUTPUT)/%.o,$(SRC_CC))
OBJ_CX = $(patsubst Source/%.cpp,$(OBJ_OUTPUT)/%.o,$(SRC_CX))
SRC    = $(SRC_CC) $(SRC_CX)
OBJ    = $(OBJ_CC) $(OBJ_CX)
DEPS   = $(OBJ:.o=.d)
DIRS   = $(dir $(OBJ))

JSONS = $(shell find Intermediate/Build/$(TARGET)/$(BUILD_TYPE) -type f -name "*.json")
define GENERATE_COMPILE_COMMANDS
echo "[" > compile_commands.json
for f in $(JSONS); do \
  cat $$f >> compile_commands.json; \
done
sed -i '$$ s/,$$//' compile_commands.json
echo "]" >> compile_commands.json
endef