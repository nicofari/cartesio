set serveroutput on
clear
declare
  TheInt   TInterval;
  TheInt2  TInterval;
  TheInt3  TInterval;
  Result   boolean;
  cIntEmpty TInterval := new TInterval(0, 0, 0, 0);
  NewColl3  TIntervalCollection;    
  NewColl2  TIntervalCollection;  
  NewColl  TIntervalCollection;
  TheColl  TIntervalCollection;
  rc       integer;
  Point    integer;
  IntEsito TInterval;
  EsitoColl TIntervalCollection;
begin
  dbms_output.enable(1000000);

  -- check interval: [2, 4)
  TheInt := new TInterval(2, 4, 1, 0);

  dbms_output.put_line('');
  dbms_output.put_line('----------------------------------');  
  dbms_output.put_line('Point included in an interval');
  dbms_output.put_line('----------------------------------');
  -- Test #1 
  Point := 4;
  Cartesio.CheckTest(1, TheInt.IsContained(Point), False, Point || ' is contained in ' || TheInt.AsString);

  -- Test #2
  Point := 2;
  Cartesio.CheckTest(2, TheInt.IsContained(Point), True, Point || ' is contained in ' || TheInt.AsString);

  -- Test #3  
  Point := 1;
  Cartesio.CheckTest(3, TheInt.IsContained(Point), False, Point || ' is contained in ' || TheInt.AsString);

  -- Test #4 
  dbms_output.put_line('');
  dbms_output.put_line('----------------------------------');  
  dbms_output.put_line('Intersections between intervals');
  dbms_output.put_line('----------------------------------');
  
  -- Intersection with [5, 8] should be empty
  TheInt3 := new TInterval(5, 8, 1, 1);
  TheInt2 := TheInt.Intersection(TheInt3);
  Cartesio.CheckTest(4, TheInt2 = cIntEmpty, True, TheInt3.AsString || ' intersected with ' || TheInt.AsString, null, cIntEmpty.AsString);
  
  -- Intersection with [3, 5] = [3, 4) (intersection on start)
  TheInt3 := new TInterval(3, 5, 1, 0);
  TheInt2 := TheInt.Intersection(TheInt3);
  IntEsito := new TInterval(3, 4, 1, 0);
  Cartesio.CheckTest(5, TheInt2 = IntEsito, True, TheInt3.AsString || ' intersected with ' || TheInt.AsString, TheInt2.AsString, IntEsito.AsString);
  
  -- Intersection with [2, 3] = [2, 3) (totally contained)
  TheInt3 := new TInterval(2, 3, 1, 0);
  TheInt2 := TheInt.Intersection(TheInt3);
  IntEsito := new TInterval(2, 3, 1, 0);
  Cartesio.CheckTest(6, TheInt2 = IntEsito, True, TheInt3.AsString || ' intersected with ' || TheInt.AsString, TheInt2.AsString, IntEsito.AsString);
  
  -- Intersection with [1, 3] = [2, 3) (intersection on end)
  TheInt3 := new TInterval(1, 3, 1, 0);
  TheInt2 := TheInt.Intersection(TheInt3);
  IntEsito := new TInterval(2, 3, 1, 0);
  Cartesio.CheckTest(7, TheInt2 = IntEsito, True, TheInt3.AsString || ' intersected with ' || TheInt.AsString, TheInt2.AsString, IntEsito.AsString);
  
  -- Intersection with [1, 10] = TheInt 
  TheInt3 := new TInterval(1, 10, 1, 0);
  TheInt2 := TheInt.Intersection(TheInt3);
  IntEsito := TheInt;
  Cartesio.CheckTest(8, TheInt2 = TheInt, True, TheInt3.AsString || ' intersecato con ' || TheInt.AsString, TheInt2.AsString, TheInt.AsString);
  
  -- Test negation
  dbms_output.put_line('');
  dbms_output.put_line('----------------------------------');  
  dbms_output.put_line('Interval negation ');
  dbms_output.put_line('----------------------------------');
  TheColl := new TIntervalCollection;
  NewColl := TheColl.Negate(TheInt);
  EsitoColl := new TIntervalCollection;
  TheInt2 := new TInterval(0, 2, 0, 0);
  TheInt3 := new TInterval(4, 32565, 1, 0);
  EsitoColl.AddOr(TheInt2);
  EsitoColl.AddOr(TheInt3);  
  Cartesio.CheckTest(9, NewColl = EsitoColl, True, 'Negate ' || TheInt.AsString || ' : ', NewColl.AsString, EsitoColl.AsString);
  
  NewColl3 := TheColl.Negate(TheInt2);
  NewColl2 := TheColl.Negate(TheInt3);
  
  TheInt3 := NewColl3.IntervalTable(1).Intersection(NewColl2.IntervalTable(1));
  Cartesio.CheckTest(10, TheInt3 = TheInt, True, 'Negate ' || NewColl.AsString || ' : ', TheInt3.AsString, TheInt.AsString);  
  
  dbms_output.put_line('');
  dbms_output.put_line('----------------------------------');  
  dbms_output.put_line('Consecutives');
  dbms_output.put_line('----------------------------------');
  TheInt2 := new TInterval(5,16,1,1);
  Cartesio.CheckTest(11, TheInt.IsConsecutive(TheInt2)=2, False, 
    'Test consecutivity ' || TheInt.AsString || ' with ' || TheInt2.AsString,
    TheInt2.AsString, 'False');
  
  TheInt := new TInterval(2,4,1,1);
  Cartesio.CheckTest(12, TheInt.IsConsecutive(TheInt2)=2, True, 
    'Test consecutivity ' || TheInt.AsString || ' with ' || TheInt2.AsString,
    TheInt2.AsString, 'True');
    
  TheInt := new TInterval(2, 4, 1, 0);
  TheInt2 := new TInterval(4,16,1,1);      
  Cartesio.CheckTest(13, TheInt.IsConsecutive(TheInt2)=2, True, 
    'Test consecutivity ' || TheInt.AsString || ' with ' || TheInt2.AsString,
    TheInt2.AsString, 'True');
    
  dbms_output.put_line('');
  dbms_output.put_line('----------------------------------');  
  dbms_output.put_line('Inclusion ');
  dbms_output.put_line('----------------------------------');
  TheInt3 := new TInterval(2, 16, 1, 1);
  IntEsito := TheInt2.Include(TheInt);
  Cartesio.CheckTest(14, IntEsito=TheInt3, True, 'Includes ' || TheInt2.AsString || ' and ' || TheInt.AsString,
    IntEsito.AsString, TheInt3.AsString);
    
end;
/
