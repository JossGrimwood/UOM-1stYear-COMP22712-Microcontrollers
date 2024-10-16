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
;       PrintTime - R0 int value of time in 1/10ths second



; memory loactions
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


; *********** Following for printing bcd time format to LCD
PrintTime
        PUSH {R1-R8, LR}                ;START clear function
        
        BL bcd_time_convert

        MOV R1, R0
        MOV R0, #0
        BL MoveToLine1

        MOV R0, R1, LSR #24     ;HOURS PRINT
        BIC R0, R0, #&FFFFFF0
        ADD R0, R0, #48
        svc 0

        MOV R0, R1, LSR #20
        BIC R0, R0, #&FFFFFF0
        ADD R0, R0, #48
        SVC 0

        MOV R0, #':'
        SVC 0

        MOV R0, R1, LSR #16     ;MINUTES PRINT
        BIC R0, R0, #&FFFFFF0
        ADD R0, R0, #48
        svc 0

        MOV R0, R1, LSR #12
        BIC R0, R0, #&FFFFFF0
        ADD R0, R0, #48
        SVC 0

        MOV R0, #':'
        SVC 0

        MOV R0, R1, LSR #8      ;SECONDS PRINT
        BIC R0, R0, #&FFFFFF0
        ADD R0, R0, #48
        SVC 0

        MOV R0, R1, LSR #4
        BIC R0, R0, #&FFFFFF0
        ADD R0, R0, #48
        SVC 0


        POP {R1-R8, PC}


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




;-------------------------------------------------------------------------------

; Convert unsigned binary value in R0 into BCD representation, returned in R0
; Any overflowing digits are generated, but not retained or returned in this
;  version.
; Corrupts registers R1-R6, inclusive; also R14
; Does not require a stack

bcd_convert	PUSH {R1-R5,LR}			; Keep return address
						;  in case there is no stack
		adr	r4, dec_table		; Point at conversion table
		mov	r5, #0			; Zero accumulator
                B bcd_loop
bcd_time_convert
                PUSH {R1-R5,LR}			; Keep return address
						;  in case there is no stack
		adr	r4, time_table		; Point at conversion table
		mov	r5, #0			; Zero accumulator

bcd_loop	ldr	r1, [r4], #4		; Get next divisor, step pointer
		cmp	r1, #1			; Termination condition?
		beq	bcd_out			;  yes

		bl	divide			; R0 := R0/R1 (rem. R2)

		add	r5, r0, r5, lsl #4	; Accumulate result
		mov	r0, r2			; Recycle remainder
		b	bcd_loop		;

bcd_out		add	r0, r0, r5, lsl #4	; Accumulate result to output

		POP {R1-R5,PC}			; Return

dec_table	DCD	1000000000, 100000000, 10000000, 1000000
		DCD	100000, 10000, 1000, 100, 10, 1

time_table	DCD	360000, 36000, 6000, 600, 100, 10, 1

;-------------------------------------------------------------------------------

; 32-bit unsigned integer division R0/R1
; Returns quotient in R0 and remainder in R2
; R3 is corrupted (will be zero)
; Returns quotient FFFFFFFF in case of division by zero
; Does not require a stack

divide		mov	r2, #0			; AccH
		mov	r3, #32			; Number of bits in division
		adds	r0, r0, r0		; Shift dividend

divide1		adc	r2, r2, r2		; Shift AccH, carry into LSB
		cmp	r2, r1			; Will it go?
		subhs	r2, r2, r1		; If so, subtract
		adcs	r0, r0, r0		; Shift dividend & Acc. result
		sub	r3, r3, #1		; Loop count
		tst	r3, r3			; Leaves carry alone
		bne	divide1			; Repeat as required

		mov	pc, lr			; Return

;-------------------------------------------------------------------------------


