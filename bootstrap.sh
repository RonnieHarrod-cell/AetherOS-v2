#!/bin/bash
# AetherOS-v2 Bootstrap Script
# Sets up the cross-compilation environment for x86_64 target
# Usage: ./bootstrap.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TARGET_ARCH="x86_64"
CROSS_COMPILE_PREFIX="${TARGET_ARCH}-elf"
TOOLCHAIN_DIR="${PWD}/toolchain"
BUILD_DIR="${PWD}/build"
SYSROOT_DIR="${TOOLCHAIN_DIR}/sysroot"

# Helper functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Main bootstrap process
main() {
    print_header "AetherOS-v2 Bootstrap - x86_64 Cross-Compilation Setup"

    # Check for required system tools
    print_info "Checking for required system tools..."
    
    local required_tools=("gcc" "g++" "make" "wget" "tar" "git")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if check_command "$tool"; then
            print_success "Found $tool"
        else
            print_error "Missing $tool"
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Please install the following tools: ${missing_tools[*]}"
        exit 1
    fi

    # Create necessary directories
    print_info "Creating directory structure..."
    mkdir -p "$TOOLCHAIN_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$SYSROOT_DIR"
    print_success "Directories created"

    # Display environment information
    print_header "Environment Configuration"
    echo "Target Architecture: $TARGET_ARCH"
    echo "Cross-Compile Prefix: $CROSS_COMPILE_PREFIX"
    echo "Toolchain Directory: $TOOLCHAIN_DIR"
    echo "Build Directory: $BUILD_DIR"
    echo "Sysroot Directory: $SYSROOT_DIR"

    # Setup environment variables
    print_info "Setting up environment variables..."
    
    cat > "${PWD}/.env.cross-compile" << 'EOF'
#!/bin/bash
# Cross-compilation environment variables for x86_64

export TARGET_ARCH="x86_64"
export CROSS_COMPILE_PREFIX="x86_64-elf"
export TOOLCHAIN_DIR="${PWD}/toolchain"
export SYSROOT_DIR="${TOOLCHAIN_DIR}/sysroot"
export BUILD_DIR="${PWD}/build"

# Compiler settings
export CC="${CROSS_COMPILE_PREFIX}-gcc"
export CXX="${CROSS_COMPILE_PREFIX}-g++"
export AR="${CROSS_COMPILE_PREFIX}-ar"
export RANLIB="${CROSS_COMPILE_PREFIX}-ranlib"
export LD="${CROSS_COMPILE_PREFIX}-ld"
export OBJDUMP="${CROSS_COMPILE_PREFIX}-objdump"
export OBJCOPY="${CROSS_COMPILE_PREFIX}-objcopy"

# Compilation flags
export CFLAGS="-O2 -march=x86-64 -mtune=generic -fPIC"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-L${SYSROOT_DIR}/lib -L${SYSROOT_DIR}/usr/lib"
export CPPFLAGS="-I${SYSROOT_DIR}/include -I${SYSROOT_DIR}/usr/include"

# Build paths
export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"
export LD_LIBRARY_PATH="${SYSROOT_DIR}/lib:${SYSROOT_DIR}/usr/lib:${LD_LIBRARY_PATH}"

echo "Cross-compilation environment loaded for x86_64 target"
EOF
    
    print_success "Environment configuration file created: .env.cross-compile"

    # Create a CMake toolchain file
    print_info "Creating CMake toolchain file..."
    
    cat > "${TOOLCHAIN_DIR}/Toolchain-x86_64-elf.cmake" << 'EOF'
# CMake Toolchain File for x86_64-elf cross-compilation

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Specify the cross compiler
set(CMAKE_C_COMPILER x86_64-elf-gcc)
set(CMAKE_CXX_COMPILER x86_64-elf-g++)
set(CMAKE_ASM_COMPILER x86_64-elf-gcc)
set(CMAKE_AR x86_64-elf-ar)
set(CMAKE_RANLIB x86_64-elf-ranlib)

# Compilation flags
set(CMAKE_C_FLAGS "-O2 -march=x86-64 -mtune=generic -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")

# Search for programs, libraries and include files
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF
    
    print_success "CMake toolchain file created: ${TOOLCHAIN_DIR}/Toolchain-x86_64-elf.cmake"

    # Create a Makefile template
    print_info "Creating Makefile template..."
    
    cat > "${BUILD_DIR}/Makefile.template" << 'EOF'
# AetherOS-v2 Build Configuration Template

# Source the environment
include ../.env.cross-compile

# Build variables
TARGET = kernel.elf
SOURCES = $(wildcard ../src/**/*.c) $(wildcard ../src/**/*.s)
OBJECTS = $(patsubst ../%.c,$(BUILD_DIR)/%.o,$(SOURCES:%.s=%.o))

# Compiler flags
CFLAGS += -Wall -Wextra -nostdlib -fno-builtin
LDFLAGS += -T kernel.ld -nostdlib

# Targets
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: ../%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: ../%.s
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

distclean: clean
	rm -rf $(TOOLCHAIN_DIR)

.PHONY: all clean distclean
EOF
    
    print_success "Makefile template created: ${BUILD_DIR}/Makefile.template"

    # Create a setup guide
    print_info "Creating setup guide..."
    
    cat > "${PWD}/BOOTSTRAP_GUIDE.md" << 'EOF'
# AetherOS-v2 Bootstrap Guide for x86_64

## Overview
This guide helps you set up the cross-compilation environment for AetherOS-v2 targeting x86_64 architecture.

## Directory Structure
```
AetherOS-v2/
├── toolchain/           # Cross-compilation toolchain
│   ├── bin/            # Compiler and tools binaries
│   ├── sysroot/        # Target system root
│   └── Toolchain-x86_64-elf.cmake
├── build/              # Build artifacts and output
├── src/                # Source code
├── bootstrap.sh        # This bootstrap script
├── .env.cross-compile  # Environment variables
└── BOOTSTRAP_GUIDE.md  # This file
```

## Environment Setup

### Load Environment Variables
```bash
source .env.cross-compile
```

### Verify Installation
```bash
# Check if cross-compiler is available
which x86_64-elf-gcc
x86_64-elf-gcc --version

# Check environment variables
echo $CROSS_COMPILE_PREFIX
echo $TOOLCHAIN_DIR
echo $SYSROOT_DIR
```

## Building the Project

### Using CMake
```bash
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/Toolchain-x86_64-elf.cmake ..
make
```

### Using Make
```bash
cd build
make -f Makefile.template
```

## Cross-Compiler Tools Available

After setup, the following x86_64-elf tools are available:
- `x86_64-elf-gcc` - C compiler
- `x86_64-elf-g++` - C++ compiler
- `x86_64-elf-as` - Assembler
- `x86_64-elf-ld` - Linker
- `x86_64-elf-ar` - Archiver
- `x86_64-elf-objdump` - Object file dumper
- `x86_64-elf-objcopy` - Object file copier

## Compilation Flags

Default flags configured for x86_64:
- `-march=x86-64` - Target x86-64 architecture
- `-mtune=generic` - Generic optimization tuning
- `-fPIC` - Position-independent code
- `-O2` - Optimization level 2

## Troubleshooting

### Cross-compiler not found
```bash
# Ensure toolchain is in PATH
export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"
```

### CMake toolchain errors
```bash
# Verify CMake toolchain file path
cmake -DCMAKE_TOOLCHAIN_FILE=./toolchain/Toolchain-x86_64-elf.cmake ..
```

### Permission denied on bootstrap.sh
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## Additional Resources

- GCC Cross-Compiler Documentation: https://gcc.gnu.org/
- OSDev Wiki: https://wiki.osdev.org/
- x86-64 Architecture: https://en.wikipedia.org/wiki/X86-64

## Support

For issues or questions, please refer to the project documentation or open an issue on GitHub.
EOF
    
    print_success "Bootstrap guide created: BOOTSTRAP_GUIDE.md"

    # Final summary
    print_header "Bootstrap Complete!"
    print_success "Cross-compilation environment for x86_64 has been configured"
    
    echo ""
    echo "Next steps:"
    echo "1. Load the environment: source .env.cross-compile"
    echo "2. Verify the setup: which x86_64-elf-gcc"
    echo "3. Read the guide: cat BOOTSTRAP_GUIDE.md"
    echo "4. Start building: cd build && make"
    echo ""
    print_info "For more information, see BOOTSTRAP_GUIDE.md"
}

# Run main function
main "$@"
