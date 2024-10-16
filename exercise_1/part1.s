IO  EQU 0x1000_0000
STATE0 EQU 0B0100_0100
STATE1 EQU 0B0100_0110
STATE2 EQU 0B0100_0001
STATE3 EQU 0B0100_0010
STATE4 EQU 0B0100_0100
STATE5 EQU 0B0110_0100
STATE6 EQU 0B0001_0100
STATE7 EQU 0B0010_0100
SMALL_DELAY EQU &30000
LARGE_DELAY EQU &80000
MAIN
        MOV r12, #IO
        MOV r0, #STATE0
        MOV r1, #STATE1
        MOV r2, #STATE2
        MOV r3, #STATE3
        MOV r4, #STATE4
        MOV r5, #STATE5
        MOV r6, #STATE6
        MOV r7, #STATE7

TRAFFIC_LOOP
        STRB r0, [R12]

        MOV R8, #SMALL_DELAY
        BL DELAY

        STRB r1, [R12]
        
        MOV R8, #SMALL_DELAY
        BL DELAY

        STRB r2, [R12]

        MOV R8, #LARGE_DELAY
        BL DELAY
        
        STRB r3, [R12]

        MOV R8, #SMALL_DELAY
        BL DELAY

        STRB r4, [R12]

        MOV R8, #SMALL_DELAY
        BL DELAY

        STRB r5, [R12]

        MOV R8, #SMALL_DELAY
        BL DELAY

        STRB r6, [R12]

        MOV R8, #LARGE_DELAY
        BL DELAY

        STRB r7, [R12]

        MOV R8, #SMALL_DELAY
        BL DELAY

        B TRAFFIC_LOOP

DELAY
        SUB R8, R8, #1
        CMP R8, #0
        BGT DELAY
    MOV PC, LR