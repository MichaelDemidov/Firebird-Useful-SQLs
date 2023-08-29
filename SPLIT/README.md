SPLIT
=====

This procedure takes as input the string containing a delimited list and the delimiter (character or short string), and returns the list elements as a table. In fact, it does the opposite of the `list` aggregate function.

Input Parameters
----------------

* `DELIMITED_LIST varchar(1000)` — the delimited list.
* `DELIMITER varchar(10)` — the delimiter (by default it is comma ',').

Output Parameters
-----------------

* `LIST_NUM smallint` — serial number of the item.
* `LIST_ITEM varchar(1000)` — item content.

Syntax
------

### Stored Procedure (Firebird 1.5+)

``` sql
select
  LIST_NUM,
  LIST_ITEM
from
  SPLIT(:DELIMITED_LIST, :DELIMITER)
```

or

``` sql
select
  LIST_NUM,
  LIST_ITEM
from
  SPLIT(:DELIMITED_LIST)
```

Demo
----

```
select
  LIST_NUM,
  LIST_ITEM
from
  SPLIT('ABC,DEF,G,HI KLM')
```

returns a table:

|LIST_NUM|LIST_ITEM|
|-------:|---------|
|1       |ABC      |
|2       |DEF      |
|3       |G        |
|4       |HI KLM   |

Remarks
-------

This procedure is compatible not only with Firebird 2.5, but also with the older Firebird 1.5.

How it can be useful: sometimes there are situations when you need to pass a variable (or unknown) number of parameters to the SQL query. For example (very simplified!): given a table containing two fields, `ID` (code) and `NAME` (name). We need to select a subset of records with certain specific codes, the number of which is not known in advance. We can express it like this:

``` sql
select
  ID,
  NAME
from
  MY_TABLE
where
  ID = any(select
             LIST_ITEM
           from
             SPLIT(:COMMA_SEPARATED_LIST_OF_IDS))
```

Now we can pass to this SQL a string containing a list of codes separated by commas, e.g. '1,5,17'.

> **Important**
> This stored procedure does not properly parse strings with escaped delimiters and does not recognize such delimiters, as many programming languages do. Although it is not so difficult to modify it for this.
