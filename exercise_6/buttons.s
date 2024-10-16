BUTTON EQU &4
CHECK_BUTTONS
        PUSH {LR}               ;poll button
        MOV R0, #IO
        LDRB R0, [R0, #BUTTON]
        MOV R0, R0 LSR #6
        POP {PC}