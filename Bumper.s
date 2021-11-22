
; Evalbot (Cortex M3 de Texas Instrument
; programme - bumpers - led 
   	
		AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run ;mode SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf

SYSCTL_PERIPH_GPIOF EQU		0x400FE108

; The GPIODATA register is the data register
; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de ;lm3s9B92.pdf

GPIO_PORTF_BASE		EQU		0x40025000
GPIO_PORTE_BASE		EQU		0x40024000


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

; Registre pour activer les switchs  en logiciel (par defaut ;ils sont relies √  la masse donc inactifs)

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
__main	

;clock sur GPIO F o√π sont branches les leds et GPIO D sur ;lequel sont branches les SW : 0x38 == 000101000)
; Enable the Port F and D,  peripheral clock by setting the ;corresponding bits,(p291 datasheet de lm3s9B96.pdf), ;GPIO::FEDCBA)
		
		ldr r6, = SYSCTL_PERIPH_GPIOF  		
        	mov r0, #0x00000038  				

	      str r0, [r6]

;"There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
;tres tres important....;; pas necessaire en simu ou en debbug ;step by step...

		nop	   									
		nop	   
		nop	   									
	
; CONFIGURATION LED

        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    

; une broche (Pin) du portF en sortie (broche 4 et 5 : 00110000)

		ldr r0, = PORT45	
        str r0, [r6]
		;ldr r0, = PORT5
		    ;str r0, [r8]  ; r8 contient sortie du PORT5

; Enable Digital Function 	

        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	
        ldr r0, = PORT45 		
        str r0, [r6]
			
; Choix de l'intensite de sortie (2mA)	

		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	
        ldr r0, = PORT45		
		str r0, [r6]
		
; pour eteindre LED

 		mov r2, #0x000           

; Enable Digital Function - Port E

		ldr r7, = GPIO_PORTE_BASE+GPIO_O_DEN	
        ldr r0, = PORT01		
        str r0, [r7]	

; Activer le registre des bumpers, Port E

		ldr r7, = GPIO_PORTE_BASE+GPIO_PUR	
        ldr r0, = PORT01
        str r0, [r7]

;Lire dans R5 l'etat du BUMPER DROIT et dans R10 l'etat du BUMPER GAUCHE

loop			

; allumer les leds broche 4 et 5 (PORT45), Allume portF broche 4 : ;00110000, @data Register = @base + (mask<<2) ==> LED

		mov r3, #PORT45
		ldr r6,= GPIO_PORTF_BASE + (PORT45<<2)  	
		mov r12,#0x30
		str  r12,[r6]


			
;lecture de l'etat du BUMPER DROIT

		ldr r7,= GPIO_PORTE_BASE + (PORT0<<2)
		ldr r5, [r7]
 
;lecture de l'etat du BUMPER GAUCHE

        ldr r9, =  GPIO_PORTE_BASE + (PORT1<<2)
		ldr r10, [r9]

;Traitement qui allume/eteint la LED1 et la LED2 en fonction de l'etat  ;du SW1, la LED1 est initialement allumee, et s'eteint si SW1 ;est active = appuye

;si BUMPER DROIT est actif , on eteint la LED1

		cmp	r5,#0x00          
		bne	noled1
			
;si BUMPER GAUCHE est actif , on eteint la LED2

		cmp r10, #0x00
		bne noled2

		str r3, [r6]          ; allume les leds 1 et 2
			
		b	loop
	
;etiendre LED1

noled1		
			ldr r6, = GPIO_PORTF_BASE + (PORT4<<2) 
			str r2, [r6]          ; eteint la led 1
			b	loop	
			
;eteindre LED2

noled2      ldr r6, = GPIO_PORTF_BASE + (PORT5<<2)
			str r2, [r6]          ; eteint la led 2
            b   loop
			nop	
			
     		   	END 