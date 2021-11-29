//----------------------------------------------------------------------
// mywc.s
// Author: Misrach Ewunetie
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
        .skip   4 // how to set equal to false?

//----------------------------------------------------------------------

        .section .bss

lIndex:
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

        .global main
main:
