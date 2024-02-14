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
.ORG 0x02				//Vector interrupçion int0
	JMP ISR_INT0
.ORG 0x04				//Vector interrupçion int1
	JMP ISR_INT1
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
	LDI R16, 0x00
	OUT DDRD, R16

	LDI R16, 0b0000_1111
	OUT DDRC, R16

	LDI R16, 0b0000_1100
	OUT PORTD, R16

	LDI R16, (0<<ISC01) | (1<<ISC00) | (0<<ISC11) | (1<<ISC10) 
	STS EICRA, R16					

	SBI EIMSK, INT0
	SBI EIMSK, INT1

	LDI R17, 0x00
	SEI		
//*******************************************************
// Apagar tx y rx
//*******************************************************

	LDI R16, 0x00
	STS UCSR0B, R16

//*******************************************************
// LOOP
//*******************************************************
loop:
	OUT PORTC, R17
	RJMP loop
//*****************************************************************************
// Sub-rutinas
//*****************************************************************************
ISR_INT0:
	PUSH R16
	IN R16, SREG
	PUSH R16

	INC R17
	SBRS R17, 1
	RJMP Regresar1

	INC R19 
    SBRC R19, 4 
	CLR R19
	CLR R17
Regresar1:
	POP R16
	OUT SREG, R16
	POP R16
	RETI

ISR_INT1:
	PUSH R16
	IN R16, SREG
	PUSH R16

	INC R17
	SBRS R17, 1
	RJMP Regresar2

	DEC R19 
    SBRC R19, 7
	CLR R19
	CLR R17

Regresar2:
	POP R16
	OUT SREG, R16
	POP R16
	NOP
	RETI