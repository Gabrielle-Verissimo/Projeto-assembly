;Nome: EMILLY EDUARDA CAROLINY SILVA
;Matricula: 20220166942
;Nome: GABRIELLE DA SILVA VERISSIMO
;Matricula: 20190096090
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
    printX db "Digite um valor para x:", 0
    printY db "Digite um valor para y:", 0
    printWidth db "Digite um valor para a largura:", 0
    printHeight db "Digite um valor para a altura:", 0
    widthImg dd 0
    finalHeader db 32 dup(0)
    lineImg db 6480 dup(0)
    readCount dd 0
    writeHandle dd 0
    newFile db 20 dup(0)
    newFilePrint db "Nome do arquivo novo:", 0 
    writeCount dd 0
    widthInput db 7 dup(0) ; recebe a entrada da largura
    heightInput db 7 dup(0) ; recebe a entrada da altura
    widthDD dd 0 ; armazena a entrada da largura convertida para dd
    heightDD dd 0 ; armazena a entrada da altura convertida para dd
    x db 7 dup(0) ; recebe a entrada da coordenada x 
    y db 7 dup(0) ; recebe a entrada da coordenada y
    coordinateX dd 0 ; armazena a entrada da coordenada x convertida para dd
    coordinateY dd 0 ; armazena a entrada da coordenada y convertida para dd
    sizeLineImg dd 0 ; armazena o tamanho de uma linha da imagem
    heightTotal dd 0 ; armazena a soma da coordenada y com a altura
    heightCopy dd 0 ; recebe uma copia da coordenada y
    
.code
    ;Funcao de censura
    censor:
        ; Verificar se atingimos o fim da largura
        push ebp
        mov ebp, esp
        sub esp, 4

        ; Soma widthDD com coordinateX e multiplica por 3 e armazena a largura total em ebp-4
        mov ebx, DWORD PTR [ebp+16]
        add ebx, DWORD PTR [ebp+12]
        mov DWORD PTR [ebp-4], ebx
        mov eax, 3
        mul DWORD PTR [ebp-4]
        mov DWORD PTR [ebp-4], eax

        ; Multiplica coordinateX por 3
        mov eax, 3
        mul DWORD PTR [ebp+12]
        mov DWORD PTR [ebp+12], eax

        mov eax, DWORD PTR [ebp-4] ; eax recebe a largura total
        
        paint:
            ; Preencher com a cor preta (0, 0, 0) no padrao RGB
            cmp DWORD PTR [ebp+12], eax
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

    invoke WriteConsole, outputHandle, addr printX, 24, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr x, sizeof x, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr printY, 24, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr y, sizeof y, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr printWidth, 32, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr widthInput, sizeof widthInput, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr printHeight, 31, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr heightInput, sizeof heightInput, addr consoleCount, NULL
    
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
    
    ;multiplica o widthImg por 3 (pixel equivalente a 3 bytes)
    mov eax, 3
    mul widthImg
    mov sizeLineImg, eax
    
    ;soma altura com coordenada y
    mov edx, heightDD
    add edx, coordinateY
    mov heightTotal, edx

    ;faz uma copia da coordenada y para a variavel heighcopy
    mov ecx, coordinateY
    mov heightCopy, ecx
   
;ler as linhas que nao serao alteradas ate encontrar a que sera� alterada e entao desviara para o begin_censor
read_write_loop:
    cmp coordinateY, 0
    je begin_censor
    invoke ReadFile, fileHandle, addr lineImg, sizeLineImg, addr readCount, NULL
    invoke WriteFile, writeHandle, addr lineImg, sizeLineImg, addr writeCount, NULL
    sub coordinateY, 1
    jmp read_write_loop

;loop onde chama a funcao de censura ate que chegue na altura total
begin_censor:
    invoke ReadFile, fileHandle, addr lineImg, sizeLineImg, addr readCount, NULL
    mov edx, heightTotal
    cmp heightCopy, edx
    je read_final
    push widthDD
    push coordinateX 
    push offset lineImg
    call censor
    invoke WriteFile, writeHandle, addr lineImg, sizeLineImg, addr writeCount, NULL
    add heightCopy, 1
    jmp begin_censor

;ler as linhas que sobraram sem alteracao
read_final:
    invoke WriteFile, writeHandle, addr lineImg, sizeLineImg, addr writeCount, NULL
    cmp readCount, 0
    je exit_program
    invoke ReadFile, fileHandle, addr lineImg, sizeLineImg, addr readCount, NULL
    jmp read_final

exit_program:
    invoke CloseHandle, fileHandle
    invoke CloseHandle, writeHandle
    invoke ExitProcess, 0
end start