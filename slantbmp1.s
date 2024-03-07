section .text
global slantbmp1

slantbmp1:
    ; Arguments:
    ;   [ebp+8]  - img
    ;   [ebp+12] - width
    ;   [ebp+16] - height
    ;
    ; Variables
    ;   [ebp-4] - carry value
    ;   [ebp-8] - line repeat counter    ----to be decided

    push ebp
    mov ebp, esp

    sub esp, 8        ; Allocate space for local variables

    ; Save registers
    push esi
    push edi
    push ebx

    mov eax, [ebp+16]   ; height
    dec eax             ; Decrement the height
    mov [ebp-8], eax

    mov eax, [ebp+12]   
    ; Calculate the size of a single line in bytes
    test eax, 7         ; Check if the width is a multiple of 8

    jz dwordCheck      ; If the remainder is 0, skip the next line
        shr eax, 3
        inc eax             ; Otherwise, add 1 to the number of bytes to ajust for the padding
        mov edi, eax   ; Save the number of bytes in a row
        jmp fixeDwordCheck
    dwordCheck:
    shr eax, 3
    mov edi, eax           ; Save the number of bytes in a row
    
    fixeDwordCheck:

    mov dword [ebp-4], 0     ; Initialize the carry value to 0

    ;;mov dword [ebp-44], 0     ; Initialize the row offset to 0
    mov edx, 0           ; Initialize the row offset to 0
    mov esi, 0           ; Initialize the byte counter to 0
    mov ebx, 0           ; Initialize the byte register to 0
    
    ;esi - byte counter 
    ;edi - number of bytes in a row
    ;bl - byte register    
    ;edx - row offset
    ;ecx & eax multi-purpose
    rowWalker:

        cmp esi, edi   ; Check if we've reached the end of the line
        jge decHeight       ; If we have, decrement the height and jump to the next line

        mov eax, [ebp+16]  ; Load the height
        cmp eax, 0          ; Check if we've reached the end of the image
        jle fin              ; If we have, return
        
        mov eax, [ebp+8]  ; Load the image
        mov ecx, [ebp-4]   ; Load the carry value

        add eax, esi  ; Add the byte counter to the image pointer
        add eax, edx  ; Add the row offset to the image pointer

        mov ebx, 0          ; Clear the byte register
        mov bl, byte [eax]      ; Load the first byte of the line

        or ebx, ecx         ; OR the carry value with the first byte (done to pre set the left input value for shift right)

        mov eax, [ebp+12]   ; Load the width
        
        lea ecx, [esi*8]    ; Multiply the byte counter by 8 to get the pixel counter
        sub eax, ecx        ; Subtract the pixel counter from the width
        cmp eax, 8          ; Check if we've reached the end of the line
        jle lastByteTransition 

        mov ecx, 0
        shr ebx, 1          ; Shift the byte to the right by 1
        jnc noCarry
            inc ecx         ; If the carry flag is set, increment the carry value
        noCarry:
        shl ecx,8
        mov [ebp-4], ecx   ; Save the carry value
  
    
        mov eax, [ebp+8]  ; Load the image
        add eax, esi  ; Add the byte counter to the image pointer
        add eax, edx  ; Add the row offset to the image pointer
        mov byte [eax], bl      ; Save the first byte of the line
        mov ebx, 0          ; Clear the byte register

        lbtRet:

        inc esi             ; Increment the byte counter
  
    
    jmp rowWalker


    lastByteTransition:
        
        mov eax, [ebp+8]  ; Load the image
        add eax, esi  ; Add the byte counter to the image pointer
        add eax, edx  ; Add the row offset to the image pointer
        mov bl, byte [eax]      ; Save the last byte of the line
        
        mov eax, ebx       ; Copy the byte register

        mov ecx, 0
        shr ebx, 1          ; Shift the byte to the right by 1
        jnc noCarry2
            inc ecx         ; If the carry flag is set, increment the carry value
        noCarry2:
            shl ecx,7
        mov [ebp-4], ecx   ; Save the carry value

        mov ecx, [ebp+12]   ; Load the width
        neg ecx
        lea ecx, [edi*8 + ecx]    ; Multiply the byte counter by 8 to get the pixel counter
        cmp ecx, 8
        je allByte 
            shr eax, cl    ; Shift the byte register to the right by the number of padding bits (to get the carry bit to the LSB position)
            shr ebx, cl   
            shl ebx, cl 


            and eax, 1      ; Get the last bit of the byte register

            mov ecx, eax
            shl ecx, 7          ; Shift the last bit to the left by 7 (bc now we wont shift the updated register)
            mov [ebp-4], ecx   ; Save the carry value
            

        allByte:

        mov eax, [ebp+8]  ; Load the image
        add eax, esi  ; Add the byte counter to the image pointer
        add eax, edx  ; Add the row offset to the image pointer
        mov byte [eax], bl      ; Save the last byte of the line
        ;Updating First Byte
        mov eax, [ebp+8]  ; Load the image
        add eax, edx  ; Add the row offset to the image pointer
        mov  bl,byte [eax]  ; Load the first byte of the line
        mov ecx, [ebp-4]
        or ebx, ecx         ; OR change first bit of first byte with last bit of last byte

        mov eax, [ebp+8]  ; Load the image
        add eax, edx  ; Add the row offset to the image pointer
        mov byte [eax], bl      ; Save the first byte of the line
        jmp lbtRet

    decHeight:
    mov eax, [ebp-8]   ; Load the line repeat counter
    cmp eax, 0          ; Check if we've reached the required number of repetitions
    jne   repeatTheProc

    mov eax, [ebp+16]   ; Load the height
    dec eax             ; Decrement the height
    mov [ebp+16], eax   ; Save the height
    dec eax             ; Decrement the line repeat counter
    ;mov eax, 2
    mov [ebp-8], eax   ; Update the line repeat counter

    interestingStuff:
    mov ecx,0
    mov ecx,  edi        ; Load the number of bytes in a row
    test ecx, 3         ; Check if the number of bytes in a row is a multiple of 4
    jz rbcNotNeeded
        shr ecx, 2
        inc ecx
        shl ecx, 2
        
    rbcNotNeeded:
    add edx, ecx
    ;;mov [ebp-44], eax   ; Save the row offset

    jmp impDataReset
    repeatTheProc:
        mov eax, [ebp-8]   ; Load the line repeat counter
        dec eax         ; Decrement the line repeat counter
        mov [ebp-8], eax   ; Save the line repeat counter

    impDataReset:
        mov dword [ebp-4], 0     ; Initialize the carry value to 0
        mov esi, 0           ; Initialize the byte register to 0

    jmp rowWalker       ; Jump back to the rowWalker


    fin:
    ; Restore registers
    mov eax, [ebp + 8]
    pop ebx
    pop edi
    pop esi

    ; Restore stack frame
    mov esp, ebp    ; Restore ESP
    pop ebp

    ret
