    printY db "Digite um valor para y:", 0
    printWidth db "\nDigite um valor para a largura:", 0
    printHeight db "\nDigite um valor para a altura:", 0
    invoke WriteConsole, outputHandle, addr printInfo, 62, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr x, sizeof x, addr consoleCount, NULL
    
    invoke WriteConsole, outputHandle, addr printY, 24, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr y, sizeof y, addr consoleCount, NULL

    invoke WriteConsole, outputHandle, addr printWidth, 32, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr widthInput, sizeof widthInput, addr consoleCount, NULL
    
    invoke WriteConsole, outputHandle, addr printHeight, 31, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr heightInput, sizeof heightInput, addr consoleCount, NULL