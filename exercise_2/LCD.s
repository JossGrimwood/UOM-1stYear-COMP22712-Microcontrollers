IO  EQU 0x1000_0000
CONTROL EQU &4
DATA EQU &0

PREP_CLEAR EQU 0B0011_0000
ENABLE_CLEAR EQU 0B0011_0001
END_CLEAR EQU 0B0011_0000
FORMFEAD EQU &01


PREP_READ EQU 0B0011_0100
ENABLE_READ EQU 0B0011_0101
END_READ EQU 0B0011_0100

BUSY_MASK EQU 0B1000_0000

PREP_WRITE EQU 0B0011_0010
ENABLE_WRITE EQU 0B0011_0011
END_WRITE EQU 0B0011_0010

B MAIN

DEFB &48, &65, &6C, &6C
DEFB &6F, &20, &57, &6F
DEFB &72, &6C, &64, &00

MAIN

        MOV R0, #IO
        MOV R3, #0
        
        MOV R5, #1
        BL WRITE
        MOV R5, #0

        LOOP
            LDRB R4, [R3]
            CMP R4, #0
            BEQ LOOP_END
            BL WRITE
            ADD R3, R3, #1
            B LOOP
        LOOP_END
        B .
WRITE
        MOV R1, #PREP_READ
        STRB R1, [R0, #CONTROL]
CHECK_BUSY
        MOV R1, #ENABLE_READ
        STRB R1, [R0, #CONTROL]
        LDRB R2, [R0, #DATA]
        MOV R1, #END_READ
        STRB R1, [R0, #CONTROL]
        MOV R1, #BUSY_MASK
        AND R2, R2, #BUSY_MASK
        CMP R2, #BUSY_MASK
        BEQ CHECK_BUSY
        CMP R5, #1
        BEQ CLEAR
WRITE_CHAR
        MOV R1, #PREP_WRITE
        STRB R1, [R0, #CONTROL]

        STRB R4, [R0, #DATA]

        MOV R1, #ENABLE_WRITE
        STRB R1, [R0, #CONTROL]
        MOV R1, #END_WRITE
        STRB R1, [R0, #CONTROL]
        MOV PC, LR
CLEAR
        MOV R1, #PREP_CLEAR
        STRB R1, [R0, #CONTROL]
        
        MOV R4, #FORMFEAD
        STRB R4, [R0, #DATA]

        MOV R1, #ENABLE_CLEAR
        STRB R1, [R0, #CONTROL]
        MOV R1, #END_CLEAR
        STRB R1, [R0, #CONTROL]
        MOV PC, LR