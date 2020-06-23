unit MyHTMLParser;

interface

uses
  MSHTML;

type
  TMyHTMLParser = class(TObject)
  private
  public
    class function Parse(AHTMLElementCollection: IHTMLElementCollection;
      const ATagName, AClassName: String; TestResult: Integer = 0)
      : TArray<IHTMLElement>; static;
  end;

implementation

uses
  System.Generics.Collections, System.SysUtils, System.Variants, NounUnit;

class function TMyHTMLParser.Parse(AHTMLElementCollection
  : IHTMLElementCollection; const ATagName, AClassName: String;
  TestResult: Integer = 0): TArray<IHTMLElement>;
var
  AElementClassName: string;
  AErrorText: string;
  AHTMLElement: IHTMLElement;
  i: Integer;
  L: TList<IHTMLElement>;
  len: Integer;
begin
  Assert(AHTMLElementCollection <> nil);
  Assert(not ATagName.IsEmpty);

  L := TList<IHTMLElement>.Create;
  try
    for i := 0 to AHTMLElementCollection.length - 1 do
    begin
      AHTMLElement := AHTMLElementCollection.item(i, EmptyParam)
        as IHTMLElement;
      Assert(AHTMLElement <> nil);
      AElementClassName := AHTMLElement._className;
      AElementClassName := AElementClassName.Trim;

      if (AHTMLElement.tagName = ATagName) and (AElementClassName = AClassName)
      then
      begin
        L.Add(AHTMLElement);
      end;
    end;
    Result := L.ToArray;
  finally
    FreeAndNil(L);
  end;

  if TestResult = 0 then
    Exit;

  len := length(Result);
  if len <> TestResult then
  begin
    AErrorText := Format('Ошибка при разборе HTML. <%s class="%s">',
      [ATagName, AClassName]);

    if len = 0 then
      AErrorText := AErrorText + ' не найден'
    else
      AErrorText := AErrorText + Format(' найден %d %s',
        [len, TNoun.Get(len, 'раз', 'раза', 'раз')]);

    raise Exception.Create(AErrorText);
  end;
end;

end.
