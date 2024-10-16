B MAIN
INCLUDE print.s

STRING DEFB "Hello World\nGoodbye World\0"
align
MAIN    
        MOV R1, #1              ;fill registers to test preservation
        MOV R2, #2
        MOV R3, #3
        MOV R4, #4
        MOV R5, #5
        MOV R6, #6
        ADR SP, STACK           ;setup stack
        ADR R0, STRING          ;setup address of stored string
        BL Clear                ;clear display
        BL PrintString          ;print the string on 2 line

        MOV R0, #12             ;move to position 12 on line 1
        BL MoveToLine1
        MOV R0, #&48            ;write character to line should be obvious on display
        BL PrintChar
        
        MOV R0, #6              ;move to position 6 on line 2
        BL MoveToLine2
        MOV R0, #'E'            ; rewrite e as E
        BL PrintChar
        B .                     ; stop

DEFS 200
STACK 