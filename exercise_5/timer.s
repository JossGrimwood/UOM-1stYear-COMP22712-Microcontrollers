TIMER EQU &8

GET_TIME
        MOV R0, #IO             ;poll timer
        LDR R0, [R0, #TIMER]
        MOV PC, LR