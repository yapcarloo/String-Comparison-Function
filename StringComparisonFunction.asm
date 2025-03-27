ORG 100H

DATA SEGMENT
    STR1 DB 20 DUP('$')  ; Buffer for first string
    STR2 DB 20 DUP('$')  ; Buffer for second string
    MSG1 DB 'Enter first string: $'
    MSG2 DB 0DH, 0AH, 'Enter second string: $'
    MSG3 DB 0DH, 0AH, 'Case-sensitive? (Y/N): $'
    MATCH DB 0DH, 0AH, '1$'  ; Identical
    NO_MATCH DB 0DH, 0AH, '0$'  ; Not identical
    CASE_FLAG DB ?
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX

    ; Prompt & Read First String
    MOV DX, OFFSET MSG1
    MOV AH, 09H
    INT 21H
    LEA DI, STR1
    CALL READ_STRING

    ; Prompt & Read Second String
    MOV DX, OFFSET MSG2
    MOV AH, 09H
    INT 21H
    LEA DI, STR2
    CALL READ_STRING

    ; Ask for case sensitivity
    MOV DX, OFFSET MSG3
    MOV AH, 09H
    INT 21H
    CALL READ_CHAR
    MOV CASE_FLAG, AL  ; Store user choice

    ; Compare Strings
    CALL COMPARE_STRINGS

    ; Exit Program
    MOV AH, 4CH
    INT 21H

; FUNCTION: READ_STRING (Reads a string from the user)
READ_STRING PROC
    MOV CX, 20
    MOV AH, 01H
NEXT_CHAR:
    INT 21H
    CMP AL, 0DH  ; Check for Enter key
    JE DONE
    MOV [DI], AL
    INC DI
    LOOP NEXT_CHAR
DONE:
    MOV AL, '$'
    MOV [DI], AL
    RET
READ_STRING ENDP

; FUNCTION: READ_CHAR (Reads a single character)
READ_CHAR PROC
    MOV AH, 01H
    INT 21H
    RET
READ_CHAR ENDP

; FUNCTION: COMPARE_STRINGS (Compares STR1 and STR2)
COMPARE_STRINGS PROC
    LEA SI, STR1
    LEA DI, STR2
COMPARE_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, '$'  ; End of string
    JE CHECK_END
    CMP BL, '$'
    JE CHECK_END

    CMP CASE_FLAG, 'N'
    JNE SKIP_CASE
    CALL TO_UPPER
    MOV [SI], AL
    MOV [DI], BL

SKIP_CASE:
    CMP AL, BL
    JNE NOT_MATCH
    INC SI
    INC DI
    JMP COMPARE_LOOP

CHECK_END:
    CMP AL, BL
    JE MATCH_FOUND

NOT_MATCH:
    MOV DX, OFFSET NO_MATCH
    MOV AH, 09H
    INT 21H
    RET

MATCH_FOUND:
    MOV DX, OFFSET MATCH
    MOV AH, 09H
    INT 21H
    RET
COMPARE_STRINGS ENDP

; FUNCTION: TO_UPPER (Converts AL and BL to uppercase if lowercase)
TO_UPPER PROC
    CMP AL, 'a'
    JB CHECK_BL
    CMP AL, 'z'
    JA CHECK_BL
    SUB AL, 20H

CHECK_BL:
    CMP BL, 'a'
    JB DONE_UPPER
    CMP BL, 'z'
    JA DONE_UPPER
    SUB BL, 20H

DONE_UPPER:
    RET
TO_UPPER ENDP

CODE ENDS
END START