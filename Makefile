.PHONY: all clean run gdb

# compiler choice
CC_CLANG = clang
CXX_CLANG = clang++-10
CC_GCC = x86_64-w64-mingw32-gcc
CXX_GCC = x86_64-w64-mingw32-g++ 

INCLUDE = -I./include
FLAGS_NOEXCEPTION = -fno-exceptions -fno-unwind-tables
CFLAGS_WARN = -Wall -Wextra
CFLAGS_GCC = -m64 $(CFLAGS_WARN) $(INCLUDE) -g3 -fno-pic  -ffreestanding -nostdinc -nostdlib -fno-stack-protector -fshort-wchar -mno-red-zone -fno-builtin -MMD -MP $(FLAGS_NOEXCEPTION)
CFLAGS_LLVM = --target=x86_64-elf -g $(INCLUDE) $(FLAGS_NOEXCEPTION) -fno-stack-protector -mno-red-zone -nostdlibinc -Wall -Wpedantic

CC = $(CC_GCC)
CXX = $(CXX_GCC)
CFLAGS = $(CFLAGS_GCC)

# linker choice
LD_GCC = x86_64-w64-mingw32-ld
LD_LLVM = ld.lld-10

EFI_ENTRY = -e efi_main
LDFLAGS_GCC = --subsystem 10 -e efi_main
LDFLAGS_LLVM = --entry KernelMain

LD = $(LD_GCC)
LDFLAGS = $(LDFLAGS_GCC)

# directory and file
FSPATH = ./bin/fs
EFIPATH = $(FSPATH)/EFI/BOOT
TARGET = $(EFIPATH)/BOOTX64.EFI
SRCDIR = ./src
OBJDIR = ./obj

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(SRC:.cpp=.o)))
DEPENDS = $(OBJECTS:.o=.d)

# tools
QEMU = qemu-system-x86_64
QEMU_FLAGS =  -m 4G -gdb tcp::10000 -S -cpu qemu64
DBG = gdb-multiarch
DBG_FLAGS = -x start.gdb

all: clean $(TARGET)

$(TARGET): $(OBJECTS) $(LIBS)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CFLAGS) -c $<  -o $@

$(OBJDIR)/%.s: $(SRCDIR)/%.cpp
	$(CXX) -S -o $@ $<

run: $(TARGET)
	$(QEMU) $(QEMU_FLAGS) \
	-drive if=pflash,format=raw,readonly,file=$(HOME)/OVMF/OVMF_CODE.fd \
	-drive if=pflash,format=raw,file=$(HOME)/OVMF/OVMF_VARS.fd \
	-drive dir=$(FSPATH),driver=vvfat,rw=on \
	$(QEMU_ADDITIONAL_ARGS)

#--device qemu-xhci device usb-mouse -device usb-kbd 

gdb: $(TARGET) $(SRC)
	$(DBG) $(DBG_FLAGS) $(TARGET)

clean:
	rm -f  $(OBJECTS) $(DEPENDS) $(TARGET)

-include $(DEPENDS)
