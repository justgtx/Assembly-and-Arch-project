; main module for the game contest
; aim to add Entry Point, and core game loop from this file.
<<<<<<< HEAD

INCLUDE Irvine32.inc
.386
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
.data
 

.code
main PROC



INVOKE ExitProcess,0
main ENDP
END main
=======
INCLUDE IRVINE32.inc
>>>>>>> 162d5e63b92fee44706756e9d0ea01adba689d30
