IO  EQU 0x1000_0000
BUTTON EQU &4
BUTTON_MASK EQU 0B1000_0000
STATE0 EQU 0B0001_0100
STATE1 EQU 0B0010_0100
STATE2 EQU 0B0100_0100
STATE3 EQU 0B0100_0001
STATE4 EQU 0B0100_0100
STATE5_1 EQU 0B0010_0100
STATE5_2 EQU 0B0000_0100
vSMALL_DELAY EQU &5000
SMALL_DELAY EQU &30000
LARGE_DELAY EQU &80000
MAIN
        MOV r12, #IO
        MOV r0, #STATE0
        MOV r1, #STATE1
        MOV r2, #STATE2
        MOV r3, #STATE3
        MOV r4, #STATE4
        MOV r5, #STATE5_1
        MOV r6, #STATE5_2

TRAFFIC_LOOP
        
        
                STRB r0, [R12]
                MOV R8, #LARGE_DELAY
                BL DELAY
        WAIT_ON_BUTTON
                MOV R9, #0
                MOV R8, #SMALL_DELAY
                BL DELAY

                CMP R9, #0
                BEQ WAIT_ON_BUTTON
        MOV R9, #0


        STRB r1, [R12]
        
        MOV R8, #SMALL_DELAY
        BL DELAY

        STRB r2, [R12]

        MOV R8, #SMALL_DELAY
        BL DELAY
        
        STRB r3, [R12]

        MOV R8, #LARGE_DELAY
        BL DELAY

        STRB r4, [R12]

        MOV R8, #SMALL_DELAY
        BL DELAY

        STRB r5, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        STRB r6, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        STRB r5, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        STRB r6, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        STRB r5, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        STRB r6, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        STRB r5, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        STRB r6, [R12]

        MOV R8, #vSMALL_DELAY
        BL DELAY

        B TRAFFIC_LOOP

DELAY
        SUB R8, R8, #1
        
        LDRB R7, [R12, #BUTTON]
        AND R7, R7, #BUTTON_MASK
        CMP R7, #BUTTON_MASK
        BNE SKIP_BUTTON_SET
                MOV R9, #1
        SKIP_BUTTON_SET
        
        CMP R8, #0
        BGT DELAY
    MOV PC, LR