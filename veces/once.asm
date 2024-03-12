;apague y prenda leds segun las veces precionado el pulsador(ra5)
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
	BCF STATUS, 6
    BSF STATUS, 5
    MOVLW 00001111
    MOVWF PORTB
loop: 
    CALL work
	GOTO loop

work:
    LG: CLRF AUX
        MOVLW 10010000
        MOVWF PORTB
    L1: BTFSC PORTA, 4
            GOTO L1 
        MOVLW 1
        MOVWF AUX 
        MOVLW 01100000
        MOVWF PORTB
    L2: BTFSC PORTA, 4
            GOTO L2
        MOVLW 2
        MOVWF AUX 
        MOVLW 10100000
        MOVWF PORTB
    L3: BTFSC PORTA, 4
            GOTO L3
        MOVLW 2
        MOVWF AUX 
        MOVLW 10100000
        MOVWF PORTB
    L4: BTFSC PORTA, 4
            GOTO L4
    GOTO LG
    END main