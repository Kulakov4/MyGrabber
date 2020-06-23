unit NounUnit;

interface

type
  TNoun = class(TObject)
  public
    class function Get(const Number: Integer; const One, Two, Five: string):
        String; static;
  end;

implementation

uses
  System.Math;

class function TNoun.Get(const Number: Integer; const One, Two, Five: string):
    String;
var
  n: Integer;
begin
  n := abs(Number);
  n := n mod 100;
  if (n >= 5) and (n <= 20) then
  begin
    Result := Five;
    Exit;
  end;

  n := n mod 10;

  if n = 1 then
  begin
    Result := One;
    Exit;
  end;

  if (n >= 2) and (n <= 4) then
  begin
    Result := Two;
    Exit;
  end;

  Result := Five;
end;

end.
