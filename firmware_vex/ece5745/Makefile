
TOOLCHAIN_PATH=
#TOOLCHAIN_PATH=/opt/riscv32imc/bin/
# TOOLCHAIN_PATH=/ef/apps/bin/

# Set the prefix for `riscvXX-unknown-elf-*`
# On installations using `multilib`, this will be `riscv64` even for compiling to 32-bit targets
TOOLCHAIN_PREFIX=riscv64
#TOOLCHAIN_PREFIX=riscv32

# ---- Test patterns for project raven ----

.SUFFIXES:

PATTERN = ece5745

hex:  ${PATTERN:=.hex}

%.elf: %.c ../sections.lds ../crt0_vex.S
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-unknown-elf-gcc -I../ -I../generated/ -O0 -mabi=ilp32 -march=rv32i_zicsr -D__vexriscv__ -Wl,-Bstatic,-T,../sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ ../crt0_vex.S ../isr.c $<
	${TOOLCHAIN_PATH}$(TOOLCHAIN_PREFIX)-unknown-elf-objdump -D ece5745.elf > ece5745.lst

%.hex: %.elf
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-unknown-elf-objcopy -O verilog $< $@
	sed -i '.orig' -e 's/@1000/@0000/g' $@

%.bin: %.elf
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-unknown-elf-objcopy -O binary $< $@

client: client.c
	gcc client.c -o client

flash: ece5745.hex
	python3 ../util/caravel_hkflash.py ece5745.hex

flash2: ece5745.hex
	python3 ../util/caravel_flash.py ece5745.hex

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.lst *.hex.orig

.PHONY: clean hex all flash

