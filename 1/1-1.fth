create line-buffer 64 allot

variable num1
variable num2
variable sum

: proc-line ( read-len -- )
    -1 num1 !
    -1 num2 !
    line-buffer over
    over + swap do
        i c@ '0' -  ( c )
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
    loop
    num1 @ -1 <> if
        num2 @ -1 <> if
            num1 @ 10 * num2 @ +
        else
            num1 @ 10 * num1 @ +
        endif
        dup .
        sum @ +
        sum !
    endif
    cr ." " ;

: proc-file ( -- )
    begin
        line-buffer 256 stdin read-line throw drop ( read-len )
        dup 0<> if
            proc-line
        endif
        0=
    until ;

proc-file

sum @ .