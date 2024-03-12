;conmute el estado de un led con interrupciones cada 50ms
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
AlarmaMin EQU 0X34
AUX EQU 0X36
INDF EQU 0X00
TMR0 EQU 0X01

main:
	PSECT por_vec, global, class=CODE, delta=2, abs, ovrld
	ORG	0x00
	CALL init
loop: 
    CALL work
	GOTO loop

	PSECT		int_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x04
interrupt:
    bcf INTCON, 2
    BSF AlarmaMin,0
    MOVLW 60
    MOVWF TMR0
    RETFIE

    PSECT		fun_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x0D
init:
    BCF STATUS, 6
    BSF STATUS, 5
    MOVLW 11111110
    MOVWF TRISB
    MOVLW 10000011
    MOVWF OPTION_REG
    BCF STATUS, 5
    MOVLW 60
    MOVWF TMR0
    MOVLW 10100000
    MOVWF INTCON
    CLRF PORTB
    RETURN
work:
    BTFSC AlarmaMin, 0
        RETURN
    COMF PORTB
    BCF AlarmaMin, 0

END main
