//----------------------------------------------------------------------
// mywc.s
// Author: Misrach Ewunetie
//----------------------------------------------------------------------
        .equ    FALSE, 0
        .equ    TRUE, 1
//----------------------------------------------------------------------
        .section .rodata

//----------------------------------------------------------------------

        .section .data
lLineCount:
        .quad   0
lWordCount:
        .quad   0
lCharCount:
        .quad   0
iInWord:
        .word FALSE

//----------------------------------------------------------------------

        .section .bss

iChar:
        .skip   4

//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // Write to stdout counts of how many lines, words, and         // characters are in stdin. A word is a sequence of
        // non-whitespace characters. Whitespace is defined by the 
        // isspace() function. Return 0.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16
        .equ    EOF, -1

        .global main
main:
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

loop1:
        // iChar = getchar();
        adr     x0, iChar
        bl      getchar
        adr     x1, iChar
        str     x0, [x1] // maybe use strb instead?

        // if ((iChar == EOF) goto whileLoopEnd;
        adr     x0, iChar
        ldr     x0, [x0]
        cmp     x0, EOF
        beq     endloop1

        // lCharCount++;
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

ifstatement1:
        // if(!isspace(iChar)) goto else1;
        adr     x0, iChar
        ldr     x0, [x0]
        bl      isspace
        cmp     x0, FALSE
        beq     else1
ifstatement2:
        // if(!iInWord) goto endif1;
        adr     x0, iInWord // should I be using a different register?
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     endif1

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // iInWord = FALSE;      
        adr     x0, iInWord
        ldr     x0, [x0]
        adr     x1, FALSE
        ldr     x1, [x1]
        str     x1, [x0]

else1:
        // if(iInWord) goto endif2;
        adr     x0, iInWord // should I be using a different register?
        ldr     x0, [x0]
        cmp     x0, TRUE
        beq     endif2

        // iInWord = TRUE;
        adr     x0, iInWord
        ldr     x0, [x0]
        adr     x1, TRUE
        ldr     x1, [x1]
        str     x1, [x0]

        // adr     x0, iInWord
        // ldr     x1, [x0]
        // str     TRUE, [x0]

endif2:

endif1:

ifstatement3:
        // if (iChar != '\n') goto endif3;
        adr     x0, iChar
        ldr     x0, [x0]
        cmp     x0, EOF
        beq     endloop1


        // lLineCount++;
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

endif3:
        // goto loop1;
        b       loop1
endloop1:

ifstatement4:
        // if(!iInWord) goto endif4;
        adr     x0, iInWord // should I be using a different register?
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     endif4

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

endif4:
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, printfFormatStr
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf

        // Epilog and return 0;
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)







        





