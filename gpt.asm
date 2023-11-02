; Função para censurar uma linha da imagem
censurar_linha:
    push ebp
    mov ebp, esp

    ; Parâmetros:
    ; ebp+8: Endereço do array que contém os bytes da linha da imagem
    ; ebp+12: Coordenada X inicial
    ; ebp+16: Largura da censura

    push esi
    push edi
    push ecx

    mov esi, [ebp + 8]  ; Endereço do array
    mov edi, [ebp + 12] ; Coordenada X inicial
    mov ecx, [ebp + 16] ; Largura da censura

    censura_loop:
        ; Verificar se atingimos o fim da largura
        cmp edi, ecx
        jae censura_done

        ; Preencher com a cor preta (0, 0, 0) no padrão RGB
        mov byte ptr [esi + edi], 0   ; Componente Azul (Blue)
        mov byte ptr [esi + edi + 1], 0 ; Componente Verde (Green)
        mov byte ptr [esi + edi + 2], 0 ; Componente Vermelho (Red)

        ; Avançar para o próximo pixel
        add edi, 3
        jmp censura_loop

    censura_done:
    pop ecx
    pop edi
    pop esi

    pop ebp
    ret



read_write_loop:
    ; Verificar se terminamos de processar todas as linhas
    cmp readCount, 0
    je end_loop

    ; Verificar se estamos dentro do intervalo de linhas que devem ser censuradas
    cmp edi, coordinateY     ; EDI contém a coordenada Y atual
    jl skip_censoring        ; Pule se estivermos acima do intervalo
    cmp edi, coordinateY + heightInput
    jge skip_censoring       ; Pule se estivermos abaixo do intervalo

    ; Se chegamos aqui, estamos dentro do intervalo, então censure a linha
    push edi                 ; Salve a coordenada Y atual
    push ecx                 ; Salve a largura atual
    push esi                 ; Salve o ponteiro para a linha
    call censurar_linha      ; Chame a função de censura
    pop esi                  ; Restaure o ponteiro para a linha
    pop ecx                  ; Restaure a largura
    pop edi                  ; Restaure a coordenada Y

    skip_censoring:

    ; Escrever a linha no arquivo de destino
    invoke WriteFile, writeHandle, addr lineImg, aux, addr writeCount, NULL

    jmp read_write_loop

;
