; main module for the game contest
; aim to add Entry Point, and core game loop from this file.

;https://csc.csudh.edu/mmccullough/asm/help/index.html
;Condensed source of all Irvine32 Library Procedure Calls
INCLUDE Irvine32.inc
;	have another INCLUDE Prompts.inc for the prompts needing user input, to remove Main.asm clutter?
.386
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
	;use EQU directive for dynamic scaling
GRID_SIZE     EQU 7 	;Scalable
TOTAL_CELLS   EQU GRID_SIZE * GRID_SIZE
TOTAL_TARGETS EQU 10	;Scalable as well
MAX_MISSES    EQU 3


.data
	; Board state: 0 is empty, 1 is hidden target, 2 is revealed/hit target, 3 is a missed guess
	board BYTE TOTAL_CELLS DUP(?)

	;Game variables
	targetsLeft BYTE TOTAL_TARGETS
	missesLeft BYTE MAX_MISSES

	;Space for UI Prompts
	
	;prompts set up this way so they are dynamic.
	promptRow	BYTE "Enter Row (1-",0
	promptCol	BYTE "Enter Column (1-",0
	promptCloseBracket	BYTE "): ",0
	promptWin BYTE "You Won! Congratulations!",0
	promptLose Byte"You Lose :( Try Again..?",0

	;user inputs
	inputRow	DWORD ?
	inputCol	Dword ?


.code
main PROC
 call Randomize		;fully randomize the range for later
 ;game initalization procedures to be built
					;call promptDifficulty		;To be added later
 call InitGame				;place the randomized values on the grid

 ;GameLoop will run continuously until the game ends.
 GameLoop:
  
  call RenderBoard			;Render the updated board after last user input
  ;call GetPlayerInput		;prompt and validate the user's entry
  ;call EvalGuess			;evaluate the user's entry
  ;call waitMsg				;Pauses and prints a proceed screen so use can process last game board state.
  call CheckWinOrLoss		;Check for exit state, exit if true

  jmp GameLoop
 
 
INVOKE ExitProcess,0
main ENDP

RenderBoard PROC
 ;render board using similar logic to the one in InitGame Proc
 ;check board state is looping around
 ;If 0 - Display " . ", If 1 - Display " . ", If 2 - Display " H ", If 3 - Display " M "


 ret
RenderBoard ENDP

;Check win or loss procedure
CheckWinOrLoss PROC
push edx
push eax
 call Clrscr
 mov dl, 30		;column
 mov dh, 13		;row
 mov eax, 5000	;set delay
 call Gotoxy	;stage cursor placement for messages

 ;check if user is out of errors
 cmp missesLeft, 0
 je loseCondition
 cmp targetsLeft, 0
 je winCondition
 jmp exitProc
 ;check if user is out of targets

 ;display nothing if game continues

 winCondition:
  mov edx, OFFSET promptWin
  call WriteString
  call delay

  jmp exitProc
 loseCondition:
  mov edx, OFFSET promptLose
  call WriteString
  call delay

  jmp exitProc

 exitProc:
 pop eax
 pop edx
 ret
CheckWinOrLoss ENDP


;Seed random numbers into the NxN grid
InitGame PROC
 mov  missesLeft, MAX_MISSES
 mov ecx, TOTAL_CELLS	;loop for every cell
 xor esi, esi			;set index tracker to 0.
 
 ClearBoardLoop:
  ;mov eax, OFFSET board
  mov board[esi], 0
  inc esi
  loop ClearBoardLoop

  movzx ecx, targetsLeft	;loop counter for targets to be placed

 PlaceTargetLoop:
  push ecx
 
 GenRandNum:
  mov eax, TOTAL_CELLS
  call RandomRange			;eax holds a random number from 0-TOTAL_CELLS - 1

  mov ebx, eax
  cmp board[ebx], 1
  je GenRandNum				;'reroll' a new number if board spot is equal to 1
  mov board[ebx], 1			;place target in spot

  pop ecx					;restore outer loop counter
  loop PlaceTargetLoop		;loop until all targets are placed

  ;Display board for 3 second
  InitDisplay:
   call Clrscr
   push ecx
   push edx
   push ebx
   push eax
   push edi

   ;display column numbers 1 - GRID_SIZE
   mov ecx, GRID_SIZE
   mov dl, 5  ;col test val
   mov dh, 2   ;row text val
   call Gotoxy
   mov bl, 1
   ColumnLoop:
    mov al, bl
	add al, '0'	;convert number to ASCII
	call WriteChar
	push eax
	mov al, ' '
	call WriteChar
	pop eax
	inc bl
	loop ColumnLoop
   
   ;Iterate for the 1, 2, ... N for the row values
   mov ecx, GRID_SIZE
   mov bl, 1
   mov dl,2 ;col
   mov dh,3 ;row
   mov edi, 0
   RowOuterLoop:
    call Gotoxy
	mov al, bl
	add al, '0'
	call WriteChar
	push eax
	mov al, ':'
	call WriteChar
	mov al, ' '
	call WriteChar
	pop eax
    
    ;Iterate through the columns, and initially place dots.
	push ecx ;push ecx so it can be saved to iterate after inner loop
	mov ecx, GRID_SIZE ;GRID_SIZE is row iterator
	
	mov dl, 5 ;reset column to 5 at the start of each new row
    RowInnerLoop: 
	 call Gotoxy

	 cmp board[edi], 1
	 je DisplayTarget

	 mov al, '.'
	 call WriteChar
	
	 jmp NoDisplayTarget

	 DisplayTarget:
	  mov al, '*'
	  call WriteChar

	 NoDisplayTarget:
	 mov al, ' '
	 call WriteChar 
	 add dl, 2	;inc col value as row moves from left -> right
	 inc edi	;inc value of board array
	 loop RowInnerLoop

	mov dl, 2	;set column back for the cilmn value.
	inc bl ;increment row counter at the beginning of the row 1:, 2:, 3: ...
	inc dh ;increment terminal row value
	pop ecx ;pop ecx so it can be used to loop again
   loop RowOuterLoop
   
   mov eax, 3000	;3 second delay
   call Delay
   pop edi
   pop eax
   pop ebx
   pop edx
   pop ecx

   ret
InitGame ENDP
END main
