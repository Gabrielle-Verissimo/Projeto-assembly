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
    printInfo db "Digite um valor para x, y, largura e altura respectivamente:", 0
    readHandle dd 0
    fileHandle dd 0
    headerBuffer db 54 dup(0)
    eighteenBytes db 18 dup(0)
    widthImg dd 0
    finalHeader db 32 dup(0)
    lineImg db 6480 dup(0)
    readCount dd 0
    writeHandle dd 0
    newFile db 20 dup(0)
    newFilePrint db "Nome do arquivo novo:", 0 
    writeCount dd 0
    widthInput dd 0
    heightInput dd 0
    x dd 0
    y dd 0
    value dd 0
    aux dd 0
    widthFinal dd 0
    countY dd 0
    countX dd 0

.code
    ;censor:
        
start:
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ;;; Pede para inserir o nome do arquivo de entrada ;;;
    invoke WriteConsole, outputHandle, addr filePrint, 20, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr fileName, sizeof fileName, addr consoleCount, NULL

    ;;; Pede a entrada do x,y, width e heigth
    invoke WriteConsole, outputHandle, addr printInfo, 61, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr x, sizeof x, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr y, sizeof y, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr widthInput, sizeof widthInput, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr heightInput, sizeof heightInput, addr consoleCount, NULL
    
    mov esi, offset fileName ; Armazenar apontador da string em esi
proximo1:
    mov al, [esi] ; Mover caractere atual para al
    inc esi ; Apontar para o proximo caractere
    cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo1
    dec esi ; Apontar para caractere anterior
    xor al, al ; ASCII 0
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

;;; Abre o arquivo ;;;
    invoke CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileHandle, eax
    invoke ReadFile, fileHandle, addr eighteenBytes, 18, addr readCount, NULL
    invoke ReadFile, fileHandle, addr widthImg, 4, addr readCount, NULL
    invoke ReadFile, fileHandle, addr finalHeader, 32, addr readCount, NULL

    ;;; Pede para inserir o nome do novo arquivo ;;;
    invoke WriteConsole, outputHandle, addr newFilePrint, 22, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr newFile, sizeof newFile, addr consoleCount, NULL
 

mov esi, offset newFile ; Armazenar apontador da string em esi
proximo2:
    mov al, [esi] ; Mover caractere atual para al
    inc esi ; Apontar para o proximo caractere
    cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo2
    dec esi ; Apontar para caractere anterior
    xor al, al ; ASCII 0
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR


    invoke CreateFile, addr newFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ; cria um novo arquivo para escrita
    mov writeHandle, eax ; ponteiro para novo arquivo
    ;;; Le os primeiros 18 bytes, depois o tamanho da largura e por ultimo os 32 bytes restante do cabe?alho ;;; 
    invoke WriteFile, writeHandle, addr eighteenBytes, 18, addr writeCount, NULL
    invoke WriteFile, writeHandle, addr widthImg, 4, addr writeCount, NULL
    invoke WriteFile, writeHandle, addr finalHeader, 32, addr writeCount, NULL
    
    mov eax, 3
    mul widthImg
    mov aux, eax
    mov countY, 0
    mov countX, 750
    ;invoke WriteConsole, outputHandle, addr x, 4, addr consoleCount, NULL
    ;invoke WriteConsole, outputHandle, addr y, 4, addr consoleCount, NULL
    ;invoke WriteConsole, outputHandle, addr widthInput, 4, addr consoleCount, NULL
    ;invoke WriteConsole, outputHandle, addr heightInput, 4, addr consoleCount, NULL
    ;invoke WriteConsole, outputHandle, addr countY, 4, addr consoleCount, NULL

read_write_loop:
    ; Ler uma linha da imagem
    invoke ReadFile, fileHandle, addr lineImg, aux, addr readCount, NULL
    cmp countY, 310
    je censor
    invoke WriteFile, writeHandle, addr lineImg, aux, addr writeCount, NULL
    add countY, 1
    jmp read_write_loop

write_file:
    ; Escrever a linha lida no arquivo de destino
    invoke WriteFile, writeHandle, addr lineImg, aux, addr writeCount, NULL
    jmp label_name

censor:
    cmp countX, 1440
    je write_file
    mov ebx, offset lineImg
    mov al, 0
    mov edx, countX
    ;mov edx, ecx
    mov [ebx][edx], al
    ;mov [ebx][edx+1], al
    ;mov [ebx][edx+2], al
    add countX, 1
    jmp censor

label_name:
    cmp countY, 340
    je read_final
    add countY, 1
    mov countX, 750
    invoke ReadFile, fileHandle, addr lineImg, aux, addr readCount, NULL
    jmp censor

read_final:
    cmp readCount, 0
    je exit_program
    ;invoke WriteConsole, outputHandle, addr fileName, sizeof fileName, addr consoleCount, NULL
    invoke ReadFile, fileHandle, addr lineImg, aux, addr readCount, NULL
    invoke WriteFile, writeHandle, addr lineImg, aux, addr writeCount, NULL
    jmp read_final

exit_program:
   
    invoke CloseHandle, fileHandle
    invoke CloseHandle, writeHandle
    invoke ExitProcess, 0
end start