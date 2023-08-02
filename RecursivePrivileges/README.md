RecursivePrivileges
===================

Recursively reads from the metadata the access privileges of a given database subject (user, role, stored procedure, trigger, etc.) on various DB objects (tables, stored procedures, etc.).

Input Parameters
----------------

* `USER_NAME varchar(31)` — the name of the user, role, stored procedure, stored function, or trigger whose privileges are being checked.

Query Fields
------------

* `OBJECT_TYPE varchar(13)` — object type (`'procedure'`, `'table'`, etc., triggers are not listed here because the privileges to run them are taken from access privileges on the corresponding table)
* `OBJECT_NAME varchar(31)` — object name
* `PRIVILEGE varchar(9)` — a comma-separated list of privileges:
  * **S** — select,
  * **R** — reference,
  * **I** — insert,
  * **D** — delete,
  * **U** — update,
  * **X** — execute (only for stored procedures and functions),
  * **M** — membership (for user in relation to role)
* `CALLER_TYPE varchar(13)` — the type of the object that has privileges to this (`'procedure'`, `'trigger'`, etc.)
* `CALLER varchar(31)` — the name of the object that has privileges to this
* `LVL smallint` — nesting level (1 — direct access, 2 — chained through one subroutine, etc.)

Demo
----

You can run this block as an usual SQL query, for example, in the SQL editor of your favorite Firebird management software (I prefer [Interbase Expert](https://www.ibexpert.net/ibe/)) and set the `USER_NAME` parameter to the user or role name, e.g. `'SYSDBA'`.

Remarks
-------

### Why I Created This?

When working with the Firebird DBMS, one difficulty arises, which is related to access privileges. If a restricted user (not administrator) has privileges, for example, to execute a stored procedure, and this procedure writes data to a table, and the table has a trigger that accesses other tables, then you need to set access privileges in a chain: for the user on the procedure, for the procedure on the table, for the trigger on other tables it needs, and so on. It is easy to get confused in this scheme. Unfortunately, even Interbase Expert, the best tool I know for working with the Firebird DBMS, cannot display the privileges in a convenient way. So I wrote this script, which gets the name of the *subject* (user, role, stored procedure, trigger, etc.) and builds a list of DB *objects* and the access privileges of this *subject* to them, as well as the access privileges of other DB objects that these previously listed objects have access to, and so on.

### Privileges To Run The Script

You don't need administrator (e.g. `SYSDBA`) privileges to run this script. Any DB user can read the metadata (but only the administrator can change them).

### Notes On Recursion

The block has a built-in mechanism to avoid endless recursion in a situation where procedures/triggers have the privilege to execute each other, including indirectly, along a chain of several objects.

> **Warning**
> Since the script is recursive, it is subject to the traditional Firebird limitation: no more than 1024 levels (*recursion levels,* not *database objects!*) in the link chain. If your database contains so many relationships, you need a more powerful tool than the simple script.

### Furthermore

:bulb: I had an idea to write a helper program that displays access privileges in a tree form and shows missing privileges (for example when a stored procedure needs to modify a table but doesn't have a permission for it). Maybe someday I'll make it.