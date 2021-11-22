; M. Akil, T. Grandpierre, R. Kachouri : d�partement IT - ESIEE Paris -
; 01/2013 - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui m�me)



		AREA    |.text|, CODE, READONLY
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



; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIOF EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40007000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000510  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN   		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Port select
PORT4				EQU		0x20		; led1 sur port 4

; blinking frequency
;DUREE   			EQU     0x002FFFFF	
;DUREE   			EQU     0x00000004	


__main	


		;; BL Branchement vers un lien (sous programme)

		; Configure les PWM + GPIO
;		BL	MOTEUR_INIT	   		   
		
		; Activer les deux moteurs droit et gauche
;		BL	MOTEUR_DROIT_ON
;		BL	MOTEUR_GAUCHE_ON
;
		; Boucle de pilotage des 2 Moteurs (Evalbot tourne sur lui m�me)
;loop	
;		; Evalbot avance droit devant
;		BL	MOTEUR_DROIT_AVANT	   
;		BL	MOTEUR_GAUCHE_AVANT
;		
;		; Avancement pendant une p�riode (deux WAIT)
;		BL	WAIT	; BL (Branchement vers le lien WAIT); possibilit� de retour � la suite avec (BX LR)
;		BL	WAIT
;		
;		; Rotation � droite de l'Evalbot pendant une demi-p�riode (1 seul WAIT)
;		BL	MOTEUR_DROIT_ARRIERE   ; MOTEUR_DROIT_INVERSE
;		BL	WAIT
;
;		b	loop



		ldr r6, = SYSCTL_PERIPH_GPIOF  			;; RCGC2
        mov r0, #0x00000008  					;; Enable clock sur GPIO F o� sont branch�s les leds (0x20 == 0b001000)
		; ;;														 									 (GPIO::FEDCBA)
        str r0, [r6]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...
	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

;        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
;        ldr r0, = PORT4 	
;        str r0, [r6]
		
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = PORT4 		
        str r0, [r6]
 
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensit� de sortie (2mA)
        ldr r0, = PORT4 			
        str r0, [r6]

        mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (PORT4)
		mov r3, #PORT4       					;; Allume portF broche 4 : 00010000
		ldr r6, = GPIO_PORTF_BASE + (PORT4<<2)  ;; @data Register = @base + (mask<<2) ==> LED1

		;; Boucle d'attante
WAIT	ldr r1, =0xAFFFFF 
wait1	subs r1, #1
        bne wait1
		
		;; retour � la suite du lien de branchement
		BX	LR

		NOP
        END
