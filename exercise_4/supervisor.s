B MAIN
B . ;UNDEFINED
B SVC_CALL
B . ;PREFETCH
B . ;DATA
NOP
B . ;IRQ
B . ;FIQ


SVC_CALL
        PUSH {LR}                   
        LDR R14, [LR, #-4]          ; load previous instruction
        BIC R14, R14, #&FF000000    ; mask of bits 
        CMP R14, #MAX_SVC           ; check svc value is valid
        BHI SVC_UNKOWN  
        ADD R14, PC, R14, LSL #2    ; address jump table
        LDR PC, [R14, #0] 
MAX_SVC EQU 2
JUMP_TABLE  DEFW SVC_0   ;PRINT
            DEFW SVC_1   ;LCD COMMAND
            DEFW SVC_2   ;halt
EXIT_SVC                 
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
MODE_CLEAR EQU &1F
SYSTEM EQU &1F
SUPERVISOR EQU &13
MAIN 
        ADR SP, SVC_STACK   ; Setup supervisor stack
        
        MRS R0, CPSR                 ; switch to system
        BIC R0, R0, #MODE_CLEAR      ; clear mode
        ORR R0, R0, #SYSTEM          ; set system mode
        MSR CPSR_c, R0               ; APPLY MODE

        ADR SP, USR_STACK   ; Setup supervisor stack
        
        MRS R0, CPSR                 ; switch to SVC
        BIC R0, R0, #MODE_CLEAR      ; clear mode
        ORR R0, R0, #SUPERVISOR      ; set SVC mode
        MSR CPSR_c, R0               ; APPLY MODE

        MOV R14, #&D0       ;USERMODE
        MSR SPSR, R14
        ADR R14, USR_CODE
        MOVS PC, R14        ;move to user code

USR_CODE
INCLUDE users.s

; libraries
INCLUDE print.s 

DEFS 100
SVC_STACK
DEFS 100
USR_STACK