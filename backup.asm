read_write_loop:
    ; Ler uma linha da imagem
    invoke ReadFile, fileHandle, addr lineImg, aux, addr readCount, NULL
    cmp y, ecx
    je read_final 
    mov edx, BYTE PTR lineImg[y]
    censor:
        cmp z, ebx
        je continue
        mov eax, BYTE PTR edx[x + z]
        mov [eax+0], 0
        mov [eax+1], 0
        mov [eax+2], 0
        
        add z, 3
        jmp censor

    continue:
    ; Escrever a linha lida no arquivo de destino
    invoke WriteFile, writeHandle, addr lineImg, aux, addr writeCount, NULL
    add y, 3
    jmp read_write_loop

read_final:
    cmp readCount, 0
    je exit_program
    invoke ReadFile, fileHandle, addr lineImg, aux, addr readCount, NULL
    invoke WriteFile, writeHandle, addr lineImg, aux, addr writeCount, NULL
    jmp read_final
    
y_loop:
   ;invoke WriteConsole, outputHandle, addr fileName, sizeof fileName, addr consoleCount, NULL
   cmp y, 30
   je read_final
   invoke ReadFile, fileHandle, addr lineImg, aux, addr readCount, NULL
   mov ecx, y
   mov eax, offset lineImg
   mov ebx, [eax][ecx]
   ;printf("entrou aqui")
   jmp censor

censor:
    cmp x, 480
    je write_file  
    mov al, 0
    mov edx, x
    mov [ebx][edx], al
    ;mov byte ptr [ebx+edx], al
    add x, 1
    jmp censor
    
write_file:
    invoke WriteFile, writeHandle, addr lineImg, aux, addr writeCount, NULL
    sub y, 1
    jmp y_loop

