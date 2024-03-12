;incremente el valor del display 7 segmentos. 
;cuando el valor = 9 y se aprete el pulsador(RA5) volver a 0
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
;pic-as -mcpu=16F628 -o build/program.hex programa.asm -xassembler-with-cpp -Wa,-a

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
AUX equ 0X32

main:
	PSECT por_vec, global, class=CODE, delta=2, abs, ovrld
	ORG	0x00
	CALL init
loop: 
    CALL work
	GOTO loop

init: 
    BSF STATUS, 5
    BCF STATUS, 6
    CLRF TRISB
    BCF STATUS, 5
    CLRF PORTB
    RETURN
work:
    BTFSC PORTA, 0
        GOTO work
    INCF AUX, F
    MOVF AUX, F
    XORLW 10
    BTFSC STATUS, 2
        CLRF AUX
    RETURN

	END		main