; nasm -f elf64 -g ./b1_l.asm
; ld b1_l.o -o b1_l

bits 64
default rel

section .data
    lpHexString						db "0123456789ABCDEF"

    fileName_msg 					db "File Directory: ", 0h
    fileName_msg_len 				equ $-fileName_msg

    error_readFileHeader_msg 		db "Failed to read file header", 0Ah, 0h
    error_readFileHeader_msg_len 	equ $-error_readFileHeader_msg
    space 							db " "
    lf 								db 10
    max_size 						equ 100
    handle 							dq 0
    count 							dd 1
    count_2 						dd 1
;; Elf Header msgs
    elf_header      				db "ELF Header:", 0Ah, "    Magic:   7f 45 4c 46 ", 0h
    elf_header_len 					equ $-elf_header
    ei_pad_msg 						db "00 00 00 00 00 00 00", 0Ah, 0h
    ei_pad_msg_len 					equ $-ei_pad_msg

;; ELF Header variables
    elf_arch 						dd 1
    elf_endianness 					dd 1
    elf_osABI 						dd 1
    elf_ABIver 						dd 1
    elf_type 						dd 1
    elf_machine 					dd 1
;; ELF Header Members msgs
    elf_class_32b 					db "    Class:                             ELF32", 0h
    elf_class_msg_len 				equ $-elf_class_32b
    elf_class_64b 					db "    Class:                             ELF64", 0h
    elf_class_msg 					dq elf_class_32b, elf_class_64b
    ; ELF Data
    elf_data_32b  					db "    Data:                              2's complement, little endian", 0h
    elf_data_msg_len 				equ $-elf_data_32b
    elf_data_64b  					db "    Data:                              2's complement, big endian   ", 0h
    elf_data_msg  					dq elf_data_32b, elf_data_64b
    ; ELF Version
    elf_version_msg 				db "    Version:                           1 (current)", 0h
    elf_version_msg_len 			equ $-elf_version_msg
    ; ELF OS/ABI
    OsAbi_00 						db "    OS/ABI:                            UNIX - System V              ", 0h
    OsAbi_msg_len 					equ $-OsAbi_00
    OsAbi_01 						db "    OS/ABI:                            HP-UX                        ", 0h
    OsAbi_02 						db "    OS/ABI:                            NetBSD                       ", 0h
    OsAbi_03 						db "    OS/ABI:                            Linux                        ", 0h
    OsAbi_04 						db "    OS/ABI:                            GNU Hurd                     ", 0h
    OsAbi_06 						db "    OS/ABI:                            Solaris                      ", 0h
    OsAbi_07 						db "    OS/ABI:                            AIX                          ", 0h
    OsAbi_08 						db "    OS/ABI:                            IRIX                         ", 0h
    OsAbi_09 						db "    OS/ABI:                            FreeBSD                      ", 0h
    OsAbi_0A 						db "    OS/ABI:                            Tru64                        ", 0h
    OsAbi_0B 						db "    OS/ABI:                            Novell Modesto               ", 0h
    OsAbi_0C 						db "    OS/ABI:                            OpenBSD                      ", 0h
    OsAbi_0D 						db "    OS/ABI:                            OpenVMS                      ", 0h
    OsAbi_0E 						db "    OS/ABI:                            Nonstop Kernel               ", 0h
    OsAbi_0F 						db "    OS/ABI:                            AROS                         ", 0h
    OsAbi_10 						db "    OS/ABI:                            Fenix OS                     ", 0h
    OsAbi_11 						db "    OS/ABI:                            CloudABI                     ", 0h
    OsAbi_12 						db "    OS/ABI:                            Stratus Technologies OpenVOS ", 0h
    OsAbi_msg 						dq OsAbi_00 , OsAbi_01 , OsAbi_02 , OsAbi_03 , OsAbi_04 , OsAbi_06 , OsAbi_06 , OsAbi_07 , OsAbi_08 , OsAbi_09 , OsAbi_0A , OsAbi_0B , OsAbi_0C , OsAbi_0D , OsAbi_0E , OsAbi_0F , OsAbi_10 , OsAbi_11 , OsAbi_12
    ; ELF ABI Version
    elf_ABIver_msg 					db "    ABI Version:                       ", 0h
    elf_ABIver_msg_len 				equ $-elf_ABIver_msg
    ; ELF Type
    elf_type_00 					db "    Type:                              NONE ", 0h
    elf_sh_type_msg_len 			equ $-elf_type_00
    elf_type_01 					db "    Type:                              REL  ", 0h
    elf_type_02 					db "    Type:                              EXEC ", 0h
    elf_type_03 					db "    Type:                              DYN  ", 0h
    elf_type_04 					db "    Type:                              CORE ", 0h
    elf_sh_type_msg 				dq elf_type_00, elf_type_01, elf_type_02, elf_type_03, elf_type_04
    ; ELF Machine
    elf_machine_value_list 			db 01, 02, 03, 06, 07, 08, 0x13, 0x14, 0x15, 0x32, 0x3E, 0xB7, 0xF3
    elf_machine_01 					db "    Machine:                           AT&T WE 32100 ", 0h
    elf_machine_msg_len 			equ $-elf_machine_01
    elf_machine_02 					db "    Machine:                           SPARC         ", 0h
    elf_machine_03 					db "    Machine:                           x86           ", 0h
    elf_machine_06 					db "    Machine:                           Intel MCU     ", 0h
    elf_machine_07 					db "    Machine:                           Intel 80860   ", 0h
    elf_machine_08 					db "    Machine:                           MIPS          ", 0h
    elf_machine_13 					db "    Machine:                           Intel 80960   ", 0h
    elf_machine_14 					db "    Machine:                           PowerPC       ", 0h
    elf_machine_15 					db "    Machine:                           PowerPC (x64) ", 0h
    elf_machine_32 					db "    Machine:                           IA - 64       ", 0h
    elf_machine_3e 					db "    Machine:                           AMD x86 - 64  ", 0h
    elf_machine_b7 					db "    Machine:                           ARM 64 - bits ", 0h
    elf_machine_f3 					db "    Machine:                           RISC - V      ", 0h
    elf_machine_msg 				dq elf_machine_01 , elf_machine_02 , elf_machine_03 , elf_machine_06 , elf_machine_07 , elf_machine_08 , elf_machine_13 , elf_machine_14 , elf_machine_15 , elf_machine_32 , elf_machine_3e , elf_machine_b7 , elf_machine_f3
    ; ELF Version
    elf_version2_msg 				db "    Version:                           0x1", 0Ah, 0h
    elf_version2_msg_len 			equ $-elf_version2_msg

    ; ELF Entry
    elf_entry_msg 					db "    Entry point address:               0x", 0h
    elf_entry_msg_len 				equ $-elf_entry_msg
    
    ; ELF Program Offset
    elf_phoff_msg 					db "    Start of program headers:          ", 0h
    elf_phoff_msg_len 				equ $-elf_phoff_msg
    bytes_into_file_msg 			db " (bytes into file)", 0Ah
    bytes_into_file_msg_len 		equ $-bytes_into_file_msg
    elf_phoff 						dd 1

    ; ELF Section Offset
    elf_shoff_msg 					db "    Start of section headers:          ", 0h
    elf_shoff_msg_len 				equ $-elf_shoff_msg
    elf_shoff 						dd 1

    ; ELF Flags
    elf_sh_flags_msg 				db "    Flags:                             0x", 0h
    elf_sh_flags_msg_len 			equ $-elf_sh_flags_msg

    ; ELF Header Size
    elf_ehsize_msg 					db "    Size of this header:               ", 0h
    elf_ehsize_msg_len 				equ $-elf_ehsize_msg
    bytes_msg 						db " (bytes)", 0Ah
    bytes_msg_len 					equ $-bytes_msg

    ; ELF Program Header Size
    elf_phentsize_msg 				db "    Size of program header:            ", 0h
    elf_phentsize_msg_len 			equ $-elf_phentsize_msg
    elf_phentsize 					dd 1

    ; Number of Program Header Size
    elf_phnum_msg 					db "    Number of program header:          ", 0h
    elf_phnum_msg_len 				equ $-elf_phnum_msg
    elf_phnum 						dd 1

    ; Size of Section Header
    elf_shentsize_msg 				db "    Size of section headers:           ", 0h
    elf_shentsize_msg_len 			equ $-elf_shentsize_msg
    elf_shentsize 					dd 1
    ; Number of Section Header
    elf_shnum_msg 					db "    Number of section headers:         ", 0h
    elf_shnum_msg_len 				equ $-elf_shnum_msg
    elf_shnum 						dd 1

    ; Index of Section Header Tbable Entry
    elf_shstrndx_msg 				db "    Section header string table index: ", 0h
    elf_shstrndx_msg_len 			equ $-elf_shstrndx_msg
    elf_shstrndx 					dd 1


;; Section Header msgs
    sectionHeader_msg 				db 0Ah, "Section Headers:", 0Ah, 0h
    sectionHeader_msg_len 			equ $-sectionHeader_msg
    open_square_bracket 			db "[ ", 0h
    open_square_bracket_len 		equ $-open_square_bracket
    name_msg						db " ] Name: ", 0h
    name_msg_len 					equ $-name_msg
    ; sh_type
    sh_type_msg_00 					db "       Type: NULL           ", 0Ah, 0h
    sh_type_msg_len 				equ $-sh_type_msg_00
    sh_type_msg_01 					db "       Type: PROGBITS       ", 0Ah, 0h
    sh_type_msg_02 					db "       Type: SYMTAB         ", 0Ah, 0h
    sh_type_msg_03 					db "       Type: STRTAB         ", 0Ah, 0h
    sh_type_msg_04 					db "       Type: RELA           ", 0Ah, 0h
    sh_type_msg_05 					db "       Type: HASH           ", 0Ah, 0h
    sh_type_msg_06 					db "       Type: DYNAMIC        ", 0Ah, 0h
    sh_type_msg_07 					db "       Type: NOTE           ", 0Ah, 0h
    sh_type_msg_08 					db "       Type: NOBITS         ", 0Ah, 0h
    sh_type_msg_09 					db "       Type: REL            ", 0Ah, 0h
    sh_type_msg_0A 					db "       Type: SHLIB          ", 0Ah, 0h
    sh_type_msg_0B 					db "       Type: DYNSYM         ", 0Ah, 0h
    sh_type_msg_0E 					db "       Type: INIT_ARRAY     ", 0Ah, 0h
    sh_type_msg_0F 					db "       Type: FINI_ARRAY     ", 0Ah, 0h
    sh_type_msg_10 					db "       Type: PREINIT_ARRAY  ", 0Ah, 0h
    sh_type_msg_11 					db "       Type: GROUP          ", 0Ah, 0h
    sh_type_msg_12 					db "       Type: SYMTAB_SHNDX   ", 0Ah, 0h
    sh_type_msg_13 					db "       Type: NUM            ", 0Ah, 0h
    sh_type_msg 					dq   sh_type_msg_00 , sh_type_msg_01 , sh_type_msg_02 , sh_type_msg_03 , sh_type_msg_04 , sh_type_msg_05 , sh_type_msg_06 , sh_type_msg_07 , sh_type_msg_08 , sh_type_msg_09 , sh_type_msg_0A , sh_type_msg_0B , sh_type_msg_0E , sh_type_msg_0F , sh_type_msg_10 , sh_type_msg_11 , sh_type_msg_12 , sh_type_msg_13
    sh_type_value_list 				dw   0x00 , 0x01 , 0x02 , 0x03 , 0x04 , 0x05 , 0x06 , 0x07 , 0x08 , 0x09 , 0x0A , 0x0B , 0x0E , 0x0F , 0x10 , 0x11 , 0x12 , 0x13
    ; sh_flags
    sh_flags_msg_ 					db "       Flags: ", 0h
    sh_flags_msg__len 				equ $-sh_flags_msg_
    sh_flags_msg_00 				db "N",  0h
    sh_flags_msg_len 				equ $-sh_flags_msg_00
    sh_flags_msg_01 				db "W",  0h
    sh_flags_msg_02 				db "A",  0h
    sh_flags_msg_04 				db "X",  0h
    sh_flags_msg_10 				db "M",  0h
    sh_flags_msg_20 				db "S",  0h
    sh_flags_msg_40 				db "I",  0h
    sh_flags_msg_80 				db "L",  0h
    sh_flags_msg_100 				db " ",  0h
    sh_flags_msg_200 				db "G",  0h
    sh_flags_msg_400 				db "T",  0h
    sh_flags_msg 					dq sh_flags_msg_400,sh_flags_msg_200, sh_flags_msg_100, sh_flags_msg_80, sh_flags_msg_40, sh_flags_msg_20, sh_flags_msg_10, sh_flags_msg_04, sh_flags_msg_02, sh_flags_msg_01
    sh_flags_value_list 			dd 0x400,0x200, 0x100, 0x80, 0x40, 0x20, 0x10, 0x04, 0x02, 0x01

    ; sh_addr
    sh_addr_msg 					db "       Address: ", 0h
    sh_addr_msg_len 				equ $-sh_addr_msg
    ; sh_offset
    sh_offset_msg 					db "       Offset: ", 0h
    sh_offset_msg_len 				equ $-sh_offset_msg
    ; sh_size
    sh_size_msg 					db "       Size: ", 0h
    sh_size_msg_len 				equ $-sh_size_msg
    ; sh_link
    sh_link_msg 					db "       Link: ", 0h
    sh_link_msg_len 				equ $-sh_link_msg    
    ; sh_info
    sh_info_msg 					db "       Info: ", 0h
    sh_info_msg_len 				equ $-sh_info_msg
    ; sh_addralign
    sh_addralign_msg 				db "       Align: ", 0h
    sh_addralign_msg_len 			equ $-sh_addralign_msg
    ; sh_entsize
    sh_entsize_msg 					db "       Entsize: ", 0h
    sh_entsize_msg_len 				equ $-sh_entsize_msg
    ; key to flags
    key_to_sh_flags_msg 			db "Key to Flags:", 0Ah, "N (null), W (write), A (alloc), X (execute), M (merge), S (strings), I (info),", 0Ah, "L (link order), O (extra OS processing required), G (group), T (TLS),", 0Ah, "C (compressed), x (unknown), o (OS specific), E (exclude),", 0Ah, "D (mbind), l (large), p (processor specific)", 0Ah, 0h
    key_to_sh_flags_msg_len 		equ $-key_to_sh_flags_msg

;; Program Header msgs
    ph_msg 							db 0Ah, "Program Header:", 0Ah, 0h
    ph_msg_len 						equ $-ph_msg
    ; p_type
    p_type_msg_00           		db " ]  Type: NULL          ",0h
    p_type_msg_len 					equ $-p_type_msg_00
    p_type_msg_01           		db " ]  Type: LOAD          ",0h
    p_type_msg_02           		db " ]  Type: DYNAMIC       ",0h
    p_type_msg_03           		db " ]  Type: INTERP        ",0h
    p_type_msg_04           		db " ]  Type: NOTE          ",0h
    p_type_msg_05           		db " ]  Type: SHLIB         ",0h
    p_type_msg_06           		db " ]  Type: PHDR          ",0h
    p_type_msg_07           		db " ]  Type: TLS           ",0h
    p_type_msg_60           		db " ]  Type: LOOS          ",0h
    p_type_msg_6f           		db " ]  Type: HIOS          ",0h
    p_type_msg_70           		db " ]  Type: LOPROC        ",0h
    p_type_msg_7f           		db " ]  Type: HIPROC        ",0h
    p_type_gnu_eh_frame_msg 		db " ]  Type: GNU_EH_FRAME  ",0h
    p_type_gnu_stack_msg    		db " ]  Type: GNU_STACK     ",0h
    p_type_gnu_relro_msg    		db " ]  Type: GNU_RELRO     ",0h
    p_type_gnu_property_msg 		db " ]  Type: GNU_PROPERTY  ",0h

    p_type_msg 						dq p_type_msg_00 ,p_type_msg_01 ,p_type_msg_02 ,p_type_msg_03 ,p_type_msg_04 ,p_type_msg_05 ,p_type_msg_06 ,p_type_msg_07 ,p_type_msg_60 ,p_type_msg_6f ,p_type_msg_70 ,p_type_msg_7f,  p_type_gnu_eh_frame_msg , p_type_gnu_stack_msg , p_type_gnu_relro_msg , p_type_gnu_property_msg
    p_type_value_list 				dd 0x00 ,0x01 ,0x02 ,0x03 ,0x04 ,0x05 ,0x06 ,0x07 ,0x60000000 ,0x6f000000 ,0x70000000 ,0x7f000000, 0x6474e550, 0x6474e551, 0x6474e552, 0x6474e553
    ; p_flags
    p_flags_msg_01 					db "       Flags: --E", 0Ah, 0h
    p_flags_msg_len 				equ $-p_flags_msg_01
    p_flags_msg_02 					db "       Flags: -W-", 0Ah, 0h
    p_flags_msg_04 					db "       Flags: R--", 0Ah, 0h
    p_flags_msg_03 					db "       Flags: -WE", 0Ah, 0h
    p_flags_msg_06 					db "       Flags: RW-", 0Ah, 0h
    p_flags_msg_05 					db "       Flags: R-E", 0Ah, 0h
    p_flags_msg_07 					db "       Flags: RWE", 0Ah, 0h
    p_flags_msg 					dq p_flags_msg_01 ,p_flags_msg_02 ,p_flags_msg_04 ,p_flags_msg_03 ,p_flags_msg_06 ,p_flags_msg_05 ,p_flags_msg_07
    p_flags_value_list 				dd 0x01 ,0x02 ,0x04 ,0x03 ,0x06 ,0x05 ,0x07
    p_flags 						dd 1
    ; p_offset
    p_offset_msg 					db "       Offset: ", 0h
    p_offset_msg_len 				equ $-p_offset_msg
    ; p_vaddr
    p_vaddr_msg 					db "       VirtAddr: ", 0h
    p_vaddr_msg_len 				equ $-p_vaddr_msg
    ; p_paddr
    p_paddr_msg 					db "       PhysAddr: ", 0h
    p_paddr_msg_len 				equ $-p_paddr_msg
    ; p_filesz
    p_filesz_msg 					db "       Filesz: ", 0h
    p_filesz_msg_len 				equ $-p_filesz_msg
    ; p_memsz
    p_memsz_msg 					db "       Memsz: ", 0h
    p_memsz_msg_len 				equ $-p_memsz_msg
    ; p_align
    p_align_msg 					db "       Align: ", 0h
    p_align_msg_len 				equ $-p_align_msg

;; Section to Segments mapping msgs
    sec2seg_msg 					db 0Ah, "Section to Segments mapping:", 0Ah, "  Segment Sections...", 0Ah, 0h
    sec2seg_msg_len 				equ $-sec2seg_msg


;; arrays
    sh_vaddr_array times 200 dd 1
    sh_name_offset_array times 200 dd 0
    sh_vaddr_plus_size_array times 200 dd 1
    ph_vaddr_array times 200 dd 1
    ph_vaddr_plus_size_array times 200 dd 1
section .bss
	fileName resb 100h
    buffer resb max_size
    BytesBuffer resb 2
    tmp_string resb max_size
    string_buf resb 20
    singleByte resb 1
    ; variables for ELF Header
    NameSection_virtOffset resb 4
    NameSection_offset resb 4
    cur_offset resb 4

section .text

	;rsi: pointer to buffer
	;rdx: buffer length
    print:
		mov rax, 1							;sys_write
        mov rdi, 1
        syscall
        ret
		
	;rsi: buffer to receive data
	;rdx: requested length to read
    read:
		mov rax, 0							;sys_read
        mov rdi, 0							;fd: stdin
        syscall
        ret
		
    exit:
        mov eax, 1
        mov ebx, 0
        int 80h
        ret
		
    newline:
        mov rsi, lf
        mov rdx, 2
        call print
        ret
		
    backspace:
        mov rsi, space
        mov rdx, 1
        call print
        ret
	
	;convert string to
    ;;  Input:   edi - input string
    ;;  Output:  eax - result in integer
    atoi:
        xor eax, eax            ; set eax = 0
    .loop:
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string
        cmp ecx, byte '-'       ; check input number is negative or positive
        je .negative
        jmp .positive
    .negative:
        inc edi                 ; skip '-' character
        movzx ecx, byte [edi]   ; 
        sub ecx, '0'            ; convert num -> int 
        jb .done_negative       ; done

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        test edi, edi
        jnz .negative
    .positive:
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string

        sub ecx, '0'            ; convert num -> int 
        jb .done_positive       ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        inc edi                 ; next character of string
        test edi, edi
        jnz .positive
    .done_negative: 
        mov ebx, 0h             ; negative_num = 0 - (- negative_number)
        sub ebx, eax
        mov eax, ebx
        ret
    .done_positive:
        ret
    ;;  Input:  eax - integer
    ;;          rsi - pointer to result buffer
    ;;  Output: rax - pointer to result buffer
	;;			rdi - number of character
    itoa:
        add rsi, max_size       ; point to the last byte of result buffer
        mov byte [rsi], 0h      ; set the last byte of result buffser to null
		
        mov ebx, 10     
        
        xor rdi, rdi			;char counter		
		
        cmp eax, 0h				;check if provided number is negative or not
        jge .loop_positive
        neg eax	
    .loop_negative:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec rsi                 ; point to the next left byte 
        mov [rsi], dl           ; mov remainder to the current byte
        inc rdi
        test eax, eax           ; if (eax == 0) ?
        jnz .loop_negative      ; if not -> loop
        mov dl, byte '-'        ; 
        dec rsi
        mov [rsi], dl           ; mov '-' to the current byte
        jmp .done
    .loop_positive:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec rsi                 ; point to the next left byte 
        mov [rsi], dl           ; mov remainder to the current byte
        inc rdi
        test eax, eax           ; if (eax == 0) ?
        jnz .loop_positive      ; if not -> loop
        jmp .done
    .done:
        mov rax, rsi            ; else return result to eax
        ret 
        
    failed_read_header:
        mov rsi, error_readFileHeader_msg
        mov rdx, error_readFileHeader_msg_len
        call print
        ret

    ;; Input: eax - number to convert
    ;;        rdi - pointer to buffer
    ;; Output: hex number in buffer
	Dec2Hex:
        mov ecx, 8
    @digit_loop:
        rol eax, 4
        mov edx, eax
        and edx, 0Fh
        movzx edx, byte [lpHexString + edx]
        mov [rdi], dl
        inc rdi

        dec ecx
        jnz @digit_loop
        mov byte [rdi], 0h
        ret

    ;; Input: eax - value to print in hex
    ;;        rdi - pointer to string
    ;;        ecx - number of bytes to print
    ;; Output: StdOut
    print_string:
        push rcx
        call Dec2Hex
        pop rcx
        mov rdi, tmp_string
        add ecx, ecx
        mov eax, 8
        sub eax, ecx
        add rdi, rax
        lea rsi, [string_buf]
        Li:
            mov ah, byte [rdi]
            mov byte [rsi], ah
            cmp ecx, 1h
            je @done
            inc rdi
            inc rsi
            dec ecx
            jmp Li
        @done:
            inc rsi
            mov byte [rsi], 0h
            mov rsi, string_buf
            mov rdx, 8
            call print 
            ret

    ;; print name in Section Header
    ;; Input: ecx - offset in file
    print_name_in_Section_Header:
        mov rdi, [handle]					;fd
        mov rdx, 0							;origin
		mov rsi, rcx						;offset
        mov rax, 8							;sys_lseek
        syscall

        loop_print_name:
			mov	rax, 0						;sys_read
            mov rdi, 3						;fd
            mov rsi, singleByte
            mov rdx, 1
            syscall

            cmp byte [singleByte], 0h
            je .done

            mov rdi, tmp_string
            mov ah, byte [singleByte]
            mov byte [rdi], ah
            inc edi
            mov byte [rdi], 0h
            
            mov rsi, tmp_string
            mov rdx, 1
            call print 
            jmp loop_print_name
        .done:
            ret
    global _start
_start:
	
	;ask for file name
    mov rsi, fileName_msg
    mov rdx, fileName_msg_len
    call print
	
	;read file name from user input
	mov rsi, fileName
	mov rdx, 100h
	call read
	
	;append null byte to file name
	lea rdi, [fileName]
	add rdi, rax
	sub rdi, 1
	mov byte [rdi], 0h

	;open file from provided file name
    mov rdi, fileName           ;open file to read
    mov rax, 2					;sys_open
    mov rsi, 0					;flags
    syscall
    mov [handle], rax
	
	;read from file and store into buffer
    mov rax, 0              	;sys_read    
    mov rdi, [handle]			;fd		
    mov rsi, buffer
    mov rdx, 4
    syscall

    cmp dword [buffer], 0x464c457f  ; check if ELF or not
    jne failed_read_header 

;; print ELF Header
    mov rsi, elf_header
    mov rdx, elf_header_len
    call print
; offset    size    name
; 0x04	    1	    e_ident[EI_CLASS]
; 0x05	    1	    e_ident[EI_DATA]
; 0x06	    1	    e_ident[EI_VERSION]
; 0x07	    1	    e_ident[EI_OSABI]
; 0x08	    1	    e_ident[EI_ABIVERSION]
; 0x09	    7	    e_ident[EI_PAD]        ->    unused
; 0x10	    2	    e_type
; 0x12	    2	    e_machine
; 0x14	    4	    e_version

;; read EI_CLASS
; 0x1 for 32-bit
; 0x2 for 64-bit

    mov rax, 0				;sys_read
    mov rdi, 3				;fd
    mov rsi, BytesBuffer	;buffer
    mov rdx, 1				;requested length
    syscall

    lea rdi, [tmp_string]
    mov ecx, 1
    movzx eax, word [BytesBuffer]
    mov [elf_arch], eax
    call print_string

    call backspace

;; read EI_DATA
; 0x1 for little endian
; 0x2 for big endian
    mov eax, 3
    mov ebx, eax
    mov ecx, BytesBuffer
    mov edx, 1
    int 80h

    lea rdi, [tmp_string]
    mov ecx, 1
    movzx eax, word [BytesBuffer]
    mov [elf_endianness], eax
    call print_string

    call backspace

;; read EI_VERSION
; set to 1
    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 1
    syscall

    lea rdi, [tmp_string]
    mov ecx, 1
    movzx eax, word [BytesBuffer]
    call print_string

    call backspace
;; read EI_OSABI
; set to 1
    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 1
    syscall

    lea rdi, [tmp_string]
    mov ecx, 1
    movzx eax, word [BytesBuffer]
    mov [elf_osABI], eax
    call print_string    

    call backspace

;; read EI_ABIVERSION
; set to 1
    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 1
    syscall

    lea rdi, [tmp_string]
    mov ecx, 1
    movzx eax, word [BytesBuffer]
    mov [elf_ABIver], eax
    call print_string    

    call backspace

;; read EI_PAD (7 bytes - unused)
    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 7				;requested length
    syscall
	
    mov rsi, ei_pad_msg
    mov rdx, ei_pad_msg_len
    call print

;; read EI_TYPE
; set to 1
    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    mov [elf_type], eax

;; read EI_MACHINE
    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    mov [elf_machine], eax

;; read EI_VERSION
;Set to 1 for the original version of ELF.
    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 4				;requested length
    syscall



;; print ELF Header members
;   print ELF Class
    mov eax, dword [elf_arch]
    dec eax
    lea rdi, [elf_class_msg]
    mov rsi, [rdi + 8 * rax]
    mov rdx, elf_class_msg_len
    call print
    call newline
;   print ELF Data
    mov eax, dword [elf_endianness]
    dec eax
    lea rdi, [elf_data_msg]
    mov rsi, [rdi + 8 * rax]
    mov rdx, elf_data_msg_len
    call print
    call newline
;   print ELF Version (default: Current = 1)
    mov rsi, elf_version_msg
    mov rdx, elf_version_msg_len
    call print
    call newline
;   print ELF OS/ABI
    mov eax, dword [elf_osABI]
    lea rdi, [OsAbi_msg]
    mov rsi, [rdi + 8 * rax]
    mov rdx, OsAbi_msg_len
    call print
    call newline
;   print ELF ABI Version
    mov rsi, elf_ABIver_msg
    mov rdx, elf_ABIver_msg_len
    call print

    movzx eax, word [elf_ABIver]
    mov rsi, tmp_string
    call itoa
    mov rsi, rax
    mov rdx, 2
    call print
    call newline
;   print ELF Type
    mov eax, [elf_type]
    mov rsi, [elf_sh_type_msg + 8 * eax]
    mov rdx, elf_sh_type_msg_len
    call print
    call newline
;   print ELF Machine
    xor ecx, ecx
    push rcx
.loop_elf_machine:
    pop rcx
    movzx eax, byte [elf_machine_value_list + ecx]
    push rcx
    cmp [elf_machine], eax 
    je .found_machine
    pop rcx
    inc ecx
    push rcx
    cmp ecx, 12
    je .found_machine
    jmp .loop_elf_machine
    .found_machine:
        mov rsi, [elf_machine_msg + ecx * 8]
        mov rdx, elf_machine_msg_len
        call print
        call newline

;   print ELF Version
    mov rsi, elf_version2_msg
    mov rdx, elf_version2_msg_len
    call print

;   print ELF Entry
    mov edx, [elf_arch]
    lea edx, [edx * 4]              ; edx = 4 if e_arch = 1
                                    ; edx = 8 if e_arch = 2
	
	mov rax, 0						;sys_read
    mov rdi, [handle]				;fd
    mov rsi, BytesBuffer			
    ;rdx							;requested length
    syscall

    mov rsi, elf_entry_msg
    mov rdx, elf_entry_msg_len
    call print

    mov eax, dword [BytesBuffer]
    mov ecx, 2
    lea rdi, [tmp_string]
    call print_string
    call newline

;   print ELF Program Header Offset
    mov edx, [elf_arch]
    lea edx, [edx * 4]              ; edx = 4 if e_arch = 1
                                    ; edx = 8 if e_arch = 2
    mov rax, 0						;sys_read
    mov rdi, [handle]				;fd
    mov rsi, BytesBuffer			
    ;rdx							;requested length
    syscall

    mov rsi, elf_phoff_msg
    mov rdx, elf_phoff_msg_len
    call print

    mov eax, dword [BytesBuffer]
    mov [elf_phoff], eax
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print

    mov rsi, bytes_into_file_msg
    mov rdx, bytes_into_file_msg_len
    call print

;   print ELF Section Header Offset
    mov edx, [elf_arch]
    lea edx, [edx * 4]              ; edx = 4 if e_arch = 1
                                    ; edx = 8 if e_arch = 2
    mov rax, 0						;sys_read
    mov rdi, [handle]				;fd
    mov rsi, BytesBuffer			
    ;rdx							;requested length
    syscall

    mov rsi, elf_shoff_msg
    mov rdx, elf_shoff_msg_len
    call print

    mov eax, dword [BytesBuffer]
    mov [elf_shoff], eax
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print

    mov rsi, bytes_into_file_msg
    mov rdx, bytes_into_file_msg_len
    call print

;   print ELF Flags
    mov rsi, elf_sh_flags_msg
    mov rdx, elf_sh_flags_msg_len
    call print 

    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 4				;requested length
    syscall

    mov eax, dword [BytesBuffer]
    lea rdi, [tmp_string]
    mov ecx, 1
    call print_string
    call newline
    
;   print ELF Header Size
    mov rsi, elf_ehsize_msg
    mov rdx, elf_ehsize_msg_len
    call print 

    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, 2
    call print
    
    mov rsi, bytes_msg
    mov rdx, bytes_msg_len
    call print

;   print ELF Program Header Size
    mov rsi, elf_phentsize_msg
    mov rdx, elf_phentsize_msg_len
    call print 

    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    mov [elf_phentsize], eax
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print
    
    mov rsi, bytes_msg
    mov rdx, bytes_msg_len
    call print

;   print Number of Program Header members
    mov rsi, elf_phnum_msg
    mov rdx, elf_phnum_msg_len
    call print 

    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    mov [elf_phnum], eax
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print
    call newline

;   print Size of Section Header
    mov rsi, elf_shentsize_msg
    mov rdx, elf_shentsize_msg_len
    call print 

    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    mov [elf_shentsize], eax
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print
    
    mov rsi, bytes_msg
    mov rdx, bytes_msg_len
    call print
;   print Number of Section Header
    mov rsi, elf_shnum_msg
    mov rdx, elf_shnum_msg_len
    call print 

    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    mov [elf_shnum], eax
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print
    call newline


;   print Index of Section Header Tbable Entry
    mov rsi, elf_shstrndx_msg
    mov rdx, elf_shstrndx_msg_len
    call print 

    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall

    movzx eax, word [BytesBuffer]
    mov [elf_shstrndx], eax
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print
    call newline

;; Section Header Print
;   find raw-offset of Name Section
    mov eax, dword [elf_shentsize]
    mov ebx, dword [elf_shstrndx]
    imul eax, ebx
    mov ebx, dword [elf_arch]
	shl	ebx, 3
    add ebx, 8
    add eax, ebx
    add eax, dword [elf_shoff]
    mov [NameSection_virtOffset], eax
    
;   point to Name Section
    mov rdi, [handle]							;fd
    mov esi, dword [NameSection_virtOffset]		;offset
    mov rdx, 0									;origin
    mov rax, 8									;sys_lseek
    syscall


    mov rax, 0				;sys_read
    mov rdi, [handle]		;fd
    mov rsi, BytesBuffer	
    mov rdx, 2				;requested length
    syscall
    ; save offset of Name Section in Section Header
    movzx eax, word [BytesBuffer]
    mov [NameSection_offset], eax

;; Section Header members print
    mov rsi, sectionHeader_msg
    mov rdx, sectionHeader_msg_len
    call print 

    mov eax, dword [elf_shoff]
    mov [cur_offset], eax

    mov dword [count], 0h
.loop_sh_print:

    mov eax, dword [elf_shnum]
    ;dec eax
    cmp dword [count], eax
    je .done_sh_print

;   print each member
    mov rsi, open_square_bracket
    mov rdx, open_square_bracket_len
    call print

    mov eax, dword [count]
    lea rsi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print

    add dword [count], 1

    mov rsi, name_msg
    mov rdx, name_msg_len
    call print

    mov rdi, [handle]							;fd
    mov esi, dword [cur_offset]		;offset
    mov rdx, 0									;origin
    mov rax, 8									;sys_lseek
    syscall

    ; get offset to a string in the .shstrtab section - which is name of each member

		mov rax, 0				;sys_read
		mov rdi, [handle]		;fd
		mov rsi, BytesBuffer	
		mov rdx, 4				;requested length
		syscall
        
        mov ecx, dword [BytesBuffer]
        add ecx, dword [NameSection_offset]
        mov ebx, dword [count]
        dec ebx
        mov dword [sh_name_offset_array + ebx * 4], ecx
        cmp ecx, 0h
        je .done_name
        call print_name_in_Section_Header
        jmp .done_name
        .done_name:
            call newline
    ; point to Section Header 
    mov rdi, [handle]							;fd
    mov esi, dword [cur_offset]					;offset
	add	esi, 4
    mov rdx, 0									;origin
    mov rax, 8									;sys_lseek
    syscall

    mov eax, dword [elf_shentsize]
    add dword [cur_offset], eax

        ; print sh_type
		mov rax, 0				;sys_read
		mov rdi, [handle]		;fd
		mov rsi, BytesBuffer	
		mov rdx, 4				;requested length
		syscall

        xor ecx, ecx
        push rcx
    .loop_sh_type:
        pop rcx
        movzx eax, word [sh_type_value_list + ecx * 2]
        push rcx
        cmp dword [BytesBuffer], eax 
        je .found_type
        pop rcx
        inc ecx
        push rcx
        cmp ecx, 17
        je .found_type
        jmp .loop_sh_type
        .found_type:
            mov rsi, [sh_type_msg + ecx * 8]
            mov rdx, sh_type_msg_len
            call print
            
        ; print sh_flags
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
		mov rax, 0				;sys_read
		mov rdi, [handle]		;fd
		mov rsi, BytesBuffer	
		syscall

        mov rsi, sh_flags_msg_
        mov rdx, sh_flags_msg__len
        call print


        xor ecx, ecx
        push rcx
    .loop_sh_flags:
        pop rcx
        cmp ecx, 10
        je .done_flags
        mov eax, dword [sh_flags_value_list + ecx * 4]
        push rcx
        mov ebx, dword [BytesBuffer]
        cmp dword [BytesBuffer], 0h
        je .done_flags
        cmp dword [BytesBuffer], eax 
        jge .found_flags
        pop rcx
        inc ecx
        push rcx
        jmp .loop_sh_flags
        .found_flags:
            sub dword [BytesBuffer], eax
            mov rsi, [sh_flags_msg + ecx * 8]
            mov rdx, sh_flags_msg_len
            call print
            pop rcx 
            inc ecx
            push rcx
            jmp .loop_sh_flags
        .done_flags:
            call newline

        ; print sh_addr
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, sh_addr_msg
        mov rdx, sh_addr_msg_len
        call print

        mov eax, dword [BytesBuffer]
        mov ebx, dword [count]
        dec ebx
        mov dword [sh_vaddr_array + ebx * 4], eax
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline

        ; print sh_offset
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, sh_offset_msg
        mov rdx, sh_offset_msg_len
        call print

        mov eax, dword [BytesBuffer]
        ; mov ebx, dword [count]
        ; dec ebx
        ; mov dword [sh_vaddr_array + ebx * 4], eax
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline

        ; print sh_size
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, sh_size_msg
        mov rdx, sh_size_msg_len
        call print

        mov eax, dword [BytesBuffer]
        mov ebx, dword [count]
        dec ebx
        mov ecx, dword [sh_vaddr_array + ebx * 4]
        add eax, ecx
        mov dword [sh_vaddr_plus_size_array + ebx * 4], eax
        mov eax, dword [BytesBuffer]
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline
        ; print sh_link
        mov edx, 4
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, sh_link_msg
        mov rdx, sh_link_msg_len
        call print

        mov eax, dword [BytesBuffer]
        lea esi, [tmp_string]
        call itoa
        mov rsi, rax
        mov rdx, rdi
        call print
        call newline
        ; print sh_info
        mov edx, 4
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, sh_info_msg
        mov rdx, sh_info_msg_len
        call print

        mov eax, dword [BytesBuffer]
        lea esi, [tmp_string]
        call itoa
        mov rsi, rax
        mov rdx, rdi
        call print
        call newline

        ; print sh_addralign
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, sh_addralign_msg
        mov rdx, sh_addralign_msg_len
        call print

        mov eax, dword [BytesBuffer]
        lea esi, [tmp_string]
        call itoa
        mov rsi, rax
        mov rdx, rdi
        call print
        call newline

        ; print sh_entsize
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, sh_entsize_msg
        mov rdx, sh_entsize_msg_len
        call print

        mov eax, dword [BytesBuffer]
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline
        jmp .loop_sh_print
    .done_sh_print:
        mov rsi, key_to_sh_flags_msg
        mov rdx, key_to_sh_flags_msg_len
        call print

; Program Header print
    mov rsi, ph_msg
    mov rdx, ph_msg_len
    call print

    mov eax, dword [elf_phoff]
    mov [cur_offset], eax

   ; point to Program Header 

    mov ebx, [handle]
    movzx ecx, word [cur_offset]
    mov edx, 0
    mov eax, 19
    int 80h

    mov dword [count], 0h
    .loop_p_print:

    mov eax, dword [elf_phnum]
    ;dec eax
    cmp dword [count], eax
    je .done_p_print

;   print each member
    mov rsi, open_square_bracket
    mov rdx, open_square_bracket_len
    call print

    mov eax, dword [count]
    lea esi, [tmp_string]
    call itoa
    mov rsi, rax
    mov rdx, rdi
    call print

    add dword [count], 1

        ; print p_type
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        mov edx, 4
        int 80h

        xor ecx, ecx
        push rcx
    .loop_p_type:
        pop rcx
        mov eax, dword [p_type_value_list + ecx * 4]
        push rcx
        cmp dword [BytesBuffer], eax 
        je .found_p_type
        pop rcx
        inc ecx
        push rcx
        cmp ecx, 15
        je .found_p_type
        jmp .loop_p_type
        .found_p_type:
            mov rsi, [p_type_msg + ecx * 8]
            mov rdx, p_type_msg_len
            call print
            
        ; save p_flags if 64bit
        mov edx, dword [elf_arch]
        dec edx
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        cmp dword [elf_arch], 0x2
        jne .not_64
        movzx eax, word [BytesBuffer]
        mov [p_flags], eax
        .not_64:
        ; print p_offset
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        call newline
        mov rsi, p_offset_msg
        mov rdx, p_offset_msg_len
        call print

        mov eax, dword [BytesBuffer]
        ; mov ebx, dword [count]
        ; dec ebx
        ; mov dword [ph_vaddr_array + ebx * 4], eax
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline
       ; print p_vaddr
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, p_vaddr_msg
        mov rdx, p_vaddr_msg_len
        call print

        mov eax, dword [BytesBuffer]
        mov ebx, dword [count]
        dec ebx
        mov dword [ph_vaddr_array + ebx * 4], eax
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline
       ; print p_paddr
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, p_paddr_msg
        mov rdx, p_paddr_msg_len
        call print

        mov eax, dword [BytesBuffer]
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline

       ; print p_filesz
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, p_filesz_msg
        mov rdx, p_filesz_msg_len
        call print

        mov eax, dword [BytesBuffer]
        ; mov ebx, dword [count]
        ; dec ebx
        ; mov ecx, dword [ph_vaddr_array + ebx * 4]
        ; add eax, ecx
        ; mov dword [ph_vaddr_plus_size_array + ebx * 4], eax
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline

       ; print p_memsz
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, p_memsz_msg
        mov rdx, p_memsz_msg_len
        call print

        mov eax, dword [BytesBuffer]
        mov ebx, dword [count]
        dec ebx
        mov ecx, dword [ph_vaddr_array + ebx * 4]
        add eax, ecx
        mov dword [ph_vaddr_plus_size_array + ebx * 4], eax
        mov eax, dword [BytesBuffer]
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline

        ; print p_flags
        ; get p_flags if 32bit
        mov edx, dword [elf_arch]
        and edx, 1
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h
        
        cmp dword [elf_arch], 0x1
        jne .not_32
        movzx eax, word [BytesBuffer]
        mov [p_flags], eax
        .not_32:

        xor ecx, ecx
        push rcx
    .loop_p_flags:
        pop rcx
        movzx eax, word [p_flags_value_list + ecx * 4]
        push rcx
        cmp dword [p_flags], eax 
        je .found_p_flags
        pop rcx
        inc ecx
        push rcx
        cmp ecx, 6
        je .found_p_flags
        jmp .loop_p_flags
        .found_p_flags:
            mov rsi, [p_flags_msg + ecx * 8]
            mov rdx, p_flags_msg_len
            call print

        ; print p_align
        mov edx, dword [elf_arch]
        lea edx, [edx * 4]
        mov eax, 3
        mov ebx, eax
        mov ecx, BytesBuffer
        int 80h

        mov rsi, p_align_msg
        mov rdx, p_align_msg_len
        call print

        mov eax, dword [BytesBuffer]
        lea edi, [tmp_string]
        mov ecx, 4
        call print_string
        call newline

        jmp .loop_p_print
    .done_p_print:

;; Section to Segment mapping

    mov rsi, sec2seg_msg
    mov rdx, sec2seg_msg_len
    call print

    mov dword [count], 0h
    .loop_segment_print:

        mov eax, dword [elf_phnum]
        ;dec eax
        cmp dword [count], eax
        je .done

    ;   print each segment
        mov eax, dword [count]
        lea rsi, [tmp_string]
        call itoa
		
        mov rsi, rax
        mov rdx, rdi
        call print
	
        call backspace
        call backspace
        call backspace
        call backspace

        mov dword [count_2], 0h
        .each_segment_print:
            mov eax, dword [elf_shnum]
            cmp dword [count_2], eax
            je .next_segment
            mov edx, dword [count_2]
            mov ebx, dword [sh_vaddr_array + edx * 4]
            cmp ebx, 0h
            je .next_section
            mov edx, dword [count]
            mov eax, dword [ph_vaddr_array + edx * 4]
            cmp ebx, eax
            jl .next_section
            mov edx, dword [count_2]
            mov ebx, dword [sh_vaddr_plus_size_array + edx * 4]
            mov edx, dword [count]
            mov eax, dword [ph_vaddr_plus_size_array + edx * 4]
            cmp ebx, eax
            jg .next_section
            movzx eax, word [count_2]
            mov ecx, dword [sh_name_offset_array + eax * 4]
            call print_name_in_Section_Header
            call backspace
            jmp .next_section
        .next_section:
            add dword [count_2], 1h
            jmp .each_segment_print
        .next_segment:
        add dword [count], 1h
        mov dword [count_2], 0h
        call newline
        jmp .loop_segment_print

.done:
    mov 	rax, 3                  ; sys_close
    mov 	rdi, [handle]
	syscall

    call exit                       ; exit

