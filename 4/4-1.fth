create line-buffer 256 allot

variable winning-nums-iter
create winning-nums 11 allot \ big enough for numbers and 0 to denote end of list

variable picked-nums-iter
create picked-nums 26 allot

variable sum
variable read-len
variable cursor-pos

: add-to-list { list iter item }
    item list iter @ + !
    iter @ 1 + iter !
    ;

: get-len-remaining ( -- len-remaining )
    read-len @                      ( read-len )
    cursor-pos @ line-buffer - -    ( len-remaining )
    ;

: load-from-cursor ( -- position len-remaining )
    cursor-pos @        ( cursor-pos )
    get-len-remaining   ( cursor-pos len-remaining )
    ;

: goto-char { c } ( c -- )
    load-from-cursor c scan ( c-addr u2 )
    drop                    ( c-addr )
    1 +                     ( c-addr+1 )
    cursor-pos !            (  )
    ;

: get-cursor-char ( -- char )
    cursor-pos @ c@
    ;


: is-digit { c } ( c -- digit? )
        c '0' -     ( c )
        0 over <=   ( c 0<= )
        over 10 <   ( c 0<= <10 )
        and         ( c 0<=c<10 )
        nip
        ;

: read-number ( -- number )
    cursor-pos @ c@ dup is-digit if '0' - 10 * else drop 0 endif
    cursor-pos @ 1 + cursor-pos !
    cursor-pos @ c@ '0' -
    +
    ;

: load-winning ( -- )
    ':' goto-char
    begin
        bl goto-char
        winning-nums winning-nums-iter read-number add-to-list
        cursor-pos @ 2 + c@ '|' = ( char=| )
        get-len-remaining 0= ( char=| end-buf)
        or ( char=|-or-end-buf)
    until
    ;

: load-picked ( -- )
    '|' goto-char
    begin
        bl goto-char
        picked-nums picked-nums-iter read-number add-to-list
        get-len-remaining 1 <= ( end-buf)
    until
    ;

: ^ ( n1 u -- n )
    \ n = the uth power of n1
    1 swap 0 u+do
        over *
    loop
    nip ;

: process-card ( -- points )
    0 winning-nums-iter !
    0 picked-nums-iter !
    load-winning
    load-picked
    0
    0 winning-nums-iter @
    over + swap do
        i winning-nums + c@ ( count win-num-i )
        0 picked-nums-iter @
        over + swap do
            i picked-nums + c@ ( count win-num-i picked-num-i )
            over = if ( count )
                swap 1 + swap
            endif
        loop
        drop
    loop
    dup 0<> if
        1 -
        2 swap ^
    endif
    ;

: process-line ( -- )
    ." Processing: " load-from-cursor type cr
    process-card    ( points )
    sum @ + sum !
    ;

: process-file ( -- )
    begin
        line-buffer 256 stdin read-line throw drop  ( read-len )
        read-len !                                  (  )
        line-buffer cursor-pos !                    \ reset cursor pos to start of line
        read-len @ 0<> if
            process-line
        endif
        read-len @ 0=
    until
    sum @ . cr
    ;

process-file
.s