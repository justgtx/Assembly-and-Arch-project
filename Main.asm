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
    promptHint BYTE "You have used a hint!",0
    promptNoHint BYTE "0 hints remaining!",0
    promptInvalid BYTE "Invalid input!",0

	;user inputs
	inputRow	DWORD ?
	inputCol	Dword ?
    input_Guess_bufferx byte 4 dup(?) ;input for user guessing which spot to pick
    input_Guess_buffery byte 4 dup(?) ;input for user guessing which spot to pick
    hint_counter BYTE 03h ; number of hints available to the user, 3 by default
.code
main PROC
 call Randomize		;fully randomize the range for later
 ;game initalization procedures to be built
					;call promptDifficulty		;To be added later
 call InitGame				;place the randomized values on the grid

 ;GameLoop will run continuously until the game ends.
 GameLoop:
  
  call RenderBoard			;Render the updated board after last user input
  call User_Input		;prompt and validate the user's entry
  ;call EvalGuess			;evaluate the user's entry
  ;call waitMsg				;Pauses and prints a proceed screen so use can process last game board state.
  call CheckWinOrLoss		;Check for exit state, exit if true

  jmp GameLoop
 
 
INVOKE ExitProcess,0
main ENDP

RenderBoard PROC
call Clrscr
push edx
push eax
push ecx
push ebx
 ;render board using similar logic to the one in InitGame Proc, implementing again because logic is slightly different
 ;check board state is looping around
 ;If 0 - Display " . ", If 1 - Display " . ", If 2 - Display " H ", If 3 - Display " M "

 mov ecx, GRID_SIZE
 mov dl, 5 ;col
 mov dh, 2 ;row
 
 ;Display the column numbers at the top of the game board

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

 
 ;build of the grid
 mov ecx, GRID_SIZE
 mov dl, 2 ;col
 mov dh, 3 ;row
 mov bl, 1
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

  push ecx
  mov ecx, GRID_SIZE
  RowInnerLoop:
	;Game Logic for "0" value
    cmp board[edi],0
	je displayEmpty

	;Game Logic for "1" value
	cmp board[edi],1
	je displayEmpty
	
	;Game Logic for "2" value
	cmp board[edi],2
	je displayHit

	;Game Logic for "3" value
	cmp board[edi],3
	je displayMiss

	displayEmpty:
	 mov al, '.'
	 call WriteChar
	 jmp nextLoopIteration

	displayHit:
	 mov al, 'H'
	 call WriteChar
	 jmp nextLoopIteration

	displayMiss:
	 mov al, 'M'
	 call WriteChar
	 jmp nextLoopIteration


	 nextLoopIteration:
	 mov al, ' '
	 call WriteChar
	 add dl, 2
	 inc edi
    loop RowInnerLoop
    pop ecx
    inc bl
    inc dh
    mov dl, 2
  loop RowOuterLoop

 mov eax, 3000
 call Delay

 pop ebx
 pop ecx
 pop eax
 pop edx
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
 inc hint_counter
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
  mov board[ebx], 1			;place target in     spot

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

    
User_Input PROC USES eax ebx ecx edx edi
check_input: ; just comparisions 
mov edx, OFFSET promptRow
call WriteString
mov eax, GRID_SIZE
call WriteDec
mov edx, OFFSET promptCloseBracket
call WriteString
mov edx, OFFSET input_Guess_bufferx
mov ecx,3
call ReadString ; read from ecx then mov it into the stored values to compare


cmp input_Guess_bufferx, 0
jz clear_buffer
cmp input_Guess_bufferx, 'h'
je hint
cmp input_Guess_bufferx, 'H'
je hint
;next segment for writing
mov edx, OFFSET promptCol
call WriteString
mov eax, GRID_SIZE
call WriteDec
mov edx, OFFSET promptCloseBracket
call WriteString
mov edx, OFFSET input_Guess_buffery
mov ecx,3
call ReadString ; read from ecx then mov it into the stored values to compare
cmp input_Guess_buffery, 0
je clear_buffer
cmp input_Guess_buffery, 'h'
je hint
cmp input_Guess_buffery, 'H'
je hint
; actual valid inputs 
cmp input_Guess_bufferx, 1
jge check_board ; greater or equal to 1 we go to check that location

ret

clear_buffer:
mov edx,OFFSET promptInvalid
call WriteString
call Crlf
mov edi,OFFSET input_Guess_bufferx
mov ecx,4
mov al,0
rep stosb
mov edi,OFFSET input_Guess_buffery
mov ecx,4
mov al,0
rep stosb
jmp check_input ; to retry input
ret


check_board:
;check if the input is within the board range and there is a target at that position.
cmp input_Guess_bufferx +1,0 ;fix 1 off error and logic
jne clear_buffer ; greater than GRID_SIZE we clear the buffer for a new input
cmp input_Guess_buffery,0
jne clear_buffer ; greater than GRID_SIZE we clear the buffer for a new input

cmp input_Guess_bufferx, '1'
jb clear_buffer
cmp input_Guess_buffery, '1'
jb clear_buffer
jb clear_buffer
cmp input_Guess_bufferx, '0' + GRID_SIZE
ja clear_buffer
cmp input_Guess_buffery, '0' + GRID_SIZE
ja clear_buffer

;valid input section


movzx eax, input_Guess_bufferx
sub eax, '0'
dec eax ; convert from 1-based to 0-based index
imul eax, GRID_SIZE
movzx ebx, input_Guess_buffery
sub ebx, '0'
dec ebx ; convert from 1-based to 0-based index
add eax, ebx
cmp board[eax], 1
; check which has the targets
;jmp miss_or_hit
ret

hint:
cmp hint_counter, 0
je no_hint ; if no hints left, clear the buffer for a new input
jne hint_display
mov ecx,3

no_hint:
mov edx, OFFSET promptNoHint
call WriteString
call Crlf
jmp clear_buffer
ret
hint_display:; hint function to flash the board for 1.5 seconds and it shows 3 times
call Clrscr
mov dl, 30		;column
mov dh, 13		;row
mov eax,1500                                                                     
call delay  
dec ecx
cmp ecx,0   
jne hint
dec hint_counter
ret

User_Input ENDP
;check branch name = "Eval"
;PROC EvalGuess USES eax 

;EvalGuess ENDP


END main