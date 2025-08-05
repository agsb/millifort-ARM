#
#
# experimental Makefile, feel free for comments
#
# use:
# to make: 	make 
# to clean: 	make clean

.PHONY: clean all

########################################

# default
BASE = /usr/bin
NAME = arm-none-eabi-

PASS = ${BASE}/${NAME}

GCC = ${PASS}gcc

GCCFLAGS = -nostartfiles -nodefaultlibs \
	   -mcpu=cortex-a53 -mlittle-endian \
	   -static -Os \

# -mcpu=arm8 
# -march=rv32ic -mabi=ilp32 \
# -fpic -fpie
# -fomit-frame-pointer \


# -march=rv64ic -mabi=lp64 -static -Oz \
# -march=rv32ic -mabi=ilp32 -static -Oz \

LDFLAGS = -Wl,--stats

#-Wl,-no-relax
#-Wl,-build-id 

ASFLAGS = -Wa,-mlittle-endian -Wa,-alms=$@.lst 

STRIP = ${PASS}strip

OBJDUMP = ${PASS}objdump

QEMU = ${BASE}qemu-riscv64

QEMU = ${BASE}qemu-riscv32

QFLAGS = -nographic -smp 1 -machine virt -bios none

MY = minimal
MY = sector-arm

########################################

%: %.S

$(MY): $(SOURCES:.S=.o)

	$(GCC) $(GCCFLAGS) $(LDFLAGS) $(ASFLAGS) -o $@.elf $@.S 2> err | tee out

	$(PASS)objdump -hda $@.elf > $@.dmp

	$(PASS)readelf -a $(MY).elf > $(MY).map

	$(PASS)objcopy --dump-section .text=$(MY).bin $(MY).elf

#	od --endian=little -A x -t x1z -v $@.elf > $@.hex

all: 
	
	$(MY)

clean:
	
	$(RM) $(MY).out $(MY).map $(MY).lst \
	      $(MY).elf $(MY).dmp $(MY).bin \
	      $(MY).elfs $(MY).ord \
	      err out

	      # $(MY).lbl $(MY).lbs $(MY).lbf \

qemu: 
	#@qemu-system-riscv32 -M ? | grep virt >/dev/null || exit
	@echo "Press Ctrl-A and then X to exit QEMU"
	$(QEMU) $(QFLAGS) -kernel $@.elf

sort:
	# extract and ordered the instructions used
	cat $(MY).dmp | grep '   1' | \
	sed -e 's/          /:/'  | \
	sort -t: -k3 > $(MY).ord
	grep '    ......' $(MY).ord > $(MY).16b
	grep -v '    ......' $(MY).ord > $(MY).32b
	wc *...c

extras:

	$(PASS)strip -o $@.elfs $@.elf 

