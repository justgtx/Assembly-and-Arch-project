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
	currMisses BYTE 0

	;Space for UI Prompts
	
	;prompts set up this way so they are dynamic.
	promptRow	BYTE "Enter Row (1-",0
	promptCol	BYTE "Enter Column (1-",0
	promptCloseBracket	BYTE "): ",0

	inputRow	DWORD ?
	inputCol	Dword ?


.code
main PROC
call Randomize		;fully randomize the range for later
 ;game initalization procedures to be built
					;call promptDifficulty		;To be added later
 ;call RandomizeGrid		;seed the grid with random values
 call InitGame				;place the randomized values on the grid
 ;call ShowPeekOfScreen		;show full displayed board for a few seconds

 ;GameLoop will run continuously until the game ends.
 GameLoop:
  ;call CheckWinOrLoss		;Check for exit state, exit if true
  ;call RenderBoard			;Render the updated board after last user input
  ;call GetPlayerInput		;prompt and validate the user's entry
  ;call EvalGuess			;evaluate the user's entry

  jmp GameLoop
 
 
INVOKE ExitProcess,0
main ENDP

;Seed random numbers into the NxN grid
InitGame PROC
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
	
	mov dl, 5
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
	 add dl, 2
	 inc edi
	 loop RowInnerLoop

	mov dl, 2
	inc bl ;increment row counter
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
