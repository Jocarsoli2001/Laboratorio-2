; Archivo: Contador_prelab2.s
; Dispositivo: PIC16F887
; Autor: José Santizo 
; Compilador: pic-as (v2.32), MPLAB X v5.50
    
; Programa: Configuración de oscilador e incrementar en RB0 y decrementar en RB1
; Hardware: LEDs en el puerto A, push pull down en RB0 Y RB1
    
; Creado: 3 de Agosto, 2021
; Última modificación: 3 de agosto de 2021
    
PROCESSOR 16F887
#include <xc.inc>
    
;configuration word 1
 CONFIG FOSC=INTRC_NOCLKOUT // Oscilador interno sin salidas
 CONFIG WDTE=OFF            // WDT desabilitado (reinicio repetitiv del PIC)
 CONFIG PWRTE=ON            // PWRTE habilitado (espera de 72 ms al iniciar)
 CONFIG MCLRE=OFF           // El pin de MCLR se utiliza como prendido o apagado
 CONFIG CP=OFF              // Sin protección de código
 CONFIG CPD=OFF		    // Sin protección de datos 
 
 CONFIG BOREN=OFF	    // Sin reinicio cuando el voltaje de alimentación baja de 4V
 CONFIG IESO=OFF	    // Reinicio sin cambio de reloj de interno a externo
 CONFIG FCMEN=OFF	    // Cambio de reloj externo a interno en caso de fallo
 CONFIG LVP=ON		    // Programación en bajo voltaje permitido
 
;configuration word 2
 CONFIG WRT=OFF		    // Protección de autoescritura por el programa desactivada
 CONFIG BOR4V=BOR40V	    // Reinicio abajo de 4v, (BOR21V = 2.1V)
 
 
;Variables a utilizar
 PSECT udata_bank0	    ; common memory
    CONT_SMALL: DS 1	    ; 1 byte
    CONT_BIG:	DS 1	    
    VAR:	DS 1	    ;Variable utilizada en suma de puertos
    
 PSECT resVect, class=CODE, abs, delta=2
 ;------------vector reset-----------------
 ORG 00h		    ; posición 0000h para el reset
 resetVec:
    PAGESEL MAIN
    goto MAIN

 PSECT CODE, DELTA=2, ABS
 ORG 100H		    ;Posición para el codigo
 ;-----------Configuración----------------
 MAIN:
    CALL    CONFIG_IO	    ;CONFIGURACIÓN DE ENTRADAS Y SALIDAS
    CALL    CONFIG_RELOJ    ;CONFIGURACIÓN DEL OSCILADOR
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL PORTC
    CLRF    PORTC
    
 ;---------Loop principal----------------
 LOOP:
    CALL    CONTADOR1	    ;Subrutina de contador 1 en el puerto A
    CALL    CONTADOR2	    ;Subrutina de contador 2 en el puerto C
    BTFSC   PORTB, 7
    CALL    SUMA_PUERTOS    ;Subrutina para sumar contadores en puertos A y C
    GOTO    LOOP	    ;Loop por siempre
    
 ;----------Sub rutinas-----------------
 CONTADOR1: 
    BTFSC   PORTB, 0	    ;Leer el estado del pin RB0
    CALL    INC_PORTA	    ;Llamar a la subrutina que incrementa a PORTA
    BTFSC   PORTB, 1	    ;Leer el estado del pin RB1
    CALL    DEC_PORTA	    ;Llamar a la subrutina que decrementa a PORTA
    RETURN
 
 CONTADOR2:
    BTFSC   PORTB, 2	    ;Leer el estado del pin RB2
    CALL    INC_PORTC	    ;Llamar a la subrutina que incrementa a PORTC
    BTFSC   PORTB, 3	    ;Leer el estado del pin RB3
    CALL    DEC_PORTC	    ;Llamar a la subrutina que decrementa a PORTC   
    RETURN
    
 SUMA_PUERTOS:
    BTFSC   PORTB, 7	    ;Chequear si el pushbutton en RB7 está presionado
    BCF	    PORTE, 0	    ;Asignar valor de RE0 en 0
    MOVF    PORTA, 0	    ;Mover el resultado presente en el puerto A a W
    ADDWF   PORTC, 0	    ;Sumar lo guardado en W a el resultado en PORTC
    MOVWF   VAR		    ;Mover resultado de suma a variable VAR
    BTFSC   VAR, 4	    ;Chequear si existe un 1 en el bit 4 de la variable VAR
    BSF	    PORTE, 0	    ;Si existe el 1 en el bit 4 de VAR, asignar en 1 el valor de RE0
    ANDLW   15		    ;And de 15 = 00001111 con el valor de VAR para tener un resultado de 4 bits
    MOVWF   PORTD	    ;Mover el resultado de el "and" hacia el puerto D
    RETURN
    
 INC_PORTC:
    CALL    DELAY_SMALL	    ;Aplicar un pequeño delay
    BTFSC   PORTB,2	    ;Chequear si RB2 está presionado
    GOTO    $-1		    ;Regresar a chequear si RB2 está presionado por si no lo está
    INCF    PORTC	    ;Incrementar en 1 el valor del puerto C
    RETURN
    
 INC_PORTA:
    CALL    DELAY_SMALL	    ;Aplicar un pequeño delay
    BTFSC   PORTB,0	    ;Chequear si RB0 está presionado
    GOTO    $-1		    ;Regresar a chequear si RB0 está presionado por si no lo está
    INCF    PORTA	    ;Incrementar en 1 el valor del puerto A
    RETURN
 
 DEC_PORTC:
    CALL    DELAY_SMALL	    ;Aplicar un pequeño delay	
    BTFSC   PORTB,3	    ;Chequear si RB3 está presionado
    GOTO    $-1		    ;Regresar a chequear si RB3 está presionado por si no lo está
    DECF    PORTC	    ;Decrementar en 1 el valor del puerto C
    RETURN
    
 DEC_PORTA:
    CALL    DELAY_SMALL	    ;Aplicar un pequeño delay
    BTFSC   PORTB,1	    ;Chequear si RB3 está presionado
    GOTO    $-1		    ;Regresar a chequear si RB3 está presionado por si no lo está
    DECF    PORTA	    ;Decrementar en 1 el valor del puerto A
    RETURN

 CONFIG_IO:
    BSF	    STATUS, 5	    ;Banco 11
    BSF	    STATUS, 6
    CLRF    ANSEL	    ;Pines digitales
    CLRF    ANSELH
    
    BSF	    STATUS, 5	    ;Banco 01
    BCF	    STATUS, 6
    CLRF    TRISA	    ;Port A como salida
    
    BSF	    TRISB,  0	    ;Asignar los pines 0, 1, 2, 3 y 7 de PORTB en 1
    BSF	    TRISB,  1
    BSF	    TRISB,  2
    BSF	    TRISB,  3
    BSF	    TRISB,  7
    
    BSF	    STATUS, 5	    ;BANCO 01
    BCF	    STATUS, 6
    CLRF    TRISC	    ;PORT C COMO SALIDA
    
    BSF	    STATUS, 5	    ;BANCO 01
    BCF	    STATUS, 6
    CLRF    TRISD	    ;PORT D COMO SALIDA
    
    BSF	    STATUS, 5	    ;BANCO 01
    BCF	    STATUS, 6
    CLRF    TRISE	    ;PORT E COMO SALIDA
    
    BCF	    STATUS, 5	    ;Banco 00
    BCF	    STATUS, 6
    CLRF    PORTA	    ;Limpiar el puerto A
    CLRF    PORTC	    ;Limpiar el puerto C
    CLRF    PORTD	    ;Limpiar el puerto D
    CLRF    PORTE	    ;Limpiar el puerto E
    RETURN
    
 CONFIG_RELOJ:
    BANKSEL OSCCON
    BSF	    IRCF2	    ;OSCCON, 6
    BCF	    IRCF1	    ;OSCCON, 5
    BCF	    IRCF0	    ;OSCCON, 4
    BSF	    SCS		    ;RELOJ INTERNO
    RETURN
    
 DELAY_BIG:
    MOVLW   200		    ;Valor inicial del contador
    MOVWF   CONT_BIG+1
    CALL    DELAY_SMALL	    ;Rutina de delay
    DECFSZ  CONT_BIG+1, 1   ;Decrementar el contador
    GOTO    $-2		    ;Ejecutar 2 lineas atrás
    RETURN
    
 DELAY_SMALL:
    MOVLW   165		    ;Valor inicial del contador
    MOVWF   CONT_SMALL	    
    DECFSZ  CONT_SMALL, 1   ;Decrementar el contador
    GOTO    $-1		    ;Ejecutar linea anterior
    RETURN
    
    
END





