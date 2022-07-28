
# https://gcc.gnu.org/wiki/cxx-modules

# In this Makefile, *.ccm files indicate precompiled module sources

TARGET=main
CXX=g++-11
LD=g++-11
SOURCE_DIR=.
BUILD_DIR=build
CXXFLAGS=-std=c++20 \
-fmodules-ts

MODULES=$(wildcard $(SOURCE_DIR)/*.ccm)
PRECOMPILED=$(patsubst $(SOURCE_DIR)/%.ccm, $(BUILD_DIR)/%.pcm, $(MODULES))

SOURCES=$(wildcard $(SOURCE_DIR)/*.cc)
OBJECTS=$(patsubst $(SOURCE_DIR)/%.cc, $(BUILD_DIR)/%.o, $(SOURCES))

# see https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Compiled-Module-Interface.html
SYSTEM_HEADERS=iostream
SYSTEM_HEADERS_OBJECTS_DIR=gcm.cache/usr/include/c++/11
SYSTEM_HEADERS_OBJECTS=$(patsubst %, $(SYSTEM_HEADERS_OBJECTS_DIR)/%.gcm, $(SYSTEM_HEADERS))

all: $(SYSTEM_HEADERS_OBJECTS) $(BUILD_DIR) $(TARGET)

# linkage
$(TARGET): $(PRECOMPILED) $(OBJECTS)
	$(LD) -o $(TARGET) $(PRECOMPILED) $(OBJECTS)

# precompiled modules
$(BUILD_DIR)/%.pcm: $(SOURCE_DIR)/%.ccm
	$(CXX) $(CXXFLAGS) -x c++ -c -MMD $< -o $@

# objects
$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.cc
	$(CXX) $(CXXFLAGS) -x c++ -c -MMD $< -o $@

$(SYSTEM_HEADERS_OBJECTS):
	$(CXX) $(CXXFLAGS) -x c++-system-header $(SYSTEM_HEADERS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean: $(BUILD_DIR)
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/*.pcm $(BUILD_DIR)/*.d
	rm -f $(TARGET)
	rm -rf gcm.cache
