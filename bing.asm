; Recebe 3 parâmetros:
; - O endereço do array que contém os bytes da linha da imagem
; - A coordenada X inicial
; - A largura da censura a ser aplicada
censurar_pixels:
    ; Carrega o endereço do array que contém os bytes da linha da imagem em um registrador
    mov r0, [r0]
    ; Adiciona o valor da coordenada X inicial ao registrador que contém o endereço do array
    add r0, r0, r1
    ; Armazena o valor atual do registrador em outro registrador para uso posterior
    mov r2, r0
    ; Adiciona o valor da largura da censura ao registrador que contém o endereço do array
    add r0, r0, r3
    ; Preenche os pixels a partir do endereço armazenado no passo anterior até o endereço atual do registrador com três bytes 0
    mov r4, #0x00000000

loop:
    ; Verifica se a linha atual está dentro do conjunto que vai desde a linha da coordenada Y inicial até a linha “Y inicial” + altura
    cmp r5, #Y_inicial
    blt skip_line
    cmp r5, #Y_inicial_altura
    bgt skip_line

    ; Se estiver dentro do conjunto, preenche os pixels com três bytes 0
    mov r6, r2
    fill_pixels:
        cmp r6, r0
        bge done_filling_pixels
        strb r4, [r6], #1
        strb r4, [r6], #1
        strb r4, [r6], #1
        b fill_pixels

skip_line:
    ; Se não estiver dentro do conjunto, copia a linha de forma inalterada para o arquivo de destino
    ; Código para copiar a linha aqui

done_filling_pixels:
    bx lr

