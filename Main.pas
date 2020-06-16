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
  CategoryParser, ProductListParser, cxLabel;

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
    cxLabel1: TcxLabel;
    Timer1: TTimer;
    procedure actStartGrabExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FCaptionIndex: Integer;
    FCaptions: TArray<String>;
    FCategoryInfoDS: TCategoryInfoDS;
    FCategoryParser: TCategoryParser;
    FPageParser: TPageParser;
    FPath: string;
    FProductListInfoDS: TProductListInfoDS;
    FProductListParser: TProductListParser;
    FViewCategory: TfrmGrid;
    FViewProductList: TfrmGrid;
    procedure AddToLog(const S: string);
    procedure DoAfterCategoryParse(Sender: TObject);
    procedure DoAfterProductListParse(Sender: TObject);
    procedure DoBeforeCategoryLoad(Sender: TObject);
    procedure DoOnChildCategoryParseComplete(Sender: TObject);
    procedure DoOnProductListParseComplete(Sender: TObject);
    procedure DoOnRootCategoryParseComplete(Sender: TObject);
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
  MyHTMLLoader, ParserManager, NotifyEvents, System.Generics.Collections;

{$R *.dfm}

procedure TMainForm.actStartGrabExecute(Sender: TObject);
begin
  StartGrab;
end;

procedure TMainForm.AddToLog(const S: string);
begin
  cxLabel1.Caption := S;
end;

procedure TMainForm.DoAfterCategoryParse(Sender: TObject);
begin
  FCategoryInfoDS.W.AppendFrom(CategoryParser.W);
  FViewCategory.MyApplyBestFit;
end;

procedure TMainForm.DoAfterProductListParse(Sender: TObject);
begin
  FProductListInfoDS.W.AppendFrom(ProductListParser.W);
  FViewProductList.MyApplyBestFit;
end;

procedure TMainForm.DoBeforeCategoryLoad(Sender: TObject);
begin
  AddToLog(Format('%s\%s - поиск подкатегорий',
    [FPath, FCaptions[FCaptionIndex]]));
  Inc(FCaptionIndex);
end;

procedure TMainForm.DoOnChildCategoryParseComplete(Sender: TObject);
var
  AIDArr: TArray<Integer>;
  AURLs: TArray<String>;
  PM: TParserManager;
  WW: TCategoryInfoW;
begin
  WW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
  try
    WW.FilterByParentID(1);
    AURLs := WW.HREF.AllValues(',').Split([',']);
    AIDArr := WW.ID.AsIntArray();

  finally
    FCategoryInfoDS.W.DropClone(WW.DataSet as TFDMemTable);
  end;

  PM := TParserManager.Create(Self, AURLs, ProductListParser,
    PageParser, AIDArr);
  TNotifyEventWrap.Create(PM.AfterParse, DoAfterProductListParse);
  TNotifyEventWrap.Create(PM.OnParseComplete, DoOnProductListParseComplete);
end;

procedure TMainForm.DoOnProductListParseComplete(Sender: TObject);
begin
  // TODO -cMM: TMainForm.DoOnProductListParseComplete default body inserted
end;

procedure TMainForm.DoOnRootCategoryParseComplete(Sender: TObject);
var
  AIDArr: TArray<Integer>;
  AURLs: TArray<String>;
  PM: TParserManager;
  WW: TCategoryInfoW;
begin
  WW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
  try
    WW.FilterByParentID(0);
    // Получаем массив URL
    AURLs := WW.HREF.AllValues(',').Split([',']);
    AIDArr := WW.ID.AsIntArray();
    FCaptions := WW.Caption.AllValues(',').Split([',']);
  finally
    FCategoryInfoDS.W.DropClone(WW.DataSet as TFDMemTable);
  end;

  FCaptionIndex := 0;
  PM := TParserManager.Create(Self, AURLs, CategoryParser, nil, AIDArr);
  TNotifyEventWrap.Create(PM.BeforeLoad, DoBeforeCategoryLoad);
  TNotifyEventWrap.Create(PM.AfterParse, DoAfterCategoryParse);
  TNotifyEventWrap.Create(PM.OnParseComplete, DoOnChildCategoryParseComplete);
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
  PM: TParserManager;
begin
  FPath := 'Промышленные соединители Han®';
  AddToLog(FPath + ' - поиск подкатегорий');

  PM := TParserManager.Create(Self,
    ['https://b2b.harting.com/ebusiness/ru/ru/13991'], CategoryParser,
    nil, [0]);
  TNotifyEventWrap.Create(PM.AfterParse, DoAfterCategoryParse);
  TNotifyEventWrap.Create(PM.OnParseComplete, DoOnRootCategoryParseComplete);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
  c: Char;
  ch: Char;
  S: string;
begin
  if cxLabel1.Caption = '' then
    Exit;

  ch := '-';
  S := cxLabel1.Caption;

  c := S.Chars[S.Length - 1];
  case c of
  '-': ch := '\';
  '\': ch := '|';
  '|': ch := '/';
  '/': ch := '-';
  else
    S := S + '  ';
  end;
  S := S.Substring(0, S.Length - 1) + ch;
  cxLabel1.Caption := S;
end;

end.
