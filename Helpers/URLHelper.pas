unit URLHelper;

interface

type
  TURLHelper = class(TObject)
  private
  protected
  public
    class function GetAbsoluteURL(AURL: string; const href: string)
      : string; static;
    class function GetURL(const href: string): string; static;
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
  S := GetURL(href);

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

class function TURLHelper.GetURL(const href: string): string;
begin
  Result := href;

  if Result.StartsWith('about:') then
    Result := Result.Substring(6);
  if Result.StartsWith('blank') then
    Result := Result.Substring(5);
end;

end.
