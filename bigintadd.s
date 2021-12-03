//----------------------------------------------------------------------
// bigintadd.s
// Author: Misrach Ewunetie
//----------------------------------------------------------------------
        .equ    FALSE, 0
        .equ    TRUE, 1
        .equ    lLength, 0
        .equ    MAX_DIGITS, 32768
//----------------------------------------------------------------------
        .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss

//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // BigInt_larger returns the larger of lLength1 and lLength2.
        //--------------------------------------------------------------

        .equ    STACK_BYTECOUNT, 32
        .equ    lLarger, 24  // local variable
        .equ    lLength1, 16 // parameter
        .equ    lLength2, 8 // parameter

        .global BigInt_larger
        .type BigInt_larger, function

// static long BigInt_larger(long lLength1, long lLength2)
BigInt_larger:
        // Prolog
        // long lLarger;
        sub     sp, sp, STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, lLength1] // Save lLength1
        str     x1, [sp, lLength2] // Save lLength2

        // if (lLength1 <= lLength2) goto else1;
        ldr     x0, [sp, lLength1]
        ldr     x1, [sp, lLength2]
        cmp     x0, x1
        bls     else1 

        // lLarger = lLength1;
        adr     x2, lLarger
        ldr     x2, [x2]
        str     x0, [x2]

else1:
        //  if (lLength1 > lLength2) goto endif1;
        ldr     x0, [sp, lLength1]
        ldr     x1, [sp, lLength2]
        cmp     x0, x1
        bhi     endif1 

        // lLarger = lLength2;
        adr     x2, lLarger
        ldr     x2, [x2]
        str     x1, [x2]
endif1:
        // return lLarger;
        ldr x0, [sp, lLarger]  // Load lLarger
        ldr x30, [sp]     // Restore x30
        add sp, sp, lLarger
        ret



            

        .section .text
        //--------------------------------------------------------------
        // BigInt_add assignes the sum of oAddent1 and oAddent2 to oSum.
        // oSum should be distinct from oAddent1 and oAddend2. Return 0
        // (FALSE) if an overflow occurred, and 1 (TRUE) otherwise.
        //--------------------------------------------------------------


        .equ    STACK_BYTECOUNT, 56

        .equ    oAddend1, 48 // parameter
        .equ    oAddend2, 40 // parameter
        .equ    oSum, 32 // parameter

        .equ    ulCarry, 0  // local variable
        .equ    ulSum, 8  // local variable
        .equ    lIndex, 16  // local variable
        .equ    lSumLength, 24  // local variable
        .equ    zero, 0  // local variable
        .equ    one, 0  // local variable

        .global BigInt_add
        .type BigInt_add, function

BigInt_add:

        
        // unsigned long ulCarry;
        // unsigned long ulSum;
        // long lIndex;
        // long lSumLength;
        // Prolog
        sub     sp, sp, STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, oAddend1] // Save oAddend1
        str     x1, [sp, oAddend2] // Save oAddend2
        str     x2, [sp, oSum] // Save oSum
        
        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        adr     x0, lSumLength
        ldr     x0, [x0]
        adr     x1, oAddend1
        ldr     x1, [x1]
        str     x1, [sp, lLength]
        adr     x2, oAddend2
        ldr     x2, [x2]
        str     x2, [sp, lLength]
        bl      BigInt_larger
        add     x0, x0, 8
        ldr     x0, [x0, x1, lsl 3]

        //    if (oSum->lLength <= lSumLength) goto endif2;
        adr     x1, oSum
        ldr     x1, [x1]
        str     x1, [sp, lLength]
        cmp     x1, x0
        bsl     endif2


        //    memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        adr     x0, oSum
        ldr     x0, [x0]
        str     x0, [sp, aulDigits]
        adr     x1, zero
        ldr     x1, [x1]
        str     x1, [x1]
        adr     x2, MAX_DIGITS
        ldr     x2, [x2]
        mul     x2, x2, 8
        str     x2, [x2]
        bl      memset

endif2:

        // ulCarry = 0;
        adr     x0, ulCarry
        ldr     x0, [x0]
        adr     x1, zero
        ldr     x1, [x1]
        str     x1, [x0]

        // lIndex = 0;
        adr     x0, lIndex
        ldr     x0, [x0]
        adr     x1, zero
        ldr     x1, [x1]
        str     x1, [x0]

loop1:
        // if (lIndex >= lSumLength) goto endloop1;
        adr     x0, lIndex
        ldr     x0, [x0]
        adr     x1, lSumLength
        ldr     x1, [x1]
        cmp     x0, x1
        bge     endloop1

        // ulSum = ulCarry;
        adr     x0, ulSum
        ldr     x0, [x0]
        adr     x1, ulCarry
        ldr     x1, [x1]
        str     x0, [x1]


        // ulCarry = 0;
        adr     x0, ulCarry
        ldr     x0, [x0]
        adr     x1, zero
        ldr     x1, [x1]
        str     x1, [x0]

        // ulSum += oAddend1->aulDigits[lIndex];
        adr     x0, ulSum
        ldr     x0, [x0]
        adr     x1, oAddend1
        ldr     x1, [x1]
        add     x1, x1, 8
        mov     x2, lIndex
        ldr     x1, [x1, x2, lsl 3] 
        add     x0, x0, x1
        str     x0, [x0]


        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
        adr     x1, oAddend1
        ldr     x1, [x1]
        add     x1, x1, 8
        mov     x2, lIndex
        ldr     x1, [x1, x2, lsl 3] 
        cmp     x0, x1
        bge     endif3

        // ulCarry = 1;
        adr     x0, ulCarry
        ldr     x0, [x0]
        adr     x1, one
        ldr     x1, [x1]
        str     x1, [x0]
endif3:

        // ulSum += oAddend2->aulDigits[lIndex];
        adr     x0, ulSum
        ldr     x0, [x0]
        adr     x1, oAddend2
        ldr     x1, [x1]
        add     x1, x1, 8
        mov     x2, lIndex
        ldr     x1, [x1, x2, lsl 3] 
        add     x0, x0, x1
        str     x0, [x0]


        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif4;
        adr     x1, oAddend1
        ldr     x1, [x1]
        add     x1, x1, 8
        mov     x2, lIndex
        ldr     x1, [x1, x2, lsl 3] 
        cmp     x0, x1
        bge     endif4

        // ulCarry = 1;
        adr     x0, ulCarry
        ldr     x0, [x0]
        adr     x1, one
        ldr     x1, [x1]
        str     x1, [x0]
endif4:
        // oSum->aulDigits[lIndex] = ulSum;
        adr     x0, oSum
        ldr     x0, [x0]
        add     x0, x0, 8
        mov     x1, lIndex
        ldr     x0, [x0, x1, lsl 3] 
        adr     x2, ulSum
        ldr     x2, [x2]
        str     x2, [x0]

        // lIndex++;
        adr     x0, lIndex
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        // goto loop1;
        b       loop1
endloop1:

        // if (ulCarry != 1) goto endloop5;
        adr     x0, ulCarry
        ldr     x0, [x0]
        adr     x1, one
        ldr     x1, [x1]
        cmp     x0, x1
        bne     endloop5

        // if (lSumLength != MAX_DIGITS) goto endloop6;
        adr     x0, lSumLength
        ldr     x0, [x0]
        adr     x1, MAX_DIGITS
        ldr     x1, [x1]
        cmp     x0, x1
        bne     endloop6

        // return FALSE;
        adr     x0, FALSE
        ldr     x0, [x0]
        ret     x0
endloop6:
        // oSum->aulDigits[lSumLength] = 1;
        adr     x0, oSum
        ldr     x0, [x0]
        add     x0, x0, 8
        mov     x1, lIndex
        ldr     x0, [x0, x1, lsl 3] 
        adr     x2, one
        ldr     x2, [x2]
        str     x2, [x0]

        // SumLength++;
        adr     x0, SumLength
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

endloop5:
        // oSum->lLength = lSumLength;
        adr     x0, oSum
        ldr     x0, [x0]
        add     x0, x0, 8
        ldr     x0, [x0, x1, lsl 3] 
        adr     x2, lSumLength
        ldr     x2, [x2]
        str     x2, [x0]

        // epilog and return TRUE;
        ldr x0, TRUE  // Load true
        ldr x30, [sp]     // Restore x30
        add sp, sp, TRUE
        ret
        







        





