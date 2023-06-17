SET TERM ^ ;

create or alter procedure SPLIT (
  DELIMITED_LIST varchar(1000),
  DELIMITER varchar(10) = ',')
returns (
  LIST_NUM smallint,
  LIST_ITEM varchar(1000))
as
declare variable I smallint; /* Counter */
begin
  LIST_NUM = 0;
  if (DELIMITED_LIST is null) then
  begin
    LIST_ITEM = DELIMITED_LIST;
    suspend;
  end
  else
    /* comparing the input string with an empty string is meaningless, because
       trailing spaces are ignored in SQL, see ANSI/ISO SQL-92 specification,
       section 8.2 */
    while (DELIMITED_LIST || '.' <> '.') do
    begin
      if (DELIMITER is null or DELIMITER || '.' = '.') then
      begin
        LIST_ITEM = substring(DELIMITED_LIST from 1 for 1);
        DELIMITED_LIST = substring(DELIMITED_LIST from 2);
      end
      else
      begin
        I = position(DELIMITER in DELIMITED_LIST);
        if (I = 0) then
        begin
          LIST_ITEM = DELIMITED_LIST;
          DELIMITED_LIST = '';
        end
        else
        begin
          LIST_ITEM = substring(DELIMITED_LIST from 1 for I - 1);
          DELIMITED_LIST = substring(DELIMITED_LIST from I + char_length(DELIMITER));
        end
      end
      LIST_NUM = LIST_NUM + 1;
      suspend;
    end
end^

SET TERM ; ^

COMMENT ON PROCEDURE SPLIT IS
'Convert a list given as a delimited string to a table';

COMMENT ON PARAMETER SPLIT.DELIMITED_LIST IS
'Delimited list';

COMMENT ON PARAMETER SPLIT.DELIMITER IS
'Delimiter';

COMMENT ON PARAMETER SPLIT.LIST_NUM IS
'Serial number of the item';

COMMENT ON PARAMETER SPLIT.LIST_ITEM IS
'Item content';