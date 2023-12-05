create line-buffer 64 allot
variable num1
variable num2
variable sum
variable line-iter
variable read-len
variable found
variable chr

: proc-line ( -- )
    -1 num1 !
    -1 num2 !
    0 line-iter !
    line-buffer read-len @
    over + swap do
        -1
        i c@ CASE
            'o' OF
                line-iter @ line-buffer + 3 S" one" search if over S" o1e" drop swap 3 cmove 1 -rot endif 2drop
                ENDOF
            't' OF
                line-iter @ line-buffer + 3 S" two" search if over S" t2o" drop swap 3 cmove 2 -rot endif 2drop
                line-iter @ line-buffer + 5 S" three" search if over S" t333e" drop swap 5 cmove 3 -rot endif 2drop
                ENDOF
            'f' OF
                line-iter @ line-buffer + 4 S" four" search if over S" f44r" drop swap 4 cmove 4 -rot endif 2drop
                line-iter @ line-buffer + 4 S" five" search if over S" f55e" drop swap 4 cmove 5 -rot endif 2drop
                ENDOF
            's' OF
                line-iter @ line-buffer + 3 S" six" search if over S" s6x" drop swap 3 cmove 6 -rot endif 2drop
                line-iter @ line-buffer + 5 S" seven" search if over S" s777n" drop swap 5 cmove 7 -rot endif 2drop
                ENDOF
            'e' OF
                line-iter @ line-buffer + 5 S" eight" search if over S" e888t" drop swap 5 cmove 8 -rot endif 2drop
                ENDOF
            'n' OF
                line-iter @ line-buffer + 4 S" nine" search if over S" n99e" drop swap 4 cmove 9 -rot endif 2drop
                ENDOF
            '0' OF 0 ENDOF
            '1' OF 1 ENDOF
            '2' OF 2 ENDOF
            '3' OF 3 ENDOF
            '4' OF 4 ENDOF
            '5' OF 5 ENDOF
            '6' OF 6 ENDOF
            '7' OF 7 ENDOF
            '8' OF 8 ENDOF
            '9' OF 9 ENDOF
        ENDCASE
        dup -1 <> if nip endif
        0 over <=    ( c 0<= )
        over 10 <   ( c 0<= <10 )
        and         ( c 0<=c<10 )
        if
            num1 @ -1 = if
                num1 !
            else
                num2 !
            endif
        else
            drop
        endif
        line-iter @ 1 + line-iter !
    loop
    num1 @ -1 <> if
        num2 @ -1 <> if
            num1 @ 10 * num2 @ +
        else
            num1 @ 10 * num1 @ +
        endif
        dup . cr
        sum @ +
        sum !
    endif
    ;

: proc-file ( -- )
    begin
        line-buffer 256 stdin read-line throw drop ( read-len )
        read-len !
        read-len @ 0<> if
            proc-line
        endif
        read-len @ 0=
    until ;

proc-file

sum @ .
.s