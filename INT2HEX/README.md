INT2HEX
=======

Given an integer. It is required to get its representation in hexadecimal number system. Perhaps the result needs to be padded with zeroes on the left.

Input Parameters
----------------

* `NUM integer` — input number.
* `MIN_LENGTH smallint` — minimum output length or zero if no padding needed (by default 0).

Return Value (Output Parameter)
-------------------------------

### Output Parameter In Stored Procedure (Firebird 2.1+)

* `RESULT varchar(8)` — the converted value.

### Return Value In Stored Function (Firebird 3+)

* `varchar(8)` — the converted value.

Syntax
------

### Stored Procedure (Firebird 2.1+)

``` sql
select
  RESULT
from
  INT2HEX(:NUM, :MIN_LENGTH)
```

### Stored Function (Firebird 3+)

```
INT2HEX (:NUM, :MIN_LENGTH)
```

Demo
----

```
INT2HEX (45345, 8) = '0000B121'
```

Remarks
-------

The return value is assumed to be a string of length 8, because in all existing Firebird versions (2.x, 3, and 4) the `integer` type is 32-bit. That is, it can be written with no more than eight hexadecimal digits from 0 (00000000) to FFFFFFFF. If we replace the `integer` type with `bigint`, then the length of the output string should exactly double (and no other changes are required). If in the future the bit count of the `integer` type increases, then the length of the output string will also have to be increased accordingly: one additional character per each 4 bits.
