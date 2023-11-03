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
    

