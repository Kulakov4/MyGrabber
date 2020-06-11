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
  System.SysUtils, System.Generics.Collections;

class function TMyHTMLParser.Parse(AHTMLElementCollection
  : IHTMLElementCollection; const ATagName, AClassName: String;
  TestResult: Integer = 0): TArray<IHTMLElement>;
var
  AHTMLElement: IHTMLElement;
  i: Integer;
  L: TList<IHTMLElement>;
begin
  Assert(AHTMLElementCollection <> nil);
  Assert(not ATagName.IsEmpty);

  L := TList<IHTMLElement>.Create;
  try
    for i := 0 to AHTMLElementCollection.length - 1 do
    begin
      AHTMLElement := AHTMLElementCollection.item(i, 0) as IHTMLElement;
      Assert(AHTMLElement <> nil);

      if (AHTMLElement.tagName = ATagName) and
        (AHTMLElement._className = AClassName) then
      begin
        L.Add(AHTMLElement);
      end;
    end;
    Result := L.ToArray;
  finally
    FreeAndNil(L);
  end;

  if TestResult > 0 then
    Assert(length(Result) = TestResult);
end;

end.
