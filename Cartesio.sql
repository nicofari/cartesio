create or replace package Cartesio is

  -- Author  : Nicola Farina
  -- Created : 27/02/2006 11.44.50

  cInfiniteNegative   constant integer := 0;
  cInfinitePositive   constant integer := 32565;

  function bitor( x in number, y in number ) return number;
  function bitxor( x in number, y in number ) return number;
  function bitnot(p_dec1 number) return number;
  function to_base( p_dec in number, p_base in number) return varchar2;
  function to_dec( p_str in varchar2, p_from_base in number default 16) return number;
  function to_hex( p_dec in number ) return varchar2;
  function to_bin( p_dec in number ) return varchar2;
  function to_oct( p_dec in number ) return varchar2;
  
  procedure CheckTest
  (
    TestNo         in pls_integer, 
    Condition      in boolean, 
    ExpectedResult in boolean, 
    MsgDesc        in varchar2,
    MsgFail        in varchar2 default null,
    MsgSucc        in varchar2 default null
  );

end Cartesio;
/
create or replace package body Cartesio is
	function bitor( x IN NUMBER, y IN NUMBER ) RETURN NUMBER  AS
	begin
	  return x + y - bitand(x,y);
	end;

	FUNCTION bitxor( x IN NUMBER, y IN NUMBER ) RETURN NUMBER  AS
	BEGIN
		RETURN bitor(x,y) - bitand(x,y);
	END;

	function to_base( p_dec in number, p_base in number) return varchar2
	is
			l_str   varchar2(255) default NULL;
			l_num   number  default p_dec;
			l_hex   varchar2(16) default '0123456789ABCDEF';
	begin
			if ( trunc(p_dec) <> p_dec OR p_dec < 0 ) then
					raise PROGRAM_ERROR;
			end if;
			loop
					l_str := substr( l_hex, mod(l_num,p_base)+1, 1 ) || l_str;
					l_num := trunc( l_num/p_base );
					exit when ( l_num = 0 );
			end loop;
			return l_str;
	end to_base;

	function to_dec( p_str in varchar2, p_from_base in number default 16 ) return number
	is
			l_num   number default 0;
			l_hex   varchar2(16) default '0123456789ABCDEF';
	begin
			for i in 1 .. length(p_str) loop
					l_num := l_num * p_from_base + instr(l_hex,upper(substr(p_str,i,1)))-1;
			end loop;
			return l_num;
	end to_dec;

	function to_hex( p_dec in number ) return varchar2
	is
	begin
			return to_base( p_dec, 16 );
	end to_hex;

	function to_bin( p_dec in number ) return varchar2
	is
	begin
			return to_base( p_dec, 2 );
	end to_bin;

	function to_oct( p_dec in number ) return varchar2
	is
	begin
			return to_base( p_dec, 8 );
	end to_oct;

	function bitnot(p_dec1 number) return  number is
	begin
	  return (0 - p_dec1) - 1;
	end;
  
  procedure CheckTest
  (
    TestNo         in pls_integer, 
    Condition      in boolean, 
    ExpectedResult in boolean, 
    MsgDesc        in varchar2,
    MsgFail        in varchar2 default null,
    MsgSucc        in varchar2 default null
  ) 
  is
    sRight varchar2(255);
  begin
    if MsgSucc is null then
      if ExpectedResult then
        sRight := ' true ';
      else
        sRight := ' false ';
      end if;
    else
      sRight := MsgSucc;
    end if;
    dbms_output.put_line('Test # ' || TestNo || ' : ' || MsgDesc || ' expected: ' || sRight);
    if Condition = ExpectedResult then
      dbms_output.put_line('OK');
    else
      dbms_output.put_line('Failed');  
      if MsgFail is not null then
        dbms_output.put_line(MsgFail);
      end if;
    end if;
  end CheckTest;

end;
/
