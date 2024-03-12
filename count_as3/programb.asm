;realizar un programa que cuente cn modulo 24, valor inicial 0 y orden ascendente
;utilizar b) timer 0
;el contador debe incrementar cada 2S, e impactarse en el puerto B (ocupar los 8 bits)
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

VALOR_INI_RETA	equ 60
M equ 10
COUNT EQU 0X33
AUX EQU 0X36
AlarmMin EQU 0X34
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

interrupt:	
		CALL SaveTemp
		BCF INTCON, 2
		BSF AlarmMin, 0
		MOVLW VALOR_INI_RETA
		MOVWF TMR0
		CALL RestoreTemp
		RETFIE

		PSECT		fun_vec, global, class=CODE, delta=2, abs, ovrld
		ORG		0x0D

init:		
		BSF		STATUS, 5
		CLRF		TRISB
		MOVLW		10000111B	; prescaler on 1:256 for Timer0 (PSA=0, PS2:0=111)
		MOVWF		OPTION_REG
		BCF		STATUS, 5
		MOVLW		10100000B	; Timer0 activated
		MOVWF		INTCON
		MOVLW		VALOR_INI_RETA
		MOVWF		TMR0
		CLRF		PORTB
		CLRF AUX
		CLRF COUNT
		CLRF AlarmMin
		RETURN

work:
	MOVF AUX, W 
	MOVWF PORTB
	BTFSS AlarmMin, 0
		RETURN
	BCF AlarmMin, 0
	INCF COUNT, F 
	MOVF COUNT, W 
	XORLW M
	BTFSS STATUS, 2
		RETURN
	CLRF COUNT 
	INCF AUX, F 
	MOVF AUX, W 
	XORLW 23	
	BTFSS STATUS, 2
		CLRF AUX
	RETURN

    
SaveTemp:
	MOVWF		WAUX
	MOVF		STATUS, W
	MOVWF		STATUSAUX
RestoreTemp:
	MOVF		STATUSAUX, W
	MOVWF		STATUS
	MOVF		WAUX, W


    END		main