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
  private
    class var FSingleInstance: TWebDM;
    { Private declarations }
  public
    destructor Destroy; override;
    class function Instance: TWebDM; static;
    function Load(const AURL: String): String; overload; stdcall;
    procedure Load(const AURL: String; AResponseContent: TStream);
      overload; stdcall;
    { Public declarations }
  end;

implementation

uses
  System.SyncObjs, IdException;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

var
  Lock: TCriticalSection;

destructor TWebDM.Destroy;
begin
  inherited;
end;

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

function TWebDM.Load(const AURL: String): String;
begin
  Assert(AURL <> '');
  IdHTTP.HandleRedirects := true;
  IdHTTP.ReadTimeout := 15000;
  IdHTTP.ConnectTimeout := 15000;
  try
    // Загружаем в html как Unicode строку
    Result := IdHTTP.Get(AURL);
  except
    On E: EIdException do
    begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

procedure TWebDM.Load(const AURL: String; AResponseContent: TStream);
begin
  Assert(AURL <> '');
  IdHTTP.HandleRedirects := true;
  IdHTTP.Get(AURL, AResponseContent);
end;

initialization

Lock := TCriticalSection.Create;

end.
