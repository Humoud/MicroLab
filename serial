; Receive a character serially and display it on Terminal and LCD.
TI BIT SCON.1
RI BIT SCON.0
TR1 BIT TCON.6
LDATA EQU P0
EN EQU P0.2

RS EQU P0.0
WR EQU P0.1
	ORG 0H
START:
	ACALL INIT ; Initialize Serial transmission parameters
	ACALL INLCD ; Initialize LCD
	MOV A,#8H ; Move cursor to 1st line
	ACALL CMD
	MOV A,#5H ; Move cursor to 6th position on the line selected
	ACALL CMD
	ACALL LDELAY ; 4.1 msec required for this command
REPEAT:
	ACALL CIN ; Receive a character serially
	MOV R2,A ; Save the character in R2
	ACALL WTEXT ; Display the character on the LCD
	MOV A,R2
	ACALL COUT ; Transmit the character to Virtual Terminal
	SJMP REPEAT
; Serial port initialization
INIT:
	MOV A,PCON ; Copy PCON to A and reset PCON.7 for normal freq.
	CLR ACC.7 ;If PCON.7 is set frequency will be doubled.
	MOV PCON,A
; Initialize SCON register
	MOV SCON,#01010000B ; 8-bit, 1-stop and Enable Reception
; Timer 1 in Mode 2 generates pulses at 19200 baud
	MOV TMOD,#00100000B ; Timer-1, mode-2
	MOV TH1,#-3 ; or #0FDH For baud rate 19200
	SETB TR1 ; Start timer-1
	RET
; --------------------Subroutine to receive a character serially --------------
CIN:
	JNB RI,CIN ; If RI = 1 a byte has been received in SBUF
	MOV A,SBUF ; Save the character in A register
	CLR RI ; Clear RI for getting ready for next reception
	RET
; ----------------Subroutine to send a character serially out --------------------
COUT:
	MOV SBUF,A
	JNB TI,$ ; If TI = 1 last bit is gone
	CLR TI ; Clear TI for getting ready for next transfer
	RET
	
;-- LCD Initialization Procedure starts here -----
INLCD:
	MOV R7,#4
WAIT:
	ACALL LDELAY ; 4.6 msec delay - reqd 15 msecs
	DJNZ R7,WAIT
	MOV P0,#7
	MOV A,#3H ; Commands sent as per data sheet
	ACALL CMD
	ACALL LDELAY
	MOV A,#3H
	ACALL CMD
	MOV A,#3H
	ACALL CMD
	MOV A,#2H ; 4-bit data
	ACALL CMD
	MOV A,#2H ; Set Interface Length
	ACALL CMD
	MOV A,#8H
	ACALL CMD
	CLR A ; Turn ON Display,Cursor ON, Blink Cursor
	ACALL CMD
	MOV A,#0FH
	ACALL CMD
	CLR A
	ACALL CMD ; Set cursor Move RIGHT
	MOV A,#06
	ACALL CMD
	CLR A
	ACALL CMD
	MOV A,#1H ; Clear Display
	ACALL CMD
	ACALL LDELAY ; 4.1 msec required for this command
	RET
;--- End of LCD initialization -----
;---- Subroutine to write COMMAND in A to the LCD -------
CMD:
	CLR RS
	ACALL COMMON
	RET
;---- Subroutine to write character to the LCD whose code is in A -------
WTEXT:
	SETB RS ; RS = 1 data write
	MOV B,A
	SWAP A
	ACALL COMMON ; write text to LCD.
	MOV A,B
	ACALL COMMON
	RET
;----- Common operation for TEXT write and COMMAND write
COMMON:
	CLR WR
	SWAP A ; Only P3.7 P3.6 P3.5 P3.4 are connected to data lines of LCD
	ANL A,#0F0h
	ANL P0,#7 ; Not to disturb the control lines on P3.2 P3.1 P3.0
	ORL P0,A ; P3 carries at this point DATA and Control signals
	SETB EN
	CLR EN
	ACALL LDELAY
	RET
;------------ 4.6 msec DELAY -------------------------------------------
LDELAY:
	PUSH 0
	PUSH 1 ; save register1.
	MOV R1,#12 ; move 12 to register R1
CON4:
	MOV R0,#0FDH
	DJNZ R0,$
	DJNZ R1,CON4 ; decrease R1, if R1 !=0, go to CON4
	POP 1
	POP 0
	RET
END
