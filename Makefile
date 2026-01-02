# ARM64 OS Makefile

CROSS_COMPILE := aarch64-linux-gnu-
CC := $(CROSS_COMPILE)gcc
AS := $(CROSS_COMPILE)as
LD := $(CROSS_COMPILE)ld
OBJCOPY := $(CROSS_COMPILE)objcopy

CFLAGS := -Wall -O2 -ffreestanding -fno-stack-protector -fno-common
ASFLAGS := -g
LDFLAGS := -nostdlib

TARGET := arm64-os. elf
IMAGE := arm64-os.img

SOURCES := kernel/kernel.c kernel/python_ide.c kernel/main. c
BOOT := bootloader/boot.s

OBJECTS := $(BOOT:.s=.o) $(SOURCES:.c=.o)

all: $(IMAGE)

$(IMAGE): $(TARGET)
	$(OBJCOPY) -O binary $< $@
	@echo "Built: $@"

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -T kernel. ld -o $@ $^
	@echo "Linked: $@"

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean: 
	rm -f $(OBJECTS) $(TARGET) $(IMAGE)

.PHONY: all clean