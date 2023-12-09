variable size
256 size !
create schematic size @ dup * allot

variable sum
0 sum !

: char-pos ( row col -- char-pos )
    swap size @ * +   ( row*size+col )
    schematic + ( char-pos )
    ;

: is-between ( i min max -- in? )
        rot dup ( min max i i)
        -rot > ( min i i<max )
        -rot <= ( min>i i<max)
        and         ( min<=i<max )
        ;

: char-at ( row col -- char )
    2dup ( row col row col )
    0 size @
    ( row col row col min max )
    is-between
    ( row col row col-between )
    2swap swap ( row col-between col row )
    0 size @  ( row col-between col row min max )
    is-between swap -rot ( row col col-between row-between )
    and 0=
    if 
        2drop
        '.'
    else
        char-pos c@ ( char )
    endif
    ;

: load-file ( -- )
    0 ( cursor )
    begin
        dup schematic + size @ stdin read-line throw drop ( cursor read-len )
        \ If we're at max size, shrink to file size to allow char-at to work
        size @ 256 = if
            dup 1 + size !
        endif
        dup ( cursor read-len read-len )
        rot ( read-len cursor read-len )
        + ( read-len cursor )
        swap ( cursor read-len )
        0=
    until
    drop (  )
    \ If we really want to log it
    size @ 1 - size !
    \ schematic size @ dup * type cr
    ;

: is-symbol ( char -- symbol? )
    false swap ( symbol? char)
    CASE
        '#' OF drop true ENDOF ( symbol? )
        '$' OF drop true ENDOF \ etc
        '%' OF drop true ENDOF
        '&' OF drop true ENDOF
        '*' OF drop true ENDOF
        '+' OF drop true ENDOF
        '-' OF drop true ENDOF
        '/' OF drop true ENDOF
        '=' OF drop true ENDOF
        '@' OF drop true ENDOF
    ENDCASE
    ;

: is-digit ( c -- digit? )
        '0' -     ( c )
        0 over <=   ( c 0<= )
        swap 10 <   ( c 0<= <10 )
        and         ( c 0<=c<10 )
        ;

: read-number-len ( row col -- number-len )
    -1 -rot ( sum row col )
    begin
        2dup char-at           ( sum   row col   char )
        2swap swap 1 + swap 2swap   ( sum+1 row col   char )
        is-digit dup                ( sum   row col   digit? digit? )
        if
            swap 1 + swap           ( sum   row col+1 digit? )
        endif
        0=
    until
    2drop
    ;

: read-number ( row col -- number )
    0 -rot ( sum row col )
    begin
        2dup char-at '0' - ( sum   row col  c-val)
        -rot 2swap ( row col sum c-val)
        2over char-at is-digit ( row col sum c-val digit? )
        if
            swap 10 * + swap rot swap   ( sum+c-val row col )
        endif
        2dup char-at is-digit ( sum row col digit? )
        swap 1 + swap ( sum row col+1 )
        0=
    until
    2swap 2drop drop
    ;

variable num-nums
variable sum-nums

: find-num ( row col -- )
    2dup char-at is-digit if
        begin
            2dup char-at           ( row col char )
            is-digit dup                ( row col digit? digit? )
            if
                swap 1 - swap           ( row col-1 digit? )
            endif
            0=
        until
        1 +
        ( row col ) \ of start of num
        num-nums @ 1 + num-nums !
        2dup read-number 
        sum-nums @ * sum-nums !
        2dup char-pos 3 '.' fill
    endif
    2drop
    ;

: check-surrounding ( row col -- )
    0 num-nums !
    1 sum-nums !
    1 - 3 ( row col-1 3)
    over + swap do
        i ( row i-col )
        swap 1 - swap ( row-1 col )
        2dup find-num
        swap 1 + swap ( row col )
        2dup find-num
        swap 1 + swap ( row+1 col )
        2dup find-num
        drop 1 - ( row )
    loop
    num-nums @ 2 = if
        sum @ sum-nums @ + sum !
    endif
    drop
    ;

: process-char { row col } ( row col -- )
    \ if gear
    row col char-at
    '*' = if
        row col check-surrounding
    endif
    ;


: process-file ( -- )
    0 size @ dup *
    over + swap do
        i ( num )
        dup ( num num )
        size @ mod ( num num%size )
        swap size @ / swap  ( num/size num%size ) \ aka ( x y )
        process-char
    loop
    ;

( size )
\ load file into schematic
load-file

process-file

." Final stack:" .s cr
sum @ .