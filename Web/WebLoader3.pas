unit WebLoader3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw,
  WebLoaderInterface, System.SyncObjs, MSHTML;

type
  TWebLoaderForm = class(TForm)
    WebBrowser: TWebBrowser;
  private
    class var FSingleInstance: TWebLoaderForm;
    { Private declarations }
  public
    class function Instance: TWebLoaderForm; static;
    function Load(const AURL: WideString): IHTMLDocument2;
    { Public declarations }
  end;

implementation

{$R *.dfm}

var
  Lock: TCriticalSection;

class function TWebLoaderForm.Instance: TWebLoaderForm;
begin
  Lock.Acquire;
  try
    if not Assigned(FSingleInstance) then
      FSingleInstance := TWebLoaderForm.Create(nil);

    Result := FSingleInstance;
  finally
    Lock.Release;
  end;

end;

function TWebLoaderForm.Load(const AURL: WideString): IHTMLDocument2;
begin
  WebBrowser.Navigate(AURL);
  // Ждём, пока страница загрузится
  while WebBrowser.ReadyState < READYSTATE_LOADED do
  begin
    Application.ProcessMessages;
  end;

  Result := WebBrowser.Document as IHTMLDocument2
end;

initialization

Lock := TCriticalSection.Create;

end.
