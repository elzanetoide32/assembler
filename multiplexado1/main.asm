;DISEÑAR EN DIAGRAMA DE FLUJO Y CODIFICAR UN ALGORITMO QUE IMPLEMENTE UN 
;CONTADOR DE 2 DIGITOS DECIMALES EL CUAL SE IMPACTE EN 2 DISPLAYS DE 7 SEGMENTOS
;MULTIPLEXADOS, VALOR INICIAL 0 Y ASCENDIENTE. INCREMENTAR SU VALOR CADA 1 SGUNDOS
;ARMAR CIRCUITO EN PROTOBOARD. 
;ENTREGAR D.D.F., CODIGO Y PROTOBOARD
;Autores: Zanetti y Fernandez
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
AlarmaMin   EQU 0X34
SELECTOR    EQU 0X37
COUNT       EQU 0X38
AUX         EQU 0X39
Tabla_disp  EQU 0x20
UNIDAD      EQU 0X20
DECENA      EQU 0x21
Tabla_hab   EQU 0x30
A           EQU 0X30
B           EQU 0X31
WAUX		EQU 0x40
STATUSAUX	EQU 0x41
main:
	PSECT		por_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x00
	CALL		init
loop:		CALL		work
	GOTO		loop
	PSECT		int_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x04

interrupt:	
;context saving
    MOVWF		WAUX
	MOVF		STATUS, W
	MOVWF		STATUSAUX
    BTFSC		INTCON, 2
        BCF		INTCON, 2
        MOVLW		99
        MOVWF		TMR0
        BSF AlarmaMin, 0  
;restore saving
    MOVF		STATUSAUX, W
	MOVWF		STATUS
	MOVF		WAUX, W
    RETFIE
	PSECT		fun_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x1D

init:		
    BCF STATUS, 6
    BSF STATUS, 5
    MOVLW 11110000B 
    MOVWF TRISB
    MOVWF TRISA
    MOVLW 10000100B ;preescaler en 32
    MOVWF OPTION_REG
    BCF STATUS, 5
    MOVLW 00010000B
    MOVF A 
    MOVLW 00100000B
    MOVF B 
    MOVLW 99 ;PARA QUE SALTA CADA 5mS
    MOVWF TMR0
    MOVLW 10100000B ;HABILITA INTERRUPCIONES GENERALES Y POR TMR0
    MOVWF INTCON
    CLRF PORTB
    CLRF PORTA
    CLRF UNIDAD
    CLRF DECENA
    CLRF SELECTOR
	CLRF AlarmaMin
    CLRF COUNT 
    CLRF AUX 
    RETURN

work:    
	BTFSS AlarmaMin, 0
		GOTO work
	BCF AlarmaMin, 0
    CALL Cambio_display
	INCF COUNT, F 
	MOVF COUNT, W 
	XORLW 200
	BTFSS STATUS, 2 
		GOTO work
	CLRF COUNT 
	CALL contador
	RETURN

contador: 
    INCF UNIDAD, F 
    MOVF UNIDAD, W
    XORLW 10
    BTFSS STATUS, 2
        RETURN
    CLRF UNIDAD 
    INCF DECENA, F 
    MOVF DECENA, W 
    XORLW 10
    BTFSS STATUS, 2
        RETURN
    CLRF DECENA 
    RETURN


Cambio_display:
    INCF SELECTOR, F 
    MOVF SELECTOR, W 
    XORLW 2
    BTFSS STATUS, 2 
        CLRF SELECTOR        
    MOVF SELECTOR, W 
    ADDLW  Tabla_disp 
    MOVWF FSR
    MOVF INDF, W 
    MOVWF AUX
    ;TABLA PARA LAS HABILITACIONES DE LOS TRANS
    MOVF Tabla_hab, w 
    ADDLW SELECTOR
    MOVWF FSR 
    MOVF INDF, W  
    IORWF AUX, W       
    MOVWF PORTB
    RETURN

END main
