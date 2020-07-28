unit HRTimer;

interface

uses Windows;

type
  THRTimer = class(TObject)
  private
    FClockRate: TLargeInteger;
    FExists: Boolean;
    FStartTime: TLargeInteger;
  public
    constructor Create(AStartTimer: Boolean);
    function ReadTimer: Double;
    function StartTimer: Boolean;
    property Exists: Boolean read FExists;
  end;

implementation

constructor THRTimer.Create(AStartTimer: Boolean);
var
  QW: TLargeInteger;
begin
  inherited Create;
  FExists := QueryPerformanceFrequency(QW);
  FClockRate := QW;
  if AStartTimer then
    StartTimer;
end;

function THRTimer.ReadTimer: Double;
var
  ET: TLargeInteger;
begin
  QueryPerformanceCounter(ET);
  Result := 1000.0 * (ET - FStartTime) / FClockRate;
end;

function THRTimer.StartTimer: Boolean;
var
  QW: TLargeInteger;
begin
  Result := QueryPerformanceCounter(QW);
  FStartTime := QW;
end;

end.
