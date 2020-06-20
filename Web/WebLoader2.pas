unit WebLoader2;

interface

uses
  System.Classes, IdHTTP, IdSSLOpenSSL;

type
  TWebLoader2 = class(TComponent)
  private
    FIdHTTP: TIdHTTP;
    FIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Load(const AURL: String; AResponseContent: TStream); overload;
        stdcall;
  end;

implementation

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

procedure TWebLoader2.Load(const AURL: String; AResponseContent: TStream);
begin
  Assert(AURL <> '');
  FIdHTTP.Get(AURL, AResponseContent);
end;

end.
