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
A equ 0x32 
B equ 0x33
C equ 0x34
D equ 0x35
COUNT1 equ 0x36
COUNT2 equ 0x37
K equ 038

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
    CLRF K
    CALL TABLA
    MOVF A,0
    MOVWF FSR
    MOVF INDF,0
    MOVWF PORTB
    RETURN
work:
    MOVLW 101
    MOVWF COUNT1
    CLRF COUNT2
    BTFSC PORTA, 5
        GOTO work
    CALL RET1
    BTFSC PORTA, 5
        GOTO work
    INCF K,0
    XORLW 4 
    BTFSC STATUS, 2
        CLRF K
    MOVF K,0
    ADDLW A
    MOVWF FSR 
    MOVF INDF,0
    MOVWF PORTB
    RETURN
TABLA:
    MOVLW 00001001
    MOVWF A 
    MOVLW 00000110
    MOVWF B 
    MOVLW 00001010
    MOVWF C 
    MOVLW 00000101
    MOVWF D


RET1:
	CALL RET2
	INCF COUNT1, 0
	BTFSC STATUS, 2
		RETURN
	GOTO RET1
RET2:
	NOP
	INCF COUNT2, 0
	BTFSS STATUS, 2
		RETURN
	GOTO RET2
END main
