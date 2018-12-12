TITLE Fibonacci Numbers     (FibonacciNumbers.asm)

; Author: Joel Huffman
; Last Modified: 10/11/2018
; OSU email address: huffmajo@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 2               Due Date: 10/14/2018
; Description: Program gets the user's name and an integer from 1 to 46. Then the fibonacci numbers from 1
; to the entered integer are printed in aligned columns with a maximum of 5 numbers per row/line. 

INCLUDE Irvine32.inc

LOWER_LIMIT	= 1
UPPER_LIMIT	= 46
ROW_LENGTH = 5

.data

userName			BYTE 33 DUP(0)			;name entered by user
fibNum				DWORD			?		;number of fibonacci terms, entered by user
fib_1				DWORD			1		;first fibonacci number used to calculate next in series
fib_2				DWORD			0		;second fibonacci number used to calculate next in series
counter				DWORD			1		;tracks current fibonacci number in sequence
programTitle		BYTE	"Fibonacci Numbers ", 0
myName				BYTE	"by Joel Huffman", 0
ec_1				BYTE	"**EC: Fibonacci numbers are displayed in aligned columns", 0
prompt_1			BYTE	"What's your name? ", 0
greeting			BYTE	"Hello, ", 0
instruct_1			BYTE	"Enter the number of Fibonacci terms to be displayed", 0
instruct_2			BYTE	"Give the number as an integer in the range [1...46]", 0
instruct_3			BYTE	"How many Fibonacci terms do you want? ", 0
outOfRange			BYTE	"Out of range. Enter a number in the range [1...46]", 0
spaces				BYTE	"             ", 0
goodBye				BYTE	"Goodbye, ", 0


.code
main PROC

;program title, author and ec completed
	mov		edx, OFFSET programTitle
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	call	CrLF
	mov		edx, OFFSET ec_1
	call	WriteString
	call	CrLF
	call	CrLf

;greet the user
	mov		edx, OFFSET prompt_1
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, 32
	call	ReadString
	call	CrLf
	mov		edx, OFFSET greeting
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf

;give user instructions
	mov		edx, OFFSET instruct_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instruct_2
	call	WriteString
	call	CrLf
getFibNum:
	call	CrLF
	mov		edx, OFFSET instruct_3
	call	WriteString

;get data from user
	call	ReadInt
	mov		fibNum, eax
	cmp		eax, LOWER_LIMIT
	jl		invalidFibNum
	cmp		eax, UPPER_LIMIT
	jg		invalidFibNum
	call	CrLf
	call	CrLf
	mov		ecx, fibNum
	jmp		fibLoop

invalidFibNum:
	mov		edx, OFFSET outOfRange
	call	WriteString
	call	CrLf
	jmp		getFibNum

;calculate next fibonacci number
fibLoop:
	mov		eax, fib_2
	mov		ebx, fib_2
	add		eax, fib_1
	call	WriteDec
	mov		fib_2, eax
	mov		fib_1, ebx

;check if tab or line break should follow latest number
	mov		eax, counter
	cmp		eax, ROW_LENGTH
	jl		tabs
	xor		edx, edx
	mov		ebx, ROW_LENGTH
	div		ebx
	cmp		edx, 0
	jne		tabs
lineBreak:
	call	CrLf
	jmp		endLoop
tabs:
	mov		al, 9
	call	WriteChar
	mov		eax, counter
	cmp		eax, 35
	jg		endLoop
	mov		al, 9
	call	WriteChar
endLoop:
	inc		counter
	loop	fibLoop

;say good-bye
	mov		eax, white + (black * 16)
	call	SetTextColor
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodBye
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

END main
