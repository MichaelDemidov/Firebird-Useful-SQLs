GEN_PASSWORD
============

Function (procedure) that generates a password of a certain length from random characters.

Input Parameters
----------------

* `MIN_LENGTH smallint` — minimum password length (by default 8).
* `MAX_LENGTH smallint` — maximum password length (by default 10).

Return Value (Output Parameter)
-------------------------------

### Output Parameter In Stored Procedure (Firebird 2.1+)

* `PWD varchar(100)` — the generated password.

### Return Value In Stored Function (Firebird 3+)

* `varchar(100)` — the generated password.

Syntax
------

### Stored Procedure (Firebird 2.1+)

``` sql
select
  RESULT
from
  GEN_PASSWORD(:MIN_LENGTH, :MAX_LENGTH)
```

### Stored Function (Firebird 3+)

```
GEN_PASSWORD(:MIN_LENGTH, :MAX_LENGTH)
```

Demo
----

```
GEN_PASSWORD(10, 14) = 'kym79PfBX@7jx6'
```

Remarks
-------

| :exclamation: Warning (for beginners)|
|:------------------------------------------|
|*This stored procedure/function is written more for fun and as an exercise for the mind. Of course, it should be understood that passwords cannot be stored as plain text in a database and need not be transmitted over networks.*|

The password must meet the following criteria:

1. The length of the password is random within the given limits, while it is at least 6 characters long (even if the parameter contains a smaller number).
2. The password consists of randomly selected characters, including uppercase and lowercase Latin letters, numbers, and special characters (“$”, “#”, etc.).
3. Letters, numbers and symbols should be included in the password more or less evenly, that is, we do not want it to consist of only uppercase or lowercase letters, or numbers, or symbols.
4. The frequency of occurrence of special characters is less than that of letters and numbers, because otherwise such a password will be inconvenient to type, for example, on a smartphone keyboard, where special characters are usually typed with switching to a separate on-screen keyboard.
5. The password should be easy to read if it is displayed on the screen or printed (written) on paper. That is, characters that are read ambiguously should be avoided. For example, in almost all fonts, the zero 0 and the capital letter O are similar. Sans-serif fonts (like *Arial*) do not distinguish between lowercase Latin “l” (i.e. “L”) and capital “I” (i.e. “i”) — both look like a simple vertical stick. Lowercase “l” (i.e. “L”) in serif fonts (such as *Times New Roman*) is indistinguishable from the digit 1. From the list of available characters, I had to throw out all the controversial characters, and it turned out to be 24 uppercase Latin letters, 25 lowercase letters (lowercase “o” is allowed because it does not look like zero in most fonts) and 8 numbers.

See also comments in the procedure/function text.
