variable size
256 size !
create schematic size @ dup * allot

\ SYMBOLS # $ % & * + - / = @

: char-at ( row col -- char )
    size @ *
    schematic + c@ dup emit cr
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
    \ If we really want to log it
    \ schematic size @ dup * type cr
    ;

( size )
\ load file into schematic
load-file
\ loop over horizontal
    \ if symbol
        \ find . before symbol, try to load number
        \ after symbol, try to load number

\ loop over vertical
    \ if symbol
        \ for above/below
            \ if above is digit, move left until . , try to load number
            \ else
                \ if above left is digit, move left until . , try to load number
                \ else
                    \ if above right is digit, move left until . , try to load number

.s