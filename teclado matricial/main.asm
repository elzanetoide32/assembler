;DISEÑAR EN D.D.F. Y CODIFICAR UN PROGRAMA Q TENGA UN TEMPORIZADOR DE FRECUENCIAS VARIABLE
;LA FRECUENCIA DEL TEMPORIZADOR DEBE SER ESCOGIBLE MEDIANTE 6 PULSADORES DISPUESTOS COMO UN TECLADO MATRICIAL
;LAS FRECUENCIAS DE DISPARO DEBE SER1/4,1/2,1,2,4 Y 8. EL PROGRAMA DEBE CONTROLAR 8 LEDS, EL LEDS DEBE DESPLAZARCE CUANDO SALTA EL TEMPORIZADOR
;ARMAR CIRCUITO EN PROTOBOARD. 
;ENTREGAR D.D.F., CODIGO Y PROTOBOARD
;Autores: Zanetti y MOLINA
;EL TMR0 SIEMPRE ES 60mS
;PARA 1/4 -> 67 VECES
;PARA 1/2 ->34
;PARA 1 -> 17 
;PARA 2 -> 9
;PARA 4 -> 5
;PARA 8 -> 2
;	            PIC16F628, DIP-18                         
;	            +-------------U-------------+             
;	       <> 1 | RA2/AN2           AN1/RA1 | 18 <>       
;	       <> 2 | RA3/AN3           AN0/RA0 | 17 <>       
;	       <> 3 | RA4/TOCKI        OSC1/RA7 | 16 <>       
;	       <> 4 | RA5/MCLR         OSC2/RA6 | 15 <>       
;	GND    -> 5 | VSS                   VDD | 14 <- 5V    
;	       <- 6 | RB0/INT         T1OSI/RB7 | 13 <>       
;	       <- 7 | RB1/RX          T1OSO/RB6 | 12 <>       
;	       <- 8 | RB2/TX                RB5 | 11 <>       
;	       <- 9 | RB3/CCP1          PGM/RB4 | 10 <>       
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
;FRECUENCIAS
FREQ1   EQU 67 
FREQ2   EQU 34
FREQ3   EQU 17 
FREQ4   EQU 9 
FREQ5   EQU 5 
FREQ6   EQU 2

FLAG_TMR0 equ 0x20
AUX equ 0x21
KeyCode equ 0x22
SELECTOR equ 0x23
A equ 0x24
B equ 0x25
C equ 0x26
D equ 0x27
E equ 0x28
KeyCodeAUX equ 0x43
WAUX		EQU 0x29
STATUSAUX	EQU 0x30
main:
	PSECT		por_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x00
	CALL		init
loop:		CALL		work
	GOTO		loop
	PSECT		int_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x04
    MOVWF WAUX
    SWAPF STATUS,W
    MOVWF STATUSAUX
    BCF STATUS, 5      
    BCF STATUS, 6       
    BTFSC INTCON, 0
        CALL Sol
    BTFSC INTCON, 2
        CALL Sol1
    SWAPF STATUSAUX,W
    MOVWF STATUS
    SWAPF WAUX,F
    SWAPF WAUX,W
    RETFIE

    PSECT		fun_vec, global, class=CODE, delta=2, abs, ovrld
	ORG		0x1D

init:
    MOVLW 0x07           ;   b'00000111'  d'007'
    MOVWF CMCON
    BSF STATUS, 5       ; !!Bank Register-Bank(0/1)-Select
    MOVLW 11110000B           ;   b'11100000'  d'224'
    MOVWF TRISA          ; !!Bank!! PORTA - TRISA
    MOVLW 11110000B           ;   b'11110000'  d'240'
    MOVWF TRISB          ; !!Bank!! PORTB - TRISB

    MOVLW 0x07           ;   b'00000111'  d'007'
    MOVWF TMR0           ; !!Bank!! TMR0 - OPTION_REG

    BCF STATUS, 5       ; !!Bank Register-Bank(0/1)-Select
    MOVLW 0xA8           ;   b'10101000'  d'168'
    MOVWF INTCON
    CLRF PORTA           ; !!Bank!! PORTA - TRISA
    CLRF PORTB           ; !!Bank!! PORTB - TRISB
    MOVLW 00000001B           ;   b'00010001'  d'017'
    MOVWF E
    MOVLW 00000010B           ;   b'00010010'  d'018'
    MOVWF D
    MOVLW 00000100B           ;   b'00010100'  d'020'
    MOVWF C
    MOVLW 00001000B           ;   b'00011000'  d'024'
    MOVWF B
    MOVLW 00000000B           ;   b'00000000'  d'000'
    MOVWF A
    MOVLW A
    MOVWF FSR
    MOVF INDF,W
    MOVWF PORTA          ; !!Bank!! PORTA - TRISA
    CLRF KeyCode
    CLRF FLAG_TMR0
    CLRF AUX
    CLRF SELECTOR
    CLRF WAUX
    CLRF STATUSAUX
    MOVLW 22           ;   b'10011110'  d'158'
    MOVWF TMR0           ; !!Bank!! TMR0 - OPTION_REG
    RETURN
work:
    BTFSS FLAG_TMR0,0
        RETURN
    BCF FLAG_TMR0, 0
    MOVF KeyCode, W
    XORLW 0           ;   b'00000000'  d'000'
    BTFSC STATUS, 2
        CALL TRES

    MOVF KeyCode, W
    XORLW 1           ;   b'00000001'  d'001'
    BTFSC STATUS, 2
        CALL UNO

    MOVF KeyCode, W
    XORLW 2           ;   b'00000010'  d'002'
    BTFSC STATUS, 2
        CALL DOS

    MOVF KeyCode, W
    XORLW 3           ;   b'00000011'  d'003'
    BTFSC STATUS, 2
        CALL TRES

    MOVF KeyCode, W
    XORLW 4           ;   b'00000100'  d'004'
    BTFSC STATUS, 2
        CALL CUATRO

    MOVF KeyCode,W
    XORLW 5           ;   b'00000101'  d'005'
    BTFSC STATUS, 2
        CALL CINCO

    MOVF KeyCode,W
    XORLW 6           ;   b'00000110'  d'006'
    BTFSC STATUS, 2
        CALL SEIS
        
    MOVF KeyCode,W
    SUBLW 16           ;   b'00010000'  d'016'
    BTFSS STATUS, 0
        CALL HELP
    RETURN
Sol:
    MOVF PORTB,F         ; !!Bank!! PORTB - TRISB
    BCF INTCON, 0
    CALL Get_KeyCode
    RETURN
Sol1:
    BCF INTCON, 2
    BSF FLAG_TMR0,0
    MOVLW 22           ;   b'10011110'  d'158'
    MOVWF TMR0           ; !!Bank!! TMR0 - OPTION_REG
    BSF STATUS, 5 
      ;reestablecer el valor del preescaler
    MOVLW 11111000B
    ANDWF OPTION_REG, F 
    MOVLW 00000111B
    IORWF OPTION_REG, F      
    BCF STATUS, 5
    RETURN
Get_KeyCode:
    MOVF KeyCode,W
    MOVWF KeyCodeAUX
    BCF INTCON, 3
    CLRF KeyCode
    SWAPF PORTB,W        ; !!Bank!! PORTB - TRISB
    CALL TABLA
    ADDWF KeyCode,F
    CALL cambio
    CLRF PORTB           ; !!Bank!! PORTB - TRISB
    MOVLW 0x0F           ;   b'00001111'  d'015'
    XORWF PORTB,W        ; !!Bank!! PORTB - TRISB
    CALL TABLA
    ADDWF KeyCode,F
    CALL cambio
    MOVF PORTB,F         ; !!Bank!! PORTB - TRISB
    BCF INTCON, 0
    BSF INTCON, 3
    RETURN
    
HELP:
    MOVF KeyCodeAUX,W
    MOVWF KeyCode
    CLRF AUX
    RETURN
cambio:
    BCF STATUS, 6       ; !!Bank Register-Bank(2/3)-Select
    BSF STATUS, 5       ; !!Bank Register-Bank(0/1)-Select
    COMF PORTB,F         ; !!Bank!! PORTB - TRISB
    BCF STATUS, 5       ; !!Bank Register-Bank(0/1)-Select
    RETURN
TABLA:
    ADDWF PCL,F          ; !!Program-Counter-Modification
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x00           ;   b'00000000'  d'000'
    RETLW 0x03           ;   b'00000011'  d'003'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x06           ;   b'00000110'  d'006'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x03           ;   b'00000011'  d'003'
    RETLW 0x14           ;   b'00010100'  d'020'
    RETLW 0x02           ;   b'00000010'  d'002'
    RETLW 0x01           ;   b'00000001'  d'001'
    RETLW 0x14           ;   b'00010100'  d'020'
TRES:
    INCF AUX,F
    MOVF AUX,W
    XORLW FREQ3           ;   b'00101000'  d'040'  "("
    BTFSS STATUS, 2
        RETURN
    CLRF AUX
    INCF SELECTOR,F
    MOVF SELECTOR,W
    XORLW 0x05           ;   b'00000101'  d'005'
    BTFSC STATUS, 2
        CLRF SELECTOR
    MOVF SELECTOR,W
    ADDLW 0x24           ;   b'00100100'  d'036'  "$"
    MOVWF FSR
    MOVF INDF,W
    MOVWF PORTA          ; !!Bank!! PORTA - TRISA
    RETURN
UNO:
    INCF AUX,F
    MOVF AUX,W
    XORLW FREQ1           ;   b'10100000'  d'160'
    BTFSS STATUS, 2
        RETURN
    CLRF AUX
    INCF SELECTOR,F
    MOVF SELECTOR,W
    XORLW 0x05           ;   b'00000101'  d'005'
    BTFSC STATUS,2
        CLRF SELECTOR
    MOVF SELECTOR,W
    ADDLW 0x24           ;   b'00100100'  d'036'  "$"
    MOVWF FSR
    MOVF INDF,W
    MOVWF PORTA          ; !!Bank!! PORTA - TRISA
    RETURN
DOS:
    INCF AUX,F
    MOVF AUX,W
    XORLW FREQ2           ;   b'01010000'  d'080'  "P"
    BTFSS STATUS,2
        RETURN
    CLRF AUX
    INCF SELECTOR,F
    MOVF SELECTOR,W
    XORLW 0x05           ;   b'00000101'  d'005'
    BTFSC STATUS,2
        CLRF SELECTOR
    MOVF SELECTOR,W
    ADDLW 0x24           ;   b'00100100'  d'036'  "$"
    MOVWF FSR
    MOVF INDF,W
    MOVWF PORTA          ; !!Bank!! PORTA - TRISA
    RETURN
CUATRO:
    INCF AUX,F
    MOVF AUX,W
    XORLW FREQ4           ;   b'00010100'  d'020'
    BTFSS STATUS,2
        RETURN
    CLRF AUX
    INCF SELECTOR,F
    MOVF SELECTOR,W
    XORLW 0x05           ;   b'00000101'  d'005'
    BTFSC STATUS,2
        CLRF SELECTOR
    MOVF SELECTOR,W
    ADDLW 0x24           ;   b'00100100'  d'036'  "$"
    MOVWF FSR
    MOVF INDF,W
    MOVWF PORTA          ; !!Bank!! PORTA - TRISA
    RETURN
CINCO:
    INCF AUX,F
    MOVF AUX,W
    XORLW FREQ5           ;   b'00001010'  d'010'
    BTFSS STATUS,2
        RETURN
    CLRF AUX
    INCF SELECTOR,F
    MOVF SELECTOR,W
    XORLW 0x05           ;   b'00000101'  d'005'
    BTFSC STATUS,2
        CLRF SELECTOR
    MOVF SELECTOR,W
    ADDLW 0x24           ;   b'00100100'  d'036'  "$"
    MOVWF FSR
    MOVF INDF,W
    MOVWF PORTA          ; !!Bank!! PORTA - TRISA
    RETURN
SEIS:
    INCF AUX,F
    MOVF AUX,W
    XORLW FREQ6           ;   b'00000101'  d'005'
    BTFSS STATUS, 2
        RETURN
    CLRF AUX
    INCF SELECTOR,F
    MOVF SELECTOR,W
    XORLW 0x05           ;   b'00000101'  d'005'
    BTFSC STATUS, 2
        CLRF SELECTOR
    MOVF SELECTOR,W
    ADDLW 0x24           ;   b'00100100'  d'036'  "$"
    MOVWF FSR
    MOVF INDF,W
    MOVWF PORTA          ; !!Bank!! PORTA - TRISA
    RETURN

    End main
