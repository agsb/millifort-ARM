# notes

https://sourceware.org/binutils/docs/as/ARM-Directives.html


The following options are target specific:
  -mabi=                      Specify an ABI.
  -mabort-on-noreturn         Generate a call to abort if a noreturn function returns.
  -mapcs                      This option lacks documentation.
  -mapcs-frame                Generate APCS conformant stack frames.
  -mapcs-reentrant            Generate re-entrant, PIC code.
  -mapcs-stack-check          This option lacks documentation.
  -march=                     Specify the name of the target architecture.
  -marm                       Generate code in 32 bit ARM state.
  -masm-syntax-unified        Assume unified syntax for inline assembly code.
  -mbe32                      When linking for big-endian targets, generate a legacy BE32 format image.
  -mbe8                       When linking for big-endian targets, generate a BE8 format image.
  -mbig-endian                Assume target CPU is configured as big endian.
  -mbranch-cost=              Cost to assume for a branch insn.
  -mbranch-protection=        Use branch-protection features.
  -mcallee-super-interworking Thumb: Assume non-static functions may be called from ARM code.
  -mcaller-super-interworking Thumb: Assume function pointers may go to non-Thumb aware code.
  -mcmse                      Specify that the compiler should target secure code as per ARMv8-M
                              Security Extensions.
  -mcpu=                      Specify the name of the target CPU.
  -mfdpic                     Enable Function Descriptor PIC mode.
  -mfix-cmse-cve-2021-35465   Mitigate issues with VLLDM on some M-profile devices (CVE-2021-35465).
  -mfix-cortex-a57-aes-1742098 Mitigate issues with AES instructions on Cortex-A57 and Cortex-A72 (Arm
                              erratum #1742098).
  -mfix-cortex-a72-aes-1655431 Mitigate issues with AES instructions on Cortex-A57 and Cortex-A72 (Arm
                              erratum #1655431).  Same as -mfix-cortex-a57-aes-1742098.
  -mfix-cortex-m3-ldrd        Avoid overlapping destination and address registers on LDRD instructions
                              that may trigger Cortex-M3 errata.
  -mflip-thumb                Switch ARM/Thumb modes on alternating functions for compiler testing.
  -mfloat-abi=                Specify if floating point hardware should be used.
  -mfp16-format=              Specify the __fp16 floating-point format.
  -mfpu=                      Specify the name of the target floating point hardware/format.
  -mgeneral-regs-only         Generate code which uses the core registers only (r0-r14).
  -mhard-float                Same as -mfloat-abi=hard.
  -mlibarch=                  This option lacks documentation.
  -mlittle-endian             Assume target CPU is configured as little endian.
  -mlong-calls                Generate call insns as indirect calls, if necessary.
  -mneon-for-64bits           This option is deprecated and has no effect.
  -mpic-data-is-text-relative Assume data segments are relative to text segment.
  -mpic-register=             Specify the register to be used for PIC addressing.
  -mpoke-function-name        Store function names in object code.
  -mprint-tune-info           Print CPU tuning information as comment in assembler file.  This is an
                              option used only for regression testing of the compiler and not intended
                              for ordinary use in compiling code.
  -mpure-code                 Do not allow constant data to be placed in code sections.
  -mrestrict-it               Generate IT blocks appropriate for ARMv8.
  -msched-prolog              Permit scheduling of a function's prologue sequence.
  -msingle-pic-base           Do not load the PIC register in function prologues.
  -mslow-flash-data           Assume loading data from flash is slower than fetching instructions.
  -msoft-float                Same as -mfloat-abi=soft.
  -mstack-protector-guard-offset= Use an immediate to offset from the TLS register. This option is for
                              use with fstack-protector-guard=tls and not for use in user-land code.
  -mstack-protector-guard=    Use given stack-protector guard.
  -mstructure-size-boundary=  Specify the minimum bit alignment of structures. (Deprecated).
  -mthumb                     Generate code for Thumb state.
  -mthumb-interwork           Support calls between Thumb and ARM instruction sets.
  -mtls-dialect=              Specify thread local storage scheme.
  -mtp=                       Specify how to access the thread pointer.
  -mtpcs-frame                Thumb: Generate (non-leaf) stack frames even if not needed.
  -mtpcs-leaf-frame           Thumb: Generate (leaf) stack frames even if not needed.
  -mtune=                     Tune code for the given processor.
  -munaligned-access          Enable unaligned word and halfword accesses to packed data.
  -mvectorize-with-neon-double Use Neon double-word (rather than quad-word) registers for
                              vectorization.
  -mvectorize-with-neon-quad  Use Neon quad-word (rather than double-word) registers for vectorization.
  -mword-relocations          Only generate absolute relocations on word sized values.

  Known ARM ABIs (for use with the -mabi= option):
    aapcs aapcs-linux apcs-gnu atpcs iwmmxt

  Known __fp16 formats (for use with the -mfp16-format= option):
    alternative ieee none

  Known ARM FPUs (for use with the -mfpu= option):
    auto crypto-neon-fp-armv8 fp-armv8 fpv4-sp-d16 fpv5-d16 fpv5-sp-d16 neon neon-fp-armv8 neon-fp16
    neon-vfpv3 neon-vfpv4 vfp vfp3 vfpv2 vfpv3 vfpv3-d16 vfpv3-d16-fp16 vfpv3-fp16 vfpv3xd vfpv3xd-fp16
    vfpv4 vfpv4-d16

  Valid arguments to -mtp=:
    auto cp15 soft

  Known floating-point ABIs (for use with the -mfloat-abi= option):
    hard soft softfp

  Valid arguments to -mstack-protector-guard=:
    global tls

  TLS dialect to use:
    gnu gnu2

Assembler options
=================

Use "-Wa,OPTION" to pass "OPTION" to the assembler.

 ARM-specific assembler options:
  -k                      generate PIC code
  -mthumb                 assemble Thumb code
  -mthumb-interwork       support ARM/Thumb interworking
  -mapcs-32               code uses 32-bit program counter
  -mapcs-26               code uses 26-bit program counter
  -mapcs-float            floating point args are in fp regs
  -mapcs-reentrant        re-entrant code
  -matpcs                 code is ATPCS conformant
  -mbig-endian            assemble for big-endian
  -mlittle-endian         assemble for little-endian
  -mapcs-frame            use frame pointer
  -mapcs-stack-check      use stack size checking
  -mno-warn-deprecated    do not warn on use of deprecated feature
  -mwarn-restrict-it      warn about performance deprecated IT instructions in ARMv8-A and ARMv8-R
  -mwarn-syms             warn about symbols that match instruction names [default]
  -mno-warn-syms          disable warnings about symobls that match instructions
  -mcpu=<cpu name>	  assemble for CPU <cpu name>
  -march=<arch name>	  assemble for architecture <arch name>
  -mfpu=<fpu name>	  assemble for FPU architecture <fpu name>
  -mfloat-abi=<abi>	  assemble for floating point ABI <abi>
  -meabi=<ver>		  assemble for eabi version <ver>
  -mimplicit-it=<mode>	  controls implicit insertion of IT instructions
  -mccs			  TI CodeComposer Studio syntax compatibility mode
  -mfp16-format=[ieee|alternative]
                          set the encoding for half precision floating point numbers to IEEE
                          or Arm alternative format.
  -EB                     assemble code for a big-endian cpu
  -EL                     assemble code for a little-endian cpu
  --fix-v4bx              Allow BX in ARMv4 code
  --fdpic                 generate an FDPIC object file

Linker options
==============

Use "-Wl,OPTION" to pass "OPTION" to the linker.

armelf: 
  --thumb-entry=<sym>         Set the entry point to be Thumb symbol <sym>
  --be8                       Output BE8 format image
  --target1-rel               Interpret R_ARM_TARGET1 as R_ARM_REL32
  --target1-abs               Interpret R_ARM_TARGET1 as R_ARM_ABS32
  --target2=<type>            Specify definition of R_ARM_TARGET2
  --fix-v4bx                  Rewrite BX rn as MOV pc, rn for ARMv4
  --fix-v4bx-interworking     Rewrite BX rn branch to ARMv4 interworking veneer
  --use-blx                   Enable use of BLX instructions
  --vfp11-denorm-fix          Specify how to fix VFP11 denorm erratum
  --fix-stm32l4xx-629360      Specify how to fix STM32L4XX 629360 erratum
  --no-enum-size-warning      Don't warn about objects with incompatible
                                enum sizes
  --no-wchar-size-warning     Don't warn about objects with incompatible
                                wchar_t sizes
  --pic-veneer                Always generate PIC interworking veneers
  --long-plt                  Generate long .plt entries
                              to handle large .plt/.got displacements
  --cmse-implib               Make import library to be a secure gateway import
                                library as per ARMv8-M Security Extensions
  --in-implib                 Import library whose symbols address must
                                remain stable
  --stub-group-size=N         Maximum size of a group of input sections that
                                can be handled by one stub section.  A negative
                                value locates all stubs after their branches
                                (with a group size of -N), while a positive
                                value allows two groups of input sections, one
                                before, and one after each stub section.
                                Values of +/-1 indicate the linker should
                                choose suitable defaults.
  --[no-]fix-cortex-a8        Disable/enable Cortex-A8 Thumb-2 branch erratum fix
  --no-merge-exidx-entries    Disable merging exidx entries
  --[no-]fix-arm1176          Disable/enable ARM1176 BLX immediate erratum fix


