FORMAT_DATE
===========

By default, Firebird can only convert the date to the form YYYY-MM-DD (ISO 8601) when casting it as a string. Therefore, I wrote this stored procedure / function, which receives a date and a format string as input. In the format string, the letters Y, M, and D indicate the position for the date elements (year, month, day) in various forms. For more details, see the description of the input parameters below and the [Remarks](#Remarks) section.

Input Parameters
----------------

* `A_DATE date` — input date.
* `FORMAT varchar(1000)` — format string (by default 'YYYY-MM-DD'), see the [Remarks](#Remarks) section.
* `LONG_DAY_NAMES varchar(255)` — comma-separated list of long day names (by default 'Sunday,Monday,..,Saturday'), see the [Remarks](#Remarks) section.
* `SHORT_DAY_NAMES varchar(50)` — comma-separated list of short day names (by default 'Sun,Mon,..,Sat'), see the [Remarks](#Remarks) section.
* `LONG_MONTH_NAMES varchar(255)` — comma-separated list of long month names (by default 'January,February,..,December'), see the [Remarks](#Remarks) section.
* `SHORT_MONTH_NAMES varchar(50)` — comma-separated list of short month names (by default 'Jan,Feb,..,Dec'), see the [Remarks](#Remarks) section.

Return Value (Output Parameter)
-------------------------------

### Output Parameter In Stored Procedure (Firebird 2.1+)

* `RESULT varchar(1000)` — the formatted date.

### Return Value In Stored Function (Firebird 3+)

* `varchar(1000)` — the formatted date.

Syntax
------

### Stored Procedure (Firebird 2.1+)

``` sql
select
  RESULT
from
  FORMAT_DATE(:A_DATE, :FORMAT, :LONG_DAY_NAMES, :SHORT_DAY_NAMES, :LONG_MONTH_NAMES, :SHORT_MONTH_NAMES)
```

or

``` sql
select
  RESULT
from
  FORMAT_DATE(:A_DATE, :FORMAT)
```

or any other combination of the input parameters.

### Stored Function (Firebird 3+)

```
FORMAT_DATE(:A_DATE, :FORMAT, :LONG_DAY_NAMES, :SHORT_DAY_NAMES, :LONG_MONTH_NAMES, :SHORT_MONTH_NAMES)
```

or

``` sql
FORMAT_DATE(:A_DATE, :FORMAT)
```

or any other combination of the input parameters.

Demo
----

```
FORMAT_DATE('2023-06-17', 'DDDD, DD MMMM YYYY') = 'Saturday, 17 June 2023'
```

Remarks
-------

### Formats

The following character combinations are replaced:
* D - day without leading space (e.g. '5' for 5 January)
* DD - day with a leading space (e.g. '05' for 5 January)
* DDD - day of the week, short name from `SHORT_DAY_NAMES`
* DDDD - day of the week, long name from `LONG_DAY_NAMES`
* M - month without leading space (e.g. '6' for June)
* MM - month number with leading space (e.g. '06' for June)
* MMM - month, short name from `SHORT_MONTH_NAMES`
* MMMM - month, long name from `LONG_MONTH_NAMES`
* YY - year, last 2 digits (e.g. '23' for 2023)
* YYYY - year, 4 digits (e.g. '2023').

In one `FORMAT` string, it is possible to use as many of these substitutions as needed in any combination, and mixed with plain text, which is not replaced by anything. It is only important to ensure that this plain text does not contain the letters “M”, “D” and “Y”, otherwise they will also be replaced with parts of the date.

### Localization

I have used English month and day names as default values for all the `..._NAMES` input parameters, but if English is not your default language, you can easily replace them with your native names. The same applies to the default “YYYY-MM-DD” date format. For example, in Serbia, you can use the following default values:

* FORMAT varchar(1000) = 'DD. MM. YYYY.',
* LONG_DAY_NAMES varchar(255) = 'Nedelja,Ponedeljak,Utorak,Sreda,Četvrtak,Petak,Subota',
* SHORT_DAY_NAMES varchar(50) = 'Ned,Pon,Uto,Sre,Čet,Pet,Sub',
* LONG_MONTH_NAMES varchar(255) = 'Januar,Februar,Mart,April,Maj,Juni,Juli,Avgust,Septembar,Oktobar,Novembar,Decembar',
* SHORT_MONTH_NAMES varchar(255) = 'Jan,Feb,Mar,Apr,Maj,Jun,Jul,Avg,Sep,Okt,Nov,Dec'

| :exclamation: Warning |
|:------------------------------------------|
|*The first day of the week in both `LONG_DAY_NAMES` and `SHORT_DAY_NAMES` must always be Sunday, this is a Firebird PSQL limitation.*|
