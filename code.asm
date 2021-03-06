; STOPWATCH FORMAT HH2_HH1:MM2_MM1:SS2_SS1
	ORG 0H
;crap comments
TR0 BIT TCON.4
TF0 BIT TCON.5
;-------------
R BIT P1.3
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


INIT:	
	MOV TMOD,#000000001B
	
	MOV SS1,#0    ; SS
	MOV SS1,#0    ; SS
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
	
	
	;------ RESUME YOUR NORMAL CRAP
	LCALL Delay
	
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
	CJNE A,#9,INC_HH1
	MOV HH1,#0
	
	INC HH2
	
	SJMP AGAIN

;comments
INC_SS1:
	INC SS1
	SJMP AGAIN
INC_SS2:
	INC SS2
	SJMP AGAIN
INC_MM1:
	INC MM1
	SJMP AGAIN
INC_MM2:
	INC MM2
	SJMP AGAIN
INC_HH1:
	INC HH1
	LJMP AGAIN
;---START OF SUB PROCESSES

Delay:
	MOV C,P1.3
	CPL C
	MOV P1.3,C

	MOV R6,#100
DELAYy:		
	MOV TH0,#0B7H
	
	MOV TL0,#0EEH
	
	
	SETB TR0


LOOP:
	JNB TF0,LOOP
	
	
	CLR TR0
	
	CLR TF0
	
	
	DJNZ R6,DELAYy
	
	RET



;------------LCD


START:
LCD:		
	ACALL INLCD ; Initialize LCD
	MOV A,#1000B ; Move cursor to 1st line � send high nibble
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
	MOV A,#0010B ; Step 7 � send high nibble
	ACALL CMD
	MOV A,#1000B ; send low nibble
	ACALL CMD
	MOV A,#0000B ; Step 8 � Turn off display � send high nibble
	ACALL CMD
	MOV A,#1000B ; send low nibble
	ACALL CMD
	MOV A,#0 ; Step 9 - Clear Display � send high nibble
	ACALL CMD
	MOV A,#0001B ; send low nibble
	ACALL CMD
	ACALL LDELAY ; 4.1 msec required for this command
	MOV A,#0000B ; Step 10 - Set cursor Move RIGHT - send high nibble
	ACALL CMD
	MOV A,#0110B ; send low nibble
	ACALL CMD
	MOV A,#0000B ; Step 11 � send high nibble
	ACALL CMD ; Turn ON Display, Cursor ON, Blink Cursor
	MOV A,#1111B ; send low nibble
	ACALL CMD
	RET
;--- End of LCD initialization -----
;---- Subroutine to write COMMAND in A to the LCD -------
CMD:
	CLR RS ; RS = 0 command write
	ACALL COMMON
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

;------------ � 5.4 msec DELAY -------------------------------------------
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

END
