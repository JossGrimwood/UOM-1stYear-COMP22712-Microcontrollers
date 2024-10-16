
        MOV R1, #0      ;INITIALIZE VALUES 
        LDR R2, VAL     ;TIMER VALUE
        MOV R3, #0      ;COUNT OF BUTTON HOLD
        BL Clear
LOOP    
        SVC 3                   ;POLL BUTTONS
        CMP R0, R1              ;CHECK IF PASSED TRIGGER VALUE
        BLT LOOP                ;IF NOT LOOP
        BL DISPLAY              ;DISPLAY TIME AND CHECK BUTTONS
        ADD R2, R2, #1          ;IF PASSED INCREMENT TIME
        STR R2, VAL             ;SAVE TIME
        ADD R1, R1, #100        ;INCREMENT TRIGGER VALUE
        CMP R1, #255            ;CHECK IF TOO LARGE
        SUBGT R1, R1, #256      ;WRAP AROUND TO LOW
        BGT HOLD                ;HOLD IF WRAPPED AROUND
        B LOOP                  ;LOOP

HOLD    
        SVC 3           ;POLLS BUTTONS
        CMP R0, R1      ;CHECK IF TIMER HAS LOOPED BACK TO 0
        BLS LOOP        ;EXIT HOLD
        B HOLD

DISPLAY
        PUSH {LR}

        MOV R0, R2      ;MOVE TIME VALUE TO R0
        BL PrintTime    ;PRINT TIME
        
        ;TO DO CHECK BUTTONS
        SVC 4

        BIC R4, R0, #0B01       ;CHECK BOTTOM BUTTON
        CMP R4, #0
        BGT PAUSE               ;PAUSE IF PRESSED
        ENDPAUSE

        BIC R4, R0, #0B10       ;CHECK TOP BUUTON
        CMP R4, #0              
        ADDGT R3, R3, #1        ;INCRIMENT IF PRESSED
        MOVEQ R3, #0            ;REST IF NOT PRESSED

        CMP R3, #10             ;IF HELD FOR 1 SECOND
        MOVGT R2, #0            ;RESET TIME
        MOVGT R3, #0            ;RESET COUNT OF BUTTON HOLD
        
        POP{PC}

PAUSE 
        SVC 4                   ;POLL BUTTON
        BIC R4, R0, #0B10       ;CHECK TOP BUTTON
        CMP R4, #0
        BGT ENDPAUSE            ;UNPAUSE IF PRESSED
        B PAUSE

VAL DEFW 0


align