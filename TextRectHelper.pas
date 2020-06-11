unit TextRectHelper;

interface

uses
  Vcl.Graphics, System.Types;

type
  TTextRect = class(TObject)
  public
    class function Calc(ACanvas: TCanvas; const S: String; AMinWidth: Integer = 0):
        TRect; overload; static;
    class function Calc(ACanvas: TCanvas; const S: String; ARect: TRect): TRect;
        overload; static;
  end;

implementation

uses
  System.SysUtils, System.Math, Winapi.Windows;

class function TTextRect.Calc(ACanvas: TCanvas; const S: String; AMinWidth:
    Integer = 0): TRect;
var
  ATextHeight: Integer;
  AMaxWidth: Integer;
  m: TArray<String>;
  ASubStr: string;
  AWord: string;
  AWordWidth: Integer;
begin

  // 1) Ищем слово с максимальной шириной
  AMaxWidth := AMinWidth;
  m := S.Split([#13, #10, ' ', #9]);
  for ASubStr in m do
  begin
    AWord := ASubStr.Trim;
    if AWord.IsEmpty then
      Continue;

    AWordWidth := ACanvas.TextWidth(AWord);
    AMaxWidth := IfThen(AWordWidth > AMaxWidth, AWordWidth, AMaxWidth);
  end;

  ATextHeight := ACanvas.TextHeight(S);

  // 2) Вычисляем какой должен быть прямоугольник, чтобы в него поместился наш текст
  Result := Calc(ACanvas, S, Rect(0, 0, AMaxWidth, ATextHeight));
end;

class function TTextRect.Calc(ACanvas: TCanvas; const S: String; ARect: TRect):
    TRect;
var
  Flags: Integer;
begin
  // Здест произойдёт копирование?
  Result := ARect;

  Flags := DT_CALCRECT or DT_WORDBREAK;

  DrawTextW(ACanvas.Handle, S, S.Length, Result, Flags);
end;

end.
