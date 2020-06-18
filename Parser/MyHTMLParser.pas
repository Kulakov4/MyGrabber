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
  System.Generics.Collections, System.SysUtils, System.Variants;

class function TMyHTMLParser.Parse(AHTMLElementCollection
  : IHTMLElementCollection; const ATagName, AClassName: String;
  TestResult: Integer = 0): TArray<IHTMLElement>;
var
  AElementClassName: string;
  AHTMLElement: IHTMLElement;
  i: Integer;
  it: WideString;
  L: TList<IHTMLElement>;
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

      // if AElementClassName.StartsWith('pagination-light__controls') then
      // beep;

      if (AHTMLElement.tagName = ATagName) and (AElementClassName = AClassName)
      then
      begin
        it := AHTMLElement.innerText;
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
