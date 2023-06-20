execute block (
  USER_NAME varchar(31) = :USER_NAME)
returns (
  OBJECT_TYPE varchar(13),
  OBJECT_NAME varchar(31),
  PRIVILEGE varchar(9),
  CALLER_TYPE varchar(13),
  CALLER varchar(31),
  LVL smallint)
as
declare variable MAX_LEVEL smallint;
declare variable RECORD_CNT integer;
declare variable RECORD_CNT_OLD integer;
begin
  MAX_LEVEL = 2;
  RECORD_CNT_OLD = -1;
  RECORD_CNT = 0;
      
  /* Get a maximum nesting level */
  while (RECORD_CNT > RECORD_CNT_OLD) do
    for with recursive data
        as (select
              1 as LVL,
              RDB$OBJECT_TYPE as OBJ_TYPE,
              RDB$RELATION_NAME as OBJECT_NAME,
              RDB$OBJECT_TYPE || trim(RDB$PRIVILEGE) || RDB$RELATION_NAME as OBJECT_DATA
            from
              RDB$USER_PRIVILEGES
            where
              RDB$USER = :USER_NAME
            union all
            select
              data.LVL + 1 as LVL,
              R.RDB$OBJECT_TYPE as OBJ_TYPE,
              R.RDB$RELATION_NAME as OBJECT_NAME,
              R.RDB$OBJECT_TYPE || trim(R.RDB$PRIVILEGE) || R.RDB$RELATION_NAME as OBJECT_DATA
            from
              RDB$USER_PRIVILEGES R
            inner join
              data on data.LVL < :MAX_LEVEL and data.OBJECT_NAME = R.RDB$USER and data.OBJECT_NAME <> R.RDB$RELATION_NAME
            where
              RDB$USER <> :USER_NAME and R.RDB$RELATION_NAME <> :USER_NAME
            union all
            select
              data.LVL + 1 as LVL,
              2 as OBJ_TYPE,
              T.RDB$TRIGGER_NAME as OBJECT_NAME,
              '2X' || T.RDB$TRIGGER_NAME as OBJECT_DATA
            from
              RDB$TRIGGERS T
            inner join
              data on data.OBJ_TYPE = 0 and data.OBJECT_NAME = T.RDB$RELATION_NAME
            where
            T.RDB$TRIGGER_INACTIVE = 0)
        select
          count(distinct OBJECT_DATA)
        from
          data
        into
          :RECORD_CNT
    do
    begin
      RECORD_CNT_OLD = RECORD_CNT;
      MAX_LEVEL = MAX_LEVEL + 1;
    end

  /* Extract the access privileges */
  for with recursive data
      as (/* Explicitly granted privileges */
          select
            1 as LVL,
            null as CALLER,
            null as CALLER_TYPE,
            RDB$OBJECT_TYPE as OBJ_TYPE,
            decode(RDB$OBJECT_TYPE,
              0, 'table',
              1, 'view',
              2, 'trigger',
              5, 'procedure',
              7, 'exception',
              8, 'user',
              9, 'domain',
              11, 'character set',
              13, 'role',
              14, 'generator',
              15, 'function',
              16, 'BLOB filter',
              17, 'collation',
              18, 'package') as OBJECT_TYPE,
            RDB$RELATION_NAME as OBJECT_NAME,
            trim(RDB$PRIVILEGE) as PRIVILEGE
          from
            RDB$USER_PRIVILEGES
          where
            RDB$USER = :USER_NAME
          union all
          /* Rivileges indirectly granted by reference from a procedure,
             trigger, etc. */
          select
            data.LVL + 1 as LVL,
            R.RDB$USER as CALLER,
            data.OBJECT_TYPE as CALLER_TYPE,
            R.RDB$OBJECT_TYPE as OBJ_TYPE,
            decode(R.RDB$OBJECT_TYPE,
              0, 'table',
              1, 'view',
              2, 'trigger',
              5, 'procedure',
              7, 'exception',
              8, 'user',
              9, 'domain',
              11, 'character set',
              13, 'role',
              14, 'generator',
              15, 'function',
              16, 'BLOB filter',
              17, 'collation',
              18, 'package') as OBJECT_TYPE,
            R.RDB$RELATION_NAME as OBJECT_NAME,
            trim(R.RDB$PRIVILEGE) as PRIVILEGE
          from
            RDB$USER_PRIVILEGES R
          inner join
            data on data.LVL < :MAX_LEVEL
              and data.OBJECT_NAME = R.RDB$USER
              and data.OBJECT_NAME <> R.RDB$RELATION_NAME
          where
            RDB$USER <> :USER_NAME and R.RDB$RELATION_NAME <> :USER_NAME
          union all
          /* Triggers do not require explicitly granted privileges to run, but
             they themselves may have the privileges to work with other database
             objects */
          select
            data.LVL + 1 as LVL,
            T.RDB$RELATION_NAME as CALLER,
            data.OBJECT_TYPE as CALLER_TYPE,
            2 as OBJ_TYPE,
            'trigger' as OBJECT_TYPE,
            T.RDB$TRIGGER_NAME as OBJECT_NAME,
            null as PRIVILEGE
          from
            RDB$TRIGGERS T
          inner join
            data on data.OBJ_TYPE = 0 and data.OBJECT_NAME = T.RDB$RELATION_NAME
          where
            T.RDB$TRIGGER_INACTIVE = 0
          order by
            2, 4, 5)
      select
        OBJECT_TYPE,
        OBJECT_NAME,
        list(distinct PRIVILEGE) as PRIVILEGE,
        CALLER,
        CALLER_TYPE,
        min(LVL)
      from
        data
      where
        OBJ_TYPE <> 2
      group by
        1, 2, 4, 5
      order by
        1 desc, 2, 4, 5, 6
      into
        :OBJECT_TYPE,
        :OBJECT_NAME,
        :PRIVILEGE,
        :CALLER,
        :CALLER_TYPE,
        :LVL
  do
    suspend;
end