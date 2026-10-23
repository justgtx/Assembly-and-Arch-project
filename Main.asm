; main module for the game contest
; aim to add Entry Point, and core game loop from this file.
INCLUDE Irvine32.inc
;	have another INCLUDE Prompts.inc for the prompts needing user input, to remove Main.asm clutter?
.386
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
.data


.code
main PROC

INVOKE ExitProcess,0
main ENDP
END main

