TIMER EQU &8
TIMER_COMP EQU &C

time_func DEFW 0
TIMER_FUNCTION
                LDR PC, time_func
SET_TIMER_FUNCTION
                STR R0, time_func
                MOV PC, LR 

SET_TIMER_VAL
                PUSH {R0-R1, LR}
                MOV R1, #IO
                STRB R0, [R1, #TIMER_COMP]
                POP {R0-R1, PC}

INCREMENT_TIMER_VAL
                PUSH {R0-R2, LR}
                MOV R1, #IO
                LDRB R2, [R1, #TIMER_COMP]
                ADD R0, R0, R2
                CMP R0, #255                 ;CHECK IF TOO LARGE
                SUBGT R0, R0, #256           ;WRAP AROUND TO LOW
                STRB R0, [R1, #TIMER_COMP]
                POP {R0-R2, PC}

TIMER_ENABLE_MASK EQU 0B0000_0001
ENABLE_TIMER
                PUSH {R0-R1, LR}
                MOV R0, #IO
                LDRB R1, [R0, #IRQ_EN_PORT]
                ORR R1, R1, #TIMER_ENABLE_MASK
                STRB R1, [R0, #IRQ_EN_PORT]
                POP {R0-R1, PC}

TIMER_DISABLE_MASK EQU 0B1111_1110
DISABLE_TIMER
                PUSH {R0-R1, LR}
                MOV R0, #IO
                LDRB R1, [R0, #IRQ_EN_PORT]
                AND R1, R1, #TIMER_DISABLE_MASK
                STRB R1, [R0, #IRQ_EN_PORT]
                POP {R0-R1, PC}