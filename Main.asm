; main module for the game contest
; aim to add Entry Point, and core game loop from this file.
INCLUDE Irvine32.inc
.386
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
.data
 ;beginner word pool (4 letters)
 beginnerWords BYTE "CODE", "BYTE", "HACK", "PROG", "DATA", "LOOP", "PUSH", "JUMP", "COND", "MASM"
 ;intermediate word pool (6 letters)
 intermediateWords BYTE "HACKER", "CYBORG", "KERNEL", "STRING", "CODING", "BUFFER", "POINTER", "STACKS", "QUEUES", "MEMORY"
 ;advanced word pool (8 letters)
 advancedWords BYTE "ASSEMBLY", "PROGRAMS", "OVERFLOW", "SEGMENTZ", "REGISTER", "COMPUTER", "ABSOLUTE", "GRAPHICS", "QUESTION", "ELEPHANT"

.code
main PROC



INVOKE ExitProcess,0
main ENDP
END main

