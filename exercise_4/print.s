; Author: Jocelyn Grimwood
; Print functions
; **************************************
; DO NOT USE FUNCTIONS IN BLOCK CAPITALS
; **************************************
; pass paramters on r0
; usefull functions:
;       PrintString - pass pointer to array with null terminating character (accepts newline character)
;       PrintChar - pass char in register
;       MoveToLine1/2 - pass character position of respective line
;       NewLine - no input
;       Clear - no input



; memory loactions
IO  EQU &1000_0000
CONTROL EQU &4
DATA EQU &0

; Mask for LCD busy
BUSY_MASK EQU 0B1000_0000

NULL_CHAR EQU 0
NEW_LINE EQU &0A

; settings for writing commands to LCD
PREP_COMMAND EQU 0B0010_0000
ENABLE_COMMAND EQU 0B0010_0001
END_COMMAND EQU 0B0010_0000
FORMFEAD EQU &01
LINEFEAD EQU &C0
STARTPOS1 EQU &80
STARTPOS2 EQU &C0

; settings for read from LCD
PREP_READ EQU 0B0010_0100
ENABLE_READ EQU 0B0010_0101
END_READ EQU 0B0010_0100

; setting for write to LCD
PREP_WRITE EQU 0B0010_0010
ENABLE_WRITE EQU 0B0010_0011
END_WRITE EQU 0B0010_0010

PrintString ; write string indexed by r0
        PUSH {LR, R0-R1}            ; Push used registers
        MOV R1, R0

    NEXT_CHAR                       ; Loop through char array
        LDRB R0, [R1], #1           ; Load char and post increment address
        CMP R0, #NULL_CHAR          ; Check not end of array
        BEQ EOS                     ; If end branch to End Of String
        CMP R0, #NEW_LINE           ; Check for new line
        SVCNE 0                     ; Print loaded char 
        BLEQ NewLine                ; Write new line
        B NEXT_CHAR                 ; Loop for next char
    EOS
        POP {PC, R0-R1}             ; Pop registers back and update pc

PrintChar                           ;pass through for SVC 0 
        PUSH {LR}                   
        SVC 0
        POP {PC}

PRINT_CHAR   ; write single Char from r0
        PUSH {LR, R0-R3}            ; Push used registers
        MOV R1, #IO                 ; Setup location of IO
        BL CHECK_BUSY               ; Check LCD busy
        BL WRITE_CHAR               ; Write to LCD
        POP {PC, R0-R3}             ; Pop registers back and update pc


; *********** Folowing procedures for commands only
MoveToLine1
        PUSH {LR, R0}            ; Push used registers
        ADD R0, R0, #STARTPOS1   ; Setup offset
        SVC 1                    ; Run command
        POP {PC, R0}             ; Pop registers back and update pc
MoveToLine2
        PUSH {LR, R0}            ; Push used registers
        ADD R0, R0, #STARTPOS2   ; Setup offset
        SVC 1                    ; Run command
        POP {PC, R0}             ; Pop registers back and update pc
NewLine
        PUSH {LR, R0}            ; Push used registers
        MOV R0, #LINEFEAD        ; Set line feed character
        SVC 1                    ; Run command
        POP {PC, R0}             ; Pop registers back and update pc
Clear   
        PUSH {LR, R0}            ; Push used registers
        MOV R0, #FORMFEAD        ; Set clear character
        SVC 1                    ; Run command
        POP {PC, R0}             ; Pop registers back and update pc

; *********** Folowing procedures not for user
SETUP_COMMAND
        PUSH {LR, R0-R3}            
        MOV R1, #IO                 ; Setup location of IO
        BL CHECK_BUSY               ; Check LCD busy
        BL WRITE_COMMAND            ; Write to LCD
        POP {PC, R0-R3} 

CHECK_BUSY
        MOV R2, #PREP_READ          ; Set signal and R/W lines
        STRB R2, [R1, #CONTROL]
    BUSY  ; Read response from LCD and repeat untill free
        MOV R2, #ENABLE_READ        ; Enable read
        STRB R2, [R1, #CONTROL]
        LDRB R3, [R1, #DATA]        ; Read data
        MOV R2, #END_READ           ; Set enable low
        STRB R2, [R1, #CONTROL]     
        TST R3, #BUSY_MASK          ; Check LCD is not busy with mask
        BNE BUSY
        MOV PC, LR                  ; Exit method

WRITE_CHAR ; Write single Char in r0 to LCD
        MOV R2, #PREP_WRITE         ; Set signal and R/W lines
        STRB R2, [R1, #CONTROL]

        STRB R0, [R1, #DATA]        ; Write Char in advance of enable 

        MOV R2, #ENABLE_WRITE       ; Pulse enable to write char
        STRB R2, [R1, #CONTROL]
        MOV R2, #END_WRITE
        STRB R2, [R1, #CONTROL]
        MOV PC, LR                  ; Exit method

WRITE_COMMAND   
        MOV R2, #PREP_COMMAND       ; Set signal and R/W lines
        STRB R2, [R1, #CONTROL]
        
        STRB R0, [R1, #DATA]        ; Write command in advance of enable

        MOV R2, #ENABLE_COMMAND     ; Pulse enable to write Command
        STRB R2, [R1, #CONTROL]
        MOV R2, #END_COMMAND
        STRB R2, [R1, #CONTROL]
        MOV PC, LR                  ; Exit method
