CC 		 := x86_64-elf-gcc
LD 		 := x86_64-elf-ld
WARNINGS := -Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
            -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations \
            -Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
            -Wconversion -Wstrict-prototypes
CFLAGS 	 := -std=gnu23 -nostdlib -nostartfiles -ffreestanding $(WARNINGS)
PROJDIRS := src
SRCFILES := $(shell find $(PROJDIRS) -type f -name "*.c")
HDRFILES := $(shell find $(PROJDIRS) -type f -name "*.h")
CFLAGS   += -MMD -MP

-include $(OBJFILES:.o=.d)

OBJFILES := $(patsubst %.c,%.o,$(SRCFILES))
DEPFILES := $(patsubst %.c,%.d,$(SRCFILES))
TARGET   := kernel.elf

all: $(OBJFILES)
	$(CC) $(CFLAGS) $(OBJFILES) -o $(TARGET)

# rule telling make how to make the object files
# $< -> c files; $@ -> target (.o)
%.o: %.c 
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	-@$(RM) $(wildcard $(OBJFILES) $(DEPFILES) $(TARGET))
	
# debugging
print:
	@echo SRCFILES=$(SRCFILES)
	@echo OBJFILES=$(OBJFILES)

.PHONY: all clean print
