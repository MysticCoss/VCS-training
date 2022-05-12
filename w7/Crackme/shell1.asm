push    ebp
mov     ebp, esp
push    ecx
mov     eax, [ebp+8]
movsx   ecx, byte ptr [eax]
and     ecx, 80000001h
jns     short loc_B00017
dec     ecx
or      ecx, 0FFFFFFFEh
inc     ecx

loc_B00017:                             ; CODE XREF: debug040:00B00010↑j
mov     [ebp-1], cl
movzx   edx, byte ptr [ebp-1]
test    edx, edx
jnz     short loc_B0003B
mov     eax, [ebp+8]
movsx   ecx, byte ptr [eax]
xor     ecx, 20h
mov     edx, [ebp+0Ch]
movzx   eax, byte ptr [edx]
cmp     ecx, eax
jnz     short loc_B0003B
mov     al, 1
jmp     short loc_B0005D
; ---------------------------------------------------------------------------
jmp     short loc_B0005B
; ---------------------------------------------------------------------------

loc_B0003B:                             ; CODE XREF: debug040:00B00020↑j
                                        ; debug040:00B00033↑j
movzx   ecx, byte ptr [ebp-1]
cmp     ecx, 1
jnz     short loc_B0005B
mov     edx, [ebp+8]
movsx   eax, byte ptr [edx]
xor     eax, 52h
mov     ecx, [ebp+0Ch]
movzx   edx, byte ptr [ecx]
cmp     eax, edx
jnz     short loc_B0005B
mov     al, 1
jmp     short loc_B0005D
; ---------------------------------------------------------------------------

loc_B0005B:                             ; CODE XREF: debug040:00B00039↑j
                                        ; debug040:00B00042↑j ...
xor     al, al

loc_B0005D:                             ; CODE XREF: debug040:00B00037↑j
                                        ; debug040:00B00059↑j
mov     esp, ebp
pop     ebp
retn
; ---------------------------------------------------------------------------