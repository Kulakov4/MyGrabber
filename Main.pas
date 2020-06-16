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
    procedure DoAfterCategoryParse(Sender: TObject);
    procedure DoAfterProductListParse(Sender: TObject);
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

  PM := TParserManager.Create(Self, AURLs, ProductListParser, PageParser, AIDArr);
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
    // �������� ������ URL
    AURLs := WW.HREF.AllValues(',').Split([',']);
    AIDArr := WW.ID.AsIntArray();
  finally
    FCategoryInfoDS.W.DropClone(WW.DataSet as TFDMemTable);
  end;

  PM := TParserManager.Create(Self, AURLs, CategoryParser, nil, AIDArr);
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
{
  var
  AURL: string;
  AMyHTMLRec: TMyHTMLRec;
  NextPageAvailable: Boolean;
  WW: TCategoryInfoW;
}
var
  PM: TParserManager;
begin
  PM := TParserManager.Create(Self,
    ['https://b2b.harting.com/ebusiness/ru/ru/13991'], CategoryParser,
    nil, [0]);
  TNotifyEventWrap.Create(PM.AfterParse, DoAfterCategoryParse);
  TNotifyEventWrap.Create(PM.OnParseComplete, DoOnRootCategoryParseComplete);

  {
    AURL := 'https://b2b.harting.com/ebusiness/ru/ru/13991';

    // ��������� �������� � ��������� HTML ��������
    AMyHTMLRec := TMyHTMLLoader.Load(AURL, TWebDM.Instance);

    // ������ ��� HTML ������� �� ������� ���������
    CategoryParser.Parse(AMyHTMLRec, FCategoryInfoDS, 0);

    WW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
    try
    WW.FilterByParentID(0);
    WW.DataSet.First;
    while not WW.DataSet.Eof do
    begin
    // ��������� �������� � ��������� HTML ��������
    AMyHTMLRec := TMyHTMLLoader.Load(WW.HREF.F.AsString, TWebDM.Instance);

    // ������ �������� HTML ��������� �� ������� ������������
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

    // ���� �� ���� ���������
    AURL := WW.HREF.F.AsString;
    repeat
    // ��������� �������� � ��������� HTML ��������
    AMyHTMLRec := TMyHTMLLoader.Load(AURL, TWebDM.Instance);

    // ������ ��� �������� �� ������� ������ �������
    ProductListParser.Parse(AMyHTMLRec, FProductListInfoDS,
    WW.ID.F.AsInteger);

    // ������ ��� �������� �� ������� ������ �� ��������� ��������
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
  }
end;

end.
