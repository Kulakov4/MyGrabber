unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, MSHTML, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, dxSkinsDefaultPainters, cxTextEdit, cxMemo, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  TMainForm = class(TForm)
    Button1: TButton;
    IdHTTP1: TIdHTTP;
    Button2: TButton;
    cxMemo1: TcxMemo;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure AddToMemo(AElement: IHTMLElement);
    procedure Process(IElement: IHTMLElement);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  Winapi.ActiveX;

{$R *.dfm}

var
  idoc: IHTMLDocument2;

procedure TMainForm.AddToMemo(AElement: IHTMLElement);
begin
  cxMemo1.Lines.Add(Format('tag=%s class=%s', [AElement.tagName,
    AElement._className]));
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  html: string;
  v: Variant;
begin
  // Сначала просто загружаем в html как строку
  IdHTTP1.HandleRedirects := true;
  html := IdHTTP1.Get('https://b2b.harting.com/ebusiness/ru/ru/13991');

  // Создаем вариантный массив
  v := VarArrayCreate([0, 0], VarVariant);
  v[0] := html; // присваиваем 0 элементу массива строку с html

  // Создаем интерфейс
  { Можно загружать через CreateComObject либо через coHTMLDocument.Create }
  // iDoc:=CreateComObject(Class_HTMLDOcument) as IHTMLDocument2;
  idoc := coHTMLDocument.Create as IHTMLDocument2;

  // пишем в интерфейс
  idoc.write(PSafeArray(System.TVarData(v).VArray));
  { все, теперь страницу можно обрабатывать при помощи MSHTML }
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  i: integer;
  s: string;
  idisp: IDispatch;
  IElement: IHTMLElement;
begin

  cxMemo1.Lines.Clear;
  for i := 0 to idoc.all.length - 1 do
  begin
    IElement := idoc.all.item(i, 0) as IHTMLElement;

    if not assigned(IElement) then
      Continue;

    if IElement.tagName = 'DIV' then
    begin
      if IElement._className = 'off-grid' then
      begin
        AddToMemo(IElement);
        Process(IElement);
      end;
    end;

  end;

end;

procedure TMainForm.Process(IElement: IHTMLElement);
var
  AChild: IHTMLElement;
  i: integer;
  AСhildCollection: IHTMLElementCollection;
begin
  AСhildCollection := IElement.all as IHTMLElementCollection;

  for i := 0 to AСhildCollection.length - 1 do
  begin
    AChild := AСhildCollection.item(i, 0) as IHTMLElement;
    AddToMemo(AChild);
  end;
end;

end.
