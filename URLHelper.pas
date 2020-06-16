unit URLHelper;

interface

type
  TURLHelper = class(TObject)
  protected
  public
    class function GetAbsoluteURL(AURL: string; const href: string)
      : string; static;
  end;

implementation

uses
  System.SysUtils, IdURI;

class function TURLHelper.GetAbsoluteURL(AURL: string;
  const href: string): string;
var
  S: string;
  URI: TIdURI;
  URI2: TIdURI;
begin
  S := href;

  if S.StartsWith('about:') then
    S := S.Substring(6);
  if S.StartsWith('blank') then
    S := S.Substring(5);

  URI := TIdURI.Create(AURL);
  URI2 := TIdURI.Create(S);
  try
    if not URI2.Path.IsEmpty then
      URI.Path := URI2.Path;

    if not URI2.Document.IsEmpty then
      URI.Document := URI2.Document;

    if not URI2.Params.IsEmpty then
      URI.Params := URI2.Params;

    Result := URI.URI;
  finally
    FreeAndNil(URI);
    FreeAndNil(URI2);
  end;
end;

end.
