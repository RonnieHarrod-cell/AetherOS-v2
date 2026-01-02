# AetherOS v2 - Cross-Compilation Makefile
# Target: x86_64
# Host: aarch64
# Toolchain: GNU

# ============================================================================
# Configuration Variables
# ============================================================================

# Target architecture
TARGET_ARCH := x86_64
HOST_ARCH := aarch64
TARGET_TRIPLE := x86_64-unknown-linux-gnu

# Cross-compiler paths
CROSS_COMPILE := x86_64-linux-gnu-
CC := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
AS := $(CROSS_COMPILE)as
AR := $(CROSS_COMPILE)ar
LD := $(CROSS_COMPILE)ld
OBJCOPY := $(CROSS_COMPILE)objcopy
OBJDUMP := $(CROSS_COMPILE)objdump

# Build directories
BUILD_DIR := build
DIST_DIR := dist
ISO_DIR := $(BUILD_DIR)/iso
BOOT_DIR := $(ISO_DIR)/boot
GRUB_DIR := $(BOOT_DIR)/grub

# Output files
KERNEL_NAME := kernel.elf
KERNEL_BIN := $(BUILD_DIR)/$(KERNEL_NAME)
ISO_OUTPUT := $(DIST_DIR)/AetherOS-v2.iso

# Compiler flags
CFLAGS := -m64 -march=x86-64 -mtune=generic -O2 -Wall -Wextra -fno-builtin \
          -fno-stack-protector -nostdinc -nostdlib -Iinclude
ASFLAGS := -m64 -march=x86-64
LDFLAGS := -m elf_x86_64 -nostdlib -T scripts/linker.ld

# Source files
KERNEL_SOURCES := $(wildcard kernel/*.c)
BOOT_SOURCES := $(wildcard boot/*.asm)
LIB_SOURCES := $(wildcard lib/*.c)

KERNEL_OBJECTS := $(patsubst kernel/%.c,$(BUILD_DIR)/%.o,$(KERNEL_SOURCES))
BOOT_OBJECTS := $(patsubst boot/%.asm,$(BUILD_DIR)/%.o,$(BOOT_SOURCES))
LIB_OBJECTS := $(patsubst lib/%.c,$(BUILD_DIR)/%.o,$(LIB_SOURCES))

ALL_OBJECTS := $(BOOT_OBJECTS) $(KERNEL_OBJECTS) $(LIB_OBJECTS)

# ============================================================================
# Phony Targets
# ============================================================================

.PHONY: all build kernel iso clean distclean help check-toolchain

# ============================================================================
# Default Target
# ============================================================================

all: check-toolchain $(ISO_OUTPUT)

# ============================================================================
# Build Rules
# ============================================================================

# Check if cross-compilation toolchain is available
check-toolchain:
	@echo "Checking cross-compilation toolchain for $(TARGET_TRIPLE)..."
	@command -v $(CC) >/dev/null 2>&1 || (echo "Error: $(CC) not found. Please install the cross-compilation toolchain." && exit 1)
	@command -v $(CXX) >/dev/null 2>&1 || (echo "Error: $(CXX) not found." && exit 1)
	@command -v $(AS) >/dev/null 2>&1 || (echo "Error: $(AS) not found." && exit 1)
	@echo "✓ Cross-compilation toolchain verified"

# Create build directories
$(BUILD_DIR) $(DIST_DIR) $(BOOT_DIR) $(GRUB_DIR):
	@mkdir -p $@

# Compile C source files to object files
$(BUILD_DIR)/%.o: kernel/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@
	@echo "✓ Compiled $<"

$(BUILD_DIR)/%.o: lib/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@
	@echo "✓ Compiled $<"

# Assemble ASM source files to object files
$(BUILD_DIR)/%.o: boot/%.asm | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@
	@echo "✓ Assembled $<"

# Link kernel
$(KERNEL_BIN): $(ALL_OBJECTS) scripts/linker.ld | $(BUILD_DIR)
	$(LD) $(LDFLAGS) -o $@ $(ALL_OBJECTS)
	@echo "✓ Linked kernel: $@"
	@$(OBJDUMP) -d $(KERNEL_BIN) > $(BUILD_DIR)/kernel.dump
	@echo "✓ Generated disassembly: $(BUILD_DIR)/kernel.dump"

# Build kernel target
kernel: check-toolchain $(KERNEL_BIN)
	@echo "✓ Kernel build complete"

# Create GRUB configuration
$(GRUB_DIR)/grub.cfg: | $(GRUB_DIR)
	@echo "Creating GRUB configuration..."
	@echo "menuentry 'AetherOS v2' {" > $@
	@echo "    multiboot /boot/$(KERNEL_NAME)" >> $@
	@echo "    boot" >> $@
	@echo "}" >> $@
	@echo "set default=0" >> $@
	@echo "set timeout=5" >> $@
	@echo "✓ Created GRUB config: $@"

# Create ISO image
$(ISO_OUTPUT): kernel $(GRUB_DIR)/grub.cfg | $(DIST_DIR)
	@echo "Creating ISO image..."
	@cp $(KERNEL_BIN) $(BOOT_DIR)/$(KERNEL_NAME)
	@echo "✓ Copied kernel to ISO boot directory"
	@grub-mkrescue -o $(ISO_OUTPUT) $(ISO_DIR) 2>/dev/null || \
	  (echo "Warning: grub-mkrescue not found. Creating minimal ISO..." && \
	   mkisofs -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 \
	   -boot-info-table -o $(ISO_OUTPUT) $(ISO_DIR) 2>/dev/null) || \
	  (echo "Warning: ISO creation tools not found. Using xorriso as fallback..." && \
	   xorriso -as mkisofs -o $(ISO_OUTPUT) $(ISO_DIR))
	@echo "✓ ISO image created: $(ISO_OUTPUT)"
	@ls -lh $(ISO_OUTPUT)

# ISO target
iso: $(ISO_OUTPUT)
	@echo "✓ ISO build complete"

# ============================================================================
# Utility Targets
# ============================================================================

# Print build information
info:
	@echo "AetherOS v2 Cross-Compilation Configuration"
	@echo "============================================"
	@echo "Host Architecture:     $(HOST_ARCH)"
	@echo "Target Architecture:   $(TARGET_ARCH)"
	@echo "Target Triple:         $(TARGET_TRIPLE)"
	@echo "Cross Compiler:        $(CC)"
	@echo "Kernel Output:         $(KERNEL_BIN)"
	@echo "ISO Output:            $(ISO_OUTPUT)"
	@echo "Build Directory:       $(BUILD_DIR)"
	@echo "Dist Directory:        $(DIST_DIR)"

# Display help
help:
	@echo "AetherOS v2 - Cross-Compilation Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all           - Build everything and create ISO (default)"
	@echo "  check-toolchain - Verify cross-compilation toolchain"
	@echo "  kernel        - Build kernel only"
	@echo "  iso           - Create bootable ISO image"
	@echo "  info          - Display build configuration"
	@echo "  clean         - Remove build artifacts"
	@echo "  distclean     - Remove all generated files"
	@echo "  help          - Display this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make              # Full build with ISO creation"
	@echo "  make kernel       # Build kernel only"
	@echo "  make clean        # Clean build artifacts"
	@echo "  make info         # Show configuration"

# ============================================================================
# Cleaning Targets
# ============================================================================

# Clean build artifacts (keep ISO)
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/*.o $(BUILD_DIR)/*.dump
	@echo "✓ Build artifacts cleaned"

# Clean everything
distclean:
	@echo "Performing full cleanup..."
	@rm -rf $(BUILD_DIR) $(DIST_DIR)
	@echo "✓ All build and dist directories removed"

# ============================================================================
# Debugging Targets
# ============================================================================

# Display object files
show-objects:
	@echo "Boot Objects:"
	@echo "$(BOOT_OBJECTS)"
	@echo ""
	@echo "Kernel Objects:"
	@echo "$(KERNEL_OBJECTS)"
	@echo ""
	@echo "Library Objects:"
	@echo "$(LIB_OBJECTS)"

# Display source files
show-sources:
	@echo "Boot Sources:"
	@echo "$(BOOT_SOURCES)"
	@echo ""
	@echo "Kernel Sources:"
	@echo "$(KERNEL_SOURCES)"
	@echo ""
	@echo "Library Sources:"
	@echo "$(LIB_SOURCES)"

# ============================================================================
# End of Makefile
# ============================================================================
