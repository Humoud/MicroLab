; STOPWATCH FORMAT HH2_HH1:MM2_MM1:SS2_SS1

TR0 BIT TCON.4
TF0 BIT TCON.5
TR1 BIT	TCON.6
TF1 BIT TCON.7
;-------------
R BIT P1.3
G BIT P1.0
;-------------
LDATA EQU P0
;------------
EN EQU P0.2
RS EQU P0.0
WR EQU P0.1
;------------
SS1 EQU 30H
SS2	EQU 31H
MM1 EQU	32H
MM2 EQU 33H
HH1	EQU	34H
HH2	EQU	35H
;------------------
		ORG 00H 
	LJMP INIT_INTER

		ORG 003H ; EX0 INT VECTOR ADDRESS
	LJMP EX0ISR

		ORG 00BH 
	LJMP T0ISR

		ORG 013H ; EX1 INT VECTOR ADDRESS
	LJMP EX1ISR

;--------INTERRUPT ROUTINES---
EX0ISR:				
; USER ENTERS NEW TIME
	LCALL PROMPT
	LCALL SETTIME
	RETI
EX1ISR:
	LCALL RESTART_LCD
	LCALL G_LED			; FLASH G LED 3 TIMES
	LJMP INIT_LCD			; NOW START COUNTING
	RETI
T0ISR:
	LCALL IntDELAY
	RETI


;------------------------------
		ORG 300H
INIT_INTER:
	MOV R6,#100
	MOV TH0,#0B7H
	MOV TL0,#0EEH
	SETB TR0
	MOV IE,#10000111B

INIT_LCD:	
	MOV TMOD,#000000001B
	
	MOV SS1,#0    ; SS
	MOV SS2,#0    ; SS
	MOV MM1,#0    ; MM
	MOV MM2,#0    ; MM
	MOV HH1,#0    ; HH
	MOV HH2,#0    ; HH

AGAIN:
	;--------------SEND HH---------
	ACALL LCD
	MOV A,HH2 ; MOVE THE HH SECOND
	ADD A,#30H	;HEXIFY
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	;---HH1
	MOV A,HH1 ; MOVE THE HH FIRST
	ADD A,#30H
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	
	MOV A,#':' ; PUT A COLOR 
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	;-------------- NOW SEND MM---------------
	MOV A,MM2 ; MOVE THE MM SECOND
	ADD A,#30H
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	
	MOV A,MM1 ; MOVE THE MM SECOND
	ADD A,#30H
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	
	MOV A,#':' ; MOVE THE : 
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	;------------------ NOW SEND SS --------------------------------
	
	MOV A,SS2 ; MOVE THE SS FIRST
	ADD A,#30H
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	
	MOV A,SS1 ; MOVE THE SS FIRST
	ADD A,#30H
	ACALL WCHR 
	ACALL LDELAY ; 4.1 msec required for this command
	
	;------ RESUME

	LJMP AGAIN

RESETT:
	MOV HH1,#0
	MOV HH2,#0
	MOV MM1,#0
	MOV MM2,#0
	MOV SS1,#0
	MOV SS2,#0
	RET
SETTIME:
	LCALL CLR_LCD
	LCALL KEYPAD
	MOV HH2,A
	
	
	
		


	RET
	
;---START OF SUB PROCESSES
IntDELAY:
	DJNZ R6,OUTT

	MOV C,R
	CPL C
	MOV R,C

	MOV R6,#100
	
		
;-------------- HANDLE THE HH2HH1:MM2MM1:SS2SS1
	
	MOV A,SS1
	CJNE A,#9,INC_SS1
	MOV SS1,#0			;MAKE ZER0
	
	MOV A,SS2
	CJNE A,#5,INC_SS2
	MOV SS2,#0			;MAKE ZERO
	
	MOV A,MM1
	CJNE A,#9,INC_MM1
	MOV MM1,#0			;MAKE ZERO
	
	MOV A,MM2
	CJNE A,#5,INC_MM2
	MOV MM2,#0
	
	MOV A,HH1
	CJNE A,#3,IsH1equal9
	SJMP IsH2equal2
	
IsH1equal9:
	CJNE A,#9,INC_HH1
	MOV HH1,#0
IsH2equal2:
	MOV A,HH2
	CJNE A,#2,INC_HH2

	LCALL RESETT
	LJMP OUTT	

INC_SS1:
	INC SS1
	LJMP OUTT
INC_SS2:
	INC SS2
	LJMP OUTT
INC_MM1:
	INC MM1
	LJMP OUTT
INC_MM2:
	INC MM2
	LJMP OUTT
INC_HH1:
	INC HH1
	LJMP OUTT
INC_HH2:
	INC HH2

	MOV TH0,#0B7H
	MOV TL0,#0EEH
OUTT:
	RET	

;------------LCD
START:
LCD:		
	ACALL INLCD ; Initialize LCD
	MOV A,#1000B ; Move cursor to 1st line – send high nibble
	ACALL CMD
	MOV A,#0000B ; send low nibble
	ACALL CMD
	ACALL LDELAY ; 4.1 msec required for this command

;-- LCD Initialization Procedure starts here -----
INLCD:
	MOV R7,#20
WAIT:
	ACALL LDELAY ; Step 1
	DJNZ R7,WAIT
	MOV P0,#00000111B ; Initialise 3 control signals=1
	
	MOV A,#0011B ; Step 2
	ACALL CMD
	ACALL LDELAY ; Step 3
	MOV A,#0011B ; Step 4
	ACALL CMD
	MOV A,#0011B ; Step 5
	ACALL CMD
	MOV A,#0010B ; Step 6
	ACALL CMD
	MOV A,#0010B ; Step 7 – send high nibble <FUNCTION SET?>
	ACALL CMD
	MOV A,#1000B ; send low nibble
	ACALL CMD
	MOV A,#0000B ; Step 8 – Turn off display – send high nibble
	ACALL CMD
	MOV A,#1000B ; send low nibble
	ACALL CMD
	MOV A,#0 ; Step 9 - Clear Display – send high nibble
	ACALL CMD
	MOV A,#0001B ; send low nibble
	ACALL CMD
	ACALL LDELAY ; 4.1 msec required for this command
	MOV A,#0000B ; Step 10 - Set cursor Move RIGHT - send high nibble
	ACALL CMD
	MOV A,#0110B ; send low nibble
	ACALL CMD
	MOV A,#0000B ; Step 11 – send high nibble
	ACALL CMD ; Turn ON Display, Cursor ON, Blink Cursor
	MOV A,#1111B ; send low nibble
	ACALL CMD
	RET
;--- End of LCD initialization -----
;----Routines:
G_LED:
	MOV R1,#3
MORE:	
	MOV C,G
	CPL C
	MOV G,C
	MOV R0,#50	
GREEN:
	DJNZ R0,GREEN	; HOLD LIGHT
	DJNZ R1,MORE	; FLASH AGAIN
	SETB G			; TURN OFF LED
	RET
RESTART_LCD:
	MOV HH2,#0	; RESET MEM LOCATIONS
	MOV HH1,#0
	MOV MM2,#0
	MOV MM1,#0
	MOV SS2,#0
	MOV SS1,#0
				
	MOV A,#1	; RESET DISPLAY
	LJMP CMD

PROMPT:		
	;PROMPT USER TO ENTER TIME		
	ACALL LINE2		; GO TO LINE 2
	ACALL LDELAY
	MOV DPTR,#PROMPT_MSG ; POINT TO MSG
	ACALL WSTR				; WRITE STRING TO LCD
	ACALL LDELAY
	ACALL GET_INPUT			; get input from keyboard
	RET
GET_INPUT:
	; CODE

;---- Subroutines to write commands in A to the LCD -------
LINE1:
	MOV A,#0
	SJMP CMD
LINE2:
	MOV A,#11000000B	; 40 HEX = LINE 2
	SJMP CMD
CMD:
	CLR RS 		; RS = 0 command write
	ACALL COMMON
	RET
;---- Subroutine to write A STRING character by character -------
WSTR:
	PUSH ACC 
CONT1: 
	CLR A
	MOVC A,@A+DPTR
	JZ EXIT1
	ACALL WCHR
	INC DPTR
	AJMP CONT1
EXIT1:
	POP ACC
	RET
	;---- Subroutine to write character in A to the LCD -------
WCHR:
	SETB RS ; RS = 1 data write
	MOV B,A
	SWAP A ; Move higher nibble to lower nibble
	ACALL COMMON ; write operation
	MOV A,B
	ACALL COMMON
	RET
;----- Common operation for CHAR write and COMMAND write
COMMON:
	CLR WR
	SWAP A ; Move Lower nibble to higher nibble
	ANL A,#11110000B
	ANL P0,#00000111B
	ORL P0,A
	SETB EN
	CLR EN
	ACALL LDELAY
	RET
;---- Subroutine to write A STRING character by character -------

;------------ ˜ 5.4 msec DELAY -------------------------------------------
LDELAY:
	PUSH 0
	PUSH 1 ; save register1.
	MOV R1,#20
CON4: 
	MOV R0,#250
	DJNZ R0,$
	DJNZ R1,CON4
	POP 1
	POP 0
	RET
;------------KEYPAD
KEYPAD:
	MOV P2,#11110000B			;make bits P2.4-P2.7 input (columns)
K1:
	MOV P2,#11110000B 
	MOV A,P2
	ANL A,#11110000B 
	CJNE A,#11110000B,K1
K2: 
	ACALL DELAY 
	MOV A,P2
	ANL A,#11110000B
	CJNE A,#11110000B,OVER SJMP K2
OVER:
	ACALL DELAY
	MOV A,P2
	ANL A,#11110000B
	CJNE A,#11110000B,OVER1 SJMP K2
OVER1:
	MOV P2,#11111110B
	MOV A,P2
	ANL A,#11110000B
	CJNE A,#11110000B,ROW_0
	MOV P2,#11111101B
	MOV A,P2
	ANL A,#11110000B
	CJNE A,#11110000B,ROW_1
	MOV P2,#11111011B
	MOV A,P2
	ANL A,#11110000B
	CJNE A,#11110000B,ROW_2
	MOV P2,#11110111B
	MOV A,P2
	ANL A,#11110000B
	CJNE A,#11110000B,ROW_3
	LJMP K2
ROW_0: 
	MOV DPTR,#KCODE0 
	SJMP FIND
ROW_1: 
	MOV DPTR,#KCODE1 
	SJMP FIND
ROW_2: 
	MOV DPTR,#KCODE2 
	SJMP FIND
ROW_3: 
	MOV DPTR,#KCODE3 
FIND:
	SWAP A
FIND1:
	RRC A
	JNC MATCH 
	INC DPTR 
	SJMP FIND1
	
MATCH: 
	CLR A
	MOVC A,@A+DPTR
	SUBB A,#30H
	RET

	; 30 msec delay 
DELAY:
	MOV TMOD,#00000001B 
	MOV TL1,#0CAH
	MOV TH1,#27H
	SETB TR1
BACK: 
	JNB TF1,BACK 
	CLR TR1
	CLR TF1
	RET

KCODE0: DB '1','2','3','0'
KCODE1: DB '4','5','6','0'
KCODE2: DB '7','8','9','0'
KCODE3: DB '0','0','0','0'

PROMPT_MSG: STRZ "Please enter new time"
END
