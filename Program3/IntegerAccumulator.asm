TITLE Integer Accumulator     (IntegerAccumulator.asm)

; Author: Joel Huffman
; Last Modified: 10/27/2018
; OSU email address: huffmajo@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 3               Due Date: 10/28/2018
; Description: Program gets the user's name and an integer from 1 to 46. Then the fibonacci numbers from 1
; to the entered integer are printed in aligned columns with a maximum of 5 numbers per row/line. 

INCLUDE Irvine32.inc

LOWER_LIMIT	= -100

.data

userName			BYTE 33 DUP(0)			;name entered by user
userNum				DWORD			?		;validated integer entered by user
counter				DWORD			0		;tracks quantity of valid numbers entered
sum					DWORD			0		;sum of valid numbers entered
average				DWORD			?		;average of valid numbers entered
remainder			DWORD			?		;remainder from divison to find average
halfCounter			DWORD			?		;half of counter value, used for determining rounding
programTitle		BYTE	"Integer Accumulator  ", 0
myName				BYTE	"by Joel Huffman", 0
ec_1				BYTE	"**EC: Lines for user input numbers are numbered.", 0
prompt_1			BYTE	"What's your name? ", 0
greeting			BYTE	"Hello, ", 0
instruct_1			BYTE	"Please enter numbers in [-100, -1].", 0
instruct_2			BYTE	"Enter  a non-negative number when you are finished to see results.", 0
instruct_3			BYTE	") Enter a number: ", 0
outOfRange			BYTE	"Entered number is out of range. Try entering a number in [-100, -1] or a non-negative number when finished.", 0
numbersEntered_1	BYTE	"You entered ", 0
numbersEntered_2	BYTE	" valid numbers.", 0 
numbersSum			BYTE	"The sum of your valid numbers is ", 0
numbersAverage		BYTE	"The rounded average is ", 0
numbersAverageFloat	BYTE	"The floating-point average is ", 0
noValidNums			BYTE	"No valid numbers were entered.", 0
goodBye_1			BYTE	"Thanks for playing Integer Accumulator! See ya later, ", 0
goodBye_2			BYTE	"!", 0

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

;prompt user to enter integers and validate input
inputLoop:
	call	validateInput
	cmp		eax, 0
	jns		exitInputLoop
	inc		counter
	mov		eax, userNum
	add		sum, eax
	jmp		inputLoop

;calculate average of entered negative numbers
exitInputLoop:
	cmp		counter, 0
	je		noNumEntered
	xor		edx, edx
	mov		eax, sum
	cdq
	mov		ebx, counter
	idiv	ebx
	mov		average, eax
;check rounding on average
	mov		remainder, edx
	cmp		edx, 1
	jle		roundUp
	mov		ebx, remainder
	mov		eax, -1
	mul		ebx
	mov		remainder, eax
	mov		eax, counter
	mov		ebx, 2
	xor		edx, edx
	div		ebx
	mov		halfCounter, eax
	mov		eax, remainder
	cmp		eax, halfCounter
	jl		roundUp		
roundDown:
	dec		average
roundUp:
	

;display results:
;display number of negative numbers entered
	mov		edx, OFFSET numbersEntered_1
	call	WriteString
	mov		eax, counter
	call	WriteDec
	mov		edx, OFFSET numbersEntered_2
	call	WriteString
	call	CrLf

;display sum of negative numbers entered
	mov		edx, OFFSET numbersSum
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf
	
;display average of negative numbers entered
	mov		edx, OFFSET numbersAverage
	call	WriteString
	mov		eax, average
	call	WriteInt
	jmp		partingMessage

;print special message if no valid numbers were entered
noNumEntered:
	mov		edx, OFFSET noValidNums
	call	WriteString

;say good-bye
partingMessage:
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodBye_1
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET goodBye_2
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

;----------------------------------------------------
; validateInput
;
; Prompts user for integer and continues re-prompting 
; until entered input is within the limits (>=-100) 
; Receives: none
; Returns:	userNum
;----------------------------------------------------
validateInput PROC
getInput:
	mov		eax, counter
	inc		eax
	call	WriteDec
	mov		edx, OFFSET instruct_3
	call	WriteString
	call	ReadInt
	cmp		eax, LOWER_LIMIT
	jge		isValid
	call	CrLf
	mov		edx, OFFSET outOfRange
	call	WriteString
	call	CrLf
	jmp		getInput
isValid:
	mov		userNum, eax
	ret
validateInput ENDP

END main
