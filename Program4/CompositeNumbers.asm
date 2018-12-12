TITLE Composite Numbers     (CompositeNumbers.asm)

; Author: Joel Huffman
; Last Modified: 11/02/2018
; OSU email address: huffmajo@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 4               Due Date: 11/04/2018
; Description: Program gets an integer from the user from 1-400. Then that quantity of composite
; numbers is printed (starting at 4) 10 numbers per line.

INCLUDE Irvine32.inc

LOWER_LIMIT	= 1
UPPER_LIMIT = 400

.data

userNum				DWORD			?		;validated integer entered by user
currentNum			DWORD			4		;current number being checked for composite-ness
currentDivisor		DWORD			2		;used to determine if currentNum is composite
lineCounter			DWORD			1		;tracks how many printed numbers are on the current line
programTitle		BYTE	"Composite Numbers  ", 0
myName				BYTE	"by Joel Huffman", 0
ec_1				BYTE	"**EC: Output columns are aligned.", 0
instruct_1			BYTE	"Enter the number of composite numbers you would like to see.", 0
instruct_2			BYTE	"Values from 1 to 400 are acceptable.", 0
instruct_3			BYTE	"Enter the number of composites to display [1 .. 400]: ", 0
outOfRange			BYTE	"Entered number is out of range. Try again.", 0
goodBye				BYTE	"Results verified by Joel Huffman. Goodbye.", 0


.code
main PROC

	call	introduction
	call	getUserData
	call	showComposites
	call	farewell

	exit	; exit to operating system
main ENDP

;----------------------------------------------------
; introduction
;
; Displays an introduction message outlining what the
; program does and who wrote it.
; Preconditions: none
; Postconditions: none
; Registers changed: edx
;----------------------------------------------------
introduction PROC
;print program title
	mov		edx, OFFSET programTitle
	call	WriteString
;print author
	mov		edx, OFFSET myName
	call	WriteString
	call	CrLF
;print ec completed
	mov		edx, OFFSET ec_1
	call	WriteString
	call	CrLF
	call	CrLf
;print instructions
	mov		edx, OFFSET instruct_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instruct_2
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP

;----------------------------------------------------
; getUserData
;
; Prompts user for number of composite numbers to be 
; printed. If that number is out of range re-prompts.
; If a valid number is given, program continues.
; Preconditions: none
; Postconditions: userNum is verified valid
; Registers changed: eax, edx
;----------------------------------------------------
getUserData PROC
	mov		edx, OFFSET instruct_3
	call	WriteString
	call	ReadInt
	mov		userNum, eax
	call	validateInput
	ret
getUserData ENDP

;----------------------------------------------------
; validateInput
;
; Checks if userNum is within the limits. If not, an
; error message is displayed and getUserData is called
; Preconditions: userNum must be populated with a user
; entered value
; Postconditions: none
; Registers changed: eax, edx
;----------------------------------------------------
validateInput PROC
	mov		eax, userNum
	cmp		eax, UPPER_LIMIT
	jg		invalid
	cmp		eax, LOWER_LIMIT
	jl		invalid
	jmp		valid
invalid:
;print out of range message and prompt to try again
	mov		edx, OFFSET outOfRange
	call	WriteString
	call	CrLF
;attempt to get user data again
	call	getUserData
valid:
	ret
validateInput ENDP

;----------------------------------------------------
; showComposites
;
; Prints the amount of composite numbers the user 
; requested in ascending order, 10 per line.
; Preconditions: userNum must be valid
; Postconditions: none
; Registers changed: ecx
;----------------------------------------------------
showComposites PROC
	mov		ecx, userNum
startShowComp:
;check if currentNum is composite
	call	isComposite
	call	printComposite
	loop startShowComp
	ret
showComposites ENDP

;----------------------------------------------------
; isComposite
;
; Checks if currentNum is composite or prime
; requested in ascending order, 10 per line.
; Preconditions: currentNum must be valid
; Postconditions: currentNum is the next composite number
; Registers changed: eax, ebx, edx
;----------------------------------------------------
isComposite PROC
startIsComp:
	mov		eax, currentNum
	mov		ebx, currentDivisor
;if currentNum == currentDivisor, currentNum is prime
	cmp		eax, currentDivisor
	je		isPrime
	xor		edx, edx
	div		ebx
	cmp		edx, 0
	je		endIsComp
	inc		currentDivisor
	jmp		startIsComp
;check next number for composite-ness, reset currentDivisor
isPrime:
	inc		currentNum
	mov		eax, 2
	mov		currentDivisor, eax
	jmp		startIsComp
endIsComp:
	ret
isComposite ENDP

;----------------------------------------------------
; printComposite
;
; Prints currentNum
; Preconditions: currentNum must be confirmed composite
; Postconditions: currentNum printed to screen
; Registers changed: eax, al
;----------------------------------------------------
printComposite PROC
;print next composite number
	mov		eax, currentNum
	call	WriteDec
	inc		currentNum
	mov		eax, 2
	mov		currentDivisor, eax
	mov		eax, lineCounter
;insert tab if <=10 numbers in the current line
	cmp		lineCounter, 10
	jge		lineReturn
	mov		al, 9
	call	WriteChar
	inc		lineCounter
	jmp		endPrintComposite
;insert return if >10 numbers in current line
lineReturn:
	call	CrLf
	mov		eax, 1
	mov		lineCounter, eax
endPrintComposite:
	ret
printComposite ENDP

;----------------------------------------------------
; farewell
;
; Displays a parting message. Includes the programmer's
; name
; Preconditions: none
; Postconditions: none
; Registers changed: edx
;----------------------------------------------------
farewell PROC
	call	CrLf
	call	CrLf
;print farewell message
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLf
	ret
farewell ENDP

END main
