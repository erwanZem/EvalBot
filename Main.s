; Evalbot (Cortex M3 de Texas Instrument
; programme - bumpers - led 
   	
		AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run ;mode SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf

SYSCTL_PERIPH_GPIOF EQU		0x400FE108

; The GPIODATA register is the data register
; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de ;lm3s9B92.pdf

GPIO_PORTF_BASE		EQU		0x40025000
GPIO_PORTE_BASE		EQU		0x40024000
GPIO_PORTD_BASE		EQU		0x40007000	


; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
; GPIO Direction (p417 datasheet de lm3s9B92.pdf

GPIO_O_DIR   		EQU 	0x400

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

GPIO_O_DR2R   		EQU 	0x500  

; Digital enable register
; To use the pin as a digital input or output, the ;corresponding GPIODEN bit must be set.
; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

GPIO_O_DEN   		EQU 	0x51C  

; Registre pour activer les switchs  en logiciel (par defaut ;ils sont relies �  la masse donc inactifs)

GPIO_PUR			EQU		0x510

; Port select - LED1 et LED2 sur la ligne 4 et 5 du port F

PORT45              EQU		0x30

; Port select - LED 2 sur la ligne 5 du port F

PORT5               EQU     0x20

; Port select - LED 1 sur la ligne 4 du port F

PORT4				EQU		0x10

; PORT E : selection des BUMPER GAUCHE et DROIT,LIGNE 01 du Port E

PORT01				EQU		0x03

; PORT E : selection du BUMPER DROIT, LIGNE 0 du Port E

PORT0				EQU		0x01
; PORT D : selection du SWICTH1

PORT6				EQU		0x40
	
; PORT D :selection du SWITCH2	

PORT7				EQU		0x80  	;switch sur port 7  ;0b 0100 0000

; PORT E : selection du BUMPER DROIT, LIGNE 1 du Port E

PORT1               EQU     0x02

; Instruction : aucune LED allumee

NOL2D				EQU		0x00

; Instruction : LED 1 allumee, ligne 4, du port F

LED1				EQU		0x10

; blinking frequency, non utile dans ce programme

DUREE   			EQU     0x002FFFFF	
	

	  	ENTRY
		EXPORT	__main
			;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; d�activer le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arri�re
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; d�activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arri�re
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
__main	

;activation des port D,F et E (SWITCH,LED et BUMPER)
		ldr r6, = SYSCTL_PERIPH_GPIOF  		
        mov r0, #0x00000058  	;58 pour Port D,F,E			

	    str r0, [r6]
		  
		nop	   									
		nop	   
		nop	   									
	
;CONFIGURATION DES LEDS
;Configuration des leds en Output
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR  
		ldr r0, = PORT45	
		str r0, [r6]
  
   ;Enable Digital Function 	

		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	
		ldr r0, = PORT45 		
		str r0, [r6]
				
	;Choix de l'intensite de sortie (2mA)	

		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	
        ldr r0, = PORT45		
		str r0, [r6]
		
	; Enable Digital Function - Port E

		ldr r7, = GPIO_PORTE_BASE+GPIO_O_DEN	
        ldr r0, = PORT01		
        str r0, [r7]	
	; Activer le registre des bumpers, Port E

		ldr r7, = GPIO_PORTE_BASE+GPIO_PUR	
        ldr r0, = PORT01
        str r0, [r7]
		
	;Activation du port d
		ldr r6, = GPIO_PORTD_BASE+GPIO_O_DEN	;;Enable Digital Function (p316 )
        ldr r0, = PORT6 + PORT7		
        str r0, [r6]

	;Activation des switchs
		ldr r6, = GPIO_PORTD_BASE+GPIO_PUR	;; Choix de l'intensit� de sortie (2mA)
        ldr r0, = PORT6 + PORT7			
        str r0, [r6]
		
		
	;Activation des moteurs
		B	MOTEUR_INIT
		B	MOTEUR_DROIT_ON
		B	MOTEUR_GAUCHE_ON
		
		;FIN CONFIGURATION
		
		;BOUCLE PRINCIPALE
loop	
		B AVANCER
		
		B LIRE_BUMPER_DROIT
		
		cmp	r5,#0x00
		
		BNE DEMI_TOUR_DROIT
		
		B LIRE_BUMPER_GAUCHE
		
		CMP r9,#0x00
		
		BNE DEMI_TOUR_GAUCHE
		
		B loop
		;FIN DE LA BOUCLE

		
		;FONCTIONS UTILS
LIRE_BUMPER_DROIT
	
		ldr r7,= GPIO_PORTE_BASE + (PORT0<<2)
		ldr r5, [r7]
		BX	LR
		
LIRE_BUMPER_GAUCHE

        ldr r9, =  GPIO_PORTE_BASE + (PORT1<<2)
		ldr r10, [r9]
		BX	LR
		
AVANCER
		mov r12,LR
		b MOTEUR_DROIT_AVANT
		b MOTEUR_GAUCHE_AVANT
		BX	r12
		
RECULER
		mov r12,LR
		b MOTEUR_DROIT_ARRIERE
		b MOTEUR_GAUCHE_ARRIERE
		BX	r12
		
DEMI_TOUR_DROIT
		mov r12,LR	
		b MOTEUR_DROIT_ARRIERE
		b MOTEUR_GAUCHE_ARRIERE
		b WAIT
		b MOTEUR_DROIT_ON
		nop
		BX	r12


; pour la dur�e de la boucle d'attente1 (wait1)
WAIT 	
		ldr r1, = DUREE
w1		subs r1, #1
		bne w1
		BX	LR
		
LIRE_SWITCH1
		ldr r7, = GPIO_PORTD_BASE+ (PORT6<<2)
		ldr r5, [r7]
		BX LR

LIRE_SWITCH2
		ldr r9, = GPIO_PORTD_BASE+ (PORT7<<2)
		ldr r10, [r9]
		BX LR
		
;DEMI_TOUR_GAUCHE
	;BX	LR

;ARRET
		;b MOTEUR_GAUCHE_OFF
		;b MOTEUR_DROIT_OFF
		
		;BX	LR
		
;CLIGNOTE
;	BX	LR

;BONUS
;BEYBLADE
;; Rotation � droite de l'Evalbot pendant une demi-p�riode (1 seul WAIT)
		;CLIGNOTE
;		B	MOTEUR_DROIT_ARRIERE   ; 
;		B	MOTEUR_DROIT_INVERSE
;		BL	WAIT
;
;		b	loop
;BX	LR

	nop
	nop
	nop

	END