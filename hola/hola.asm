; Contador de módulo N, valor inicial 0, cuyos 4 bits menos significativos
; se impactan en RB3->0, mediante los cuales se encienden
; LEDS (HL = encendido). Se incrementa el valor del contador cuando
; se presiona el pulsador ubicado en RA5, el cuál cuenta con PULL-UP
; externo. Se implementa un antirrebote de 200ms para el pulsador.
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

VALOR_INI_RETA	equ 13
WAUX		equ 0x30
STATUSAUX	equ 0x31

main:

		PSECT		por_vec, global, class=CODE, delta=2, abs, ovrld
		ORG		0x00

		CALL		init
loop:		CALL		work
		GOTO		loop

		PSECT		int_vec, global, class=CODE, delta=2, abs, ovrld
		ORG		0x04

interrupt:	MOVWF		WAUX
		MOVF		STATUS, W
		MOVWF		STATUSAUX
		BTFSC		INTCON, 2
			CALL		rst_count
		BTFSC INTCON, 0
			CALL pepe
		MOVF		STATUSAUX, W
		MOVWF		STATUS
		MOVF		WAUX, W
		RETFIE

		PSECT		fun_vec, global, class=CODE, delta=2, abs, ovrld
		ORG		0x1D

init:		BSF		STATUS, 5
		MOVLW		0xF0
		MOVWF		TRISB
		CLRF TRISA
		MOVLW		10000111B	; prescaler on 1:256 for Timer0 (PSA=0, PS2:0=111)
		MOVWF		OPTION_REG
		BCF		STATUS, 5
		MOVLW		10101000B	; Timer0 activated
		MOVWF		INTCON
		MOVLW		VALOR_INI_RETA
		MOVWF		TMR0
		CLRF		PORTB
		CLRF PORTA
		RETURN

work:		RETURN

rst_count:	BCF		INTCON, 2
		MOVLW		VALOR_INI_RETA
		MOVWF		TMR0
		INCF		PORTB, F
		RETURN
pepe: BCF INTCON, 0
	COMF PORTA
	RETURN
END main
