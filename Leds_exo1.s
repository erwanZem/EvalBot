
	;; TG 09/2012 - Evalbot (Cortex M3 de Texas Instrument)
	;; make both leds blinkying no  libs!
   	
		AREA    |.text|, CODE, READONLY
 

SYSCTL_PERIPH		EQU		0x400FE108	;SYSCTL_RCGC2_R : pour enable clock (p291 datasheet de lm3s9b92.pdf)
GPIO_PORTF_BASE		EQU		0x40025000  ; voir chap.8 "GPIO": page 416 de lm3s9B92.pdf
GPIO_PORTD_BASE		EQU		0x40007000	; GPIO Port D SWITCHS / ADRESSE DE BASE
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction  (p417 de lm3s9B92.pdf)
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 de lm3s9B92.pdf)
GPIO_O_DEN   		EQU 	0x0000051C  ; GPIO Digital Enable	(p437 de lm3s9B92.pdf)
GPIO_O_PUR   		EQU 	0x00000510  ; OFFSET PUR 510
										; Pour être "propre" il faudrait aussi s'assurer que les
										;autres registres de configuration sont a 0 (ce qui est le
										;cas a l'init.)


PORT4				EQU		0x10	;led sur port 4     ;0b 0000 0001  
PORT5				EQU		0x20  	;led sur port 5     ;0b 0000 0010 
PORT6				EQU		0x40	;switch sur port 6  ;0b 0010 0000 
PORT7				EQU		0x80  	;switch sur port 7  ;0b 0100 0000
	;0b 0110 0000

LEDOFF				EQU		0x00	;led eteints


DUREE   			EQU     0x002FFFFF	

	  	ENTRY
		EXPORT	__main
__main	
; Enable the Port F peripheral clock by setting bit 5 (0x20 == 0b101000)-
;(p291 datasheet de lm3s9B96.pdf), 						  (GPIO::FEDCBA)
		ldr r6, = SYSCTL_PERIPH
        mov r0, #0x00000028  ;;Enable clock sur GPIOF où sont branchés les leds
        str r0, [r6]
		
		nop	   ; tres tres important....(beaucoup temps perdu, cf petite note p413!)
		nop	   ; "There must be  a delay of 3 system clocks before any GPIO reg. access
		nop	   ; pas necessaire en simu  ou en debbug step by step...@#@! :-(
	
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR   ;2 Pins du portF en sortie
        ldr r0, = PORT4 + PORT5	
        str r0, [r6]
		
		ldr r6, = GPIO_PORTD_BASE+GPIO_O_DIR   ;2 Pins du portF en sortie
        ldr r0, = 0x00000000						;; les configurer tous en input
        str r0, [r6]
		
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;;Enable Digital Function (p316 )
        ldr r0, = PORT4 + PORT5		
        str r0, [r6]

        ldr r6, = GPIO_PORTD_BASE+GPIO_O_DEN	;;Enable Digital Function (p316 )
        ldr r0, = PORT6 + PORT7		
        str r0, [r6]


		ldr r6, = GPIO_PORTD_BASE+GPIO_O_PUR	;; Choix de l'intensité de sortie (2mA)
        ldr r0, = PORT6 + PORT7			
        str r0, [r6]

        mov r2, #0x000       ;pour eteindre tout
     
		;Allume les 2 leds
		;mov r3, #(PORT4 + PORT5)     ;Allume portF broche 4et 5 : 00110000
        ;ldr r6, = GPIO_PORTF_BASE+ ((PORT4+PORT5)<<2) ; @data Register = @base + (mask<<2)

		;Pour allumer seulement la led broche 4 sans toucher au reste (led 5)
		;mov r3, #PORT4       ;Allume portF broche 4 : 00010000
		;ldr r6, = GPIO_PORTF_BASE+ (PORT4<<2) ; @data Register = @base + (mask<<2)
		
		
		
		;on peut aussi allumer la led 4 comme ca => ca eteint la led 5 si allumée
		;mov r3, #PORT5 	     ;Allume portF broche 4et 5 : 00110000
        ;ldr r6, = GPIO_PORTF_BASE+ ((PORT4+PORT5)<<2) ; @data Register = @base + (mask<<2)
		
loop
		
		mov r3, #(PORT4 + PORT5)     ;Allume portF broche 4et 5 : 00110000
        ldr r6, = GPIO_PORTF_BASE+ ((PORT4+PORT5)<<2) ; @data Register = @base + (mask<<2)
		mov r12, #(PORT4 + PORT5)
        str r12, [r6]    ;Eteint tout car r2 = 0x00      
		
		ldr r7, = GPIO_PORTD_BASE+ (PORT6<<2)
		ldr r5, [r7]
		
		ldr r9, = GPIO_PORTD_BASE+ (PORT7<<2)
		ldr r10, [r9]
			
		cmp r5, #0x000
		bne eteindrel1
		
		cmp r10, #0x000
		bne eteindrel2
		
		str r3, [r6]
		
		b	loop

eteindrel1	ldr r6, = GPIO_PORTF_BASE+ (PORT4<<2)
			str r2, [r6]
			nop
			nop
			nop
			b	loop

eteindrel2	ldr r6, = GPIO_PORTF_BASE+ (PORT5<<2)
			str r2, [r6]
			nop
			nop
			nop
			
        nop                 
        END 