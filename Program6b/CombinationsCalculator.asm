TITLE CombinationsCalculator    (CombincationsCalculator.asm)

; Author: Joel Huffman
; Last Modified: 12/01/2018
; OSU email address: huffmajo@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 6b             Due Date: 12/02/2018 
; Description: Provide randomized r and n values for a combination problem to the user and prompt
; for an answer. Then check and provide feedback on the correctness of the answer. Keep creating
; problems until the user chooses to quit.

INCLUDE Irvine32.inc

N_HIGH = 12
N_LOW = 3
R_LOW = 1

;----------------------------------------------------
; displayString
;
; Prints the provided string.
;
; Parameters: @str
; Returns: nothing
; Preconditions: none
; Postconditions: none
; Registers changed: edx
;----------------------------------------------------
displayString MACRO str
	push	edx
	mov		edx, str
	call	WriteString
	pop		edx
ENDM

.data

programTitle		BYTE	"Combinations Calculator by Joel Huffman", 0
ec_1				BYTE	"**EC: Problems are numbered with total score printed at end of program.", 0
instruct_1			BYTE	"I'll give you a combinations problem. You enter your answer,", 0
instruct_2			BYTE	"and I'll let you know if you're right.", 0
problemStr			BYTE	"Problem ", 0
nStr				BYTE	"Number of elements in set: ", 0
rStr				BYTE	"Number of elements to choose from the set: ", 0
answerPrompt		BYTE	"How many combinations are there: ", 0
answerStr1			BYTE	"There are ", 0
answerStr2			BYTE	" combinations of ", 0
answerStr3			BYTE	" items from a set of ", 0
correctStr			BYTE	"You are correct!", 0
wrongStr			BYTE	"You are wrong :(", 0
repeatPrompt		BYTE	"Another problem? (y/n)", 0
invalidPrompt		BYTE	"Invalid response. ", 0
goodBye				BYTE	"Thanks for using the Combinations Calculator!", 0
numCorrectStr		BYTE	"Number of problems answered correctly: ", 0
numWrongStr			BYTE	"Number of problems answered incorrectly: ", 0
n					DWORD	?		;randomized n value [3..12]
r					DWORD	?		;randomized r value [1..n]
nFactorial			DWORD	1		;calculated value of n!
rFactorial			DWORD	1		;calculated value of r!
n_rFactorial		DWORD	1		;calculated value of (n-r)!
userAnswer			DWORD	?		;user-submitted answer
actualAnswer		DWORD	?		;calculated answer
problemNum			DWORD	1		;the number of problem the user is solving
score				DWORD	0		;quantity of problems answered correctly


.code
main PROC
;seed randomize 
	call	Randomize
;display introduction and instructions
	push	OFFSET programTitle	;+20
	push	OFFSET ec_1			;+16
	push	OFFSET instruct_1	;+12
	push	OFFSET instruct_2	;+8
	call	introduction
;calculate and show problem to user
displayProblem:
	push	problemNum	;+28
	push	OFFSET problemStr	;+24
	push	OFFSET nStr			;+20
	push	OFFSET rStr			;+16
	push	OFFSET n			;+12
	push	OFFSET r			;+8
	call	showProblem
;prompt for and get answer from user
	push	OFFSET answerPrompt	;+12
	push	OFFSET userAnswer	;+8
	call	getData
;calculate combinations
	push	n					;+28
	push	OFFSET nFactorial	;+24
	push	r					;+20
	push	OFFSET rFactorial	;+16
	push	OFFSET n_rFactorial	;+12
	push	OFFSET actualAnswer	;+8
	call	combination
;show results and give user feedback
	push	OFFSET score		;+44
	push	actualAnswer		;+40
	push	n					;+36
	push	r					;+32
	push	userAnswer			;+28
	push	OFFSET answerStr1	;+24
	push	OFFSET answerStr2	;+20
	push	OFFSET answerStr3	;+16
	push	OFFSET correctStr	;+12
	push	OFFSET wrongStr		;+8
	call	showResults
;check for repeat
repeatCheck:
	displayString	OFFSET repeatPrompt
	call			readChar
	cmp				al, 110			;check for 'n'
	je				theEnd
	cmp				al, 121			;check for 'y'
	je				resetPrep
	call			CrLf
	displayString	OFFSET invalidPrompt
	jmp				repeatCheck
resetPrep:
	push			OFFSET problemNum	;+20
	push			OFFSET nFactorial	;+16
	push			OFFSET rFactorial	;+12
	push			OFFSET n_rFactorial	;+8
	call			resetFactorials		
	jmp				displayProblem
;say goodbye
theEnd:
	push	OFFSET numWrongStr			;+24
	push	OFFSET numCorrectStr		;+20
	push	problemNum					;+16
	push	score						;+12
	push	OFFSET goodBye				;+8
	call	programEnd
	exit	; exit to operating system
main ENDP

;----------------------------------------------------
; introduction
;
; Displays an introduction message outlining what the
; program does and who wrote it.
;
; Parameters: @programTitle, @ec_1, @instruct1, @instruct2 
; Returns: nothing
; Preconditions: none
; Postconditions: none
; Registers changed: edx
;----------------------------------------------------
introduction PROC
	push			ebp
	mov				ebp, esp
	displayString	[ebp+20]	;print title and author
	call			CrLf
	displayString	[ebp+16]	;print ec
	call			CrLf
	call			CrLf
	displayString	[ebp+12]	;print instructions
	call			CrLf
	displayString	[ebp+8]		;print additional instructions
	pop				ebp
	ret				16
introduction ENDP

;----------------------------------------------------
; ShowProblem
;
; Calculates a value for n [3..12] and r [1..n]. Then
; Lets the user now those values.
; 
; Parameters: problemNum, @problemStr, @nStr, @rStr, @n, @r
; Returns: n and r values
; Preconditions: none
; Postconditions: n and r values are not populated
; Registers changed: eax, ebx, ecx, edx
;----------------------------------------------------
showProblem PROC
	push			ebp
	mov				ebp, esp
	pushad
	call			CrLf
	call			CrLf
;generate value for n [3..12]
	mov				ebx, [ebp+12]
	mov				eax, N_HIGH
	sub				eax, N_LOW
	inc				eax
	call			RandomRange
	add				eax, N_LOW
	mov				[ebx], eax	
;generate value for r [1..n]
	mov				ecx, [ebp+8]
	sub				eax, R_LOW
	inc				eax
	call			RandomRange
	add				eax, R_LOW
	mov				[ecx], eax
;print problem to screen for user
	displayString	[ebp+24]		;print "problem "
	mov				eax, [ebp+28]
	call			WriteDec
	call			CrLf
	displayString	[ebp+20]		;print setup for n
	mov				eax, [ebx]		;print n
	call			writeDec		
	call			CrLf
	displayString	[ebp+16]		;print setup for r
	mov				eax, [ecx]		;print r
	call			writeDec		
	call			CrLf
	popad
	pop				ebp
	ret				24
showProblem ENDP

;----------------------------------------------------
; getData
;
; Prompts the user for an answer to the problem. That
; answer is then stored in the userAnswer variable
; 
; Parameters: @userAnswer @answerPrompt
; Returns: user-submitted userAnswer 
; Preconditions: none
; Postconditions: userAnswer is now populated
; Registers changed: eax, ebx
;----------------------------------------------------
getData PROC
	push			ebp
	mov				ebp, esp
	pushad
	displayString	[ebp+12]		;print prompt for answer
	mov				ebx, [ebp+8]	;load @userAnswer
	call			readInt
	mov				[ebx], eax
	call			CrLf
	call			CrLf
	popad
	pop				ebp
	ret				8
getData ENDP

;----------------------------------------------------
; combination
;
; Calculates the actual number of combinations using
; the following equation: n!/[r!*(n-r)!]
; 
; Parameters: n, @nFactorial, r, @rFactorial, 
; @n_rFactorial, @actualAnswer
; Returns: actuaAnswer has the calculated answer
; Preconditions: n and r must be determined
; Postconditions: actualAnswer now has the correct
; answer
; Registers changed: eax, ebx, ecx, edx, edi
;----------------------------------------------------
combination PROC
	push	ebp
	mov		ebp, esp
	pushad
;calculate (n-r)!
	mov		eax, [ebp+28]	;load n
	mov		ebx, [ebp+20]	;load r
	sub		eax, ebx
	mov		ebx, [ebp+12]	;load @n_rFactorial
	push	ebx
	push	eax
	call	factorial
;calculate r!
	mov		eax, [ebp+20]	;load r
	mov		ecx, [ebp+16]	;load @rFactorial
	push	ecx
	push	eax
	call	factorial

;calculate n!
	mov		eax, [ebp+28]	;load n
	mov		edi, [ebp+24]	;load @nFactorial
	push	edi
	push	eax
	call	factorial
;calculate r!(n-r!)
	mov		edx, [ebx]		
	mov		eax, [ecx]
	mul		edx				
	mov		ecx, eax		;ecx now contains r!(n-r!)
;calculate n!/[r!(n-r)!]
	mov		eax, [edi]
	xor		edx, edx
	div		ecx
;put result in actualAnswer
	mov		ebx, [ebp+8]
	mov		[ebx], eax
	popad
	pop		ebp
	ret		8
combination ENDP

;----------------------------------------------------
; factorial
;
; Calculates the input value's factorial and returns 
; this factorial in the output's address. Behold the 
; power of RECURSION!
;
; Parameters: input, @output
; Returns: input's factorial in @output
; Preconditions: input must be positive
; Postconditions: @output now has input's factorial
; Registers changed: eax, ebx, ecx, edx
;----------------------------------------------------
factorial PROC
	push	ebp
	mov		ebp, esp
	pushad
	mov		ecx, [ebp+12]	;@output
	mov		ebx, [ebp+8]	;input
	cmp		ebx, 0
	je		quit
	mov		eax, [ecx]
	mul		ebx
	mov		[ecx], eax
	cmp		ebx, 1
	je		quit
recurse:
	dec		ebx
	push	ecx
	push	ebx
	call	factorial
quit:
	popad
	pop		ebp
	ret		8
factorial ENDP

;----------------------------------------------------
; showResults
;
; Prints n, r and and the calculated answer. Then lets
; the user know if their submitted answer was correct.
; Increments score if user is correct.
; 
; Parameters: @score, actualAnswer, n, r, userAnswer, 
; @answerStr1, @answerStr2, @answerStr3, @correctStr, 
; @wrongStr
; Returns: none
; Preconditions: All parameters are populated 
; Postconditions: none
; Registers changed: eax, ebx
;----------------------------------------------------
showResults PROC
	push			ebp
	mov				ebp, esp
	pushad
	displayString	[ebp+24]	
	mov				eax, [ebp+40]	;print actualAnswer
	call			WriteDec
	displayString	[ebp+20]
	mov				eax, [ebp+32]	;print r
	call			writeDec
	displayString	[ebp+16]
	mov				eax, [ebp+36]	;print n
	call			writeDec
	call			CrLf
;verify user answer
	mov				eax, [ebp+40]	;load calculated answer
	mov				ebx, [ebp+28]	;load users answer
	cmp				eax, ebx
	je				isCorrect
isWrong:
	displayString	[ebp+8]
	jmp				endResults
isCorrect:
	displayString	[ebp+12]
	mov				eax, [ebp+44]	;load @score
	mov				ebx, 1
	add				[eax], ebx
endResults:
	call			CrLf
	call			CrLf
	popad
	pop				ebp
	ret				36
showResults ENDP

;----------------------------------------------------
; resetFactorials
;
; Resets the factorial values to 1 for repeated problems. 
; Also increments problemNum.
;
; Parameters: @problemNum, @nfactorial, @rFactorial, @n_rFactorial
; Returns: All factorials with a value of 1
; Preconditions: none
; Postconditions: All factorials are populated with 1
; Registers changed: eax, ebx
;----------------------------------------------------
resetFactorials PROC
	push	ebp
	mov		ebp, esp
	pushad
	mov		ebx, 1
	mov		eax, [ebp+16]
	mov		[eax], ebx
	mov		eax, [ebp+12]
	mov		[eax], ebx
	mov		eax, [ebp+8]
	mov		[eax], ebx
	mov		eax, [ebp+20]	;load @problemNum
	add		[eax], ebx		;increment problemNum
	popad
	pop		ebp
	ret		12
resetFactorials ENDP

	push	problemNum			;+16
	push	score				;+12
	push	OFFSET goodBye		;+8
;----------------------------------------------------
; programEnd
;
; Prints the users final score and a parting message. 
;
; Parameters: @numWrongStr, @numCorrectStr, problemNum,
; score, @goodBye
; Returns: nothing
; Preconditions: none
; Postconditions: none
; Registers changed: eax, ebx
;----------------------------------------------------
programEnd PROC
	push			ebp
	mov				ebp, esp
	call			CrLf
	call			CrLf
	displayString	[ebp+20]		;print string for correct answers
	mov				eax, [ebp+12]	;load score
	mov				ebx, eax
	call			writeDec
	call			CrLf
	displayString	[ebp+24]		;print string for wrong answers
	mov				eax, [ebp+16]	;load problemNum
	sub				eax, ebx		;problemNum - score = #wrong
	call			WriteDec
	call			CrLf
	displayString	[ebp+8]		;print parting message
	call			CrLf
	pop				ebp
	ret				4
programEnd ENDP

END main
