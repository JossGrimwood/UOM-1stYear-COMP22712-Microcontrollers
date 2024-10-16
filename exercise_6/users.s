        ADR R0, INCREMENT_TIME
        SVC 3
        MOV R0, #0      ;INITIALIZE VALUES 
        SVC 4
        BL Clear
        SVC 6
        B .
        
        
        
;INTERUPT FUNCTIONS
INCREMENT_TIME
        PUSH {R0-R1,LR}
        LDR R1, VAL
        ADD R1, R1, #1
        STR R1, VAL

        MOV R0, #100        ;INCREMENT TRIGGER VALUE
        SVC 7

        MOV R0, R1
        BL DISPLAY
        POP {R0-R1,LR}

DISPLAY
        PUSH {R0-R4,LR}

        BL PrintTime    ;PRINT TIME
        
        LDR R3, BUTTON 
        ;TO DO CHECK BUTTONS
        SVC 8

        BIC R4, R0, #0B01       ;CHECK BOTTOM BUTTON
        CMP R4, #0
        BGT PAUSE               ;PAUSE IF PRESSED
        ENDPAUSE

        BIC R4, R0, #0B10       ;CHECK TOP BUUTON
        CMP R4, #0              
        ADDGT R3, R3, #1        ;INCRIMENT IF PRESSED
        MOVEQ R3, #0            ;REST IF NOT PRESSED

        CMP R3, #10             ;IF HELD FOR 1 SECOND
        MOVGT R0, #0            ;RESET TIME
        STRGE R0, VAL
        MOVGT R3, #0            ;RESET COUNT OF BUTTON HOLD
        
        STR R3, BUTTON 
        POP{R0-R4,PC}

PAUSE 
        SVC 8                   ;POLL BUTTON
        BIC R4, R0, #0B10       ;CHECK TOP BUTTON
        CMP R4, #0
        BGT ENDPAUSE            ;UNPAUSE IF PRESSED
        B PAUSE

VAL DEFW 0
BUTTON DEFW 0

align