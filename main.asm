; Lab2.asm
;
; Created: 2/1/2018 3:31:55 PM
; Author : Jessica Brown, Skylar Chatman
;
; need to inport a library to convert binary to LED number
; put code here to configure I/O lines
; connected to TPIC6C595 as output
ldi R17, 8
ldi R20, 0 ; counter for time pressed
ldi R25, 0 ; counter for inc/dec mode ; initially in inc mode
out ddrb, R17
sbi   DDRB,0      ; PB0 is now output
sbi   DDRB,1      ; PB1 is now output
sbi   DDRB,2      ; PB2 is now output

; start main program
cbi   PORTB,0      ; clear PB0
cbi   PORTB,1      ; clear PB1
cbi   PORTB,2      ; clear PB2

; pushbutton interaction
rcall pressed

pressed: ; instruction checks if pushbutton is pressed
cpi R16, 0x00 ; if pressed (R16 == 0)
		breq delay ; call delay
		delay: ; delay 250ms, increment time counter, call pressed again
		     ldi   r23,10      ; r23 <-- Counter for outer loop
		 d1: ldi   r24,250     ; r24 <-- Counter for level 2 loop 
		 d2: ldi   r25,250     ; r25 <-- Counter for inner loop
		 d3: inc   r23
		 nop               ; no operation 
		 brne  d3 
	     dec   r24
         brne  d2
         dec   r23
         brne  d1
         ret
		 inc R20 ; increment counter (R20)
		 rjmp pressed ; call pressed
	; if not pressed (R16 == 1)
		cpi R20, 4 ; check R20
			brlt do_display; if < 4
				do_display:
					cpi R25, 0 ; if R25 == 0
					breq display0_inc ; call display0_inc
					rjmp display0_dec; if R25 == 1, call display0_dec
			brge switch; if >= 4
				switch:
					cpi R25, 0 ; if R25 == 0
					breq increment
						increment:
							inc R25 ; set R25 = 1
					brne decrement ; if R25 == 1
						decrement:
							dec R25 ; set R25 = 0
							rjmp pressed; call pressed

; display a digit, we are in increment mode
display0_inc:
cpi R16, 0b01100111
brne display1_inc
; if is 9, load 0 into R16 and display
ldi R16, 0b00111111  ; load pattern to display
rjmp display ; call general display subroutine

display1_inc: 
cpi R16, 0b00111111
brne display2_inc
ldi R16, 0b00000110 ; load pattern to display
rjmp display ; call general display subroutine

display2_inc:
cpi R16, 0b00000110
brne display3_inc
ldi R16, 0b01011011  ; load pattern to display
rjmp display ; call general display subroutine

display3_inc:
cpi R16, 0b01011011
brne display4_inc
ldi R16, 0b01001111 ; load pattern to display
rjmp display ; call general display subroutine

display4_inc:
cpi R16, 0b01001111
brne display5_inc
ldi R16, 0b01100110 ; load pattern to display
rjmp display ; call general display subroutine

display5_inc:
cpi R16, 0b01100110
brne display6_inc
ldi R16, 0b01101101 ; load pattern to display
rjmp display ; call general display subroutine

display6_inc:
cpi R16, 0b01101101
brne display7_inc
ldi R16, 0b01111101 ; load pattern to display
rjmp display ; call general display subroutine

display7_inc:
cpi R16, 0b01111101
brne display8_inc
ldi R16, 0b00000111 ; load pattern to display
rjmp display ; call general display subroutine

display8_inc:
cpi R16, 0b00000111
brne display9_inc
ldi R16, 0b01111111 ; load pattern to display
rjmp display ; call general display subroutine

display9_inc:
cpi R16, 0b01111111
brne display0_inc
ldi R16, 0b01100111 ; load pattern to display
rjmp display ; call display subroutine

; display a digit, we are in decrement mode
display0_dec:
cpi R16, 0b10000110
brne display1_dec
ldi R16, 0b10111111  ; load pattern to display
rjmp display ; call general display subroutine

display1_dec: 
cpi R16, 0b11011011
brne display2_dec
ldi R16, 0b10000110 ; load pattern to display
rjmp display ; call general display subroutine

display2_dec:
cpi R16, 0b11001111
brne display3_dec
ldi R16, 0b11011011  ; load pattern to display
rjmp display ; call general display subroutine

display3_dec:
cpi R16, 0b11100110
brne display4_dec
ldi R16, 0b11001111 ; load pattern to display
rjmp display ; call general display subroutine

display4_dec:
cpi R16, 0b11101101
brne display5_dec
ldi R16, 0b11100110 ; load pattern to display
rjmp display ; call general display subroutine

display5_dec:
cpi R16, 0b11111101
brne display6_dec
ldi R16, 0b11101101 ; load pattern to display
rjmp display ; call general display subroutine

display6_dec:
cpi R16, 0b10000111
brne display7_dec
ldi R16, 0b11111101 ; load pattern to display
rjmp display ; call general display subroutine

display7_dec:
cpi R16, 0b11111111
brne display8_dec
ldi R16, 0b10000111 ; load pattern to display
rjmp display ; call general display subroutine

display8_dec:
cpi R16, 0b11100111
brne display9_dec
ldi R16, 0b11111111 ; load pattern to display
rjmp display ; call general display subroutine

display9_dec:
cpi R16, 0b10111111
brne display0_dec
ldi R16, 0b11100111 ; load pattern to display
rjmp display ; call display subroutine


; display subroutine
display:
; backup used registers on stack
push R16
push R17
in R17, SREG
push R17
ldi R17, 8 ; loop --> test all 8 bits
loop:
rol R16 ; rotate left trough Carry
BRCS set_ser_in_1 ; branch if Carry set

cbi PORTB,0; set SER_IN to 0 (low)

rjmp end

set_ser_in_1:
sbi PORTB,0 ; set SER_IN to 1 (high)
end:

; put code here to generate SRCK pulse
cbi PORTB,1 ; set SRCK low
nop ; no operation for delay
nop ; no operation for delay
nop ; no operation for delay
nop ; no operation for delay
nop ; no operation for delay
sbi PORTB,1 ; set SRCK high

dec R17
brne loop
; put code here to generate RCK pulse
cbi PORTB,2 ; set RCK low
nop ; no operation for delay
nop ; no operation for delay
nop ; no operation for delay
nop ; no operation for delay
nop ; no operation for delay
sbi PORTB,2 ; set RCK high

; restore registers from stack
pop R17
out SREG, R17
pop R17
pop R16
ret