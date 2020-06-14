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
  i: Integer;
  S: string;
  URI: TIdURI;
begin
  URI := TIdURI.Create(AURL);
  try
    // Protocol = URI.Protocol
    // Username = URI.Username
    // Password = URI.Password
    // Host = URI.Host
    // Port = URI.Port
    // Path = URI.Path
    // Query = URI.Params

    if href.StartsWith('about:blank?') then
    begin
      URI.Params := href.Replace('about:blank?', '');
    end;
    if href.StartsWith('about:/') then
    begin
       URI.Path
    end

  finally
    URI.Free;
  end;

else
begin
  i := AURL.LastDelimiter('/');
  Assert(i > 0);
  S := AURL.Substring(0, i + 1);

  Assert(href.IndexOf('about:') = 0);
  Result := href.Replace('about:', S);
end;
end;

end.
