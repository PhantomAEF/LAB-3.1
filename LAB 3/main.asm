//*****************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programacion de microcontroladores
// Proyecto: Lab 2
// Created: 07/2/2024 14:56
// Author : alane
//*****************************************************************************
// Encabezado
//*****************************************************************************
.INCLUDE "M328PDEF.inc"
.CSEG //Inicio del código
.ORG 0x00 
	JMP MAIN			//Vector reset
.org 0x08				//Vector interrupçion puerto b
	JMP ISR_PCINT0
.org 0x0020
	JMP TIM0_OVF
MAIN:
//*****************************************************************************
// Stack Pointer
//*****************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//*****************************************************************************
// Tabla de Valores
//*****************************************************************************
	TABLA7SEG: .DB 0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78,  0x00, 0x10, 0x08, 0x03, 0x46, 0x21, 0x06, 0x0E
//*****************************************************************************
// Configuracion
//*****************************************************************************
Setup:
//7 SEGMENTOS
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)


	LDI R16, 0b0111_1111
	OUT DDRD, R16

	LDI R16, 0b0000_1100
	OUT DDRB, R16

	LDI R16, 0b0000_1111
	OUT DDRC, R16

	LDI R16, 0b0000_0011
	OUT PORTB, R16

	LDI R16,0b0001//pines de control
	STS PCICR,R16

	LDI R16, 0b0000_0001
	STS TIMSK0, R16

	LDI R16, 0b0011 //coloca la máscara a lo pines pertenecientes
	STS PCMSK0, R16
	
	CALL IdelayT0	

	SEI		
//*******************************************************
// Apagar tx y rx
//*******************************************************

	LDI R16, 0x00
	STS UCSR0B, R16
	LDI R16, 0
	LDI R17, 0
	LDI R18, 0
	LDI R19, 0
	LDI R20, 0
	LDI R21, 0
	LDI R22, 0
	LDI R23, 0
//*******************************************************
// LOOP
//*******************************************************
loop:
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R22
	SBI PORTB, PB2
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce2
	CBI PORTB, PB2

	CALL delaybounce2

	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R18
	SBI PORTB, PB3
	LPM R20, Z
	OUT PORTD, R20

	CALL delaybounce2

	CBI PORTB, PB3

	OUT PORTC, R19
	RJMP loop
//*****************************************************************************
// Sub-rutinas
//*****************************************************************************

delaybounce2:
	LDI R16, 255

	delay2:
		DEC R16
		BRNE delay2
	ret

IdelayT0:
	LDI R16, (1 << CS02) | (1 << CS00)
	OUT TCCR0B, R16

	LDI R16, 100
	OUT TCNT0, R16

	RET
ISR_PCINT0:
	PUSH R16
	IN R16, SREG
	PUSH R16

	INC R17
	SBRS R17, 1
	RJMP FIN
Verificar:
	CLR R17
	SBRS R21, 0
	RJMP INCRE
	RJMP DECRE
INCRE:
	INC R19 
    SBRC R19, 4 
	CLR R19
	RJMP FIN
DECRE: 
	DEC R19 
    SBRC R19, 7
	CLR R19
	RJMP FIN
FIN:
	IN R21, PINB
	POP R16
	OUT SREG, R16
	POP R16
	RETI
//***********************************************************************************
//TIMER0
//***********************************************************************************
TIM0_OVF:
	PUSH R16
	IN R16, SREG
	PUSH R16

	LDI R16, 100
	OUT TCNT0, R16

	INC R23
	CPI R23, 100
	BRNE FIN2
	CLR R23
SUM:
    INC R22						//Contador de segundos
	CPI R22, 0b000_1010
    BREQ OVERFLO
	RJMP FIN2
OVERFLO:
	CLR R22
	INC R18                         //Contador de decenas
	CPI R18, 0b000_0110
	BREQ OVERFLO2
	RJMP FIN2
OVERFLO2:
	CLR R18
FIN2:
	POP R16
	OUT SREG, R16
	POP R16
	RETI