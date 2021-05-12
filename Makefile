all: jag3.out

jag3.out: jag3.s
	arm-linux-gnueabi-gcc -ggdb3 jag3.s -o jag3.out -static -mfpu=vfp -lm

.PHONY: start_app_server
start_app_server:
	qemu-arm -L usr/arm-linux-gnueabi -g 25566 jag3.out "78 + 55"

.PHONY: start_debugger
start_debugger:
	gdb-multiarch -q --nh -ex 'set architecture arm' -ex 'set sysroot /usr/arm/arm-linux-gnueabi' -ex 'file jag3.out' -ex 'target remote localhost:25566' -ex 'break main'
