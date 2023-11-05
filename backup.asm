    printY db "Digite um valor para y:", 0
    printWidth db "Digite um valor para a largura:", 0
    printHeight db "Digite um valor para a altura:", 0
    invoke WriteConsole, outputHandle, addr printInfo, 62, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr x, sizeof x, addr consoleCount, NULL
    
    invoke WriteConsole, outputHandle, addr printY, 24, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr y, sizeof y, addr consoleCount, NULL

    invoke WriteConsole, outputHandle, addr printWidth, 32, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr widthInput, sizeof widthInput, addr consoleCount, NULL
    
    invoke WriteConsole, outputHandle, addr printHeight, 31, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr heightInput, sizeof heightInput, addr consoleCount, NULL


    ;soma width com coordenada x e multiplica por 3
    ;mov ebx, widthDD
    ;add ebx, coordinateX
    ;mov widthTotal, ebx
    ;mov eax, 3
    ;mul widthTotal
    ;mov widthTotal, eax

    ;multiplica coordenada x por 3
    ;mov eax, 3
    ;mul coordinateX
    ;mov coordinateX, eax