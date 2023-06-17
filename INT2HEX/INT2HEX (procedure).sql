SET TERM ^ ;

create or alter procedure INT2HEX (
  NUM integer,
  MIN_LENGTH smallint = 0)
returns (
  RESULT varchar(8))
as
begin
  if (NUM is null) then
    RESULT = null;
  else
  begin
    RESULT = '';
    while (NUM > 0) do
    begin
      RESULT = decode(mod(NUM, 16),
        15, 'F',
        14, 'E',
        13, 'D',
        12, 'C',
        11, 'B',
        10, 'A',
        mod(NUM, 16)) || RESULT;
      NUM = NUM / 16;
    end
    if (MIN_LENGTH > 0) then
      RESULT = lpad(RESULT, MIN_LENGTH, '0');
  end
  suspend;
end^

SET TERM ; ^

COMMENT ON PROCEDURE INT2HEX IS
'Convert integer to a hexadecimal string';

COMMENT ON PARAMETER INT2HEX.NUM IS
'Input number';

COMMENT ON PARAMETER INT2HEX.MIN_LENGTH IS
'Minimum output length';

COMMENT ON PARAMETER INT2HEX.RESULT IS
'The converted value';