
        MOV R1, #1
        MOV R2, #2
        MOV R3, #3
        MOV R4, #4
        MOV R5, #5
        MOV R6, #6
        ADR R0, STRING
        BL Clear
        BL PrintString

        MOV R0, #12
        BL MoveToLine1
        MOV R0, #&48
        BL PrintChar
        
        MOV R0, #6
        BL MoveToLine2
        MOV R0, #'E'
        BL PrintChar
        SVC 2
    STRING DEFB "Hello World\nGoodbye World\0"
align