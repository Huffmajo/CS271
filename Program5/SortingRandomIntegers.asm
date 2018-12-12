TITLE Sorting Random Integers     (SortingRandomIntegers.asm)

; Author: Joel Huffman
; Last Modified: 11/20/2018
; OSU email address: huffmajo@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 5               Due Date: 11/18/2018 (11/20/2018 with 2 grace days)
; Description: Print a user-chosen number[10-200] of random integers [10-999].
; Then print the median value and the list again, but in descending order.

INCLUDE Irvine32.inc

MIN	= 10
MAX = 200
LO = 100
HI = 999

.data

request				DWORD		?			;user-provided quantity of random integers to generate
array				DWORD		MAX DUP(?)	;array for populating with random integers
programTitle		BYTE	"Sorting Random Integers by Joel Huffman", 0
ec_1				BYTE	"**EC: Nothing right now.", 0
instruct_1			BYTE	"This program, generates random numbers in the range [100 .. 999],", 0
instruct_2			BYTE	"displays the original list, sorts the list, and calculates the", 0
instruct_3			BYTE	"median value. Finally it displays the list sorted in descending order.", 0
instruct_4			BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
outOfRange			BYTE	"Entered number is out of range. Try again.", 0
unsorted			BYTE	"The unsorted random numbers:", 0
sorted				BYTE	"The sorted random numbers:", 0
medianMessage		BYTE	"The median is ", 0
goodBye				BYTE	"Results verified by Joel Huffman. Goodbye.", 0


.code
main PROC
;initialize random seed
	call	Randomize
;display introduction and instructions
	push	OFFSET instruct_3
	push	OFFSET instruct_2
	push	OFFSET instruct_1
	push	OFFSET ec_1
	push	OFFSET programTitle
	call	introduction
;get and validate request data from user
	push	OFFSET instruct_4
	push	OFFSET request
	push	OFFSET outOfRange
	call	getUserData
;fill array with random numbers
	push	OFFSET array
	push	request
	call	fillArray
;display unsorted array
	push	OFFSET unsorted
	push	OFFSET array
	push	request
	call	displayList
;sort the array
	push	OFFSET array
	push	request
	call	sortList
;display the median of the array
	push	OFFSET medianMessage
	push	OFFSET array
	push	request
	call	displayMedian
;display the sorted array
	push	OFFSET sorted
	push	OFFSET array
	push	request
	call	displayList
	exit	; exit to operating system
main ENDP

;----------------------------------------------------
; introduction
;
; Displays an introduction message outlining what the
; program does and who wrote it.
; Parameters: @instruct3, @instruct2, @instruct1, @ec_1, @programTitle
; Returns: nothing
; Preconditions: none
; Postconditions: none
; Registers changed: edx
;----------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp
;print program title and name
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLF
;print ec completed
	mov		edx, [ebp+12]
	call	WriteString
	call	CrLF
	call	CrLf
;print instructions
	mov		edx, [ebp+16]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+20]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+24]
	call	WriteString
	call	CrLf
	call	CrLf
	pop		ebp
	ret		20
introduction ENDP

;----------------------------------------------------
; getUserData
;
; Prompts user for number of random integers to be
; generated. If that number is out of range re-prompts.
; If a valid number is given, program continues.
; Parameters: @instruct_4, @request, @outOfRange
; Returns: request
; Preconditions: none
; Postconditions: request is verified valid
; Registers changed: eax, ebx, edx
;----------------------------------------------------
getUserData PROC
	push	ebp
	mov		ebp, esp
getData:
	mov		edx, [ebp+16]	;load prompt for number
	call	WriteString			
	call	ReadInt
	mov		ebx, [ebp+12]	;load pointer to request address
	mov		[ebx], eax		
;validate input
	cmp		eax, MAX
	jg		invalid
	cmp		eax, MIN
	jl		invalid
	jmp		valid
invalid:
	mov		edx, [ebp+8]	;load outOfRange error message
	call	WriteString
	call	CrLf
	jmp		getData
valid:
	pop		ebp
	ret		12
getUserData ENDP

;----------------------------------------------------
; fillArray
;
; Fills the array with the amount of random integers 
; that the user chose.
; Parameters: @array, request
; Returns: nothing
; Preconditions: request must be valid
; Postconditions: array is not populated with random 
; integers
; Registers changed: edi, ecx, eax
;----------------------------------------------------
fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]	;load array starting address
	mov		ecx, [ebp+8]	;load requests# for loop
fillMore:
;generate random number
	mov		eax, HI
	sub		eax, LO
	inc		eax
	call	RandomRange
	add		eax, LO
;insert random number into array
	mov		[edi], eax
	add		edi, 4
	loop	fillMore
	pop		ebp
	ret		8
fillArray ENDP

;----------------------------------------------------
; sortList
;
; Sorts the elements of array into descending order.
; Parameters: @array, request
; Returns: array(sorted)
; Preconditions: array must be populated with random integers
; Postconditions: array is now sorted in descending order
; Registers changed: edi, ecx, eax, esi
;----------------------------------------------------
sortList PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]	;load array starting address
	mov		ecx, [ebp+8]	;load requests# for loop
	dec		ecx
outerLoop:
	push	ecx
	mov		edi, [ebp+12]	;load array starting address
compare:
	mov		eax, [edi]
	cmp		[edi+4], eax
	jg		moveUp
;swap elements
	push	[edi]
	push	[edi+4]
	call	swapElements
	xchg	eax, [edi+4]
	mov		[edi], eax
moveUp:
	add		edi, 4
	loop	compare
	pop		ecx
	loop	outerLoop
allDone:
	pop		ebp
	ret		8
sortList ENDP

;----------------------------------------------------
; swapElements
;
; Two passed elements swap addresses
; Parameters: @value1, @value2
; Returns: value1 and value2, but switched
; Preconditions: Both values must be valid addresses
; Postconditions: Values are now swapped (occupying the other's address)
; Registers changed: ebx, edx
;----------------------------------------------------
swapElements PROC
	push	ebp
	mov		ebp, esp
	mov		ebx, [ebp+8]	;value 1
	mov		edx, [ebp+12]	;value 2
	mov		[ebp+8], edx
	mov		[ebp+12], ebx
	pop		ebp
	ret		8
SwapElements ENDP

;----------------------------------------------------
; displayMedian
;
; Calculates the median value of the sorted array and prints it.
; Parameters: @medianMessage, @array, request
; Returns: nothing
; Preconditions: array must be populated with random number AND be sorted
; Postconditions: prints the median value
; Registers changed: eax, ebx, ecx, edx, 
;----------------------------------------------------
displayMedian PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+16]	;load prompt for median
	call	CrLf
	call	CrLf
	call	WriteString
;check if even/odd of size of array
	mov		edi, [ebp+12]	;load array starting address
	mov		eax, [ebp+8]	;load request value
	mov		ebx, 2
	xor		edx, edx
	div		ebx
	cmp		edx, 0
	je		isEven
;get element in center of array
isOdd:
	mov		ebx, 4
	mul		ebx
	add		edi, eax
	mov		eax, [edi]
	jmp		printMedian
isEven:
	mov		ebx, 4
	mul		ebx
	add		edi, eax
	mov		eax, [edi]
	add		eax, [edi-4]
	mov		ebx, 2
	xor		edx, edx
	div		ebx
printMedian:
	call	WriteDec
	pop		ebp
	ret		12
displayMedian ENDP

;----------------------------------------------------
; displayList
;
; Prints out the current array as they appear in memory.
; Parameters: @title, @array, request
; Returns: nothing
; Preconditions: array must be populated and request must be valid
; Postconditions: array is printed
; Registers changed: ebx, ecx, edi, edx, eax
;----------------------------------------------------
displayList PROC
	push	ebp
	mov		ebp, esp
	mov		ebx, 1			;load count variable for when to insert linebreak
	mov		ecx, [ebp+8]	;load loop for repeating
	mov		edi, [ebp+12]	;load starting array point
	mov		edx, [ebp+16]	;load title/description of list 
	call	CrLf
	call	CrLf
	call	WriteString
	call	CrLf
displayMore:
	mov		eax, [edi]
	call	WriteDec
	cmp		ebx, 10
	jge		lineBreak
gap:
	mov		al, 9
	call	WriteChar
	inc		ebx
	jmp		displayContinue
lineBreak:
	call	CrLf
	mov		ebx, 1
displayContinue:
	add		edi, 4
	loop	displayMore
	pop		ebp
	ret		12
displayList ENDP

END main
