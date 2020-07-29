unit WebLoader2;

interface

uses
  System.Classes, IdHTTP, IdSSLOpenSSL;

type
  TWebLoader2 = class(TComponent)
  private
    FIdHTTP: TIdHTTP;
    FIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    procedure InitIdHttp;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Load(const AURL: String; AResponseContent: TStream);
      overload; stdcall;
    function Load(const AURL: String): string; overload; stdcall;
  end;

implementation

uses
  IdException, System.SysUtils;

constructor TWebLoader2.Create(AOwner: TComponent);
begin
  inherited;
  FIdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  FIdSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvTLSv1;
  FIdSSLIOHandlerSocketOpenSSL.SSLOptions.Mode := sslmClient;

  FIdHTTP := TIdHTTP.Create(Self);
  FIdHTTP.HandleRedirects := true;
  FIdHTTP.IOHandler := FIdSSLIOHandlerSocketOpenSSL;
end;

procedure TWebLoader2.InitIdHttp;
begin
  FIdHTTP.HandleRedirects := true;
  FIdHTTP.ReadTimeout := 5000;
  FIdHTTP.ConnectTimeout := 5000;
  FIdHTTP.AllowCookies := true;
  FIdHTTP.Request.CacheControl := 'max-age=0';
  FIdHTTP.Request.Connection := 'keep-alive';
  FIdHTTP.Request.ContentLength := -1;
  FIdHTTP.Request.ContentRangeEnd := -1;
  FIdHTTP.Request.ContentRangeStart := -1;
  FIdHTTP.Request.ContentRangeInstanceLength := -1;
  FIdHTTP.Request.Accept :=
    'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp' +
    ',*/*;q=0.8';
  FIdHTTP.Request.AcceptEncoding := 'gzip, deflate, br';
  FIdHTTP.Request.AcceptLanguage := 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3';
  FIdHTTP.Request.BasicAuthentication := False;
  FIdHTTP.Request.UserAgent :=
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/2010010' +
    '1 Firefox/78.0';
  FIdHTTP.Request.Ranges.Units := 'bytes';
  FIdHTTP.HTTPOptions := [hoForceEncodeParams];
end;

procedure TWebLoader2.Load(const AURL: String; AResponseContent: TStream);
begin
  Assert(AURL <> '');
  FIdHTTP.Get(AURL, AResponseContent);
end;

function TWebLoader2.Load(const AURL: String): string;
begin
  Assert(AURL <> '');

  InitIdHttp;
  try
    // Загружаем в html как Unicode строку
    Result := FIdHTTP.Get(AURL);
  except
    On E: EIdException do
    begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

end.
