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
    inputHandle dd 0 ; Variavel para armazenar o handle de entrada
    outputHandle dd 0 ; Variavel para armazenar o handle de saida
    consoleCount dd 0 ; Variavel para armazenar caracteres lidos/escritos na console
    fileName db 20 dup(0)
    filePrint db "Arquivo de entrada:", 0
    readHandle dd 0
    fileHandle dd 0
    headerBuffer db 54 dup(0)
    readCount dd 0
    writeHandle dd 0
    newFile db 20 dup(0)
    newFilePrint db "Nome do arquivo novo:", 0 
    writeCount dd 0
    threeBytes db 3 dup(0)
    color dd 0
    colorDD dd 0
    colorPrint db "Codigo da cor:", 0
    valueAdd dd 0
    value dd 0
    valueAddPrint db "Valor a ser somado:", 0
           
.code
 changeColor:
    push ebp
    mov ebp, esp
    sub esp, 8  
    xor ebx, ebx
    mov ebx, DWORD PTR [ebp+8] ; threeBytes
    xor eax, eax
    mov eax, DWORD PTR [ebp+12] ; cor
    mov cl, BYTE PTR [ebp+16] ; valor
    add ebx, eax ; endereço de threeBytes+0
    mov bl, BYTE PTR [ebx]
    add bl, cl
    jc numMax
    mov BYTE PTR [ebp-4], bl
    mov ebx, [ebp-4]
    jmp sair
    numMax:
        mov BYTE PTR [ebp-8], 255
        mov ebx, [ebp-8]
        jmp sair
    sair:
        mov esp, ebp
        pop ebp
        ret 12
start:
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    
    invoke WriteConsole, outputHandle, addr filePrint, 20, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr fileName, sizeof fileName, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newFilePrint, 22, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr newFile, sizeof newFile, addr consoleCount, NULL

    invoke WriteConsole, outputHandle, addr colorPrint, 15, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr color, sizeof color, addr consoleCount, NULL
    mov esi, offset color; Armazenar apontador da string em esi
proximoRead:
    mov al, [esi] ; Mover caracter atual para al
    inc esi ; Apontar para o proximo caracter
    cmp al, 48 ; Verificar se menor que ASCII 48 - FINALIZAR
    jl terminar
    cmp al, 58 ; Verificar se menor que ASCII 58 - CONTINUAR
    jl proximoRead
terminar:
    dec esi ; Apontar para caracter anterior
    xor al, al ; 0 ou NULL
    mov [esi], al ; Inserir NULL logo apos o termino do numero
    invoke atodw, addr color
    mov colorDD, eax



    invoke WriteConsole, outputHandle, addr valueAddPrint, 20, addr consoleCount, NULL 
    invoke ReadConsole, inputHandle, addr valueAdd, sizeof valueAdd, addr consoleCount, NULL
    mov esi, offset valueAdd; Armazenar apontador da string em esi
nextRead:
    mov al, [esi] ; Mover caracter atual para al
    inc esi ; Apontar para o proximo caracter
    cmp al, 48 ; Verificar se menor que ASCII 48 - FINALIZAR
    jl finish
    cmp al, 58 ; Verificar se menor que ASCII 58 - CONTINUAR
    jl nextRead
finish:
    dec esi ; Apontar para caracter anterior
    xor al, al ; 0 ou NULL
    mov [esi], al ; Inserir NULL logo apos o termino do numero
    invoke atodw, addr valueAdd
    mov value, eax

    mov esi, offset fileName ; Armazenar apontador da string em esi
 proximo:
    mov al, [esi] ; Mover caractere atual para al
    inc esi ; Apontar para o proximo caractere
    cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo
    dec esi ; Apontar para caractere anterior
    xor al, al ; ASCII 0
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
    
    invoke CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL ; abre arquivo para leitura
    mov fileHandle, eax ; ponteiro para arquivo
    invoke ReadFile, fileHandle, addr headerBuffer, 54, addr readCount, NULL ; lê o arquivo
   
     mov esi, offset newFile
 next:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne next
    dec esi
    xor al, al
    mov [esi], al
    
    invoke CreateFile, addr newFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ; cria um novo arquivo para escrita
    mov writeHandle, eax ; ponteiro para novo arquivo
    invoke WriteFile, writeHandle, addr headerBuffer, 54, addr writeCount, NULL ; escreve no novo arquivo
    
read:
    invoke ReadFile, fileHandle, addr threeBytes, 3, addr readCount, NULL
    ;invoke WriteConsole, outputHandle, addr valueAdd, 4, addr consoleCount, NULL
    cmp readCount, 0
    je final
    push value
    push colorDD
    push offset threeBytes
    call changeColor
    invoke WriteFile, writeHandle, addr threeBytes, 3, addr writeCount, NULL
    jmp read ; se der erro, trocar pra jne
final:
    invoke CloseHandle, fileHandle
    invoke CloseHandle, writeHandle
    invoke ExitProcess, 0
end start
