; main module for the game contest
; aim to add Entry Point, and core game loop from this file.
INCLUDE Irvine32.inc
;	have another INCLUDE Prompts.inc for the prompts needing user input, to remove Main.asm clutter?
.386
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
	;use EQU directive for dynamic scaling
GRID_SIZE     EQU 5		;Scalable
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

	inputRow	DWORD ?
	inputCol	Dword ?

.code
main PROC

INVOKE ExitProcess,0
main ENDP
END main
