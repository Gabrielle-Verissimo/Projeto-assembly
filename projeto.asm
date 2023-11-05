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
    inputHandle dd 0
    outputHandle dd 0
    consoleCount dd 0
    fileName db 20 dup(0)
    filePrint db "Arquivo de entrada:", 0
    printInfo db "Digite um valor para x, y, largura e altura respectivamente:", 0
    readHandle dd 0
    fileHandle dd 0
    eighteenBytes db 18 dup(0)
    widthImg dd 0
    finalHeader db 32 dup(0)
    lineImg db 6480 dup(0)
    readCount dd 0
    writeHandle dd 0
    newFile db 20 dup(0)
    newFilePrint db "Nome do arquivo novo:", 0 
    writeCount dd 0
    widthInput db 4 dup(0)
    heightInput db 5 dup(0)
    widthDD dd 0
    heightDD dd 0
    x db 4 dup(0)
    y db 4 dup(0)
    coordinateX dd 0
    coordinateY dd 0
    sizeLineImg dd 0
    widthTotal dd 0
    heightCopy dd 0
    heightTotal dd 0
.code
    ;Funcao de censura
    censor:
        ; Verificar se atingimos o fim da largura
        push ebp
        mov ebp, esp
        
        mov eax, DWORD PTR [ebp+16]

        paint:
            ; Preencher com a cor preta (0, 0, 0) no padrao RGB
            cmp  DWORD PTR [ebp+12], eax
            je return_func
            mov ebx, [ebp+8]
            mov ecx, DWORD PTR [ebp+12]
            mov BYTE PTR [ebx][ecx], 0
            mov BYTE PTR [ebx][ecx+1], 0
            mov BYTE PTR [ebx][ecx+2], 0
            ; Avancar para o proximo pixel
            add DWORD PTR [ebp+12], 3
            jmp paint

        return_func:
        mov esp, ebp
        pop ebp
        ret 12
        
start:
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ;;; Pede para inserir o nome do arquivo de entrada ;;;
    invoke WriteConsole, outputHandle, addr filePrint, 20, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr fileName, sizeof fileName, addr consoleCount, NULL

    invoke WriteConsole, outputHandle, addr printInfo, 61, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr x, sizeof x, addr consoleCount, NULL
    mov esi, offset x ; Armazenar apontador da string em esi
clear_x:
    mov al, [esi] ; Mover caracter atual para al
    inc esi ; Apontar para o proximo caracter
    cmp al, 48 ; Verificar se menor que ASCII 48 - FINALIZAR
    jl convert_x
    cmp al, 58 ; Verificar se menor que ASCII 58 - CONTINUAR
    jl clear_x
; Converte x de string para inteiro
convert_x:
    dec esi ; Apontar para caracter anterior
    xor al, al ; 0 ou NULL
    mov [esi], al ; Inserir NULL logo apos o termino do numero
    invoke atodw, addr x
    mov coordinateX, eax
   
    invoke ReadConsole, inputHandle, addr y, sizeof y, addr consoleCount, NULL
    mov esi, offset y
clear_y:
    mov al, [esi]
    inc esi
    cmp al, 48
    jl convert_y
    cmp al, 58
    jl clear_y
; Converte y de string para inteiro
convert_y:
    dec esi
    xor al, al
    mov [esi], al
    invoke atodw, addr y
    mov coordinateY, eax

    invoke ReadConsole, inputHandle, addr widthInput, sizeof widthInput, addr consoleCount, NULL
    mov esi, offset widthInput
clear_width:
    mov al, [esi]
    inc esi
    cmp al, 48
    jl convert_width
    cmp al, 58
    jl clear_width
; Converte width de string para inteiro
convert_width:
    dec esi
    xor al, al
    mov [esi], al
    invoke atodw, addr widthInput
    mov widthDD, eax

    invoke ReadConsole, inputHandle, addr heightInput, sizeof heightInput, addr consoleCount, NULL
    mov esi, offset heightInput
clear_height:
    mov al, [esi]
    inc esi
    cmp al, 48
    jl convert_height
    cmp al, 58
    jl clear_height
; Converte height de string para inteiro
convert_height:
    dec esi
    xor al, al
    mov [esi], al
    invoke atodw, addr heightInput
    mov heightDD, eax
    
    mov esi, offset fileName
clear_file:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne clear_file
    dec esi
    xor al, al
    mov [esi], al

    ;;; Abre o arquivo ;;;
    invoke CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileHandle, eax
    invoke ReadFile, fileHandle, addr eighteenBytes, 18, addr readCount, NULL
    invoke ReadFile, fileHandle, addr widthImg, 4, addr readCount, NULL
    invoke ReadFile, fileHandle, addr finalHeader, 32, addr readCount, NULL
    
    ;;; Pede para inserir o nome do novo arquivo ;;;
    invoke WriteConsole, outputHandle, addr newFilePrint, 22, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr newFile, sizeof newFile, addr consoleCount, NULL
 

mov esi, offset newFile
clear_new_file:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne clear_new_file
    dec esi
    xor al, al
    mov [esi], al


    invoke CreateFile, addr newFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ; cria um novo arquivo para escrita
    mov writeHandle, eax ; ponteiro para novo arquivo

    ;;; Le os primeiros 18 bytes, depois o tamanho da largura e por ultimo os 32 bytes restante do cabe?alho ;;; 
    invoke WriteFile, writeHandle, addr eighteenBytes, 18, addr writeCount, NULL
    invoke WriteFile, writeHandle, addr widthImg, 4, addr writeCount, NULL
    invoke WriteFile, writeHandle, addr finalHeader, 32, addr writeCount, NULL
    
    ;multiplica o widht por 3 (pixel equivalente a 3 bytes)
    mov eax, 3
    mul widthImg
    mov sizeLineImg, eax
    
    ;soma width com coordenada x e multiplica por 3
    mov ebx, widthDD
    add ebx, coordinateX
    mov widthTotal, ebx
    mov eax, 3
    mul widthTotal
    mov widthTotal, eax
    
    ;soma altura com coordenada y
    mov edx, heightDD
    add edx, coordinateY
    mov heightTotal, edx

    ;faz uma copia da coordenada y para a variavel heighcopy
    mov ecx, coordinateY
    mov heightCopy, ecx
    
    ;multiplica coordenada x por 3
    mov eax, 3
    mul coordinateX
    mov coordinateX, eax
   
;ler as linhas que não serão alteradas até encontrar a que será alterada e então desviará para o begin_censor
read_write_loop:
    cmp coordinateY, 0
    je begin_censor

    ;Ler uma linha da imagem
    invoke ReadFile, fileHandle, addr lineImg, sizeLineImg, addr readCount, NULL
    invoke WriteFile, writeHandle, addr lineImg, sizeLineImg, addr writeCount, NULL
    sub coordinateY, 1
    jmp read_write_loop

;loop onde chama a funcao de censura até que chegue na altura total que foi informada
begin_censor:
    ;Ler uma linha da imagem
    invoke ReadFile, fileHandle, addr lineImg, sizeLineImg, addr readCount, NULL
    mov edx, heightTotal
    cmp heightCopy, edx
    je read_final
    push widthTotal
    push coordinateX 
    push offset lineImg
    call censor
    invoke WriteFile, writeHandle, addr lineImg, sizeLineImg, addr writeCount, NULL
    add heightCopy, 1
    jmp begin_censor

;ler as linhas que sobraram sem alteracao
read_final:
    cmp readCount, 0
    je exit_program
    invoke ReadFile, fileHandle, addr lineImg, sizeLineImg, addr readCount, NULL
    invoke WriteFile, writeHandle, addr lineImg, sizeLineImg, addr writeCount, NULL
    jmp read_final

exit_program:
    invoke CloseHandle, fileHandle
    invoke CloseHandle, writeHandle
    invoke ExitProcess, 0
end start