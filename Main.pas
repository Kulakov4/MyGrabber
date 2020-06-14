unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, MSHTML, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, dxSkinsDefaultPainters, cxTextEdit, cxMemo, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, Vcl.ExtCtrls,
  GridFrame, CategoryInfoDataSet, ProductListInfoDataSet, dxBarBuiltInMenu,
  System.Actions, Vcl.ActnList, cxClasses, dxBar, cxPC, PageParser,
  CategoryParser, ProductListParser;

type
  TMainForm = class(TForm)
    cxPageControl1: TcxPageControl;
    dxBarManager1: TdxBarManager;
    dxBarManager1Bar1: TdxBar;
    ActionList1: TActionList;
    actStartGrab: TAction;
    cxTabSheetCategory: TcxTabSheet;
    cxTabSheetProductList: TcxTabSheet;
    dxBarButton1: TdxBarButton;
    procedure actStartGrabExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FCategoryInfoDS: TCategoryInfoDS;
    FCategoryParser: TCategoryParser;
    FPageParser: TPageParser;
    FProductListInfoDS: TProductListInfoDS;
    FProductListParser: TProductListParser;
    FViewCategory: TfrmGrid;
    FViewProductList: TfrmGrid;
    function GetCategoryParser: TCategoryParser;
    function GetPageParser: TPageParser;
    function GetProductListParser: TProductListParser;
    procedure StartGrab;
    { Private declarations }
  protected
    property CategoryParser: TCategoryParser read GetCategoryParser;
    property PageParser: TPageParser read GetPageParser;
    property ProductListParser: TProductListParser read GetProductListParser;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  WebLoader, FireDAC.Comp.Client,
  MyHTMLLoader;

{$R *.dfm}

procedure TMainForm.actStartGrabExecute(Sender: TObject);
begin
  StartGrab;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FViewCategory := TfrmGrid.Create(Self);
  FViewCategory.Name := 'ViewCategory1';
  FViewCategory.Place(cxTabSheetCategory);

  FViewProductList := TfrmGrid.Create(Self);
  FViewProductList.Name := 'ViewProductList1';
  FViewProductList.Place(cxTabSheetProductList);

  FCategoryInfoDS := TCategoryInfoDS.Create(Self);
  FViewCategory.DSWrap := FCategoryInfoDS.W;

  FProductListInfoDS := TProductListInfoDS.Create(Self);
  FViewProductList.DSWrap := FProductListInfoDS.W;
end;

function TMainForm.GetCategoryParser: TCategoryParser;
begin
  if FCategoryParser = nil then
    FCategoryParser := TCategoryParser.Create(Self);
  Result := FCategoryParser;
end;

function TMainForm.GetPageParser: TPageParser;
begin
  if FPageParser = nil then
    FPageParser := TPageParser.Create(Self);

  Result := FPageParser;
end;

function TMainForm.GetProductListParser: TProductListParser;
begin
  if FProductListParser = nil then
    FProductListParser := TProductListParser.Create(Self);
  Result := FProductListParser;
end;

procedure TMainForm.StartGrab;
var
  AURL: string;
  AMyHTMLRec: TMyHTMLRec;
  NextPageAvailable: Boolean;
  WW: TCategoryInfoW;
begin
  AURL := 'https://b2b.harting.com/ebusiness/ru/ru/13991';

  // Загружаем страницу и формируем HTML документ
  AMyHTMLRec := TMyHTMLLoader.Load(AURL, TWebDM.Instance);

  // парсим наш HTML докумет на наличие категорйи
  CategoryParser.Parse(AMyHTMLRec, FCategoryInfoDS, 0);

  WW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
  try
    WW.FilterByParentID(0);
    WW.DataSet.First;
    while not WW.DataSet.Eof do
    begin
      // Загружаем страницу и формируем HTML документ
      AMyHTMLRec := TMyHTMLLoader.Load(WW.HREF.F.AsString, TWebDM.Instance);

      // Парсим дочерние HTML документы на наличие подкатегорий
      CategoryParser.Parse(AMyHTMLRec, FCategoryInfoDS, WW.ID.F.AsInteger);
      WW.DataSet.Next;
    end;
  finally
    FCategoryInfoDS.W.DropClone(WW.DataSet as TFDMemTable);
  end;

  WW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
  try
    WW.FilterByParentID(1);
    WW.DataSet.First;
    // while not WW.DataSet.Eof do
    // begin

    // Цикл по всем страницам
    AURL := WW.HREF.F.AsString;
    repeat
      // Загружаем страницу и формируем HTML документ
      AMyHTMLRec := TMyHTMLLoader.Load(AURL, TWebDM.Instance);

      // Парсим эту страницу на наличие списка товаров
      ProductListParser.Parse(AMyHTMLRec, FProductListInfoDS,
        WW.ID.F.AsInteger);

      // Парсим эту страницу на наличие ссылки на следующую страницу
      NextPageAvailable := PageParser.Parse(AMyHTMLRec, AURL);
    until not NextPageAvailable
    // WW.DataSet.Next;
    // end;
      finally FCategoryInfoDS.W.DropClone(WW.DataSet as TFDMemTable);
  end;

  FCategoryInfoDS.First;
  FProductListInfoDS.First;
  FViewCategory.MyApplyBestFit;
  FViewProductList.MyApplyBestFit;
end;

end.
