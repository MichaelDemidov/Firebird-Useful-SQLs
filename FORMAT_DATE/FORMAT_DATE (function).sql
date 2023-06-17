SET TERM ^ ;

create or alter function FORMAT_DATE (
  A_DATE date = current_date,
  FORMAT varchar(1000) = 'YYYY-MM-DD',
  LONG_DAY_NAMES varchar(255) = 'Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday',
  SHORT_DAY_NAMES varchar(50) = 'Sun,Mon,Tue,Wed,Thu,Fri,Sat',
  LONG_MONTH_NAMES varchar(255) = 'January,February,March,April,May,June,July,August,September,October,November,December',
  SHORT_MONTH_NAMES varchar(255) = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec')
returns varchar(1000)
as
declare variable D_YEAR smallint; /* Year number */
declare variable D_MONTH smallint; /* Month number */
declare variable D_DAY smallint; /* Day number */
declare variable I smallint; /* Versatile counter */
declare variable L1 smallint; /* Delimiter position 1 in the long month/day name */
declare variable S1 smallint; /* Delimiter position 1 in the short month/day name */
declare variable L2 smallint; /* Delimiter position 2 in the long month/day name */
declare variable S2 smallint; /* Delimiter position 2 in the short month/day name */
declare variable WILDCARD varchar(1000); /* Wildcard string */
declare variable NAME varchar(100); /* Name of the month or day */
declare variable RESULT varchar(1000); /* Formatted date */
begin
  if (A_DATE is null) then
    RESULT = null;
  else
  if (FORMAT is null) then
    RESULT = cast(A_DATE as varchar(1000));
  else
  begin
    D_YEAR = extract(year from A_DATE);
    D_MONTH = extract(month from A_DATE);
    D_DAY = extract(day from A_DATE);
    RESULT = FORMAT;
    WILDCARD = FORMAT;

    LONG_MONTH_NAMES = LONG_MONTH_NAMES || ',';
    SHORT_MONTH_NAMES = SHORT_MONTH_NAMES || ',';
    LONG_DAY_NAMES = LONG_DAY_NAMES || ',';
    SHORT_DAY_NAMES = SHORT_DAY_NAMES || ',';

    if (RESULT like '%YYYY%') then
    begin
      RESULT = replace(RESULT, 'YYYY', D_YEAR);
      WILDCARD = replace(WILDCARD, 'YYYY', lpad('', char_length(D_YEAR), '_'));
    end
    if (RESULT like '%YY%') then
    begin
      RESULT = replace(RESULT, 'YY', mod(D_YEAR, 100));
      WILDCARD = replace(WILDCARD, 'YY', '__');
    end
    if (RESULT like '%MMM%') then
    begin
      I = D_MONTH;
      L2 = 0;
      S2 = 0;
      while (I > 0) do
      begin
        L1 = L2 + 1;
        S1 = S2 + 1;
        L2 = position(',', LONG_MONTH_NAMES, L1);
        S2 = position(',', SHORT_MONTH_NAMES, S1);
        I = I - 1;
      end
      I = position('MMMM', WILDCARD);
      if (I > 0) then
      begin
        NAME = substring(LONG_MONTH_NAMES from L1 for L2 - L1);
        while (I > 0) do
        begin
          RESULT = overlay(RESULT placing NAME from I for 4);
          WILDCARD = overlay(WILDCARD placing lpad('', L2 - L1, '_') from I for 4);
          I = position('MMMM', WILDCARD);
        end
      end
      I = position('MMM', WILDCARD);
      if (I > 0) then
      begin
        NAME = substring(SHORT_MONTH_NAMES from S1 for S2 - S1);
        while (I > 0) do
        begin
          RESULT = overlay(RESULT placing NAME from I for 3);
          WILDCARD = overlay(WILDCARD placing lpad('', S2 - S1, '_') from I for 3);
          I = position('MMM', WILDCARD);
        end
      end
    end

    if (RESULT like '%DDD%') then
    begin
      I = extract(weekday from A_DATE);
      L2 = 0;
      S2 = 0;
      while (I >= 0) do
      begin
        L1 = L2 + 1;
        S1 = S2 + 1;
        L2 = position(',', LONG_DAY_NAMES, L1);
        S2 = position(',', SHORT_DAY_NAMES, S1);
        I = I - 1;
      end
      I = position('DDDD', WILDCARD);
      if (I > 0) then
      begin
        NAME = substring(LONG_DAY_NAMES from L1 for L2 - L1);
        while (I > 0) do
        begin
          RESULT = overlay(RESULT placing NAME from I for 4);
          WILDCARD = overlay(WILDCARD placing lpad('', L2 - L1, '_') from I for 4);
          I = position('DDDD', WILDCARD);
        end
      end
      I = position('DDD', WILDCARD);
      if (I > 0) then
      begin
        NAME = substring(SHORT_DAY_NAMES from S1 for S2 - S1);
        while (I > 0) do
        begin
          RESULT = overlay(RESULT placing NAME from I for 3);
          WILDCARD = overlay(WILDCARD placing lpad('', S2 - S1, '_') from I for 3);
          I = position('DDD', WILDCARD);
        end
      end
    end

    I = position('MM', WILDCARD);
    while (I > 0) do
    begin
      RESULT = overlay(RESULT placing lpad(cast(D_MONTH as varchar(2)), 2, '0') from I for 2);
      WILDCARD = overlay(WILDCARD placing '__' from I for 2);
      I = position('MM', WILDCARD);
    end
    I = position('M', WILDCARD);
    while (I > 0) do
    begin
      RESULT = overlay(RESULT placing D_MONTH from I for 1);
      WILDCARD = overlay(WILDCARD placing lpad('', char_length(D_MONTH), '_') from I for 1);
      I = position('M', WILDCARD);
    end
    I = position('DD', WILDCARD);
    while (I > 0) do
    begin
      RESULT = overlay(RESULT placing lpad(cast(D_DAY as varchar(2)), 2, '0') from I for 2);
      WILDCARD = overlay(WILDCARD placing '__' from I for 2);
      I = position('DD', WILDCARD);
    end
    I = position('D', WILDCARD);
    while (I > 0) do
    begin
      RESULT = overlay(RESULT placing D_MONTH from I for 1);
      WILDCARD = overlay(WILDCARD placing lpad('', char_length(D_DAY), '_') from I for 1);
      I = position('D', WILDCARD);
    end
  end
  return RESULT;
end^

SET TERM ; ^

COMMENT ON FUNCTION FORMAT_DATE IS
'Format date';

COMMENT ON PARAMETER FORMAT_DATE.A_DATE IS
'Date to format';

COMMENT ON PARAMETER FORMAT_DATE.FORMAT IS
'Format string';

COMMENT ON PARAMETER FORMAT_DATE.LONG_DAY_NAMES IS
'Long day names (Sunday..Saturday), localize it if needed';

COMMENT ON PARAMETER FORMAT_DATE.SHORT_DAY_NAMES IS
'Short day names (Sun..Sat), localize it if needed';

COMMENT ON PARAMETER FORMAT_DATE.LONG_MONTH_NAMES IS
'Long month names (January..December), localize it if needed';

COMMENT ON PARAMETER FORMAT_DATE.SHORT_MONTH_NAMES IS
'Short month names (Jan..Dec), localize it if needed';