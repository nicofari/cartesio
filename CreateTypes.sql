drop type TIntervalCollection;
drop type TIntervalTable;
create or replace type TInterval as object
(
  a       integer,
  b       integer,
  CloseA  integer,
  CloseB  integer,
  member function Length return integer,
  member function IsContained(CfrPoint in integer) return boolean,
  member function IsConsecutive(CfrInt in TInterval) return integer,
  member function Intersection(CfrInt in TInterval) return TInterval,
  member function Include(CfrInt in TInterval) return TInterval,
  map member function AsString return varchar2,
  constructor function TInterval(a in integer, b in integer, CloseA in integer, CloseB in integer) return self as result
);
/
create or replace type body TInterval as

  constructor function TInterval(a in integer, b in integer, CloseA in integer, CloseB in integer) return self as result
  is
  begin
    if a < 0 or b < 0 or CloseA not in (0,1) or CloseB not in (0,1) then
      raise_application_error(-20000, 'TInterval: invalid parameters: a, b should be positive integers and CloseA|B 0 or 1'); 
    end if;
    Self.a := a;
    Self.b := b;
    Self.CloseA := CloseA;
    Self.CloseB := CloseB;
    return;
  end TInterval;

  map member function AsString return varchar2
  is
  begin
    if CloseA=1 then
      if CloseB=1 then
        -- [a,b]
        return '[' || a || ', ' || b || ']';
      else
        -- [a,b)
        return '[' || a || ', ' || b || ')';
      end if;
    else
      -- (a, b]
      if CloseB=1 then
        return '(' || a || ', ' || b || ']';
      else
      -- (a,b)
        return '(' || a || ', ' || b || ')';
      end if;
    end if;
  end AsString;

  -- Return: 0 not consecutive, 1 left consecutive, 2 right consecutive
  member function IsConsecutive(CfrInt in TInterval) return integer
  is
    Result integer := 0;
    a1     integer;
    b1     integer;
    a2     integer;
    b2     integer;
  begin
    if CloseA=1 then
      a1 := a;
    else
      a1 := a+1;
    end if;
    
    if CloseB=1 then
      b1 := b;
    else
      b1 := b-1;
    end if;
    
    if CfrInt.CloseA=1 then
      a2 := CfrInt.a;
    else
      a2 := CfrInt.a + 1;
    end if;
    
    if CfrInt.CloseB=1 then
      b2 := CfrInt.b;
    else
      b2 := CfrInt.b - 1;
    end if;
    
    if a1 = b2 + 1 then
      Result := 1;
    elsif b1 = a2 - 1 then
      Result := 2;
    end if;
    return Result;
  end IsConsecutive;
  
  member function Include(CfrInt in TInterval) return TInterval
  is
    Result TInterval;
    Consecutio integer;
  begin
    Consecutio := Self.IsConsecutive(CfrInt);
    if Consecutio = 0 then
      raise_application_error(-20000, 'TInterval.Include: not consecutive: self: ' || Self.AsString || ' CfrInt: ' || CfrInt.AsString);
    end if;
    Result := new TInterval(0,0,0,0);
    if Consecutio=1 then
      Result.a      := CfrInt.a;
      Result.CloseA := CfrInt.CloseA;
      Result.b      := Self.b;
      Result.CloseB := Self.CloseB;
    else
      Result.a      := Self.a;
      Result.CloseA := Self.CloseA;
      Result.b      := CfrInt.b;
      Result.CloseB := CfrInt.CloseB;
    end if;
    return Result;
  end Include;
  
  member function IsContained(CfrPoint in integer) return boolean
  is
  begin
    if CloseA=1 then
      if CloseB=1 then
        -- [a,b]
        return a <= CfrPoint and CfrPoint <= b;
      else
        -- [a,b)
        return a <= CfrPoint and CfrPoint < b;
      end if;
    else
      -- (a, b]
      if CloseB=1 then
        return a < CfrPoint and CfrPoint <= b;
      else
      -- (a,b)
        return a < CfrPoint and CfrPoint < b;
      end if;
    end if;
  end IsContained;
  
  member function Length return integer
  is
  begin
    if CloseA=1 then
      if CloseB=1 then
        -- [a,b]
        return b - a + 1;
      else
        -- [a,b)
        return b - a;
      end if;
    else
      -- (a, b]
      if CloseB=1 then
        return b - a;
      else
      -- (a,b)
        return b - a - 1;
      end if;
    end if;
  end Length;
  
  member function Intersection(CfrInt in TInterval) return TInterval
  is
    Result TInterval := new TInterval(0, 0, 0, 0);
    IsContainedA    boolean := false;
    IsContainedB    boolean := false;
    CfrA            integer;
    CfrB            integer;
  begin
    if CfrInt.CloseA=1 then
      IsContainedA := IsContained(CfrInt.a);
      CfrA := CfrInt.a;
    else
      IsContainedA := IsContained(CfrInt.a+1);
      CfrA := CfrInt.a+1;
    end if;
    
    if CfrInt.CloseB=1 then
      IsContainedB :=  IsContained(CfrInt.b);
      CfrB := CfrInt.b;
    else
      IsContainedB := IsContained(CfrInt.b-1);
      CfrB := CfrInt.b - 1;
    end if;

    if IsContainedA then
      if IsContainedB then
        -- CfrInt totally contained => he is the intersection
        Result := CfrInt;
      else
        -- Self contains CfrInt.a only
        Result.a := CfrInt.a;
        Result.b := Self.b;
        Result.CloseA := CfrInt.CloseA;
        Result.CloseB := Self.CloseB;
      end if;
    else
      -- Self contains CfrInt.b only
      if IsContainedB then
        Result.a := Self.a;
        Result.b := CfrInt.b;
        Result.CloseA := Self.CloseA;
        Result.CloseB := CfrInt.CloseB;
      else
        -- Self is totally contained in CfrInt
        if CfrA < Self.a and Self.b < CfrB then
          Result := Self;
        else
          -- No intersection => returns empty interval
          Result.a := 0;
          Result.b := 0;
          Result.CloseA := 0;
          Result.CloseB := 0;
        end if;          
      end if;
    end if;
    
    return Result;
  end Intersection;
  
end;
/
create or replace type TIntervalTable as table of TInterval;
/
create or replace type TIntervalCollection as object
(
  IntervalTable TIntervalTable,
  map member function AsString return varchar2,
  member function Count return integer,
  member procedure Clear,
  member procedure AddOr(Self in out TIntervalCollection, TheInt in TInterval),
  member function Intersection(CfrInt in TInterval) return TIntervalCollection,
  member function Negate(Self in out TIntervalCollection, CfrInt in TInterval) return TIntervalCollection,
  constructor function TIntervalCollection return self as result
);
/
create or replace type body TIntervalCollection as
  
  constructor function TIntervalCollection return self as result
  is
  begin
    IntervalTable := new TIntervalTable(); 
    return;
  end TIntervalCollection;
    
  map member function AsString return varchar2
  as
    i pls_integer;
    Result varchar2(255); 
  begin
    for i in 1 .. IntervalTable.Count
    loop
      if i > 1 then
        Result := Result || ', ' || IntervalTable(i).AsString;
      else
        Result := IntervalTable(i).AsString;
      end if;
    end loop;
    return Result;
  end AsString;
  
  member procedure Clear
  is
  begin
    IntervalTable.Delete;
  end;
  
  member function Count return integer
  as
  begin
    return IntervalTable.Count;
  end Count;
  
  member procedure AddOr(Self in out TIntervalCollection, TheInt in TInterval)
  is
    Ctr integer;
  begin
    IntervalTable.Extend(1);
    Ctr := IntervalTable.Count;
    IntervalTable(Ctr) := TheInt;
  end AddOr;
  
  member function Intersection(CfrInt in TInterval) return TIntervalCollection
  as
    Result TIntervalCollection;
  begin
    
    return Result;
  end Intersection;
  
  member function Negate(Self in out TIntervalCollection, CfrInt in TInterval) return TIntervalCollection
  is
    IntA   TInterval := new TInterval(0,0,0,0);
    IntB   TInterval := new TInterval(0,0,0,0);
    Result TIntervalCollection := new TIntervalCollection;
  begin
    IntA.a := Cartesio.cInfiniteNegative;
    IntA.b := CfrInt.a;
    IntA.CloseA := 0;
    IntA.CloseB := Cartesio.Bitxor(CfrInt.CloseA,1);
    -- Don't add (0,0)
    if IntA.b <> Cartesio.cInfiniteNegative then
      Result.AddOr(IntA);
    end if;
    IntB.a := CfrInt.b;
    IntB.b := Cartesio.cInfinitePositive;
    IntB.CloseA := Cartesio.Bitxor(CfrInt.CloseB,1);
    IntB.CloseB := 0;
    -- Don't add -inf +inf
    if IntB.a <> Cartesio.cInfinitePositive then
      Result.AddOr(IntB);
    end if;
    return Result;
  end Negate;
  
end;
/

    


