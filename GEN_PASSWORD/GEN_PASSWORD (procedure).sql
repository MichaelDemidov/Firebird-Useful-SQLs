SET TERM ^ ;

create or alter procedure GEN_PASSWORD (
  MIN_LENGTH smallint = 8,
  MAX_LENGTH smallint = 10)
returns (
  PWD varchar(100))
as
declare variable P_LENGTH smallint; /* Password length */
declare variable DICE smallint; /* Dice (random number) */
declare variable LOWER_CHARS char(25) = 'abcdefghijkmnopqrstuvwxyz'; /* Lower letters */
declare variable LOWER_CHARS_CHANCE smallint = 50; /* Probability of the lower letter */
declare variable UPPER_CHARS char(24) = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; /* Upper letters */
declare variable UPPER_CHARS_CHANCE smallint = 35; /* Probability of the upper letter */
declare variable DIGITS char(8) = '23456789'; /* Digits */
declare variable DIGITS_CHANCE smallint = 20; /* Probability of the digit */
declare variable ADD_CHARS char(11) = '$~+-_?!#@^&'; /* Special characters */
declare variable ADD_CHARS_CHANCE smallint = 15; /* Probability of the special character */
begin
  /* The minimum length must be at least 6 characters */
  if (MIN_LENGTH is null or MIN_LENGTH < 6) then
    MIN_LENGTH = 6;
  if (MAX_LENGTH is null or MAX_LENGTH < MIN_LENGTH) then
    MAX_LENGTH = MIN_LENGTH;

  P_LENGTH = MAX_LENGTH - trunc(rand() * (MAX_LENGTH - MIN_LENGTH + 1));
  PWD = '';
  /* in order to achieve some uniformity in the distribution of different types
     of characters, after the appearance of each next character, we decrease
     the probability of the appearance of a character of the same type and
     increase the probability of the appearance of all other types. However,
     we also do not want special characters (not letters or numbers) to appear
     too often, so with each occurrence of a special character, the probability
     of the next special character appearing should drop faster than for other
     character types. The same rule applies to capital letters, but to a lesser
     extent */
  while (P_LENGTH > 0) do
  begin
    DICE = trunc(rand() * (LOWER_CHARS_CHANCE + UPPER_CHARS_CHANCE
      + DIGITS_CHANCE + ADD_CHARS_CHANCE));
    if (DICE < LOWER_CHARS_CHANCE) then
    begin
      PWD = PWD || substring(LOWER_CHARS from 1 + trunc(rand()
        * char_length(LOWER_CHARS)) for 1);
      LOWER_CHARS_CHANCE = LOWER_CHARS_CHANCE - 5;
      if (LOWER_CHARS_CHANCE <= 0) then
        LOWER_CHARS_CHANCE = 1;
      UPPER_CHARS_CHANCE = UPPER_CHARS_CHANCE + 4;
      DIGITS_CHANCE = DIGITS_CHANCE + 5;
      ADD_CHARS_CHANCE = ADD_CHARS_CHANCE + 2;
    end
    else
    if (DICE < LOWER_CHARS_CHANCE + UPPER_CHARS_CHANCE) then
    begin
      PWD = PWD || substring(UPPER_CHARS from 1 + trunc(rand()
        * char_length(UPPER_CHARS)) for 1);
      LOWER_CHARS_CHANCE = LOWER_CHARS_CHANCE + 5;
      UPPER_CHARS_CHANCE = UPPER_CHARS_CHANCE - 5;
      if (UPPER_CHARS_CHANCE <= 0) then
        UPPER_CHARS_CHANCE = 1;
      DIGITS_CHANCE = DIGITS_CHANCE + 5;
      ADD_CHARS_CHANCE = ADD_CHARS_CHANCE + 2;
    end
    else
    if (DICE < LOWER_CHARS_CHANCE + UPPER_CHARS_CHANCE + DIGITS_CHANCE) then
    begin
      PWD = PWD || substring(DIGITS from 1 + trunc(rand() * char_length(DIGITS))
        for 1);
      LOWER_CHARS_CHANCE = LOWER_CHARS_CHANCE + 5;
      UPPER_CHARS_CHANCE = UPPER_CHARS_CHANCE + 4;
      DIGITS_CHANCE = DIGITS_CHANCE - 5;
      if (DIGITS_CHANCE <= 0) then
        DIGITS_CHANCE = 1;
      ADD_CHARS_CHANCE = ADD_CHARS_CHANCE + 2;
    end
    else
    begin
      PWD = PWD || substring(ADD_CHARS from 1 + trunc(rand()
        * char_length(ADD_CHARS)) for 1);
      LOWER_CHARS_CHANCE = LOWER_CHARS_CHANCE + 5;
      UPPER_CHARS_CHANCE = UPPER_CHARS_CHANCE + 4;
      DIGITS_CHANCE = DIGITS_CHANCE + 5;
      ADD_CHARS_CHANCE = ADD_CHARS_CHANCE - 5;
      if (ADD_CHARS_CHANCE <= 0) then
        ADD_CHARS_CHANCE = 1;
    end
    P_LENGTH = P_LENGTH - 1;
  end
  /* if the password consists of only lowercase or only uppercase letters,
     then it must be generated again!

     NB! If the minimum password length is reduced to 1 character, the procedure
     may hang. Above, we prohibited the MIN_LENGTH of less than 6 characters,
     so it is impossible until that check is removed */
  if (PWD = upper(PWD) or PWD = lower(PWD)) then
    PWD = (select PWD from GEN_PASSWORD(:MIN_LENGTH, :MAX_LENGTH));
  suspend;
end^

SET TERM ; ^

COMMENT ON PROCEDURE GEN_PASSWORD IS
'Generate a random password';

COMMENT ON PARAMETER GEN_PASSWORD.MIN_LENGTH IS
'Minimum length';

COMMENT ON PARAMETER GEN_PASSWORD.MAX_LENGTH IS
'Maximum length';

COMMENT ON PARAMETER GEN_PASSWORD.PWD IS
'Generated password';

GRANT EXECUTE ON PROCEDURE GEN_PASSWORD TO PROCEDURE GEN_PASSWORD;