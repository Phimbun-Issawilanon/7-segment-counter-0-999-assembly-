; Replace with your application code
.INCLUDE "m328pdef.inc"
 .def num =r18   
 .def numHun =r24   
 
  .org 0x00  


 ldi r26, 0
 ldi r27, 0x5F
 ldi r30,1
 ldi r20,2
 rjmp main

 EEPROM_WRITE:
	sbic EECR,EEPE
	rjmp EEPROM_WRITE

	out EEARH, r26
	out EEARL, r27

	out EEDR,r28

	sbi EECR, EEMPE
	sbi EECR, EEPE
    
	ret

EEPROM_WRITE2:
	sbic EECR,EEPE
	rjmp EEPROM_WRITE

	out EEARH, r30
	out EEARL, r27

	out EEDR,r29

	sbi EECR, EEMPE
	sbi EECR, EEPE
    rcall eepromflagw
	ret
eepromflagw:
	sbic EECR,EEPE
	rjmp EEPROM_WRITE

	out EEARH, r20
	out EEARL, r27

	ldi r19,1
	out EEDR,r19

	sbi EECR, EEMPE
	sbi EECR, EEPE
    
	ret
readflag:
	sbic EECR,EEPE
	rjmp EEPROM_READ

	out EEARH, r20
	out EEARL, r27

	sbi EECR, EERE

	in r19,EEDR
	
	ret
 EEPROM_READ:
	sbic EECR,EEPE
	rjmp EEPROM_READ

	out EEARH, r26
	out EEARL, r27

	sbi EECR, EERE

	in r28,EEDR
	
	ret
 EEPROM_READ2:
	sbic EECR,EEPE
	rjmp EEPROM_READ

	out EEARH, r30
	out EEARL, r27

	sbi EECR, EERE

	in r29,EEDR
	ret
 main:     
 ldi r16, low(RAMEND)    ;initialize
 out SPL, r16			;stack pointer
 ldi r16, high(RAMEND)    ; to RAMEND
 out SPH, r16    
 ldi r16, 0xff          ; make PortB&PortA as output           
 out DDRD, r16			; output num
  
 CBI  DDRC, 0			; 0-999
 CBI  DDRC, 1			; 999-0
 CBI  DDRC, 2			; stop
 CBI  DDRC, 3			; clear
 CBI  DDRC, 4			; clear

 SBI  DDRB, 0			; led
 SBI  DDRB, 1			; output หลักร้อย
 SBI  DDRB, 2			; output หลักสิบ
 SBI  DDRB, 3			; output หลักหน่วย

 ldi r26, 0xC0			;เเสดงเริ่มต้น 0
 CBI PORTB, 0			; ปิด led
 SBI PORTB, 1			; เปิด port digit หลักร้อย
 SBI PORTB, 2			; เปิด port digit หลักสิบ
 SBI PORTB, 3			; เปิด port digit หลักหน่วย

 out portD, r26
 	
 AGAIN:					
	SBIC PINC, 0		; skip next if PD7 is clear
	rjmp swCountup
	SBIC PINC, 1		; skip next if PD6 is clear
	rjmp swCountdown
	rjmp AGAIN

r:
	CBI PORTB,1
	CBI PORTB,2
	CBI PORTB,3 
	rcall delays
	rcall EEPROM_READ
	mov r25, r28
	rcall EEPROM_READ2
	mov r23, r29
	ldi r22, 0
	rjmp h
	

swCountup:					
	ldi r22, 1		
	rjmp countHun
swCountdown:
	ldi r22, 0
	rjmp countHun

function:				
	SBIC PINC, 2			; skip next if PC2 is clear
	rjmp stop
	SBIC PINC, 3			; skip next if PC3 is clear
	rjmp main
	SBIC PINC, 0			; skip next if PC0 is clear	(sw count up)
	rjmp up
	SBIC PINC, 1			; skip next if PC1 is clear	(sw count down)
	rjmp down
	SBIC PINC, 4			; skip next if PC1 is clear	(sw count down)
	rjmp r
	ret

checkSw:
	SBIC PINC, 3			; skip next if PC3 is clear  (sw clear)
	rjmp main
	SBIC PINC, 0			; skip next if PC0 is clear	(sw count up)
	rjmp up
	SBIC PINC, 1			; skip next if PC1 is clear	(sw count down)
	rjmp down
	SBIC PINC, 4			; skip next if PC1 is clear	(sw count down)
	rjmp r
	rjmp stop 

up:							;นับขึ้น
	CBI PORTB,0
	cpi r22,1
	breq delaySeg
	
	ldi r22,1	
	ldi r20, 99
	sub r20, r25
	mov r25,r20

	ldi r20,9
	sub r20,r23
	mov r23,r20
	rjmp delaySeg

down:						;นับลง
	CBI PORTB,0
	cpi r22,0
	breq delaySeg
	
	ldi r22,0	
	ldi r20, 99
	sub r20, r25
	mov r25,r20

	ldi r20,9
	sub r20,r23
	mov r23,r20
	rjmp delaySeg

 countHun:    
	clr r23			; count hundred = 0
                          
 hundred:  
	clr r25			; count(0-99) = 0
 h:
	mov r17,r23		

 loophun :       
	push r16         
	mov numHun,r17		
	rcall converseHun    ;7-segment
	mov r11,r0           ;ค่าที่จะเเสดงในหลักร้อย
	pop numHun           

 last2digits:    
	mov r4,r25	
		
 loop :     
	rcall for    
	push r16   
	mov num,r4				
	rcall converse    ;7-segment
	mov r9,r0         ;ค่าที่จะเเสดงในหลักหน่วย
	pop num           
	rcall converse    ;7-segment
	mov r10,r0        ;ค่าที่จะเเสดงในหลักสิบ
                            
 delaySeg: ldi r21,50
    
 loopDigits:      
	 
	CBI PORTB,1
	CBI PORTB,2
	SBI PORTB,3  
	out PORTD,r9			;แสดงเลข 7-segmentในหลักหน่วย
	rcall delays 
	
	CBI PORTB,1
	CBI PORTB,3
	SBI PORTB,2
	out PORTD,r10          ;แสดงเลข 7-segmentในหลักสิบ
	rcall delays 

	CBI PORTB,2
	CBI PORTB,3
	SBI PORTB,1
	out PORTD,r11         ;แสดงเลข 7-segmentในหลักร้อย
	rcall delays     
	
	dec r21 

	mov r28,r25
	rcall EEPROM_WRITE
	mov r29,r23
	rcall EEPROM_WRITE2

	rcall function  
	brne loopDigits
	     
    
	inc r25    
	cpi r25,100          ;check count 0-99
	brne last2digits   

	inc r23
	cpi r23,10			;check count 0-9 ????????
	brne hundred

	rjmp stop

 stop: 
	SBI PORTB,0
	
	CBI PORTB,1
	CBI PORTB,2
	SBI PORTB,3  
	out PORTD,r9          ;แสดงเลข 7-segmentในหลักหน่วย
	rcall delays 
	
	CBI PORTB,1
	CBI PORTB,3
	SBI PORTB,2
	out PORTD,r10         ;แสดงเลข 7-segmentในหลักสิบ
	rcall delays 

	CBI PORTB,2
	CBI PORTB,3
	SBI PORTB,1
	out PORTD,r11         ;แสดงเลข 7-segmentในหลักร้อย

	CBI PORTB,0  
	rcall delays
	rjmp checkSw

converseHun:    
	cpi r22,1	   
	breq coutUphun
	cpi r22, 0
	breq coutDownhun
	ret
coutUphun:
	clr r2    
	ldi zh,high(numUp<<1)				
	ldi zl,low(numUp<<1)     
	add zl,numHun                             
	adc zh, r2     
	lpm                          ;load pointer z เก็บไว้ใน r0            
	ret 
coutDownhun:
	clr r2    
	ldi zh,high(numDown<<1)				
	ldi zl,low(numDown<<1)     
	add zl,numHun                             
	adc zh, r2     
	lpm                                ;load pointer z เก็บไว้ใน r0
	ret 
      
 converse:    
	cpi r22,1
	breq countUp
	cpi r22, 0
	breq countdown
	ret
 countUp:
	clr r2    
	ldi zh,high(numUp<<1)				
	ldi zl,low(numUp<<1)     
	add zl,num                             
	adc zh, r2     
	lpm                                ;load pointer z เก็บไว้ใน r0        
	ret  
 countdown:
	clr r2    
	ldi zh,high(numDown<<1)				
	ldi zl,low(numDown<<1)     
	add zl,num                             
	adc zh, r2     
	lpm                                 ;load pointer z เก็บไว้ใน r0
	ret     

 delays:     
	 ldi r16,20   
 loop1:    
	ldi r17,255
 loop2:    
	dec r17   
	brne loop2    
	dec r16        
	brne loop1    
	nop
	ret 

 for:    
	ldi r16,10    
	mov r3,r16    
	ldi r16,0                          
for2:    
	 cp r4,r3             
	 brlo return   
	 inc r16                              
	 sub r4,r3    
	 rjmp for2    

 return:    
	ret    

numUp:    ; list 7-segment
 .db    0xc0,    0xf9,    0xa4,    0xb0,    0x99,    0x92,    0x82,    0xf8,  0x80,0x90

 numDown:    ;list 7-segment
 .db    0x90,  0x80 , 0xf8 , 0x82 , 0x92, 0x99, 0xb0 , 0xa4 , 0xf9 , 0xc0