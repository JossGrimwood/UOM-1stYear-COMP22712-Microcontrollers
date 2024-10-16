B MAIN
B . ;UNDEFINED
B SVC_CALL
B . ;PREFETCH
B . ;DATA
NOP
B IRQ_CALL
B . ;FIQ

IO  EQU &1000_0000

IRQ_PORT EQU &18
IRQ_EN_PORT EQU &1C
TIMER_MASK EQU 0B1111_1110

IRQ_CALL
        SUB LR,LR, #4
        PUSH {R0-R2,LR}

        MOV R0, #IO
        LDRB R1, [R0, #IRQ_PORT]

        BIC R2, R1, #TIMER_MASK
        CMP R2, #0
        BLNE TIMER_FUNCTION
        ANDNE R1, R1, #TIMER_MASK

        STRB R1, [R0, #IRQ_PORT]
        POP {R0-R2,PC}^

REG_STORE DEFW 0
SVC_CALL
        PUSH {LR}
        STR R0, REG_STORE           ; SAVE R0
        MRS R0, SPSR                ; GET SPSR
        PUSH {R0}                   ; PUSH SPSR      
        LDR R0, REG_STORE           ; RETRIEVE R0             
        LDR R14, [LR, #-4]          ; load previous instruction
        BIC R14, R14, #&FF000000    ; mask of bits 
        CMP R14, #MAX_SVC           ; check svc value is valid
        BHI SVC_UNKOWN  
        ADD R14, PC, R14, LSL #2    ; address jump table
        LDR PC, [R14, #0] 
MAX_SVC EQU 4
JUMP_TABLE  DEFW SVC_0   ;PRINT
            DEFW SVC_1   ;LCD COMMAND
            DEFW SVC_2   ;halt
            DEFW SVC_3   ;TIMER SET FUNC
            DEFW SVC_4   ;TIMER SET VAL
            DEFW SVC_5   ;TIMER DISABLE
            DEFW SVC_6   ;TIMER ENABLE
            DEFW SVC_7   ;TIMER INCREMENT
            DEFW SVC_8   ;BUTTONS
EXIT_SVC
        STR R0, REG_STORE           ; SAVE R0
        POP {R0}                    ; POP SPSR
        MSR SPSR, R0                ; RETURN SPSR    
        LDR R0, REG_STORE           ; RETRIEVE R0                  
        POP {LR}         ;return back to user code
        MOVS PC, LR

SVC_UNKOWN
    B .             ;SVC unknown
SVC_0               ;Print char
    BL PRINT_CHAR
    B EXIT_SVC
SVC_1               ;LCD command
    BL SETUP_COMMAND  
    B EXIT_SVC
SVC_2               ;Halt
    HALT EQU &20
    MOV R0, #IO
    MOV R1, #&FF
    STR R1, [R0, #HALT] ;halt
SVC_3               ;TIMER SET FUNC
    BL SET_TIMER_FUNCTION  
    B EXIT_SVC
SVC_4               ;TIMER SET VAL
    BL SET_TIMER_VAL  
    B EXIT_SVC
SVC_5               ;TIMER DISABLE
    BL DISABLE_TIMER  
    B EXIT_SVC
SVC_6               ;TIMER ENABLE
    BL ENABLE_TIMER  
    B EXIT_SVC
SVC_7               ;TIMER INCREMENT
    BL INCREMENT_TIMER_VAL  
    B EXIT_SVC
SVC_8               ;BUTTON
    BL CHECK_BUTTONS  
    B EXIT_SVC

MODE_CLEAR EQU &1F
SYSTEM EQU &1F
SUPERVISOR EQU &13
INTERUPT EQU &12
MAIN 
        ADRL SP, SVC_STACK   ; Setup supervisor stack
        
        MRS R0, CPSR                 ; switch to system
        BIC R0, R0, #MODE_CLEAR      ; clear mode
        ORR R0, R0, #SYSTEM          ; set system mode
        MSR CPSR_c, R0               ; APPLY MODE

        ADRL SP, USR_STACK   ; Setup supervisor stack

        MRS R0, CPSR                 ; switch to IRQ
        BIC R0, R0, #MODE_CLEAR      ; clear mode
        ORR R0, R0, #INTERUPT        ; set IRQ mode
        MSR CPSR_c, R0               ; APPLY MODE

        ADRL SP, IRQ_STACK   ; Setup supervisor stack

        MOV R0, #IO
        MOV R2, #0
        STRB R2, [R0, #IRQ_EN_PORT]


        MOV R14, #&D0       ;USERMODE
        MSR SPSR, R14
        ADR R14, USR_CODE
        MOVS PC, R14        ;move to user code

USR_CODE
INCLUDE users.s
ALIGN
; libraries
INCLUDE print.s 
INCLUDE timer.s 
INCLUDE buttons.s 

DEFS 80
USR_STACK
DEFS 80
SVC_STACK
DEFS 80
IRQ_STACK