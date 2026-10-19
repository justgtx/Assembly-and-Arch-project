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

 wordLength BYTE 4		;word length for the game
 wordCount BYTE 4		;amount of words
 attemptsLeft BYTE 5	;attempts left in game
 tarOffset DWORD ?		;memory offset for randomly chosen password.


.code
main PROC

DisplayStartingMenu:
;  set screen to black, text to green
;  would be cool if these could come on the screen incrementally like someone is typing them out into the terminal.
;  display options as follows:
;1. Beginner (4-letter words)
;2. Intermediate (6-letter words)
;3. Advanced (8-letter words)

call ReadChar	;returned value is in AL.



INVOKE ExitProcess,0
main ENDP
END main

