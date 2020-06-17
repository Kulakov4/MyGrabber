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
  CategoryParser, ProductListParser, cxLabel, System.Generics.Collections;

type
  TCategoryNode = class(TObject)
  private
    FID: Integer;
    FParentID: Integer;
  protected
    property ID: Integer read FID write FID;
    property ParentID: Integer read FParentID write FParentID;
  end;

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
    FCategoryInfoDS: TCategoryInfoDS;
    FCategoryInfoW: TCategoryInfoW;
    FCategoryNode: TCategoryNode;
    FCategoryParser: TCategoryParser;
    FCh: Char;
    FPageParser: TPageParser;
    FProductListInfoDS: TProductListInfoDS;
    FProductListParser: TProductListParser;
    FViewCategory: TfrmGrid;
    FViewProductList: TfrmGrid;
    procedure AddToLog(const S: string);
    procedure DoAfterCategoryParse(Sender: TObject);
    procedure DoAfterProductListParse(Sender: TObject);
    procedure DoBeforeCategoryLoad(Sender: TObject);
    procedure DoBeforeProductListLoad(Sender: TObject);
    procedure DoOnProductListParseComplete(Sender: TObject);
    procedure DoOnCategoryParseComplete(Sender: TObject);
    function GetCategoryParser: TCategoryParser;
    function GetCategoryPath(AID: Integer): string;
    function GetPageParser: TPageParser;
    function GetProductListParser: TProductListParser;
    procedure StartGrab;
    procedure StartParsing(AID: Integer);
    { Private declarations }
  protected
    property CategoryParser: TCategoryParser read GetCategoryParser;
    property PageParser: TPageParser read GetPageParser;
    property ProductListParser: TProductListParser read GetProductListParser;
  public
    property CategoryInfoW: TCategoryInfoW read FCategoryInfoW;
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  WebLoader, FireDAC.Comp.Client,
  MyHTMLLoader, ParserManager, NotifyEvents, System.StrUtils;

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
var
  ANotifyObj: TNotifyObj;
begin
  FCategoryInfoDS.W.AppendFrom(CategoryParser.W);
  FViewCategory.MyApplyBestFit;

  ANotifyObj := Sender as TNotifyObj;

  if FCategoryInfoW.HREF.Locate(ANotifyObj.URL, []) then
  begin
    // Если результат парсинга успешен
    if CategoryParser.W.RecordCount > 0 then
    begin
      FCategoryInfoW.TryEdit;
      FCategoryInfoW.Done.F.AsInteger := 1;
      FCategoryInfoW.TryPost;
    end;
  end;
end;

procedure TMainForm.DoAfterProductListParse(Sender: TObject);
var
  ANotifyObj: TNotifyObj;
begin
  FProductListInfoDS.W.AppendFrom(ProductListParser.W);
  FViewProductList.MyApplyBestFit;

  ANotifyObj := Sender as TNotifyObj;

  if FCategoryInfoW.HREF.Locate(ANotifyObj.URL, []) then
  begin
    // Если результат парсинга списка товаров успешен
    if ProductListParser.W.RecordCount > 0 then
    begin
      FCategoryInfoW.TryEdit;
      FCategoryInfoW.Done.F.AsInteger := 2;
      FCategoryInfoW.TryPost;
    end;
  end;

end;

procedure TMainForm.DoBeforeCategoryLoad(Sender: TObject);
begin
  AddToLog(Format('%s - %s %s', [GetCategoryPath(FCategoryNode.ID),
    'поиск подкаталогов', FCh]));
end;

procedure TMainForm.DoBeforeProductListLoad(Sender: TObject);
begin
  AddToLog(Format('%s - %s %s', [GetCategoryPath(FCategoryNode.ID),
    'поиск товаров', FCh]));
end;

procedure TMainForm.DoOnProductListParseComplete(Sender: TObject);
var
  AParentID: Integer;
begin
  // Переходим на ту категорию, содержимое которой парсили
  FCategoryInfoW.ID.Locate(FCategoryNode.ID, [], True);

  // Если для этой категории не были найдены товары
  if FCategoryInfoW.Done.F.AsInteger = 0 then
  begin
    // добавить эту категорию в список категорий с ошибками!
    FCategoryInfoW.TryEdit;
    FCategoryInfoW.Done.F.AsInteger := 100;
    FCategoryInfoW.TryPost;
  end;

  AParentID := FCategoryNode.ParentID;
  // Возвращаемся по дереву категорий к дочерним
  while AParentID > 0 do
  begin
    // Переходим на дочернюю категорию
    FCategoryInfoW.ID.Locate(AParentID, [], True);
    // Дочерняя должна быть успешно обработана
    Assert(FCategoryInfoW.Done.F.AsInteger > 0);

    AParentID := FCategoryInfoW.ParentID.F.AsInteger;

    // У дочерней нет дочерней
    if AParentID = 0 then
      break;

    // Ищем, есть ли на этом уровне не обработанные категории
    FCategoryInfoW.FilterByParentIDAndNotDone(AParentID);

    // Если на этом уровне не все категории ещё обработаны
    if FCategoryInfoW.DataSet.RecordCount > 0 then
    begin
      StartParsing(FCategoryInfoW.ID.F.AsInteger);
      break;
    end;
  end;
end;

procedure TMainForm.DoOnCategoryParseComplete(Sender: TObject);
var
  PM: TParserManager;
begin
  // Переходим на ту категорию, содержимое которой парсили
  FCategoryInfoW.ID.Locate(FCategoryNode.ID, [], True);

  // Если для этой категории не были найдены подкатегории
  if FCategoryInfoW.Done.F.AsInteger = 0 then
  begin
    // Пробуем поискать список товаров в этой категории
    PM := TParserManager.Create(Self, FCategoryInfoW.HREF.F.AsString,
      ProductListParser, PageParser, FCategoryInfoW.ID.F.AsInteger);

    TNotifyEventWrap.Create(PM.BeforeLoad, DoBeforeProductListLoad);
    TNotifyEventWrap.Create(PM.AfterParse, DoAfterProductListParse);
    TNotifyEventWrap.Create(PM.OnParseComplete, DoOnProductListParseComplete);
  end
  else
  begin
    // Ищем дочернюю категорию
    FCategoryInfoW.ParentID.Locate(FCategoryNode.ID, [], True);
    // Начинаем парсинг этой дочерней категории
    StartParsing(FCategoryInfoW.ID.F.AsInteger);
  end;
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

  FCategoryInfoW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
  FCategoryNode := TCategoryNode.Create;
  FCh := '-';
end;

function TMainForm.GetCategoryParser: TCategoryParser;
begin
  if FCategoryParser = nil then
    FCategoryParser := TCategoryParser.Create(Self);
  Result := FCategoryParser;
end;

function TMainForm.GetCategoryPath(AID: Integer): string;
Var
  ID: Integer;
begin
  Result := '';
  ID := AID;
  repeat
    FCategoryInfoW.LocateByPK(ID, True);
    Result := FCategoryInfoW.Caption.F.AsString + IfThen(Result.IsEmpty, '',
      '\') + Result;
    ID := FCategoryInfoW.ParentID.F.AsInteger;
  until ID = 0;
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
begin
  FCategoryInfoDS.W.TryAppend;
  FCategoryInfoDS.W.Caption.F.AsString := 'Промышленные соединители Han®';
  FCategoryInfoDS.W.HREF.F.AsString :=
    'https://b2b.harting.com/ebusiness/ru/ru/13991';
  FCategoryInfoDS.W.TryPost;
  FViewCategory.MyApplyBestFit;

  StartParsing(FCategoryInfoDS.W.ID.F.AsInteger);
end;

procedure TMainForm.StartParsing(AID: Integer);
var
  PM: TParserManager;
begin
  Assert(AID > 0);
  // Ищем запись о этой категории
  FCategoryInfoW.DataSet.Filtered := False;
  FCategoryInfoW.ID.Locate(AID, [], True);
  // Она должна быть ещё не обработана
  Assert(FCategoryInfoW.Done.F.AsInteger = 0);

  FCategoryNode.ID := FCategoryInfoW.ID.F.AsInteger;
  FCategoryNode.ParentID := FCategoryInfoW.ParentID.F.AsInteger;

  PM := TParserManager.Create(Self, FCategoryInfoW.HREF.F.AsString,
    CategoryParser, nil, FCategoryInfoW.ID.F.AsInteger);
  TNotifyEventWrap.Create(PM.BeforeLoad, DoBeforeCategoryLoad);
  TNotifyEventWrap.Create(PM.AfterParse, DoAfterCategoryParse);
  TNotifyEventWrap.Create(PM.OnParseComplete, DoOnCategoryParseComplete);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
  c: Char;
  S: string;
begin
  if cxLabel1.Caption = '' then
    Exit;

  FCh := '-';
  S := cxLabel1.Caption;

  c := S.Chars[S.Length - 1];
  case c of
    '-':
      FCh := '\';
    '\':
      FCh := '|';
    '|':
      FCh := '/';
    '/':
      FCh := '-';
  else
    S := S + '  ';
  end;
  S := S.Substring(0, S.Length - 1) + FCh;
  cxLabel1.Caption := S;
end;

end.
