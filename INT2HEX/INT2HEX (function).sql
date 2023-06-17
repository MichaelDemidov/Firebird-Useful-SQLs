SET TERM ^ ;

create or alter function INT2HEX_F (
  NUM integer,
  MIN_LENGTH smallint = 0)
returns varchar(8)
as
declare variable RESULT varchar(8);
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
  return RESULT;
end^

SET TERM ; ^

COMMENT ON FUNCTION INT2HEX_F IS
'Convert integer to a hexadecimal string';

COMMENT ON PARAMETER INT2HEX_F.NUM IS
'Input number';

COMMENT ON PARAMETER INT2HEX_F.MIN_LENGTH IS
'Minimum output length';