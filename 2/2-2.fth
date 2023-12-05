create line-buffer 256 allot
variable sum
variable read-len
variable cursor-pos
variable max-red
variable max-blue
variable max-green

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
        ;

: read-number ( -- number )
    0                   ( sum )
    load-from-cursor
    over + swap do
        i c@ is-digit   ( sum char digit? )
        if
            swap 10 * +
        else
            drop leave
        endif
    loop
    ;

: get-game-id ( -- id )
    bl goto-char    (  )
    read-number     ( number )
    ;

: update-max { number var }
    var @ number < ( var<num )
    if
        number var !
    endif
    ;

: read-round ( -- )
    begin
        \ 11: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \  ^cursor here
        \ read until ' ' (bl)
        \ 11: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \    ^cursor here
        \ read-number
        bl goto-char
        read-number ( number )
        \ read until ' ' (bl)
        \ 11: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \      ^cursor here
        \ read next char move forward by rbg word len
        bl goto-char
        get-cursor-char CASE
            'r' OF max-red update-max 3 ENDOF
            'b' OF max-blue update-max 4 ENDOF
            'g' OF max-green update-max 5 ENDOF
        ENDCASE
        cursor-pos @ + cursor-pos ! \ move cursor forward
        \ 11: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \           ^cursor here
        \ if ',' repeat, if ';' or at read-len exit loop
        get-cursor-char ';' = ( char=; )
        get-len-remaining 0= ( char=; end-buf)
        or ( char=;-or-end-buf)
    until
    ;

: process-game ( -- possible )
    0 max-red !
    0 max-blue !
    0 max-green !  (  )
    \ read rounds until end at read-len
    begin
        read-round
        get-len-remaining 0=
    until
    \ check if max recorded exceeds limit
    max-red @
    max-blue @
    max-green @
    * *
    sum @ + sum !
    ;

: process-line ( -- )
    ." Processing: " load-from-cursor type cr
    get-game-id drop ( )
    process-game    ( power )
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
    ;

process-file
.s
sum @ .