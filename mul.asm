.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib
include \masm32\macros\macros.asm

.data
    list db 10 dup(0)
    y dd 0
    x db 0
    aux dd 0
.code
start:
    ;mov ebx, offset list
    ;mov cl, 2
    ;mov [ebx][3], cl 
    ;mov [ebx][3], 2
    ;mov al, list[3]
    ;printf("%d", al);

    mov y, 10
    mov x, 5
    mov al, x
    mov aux, eax
    mov ebx, y
    add aux, ebx
    printf("%d\n", aux)

    invoke ExitProcess, 0
end start