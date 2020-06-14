unit WebLoader;

interface

uses
  System.SysUtils, System.Classes, WebLoaderInterface, IdTCPConnection,
  IdTCPClient, IdHTTP, IdBaseComponent, IdComponent, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  TWebDM = class(TDataModule, IWebLoader)
    IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    IdHTTP: TIdHTTP;
  strict private
    function Load(const AURL: WideString): WideString; stdcall;
  private
  class var
    FSingleInstance: TWebDM;
    { Private declarations }
  public
    class function Instance: TWebDM; static;
    { Public declarations }
  end;

implementation

uses
  System.SyncObjs;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

var
  Lock: TCriticalSection;

class function TWebDM.Instance: TWebDM;
begin
  Lock.Acquire;
  try
    if not Assigned(FSingleInstance) then
      FSingleInstance := TWebDM.Create(nil);

    Result := FSingleInstance;
  finally
    Lock.Release;
  end;

end;

function TWebDM.Load(const AURL: WideString): WideString;
begin
  Assert(AURL <> '');
  IdHTTP.HandleRedirects := true;
  // ��������� � html ��� Unicode ������
  Result := IdHTTP.Get(AURL);
end;

initialization

Lock := TCriticalSection.Create;

end.
