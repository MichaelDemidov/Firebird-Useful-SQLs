Useful Firebird SQL
===================

What is it?
-----------

This is a collection of various auxiliary stored procedures and functions for the [Firebird DBMS](https://www.firebirdsql.org/). Some of them I use in my daily work, and some were created by me just for fun, but I think that they could be useful (or just funny) to someone else. I have been collecting them for a long time, and it is likely that the list will be replenished in the future. At least I created more procedures, but it’s just that I don’t have time to neatly format and test them, and write a readme.

The algorithms are presented as PSQL scripts. Most of them exist in two forms: as a stored procedure (for compatibility with Firebird versions lower than 3) and as a stored function (for Firebird 3 and above). Some algorithms return a dataset so they cannot be represented as a stored function, but only as a stored procedure.

All of the **stored procedures** are compatible with Firebird versions 2.5 and 3 and have been tested on those versions. They must also be compatible with newer versions of the DBMS. Some procedures are compatible with Firebird 2.1 and even 1.5 — I always write the minimum version in the **Syntax** section.

All **stored functions** presented are for Firebird version 3 and above only.

Each pair of stored procedure and function (or just a stored procedure) is placed in a separate subfolder along with its own readme file.

List of procedures and functions
--------------------------------

in alphabetical order

* [FORMAT_DATE](FORMAT_DATE/README.md) — format date.
* [GEN_PASSWORD](GEN_PASSWORD/README.md) — generate a random password.
* [INT2HEX](INT2HEX/README.md) — convert an integer to a hexadecimal string.
* [SPLIT](SPLIT/README.md) — convert a string containing a delimited list to a table, i.e. perform the opposite task of the `list` aggregate function.

For more information, please read the readme file in the corresponding subfolder.

Author
------
Copyright (c) 2023, Michael Demidov

Visit my GitHub page to check for updates, report issues, etc.: https://github.com/MichaelDemidov

Drop me an e-mail at: michael.v.demidov@gmail.com
