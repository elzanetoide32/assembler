;CONTADOR BINARIO, SENTIDO DESCENDENTE, DE MODULO 128, VALORT INICIAL 127
;DECREMENTAR CADA 1S Y MOSTRALO EN EL PORTB
;
;	            PIC16F628, DIP-18                         
;	            +-------------U-------------+             
;	       <> 1 | RA2/AN2           AN1/RA1 | 18 <>       
;	       <> 2 | RA3/AN3           AN0/RA0 | 17 <>       
;	       <> 3 | RA4/TOCKI        OSC1/RA7 | 16 <>       
;	       <> 4 | RA5/MCLR         OSC2/RA6 | 15 <>       
;	GND    -> 5 | VSS                   VDD | 14 <- 5V    
;	LED8HZ <- 6 | RB0/INT         T1OSI/RB7 | 13 <>       
;	LED4HZ <- 7 | RB1/RX          T1OSO/RB6 | 12 <>       
;	LED2HZ <- 8 | RB2/TX                RB5 | 11 <>       
;	LED1HZ <- 9 | RB3/CCP1          PGM/RB4 | 10 <>       
;	            +---------------------------+             

PROCESSOR 16F628

CONFIG FOSC = INTOSCIO	; Oscilador interno
CONFIG WDTE = OFF	; WDT desactivado
CONFIG PWRTE = OFF	; PWRT desactivado
CONFIG MCLRE = OFF	; RA5 como I/O
CONFIG BOREN = ON	; BOD activado
CONFIG LVP = OFF	; RB4 como I/O
CONFIG CPD = OFF	; Protección de datos desactivada
CONFIG CP = OFF		; Protección de código desactivada

#include <xc.inc>
COUNT1 EQU 0X32
COUNT2 EQU 0X33
COUNT3 EQU 0X34
AUX EQU 0X36

main:
	PSECT por_vec, global, class=CODE, delta=2, abs, ovrld
	ORG	0x00
	CALL init
loop: 
    CALL work
	GOTO loop
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
init:
	BSF STATUS, 5
	BCF STATUS, 6
	MOVLW 00000000
	MOVWF TRISB
	BCF STATUS, 5
	MOVLW 01111111
	MOVWF PORTB
	CLRF COUNT1
	CLRF COUNT2
	CLRF COUNT3
	RETURN
work:
	CALL RET1
	DECF AUX, F
	MOVF AUX, F
	BTFSS STATUS, 2
		MOVF 127
		MOVWF AUX
	MOVWF AUX
	RETURN
RET1:
	CALL RET2
	INCF COUNT1, 0
	BTFSC STATUS, 2
		RETURN
	GOTO RET1
RET2:
	CALL RET3
	INCF COUNT2, 0
	BTFSS STATUS, 2
		RETURN
	GOTO RET2
RET3:
	NOP
	INCF COUNT3, 0
	BTFSS STATUS, 2
		RETURN
	GOTO RET3

END main