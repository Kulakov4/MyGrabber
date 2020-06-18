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
  GridFrame, CategoryDataSet, ProductListDataSet, dxBarBuiltInMenu,
  System.Actions, Vcl.ActnList, cxClasses, dxBar, cxPC, PageParser,
  CategoryParser, ProductListParser, cxLabel, System.Generics.Collections,
  Status, ProductsDataSet, ProductParser;

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
    Timer1: TTimer;
    actStopGrab: TAction;
    cxTabSheetLog: TcxTabSheet;
    cxMemo1: TcxMemo;
    cxTabSheetProducts: TcxTabSheet;
    procedure actStartGrabExecute(Sender: TObject);
    procedure actStopGrabExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FCategoryDS: TCategoryDS;
    FCategoryW: TCategoryW;
    FCategoryNode: TCategoryNode;
    FCategoryParser: TCategoryParser;
    FCh: Char;
    FPageParser: TPageParser;
    FProductsDS: TProductsDS;
    FProductListDS: TProductListDS;
    FProductListW: TProductListW;
    FProductListParser: TProductListParser;
    FProductParser: TProductParser;
    FProductParseStarted: Boolean;
    FStatus: TStatus;
    FViewCategory: TfrmGrid;
    FViewProducts: TfrmGrid;
    FViewProductList: TfrmGrid;
    procedure AddToLog(const S: string);
    procedure DoAfterCategoryParse(Sender: TObject);
    procedure DoAfterProductParse(Sender: TObject);
    procedure DoAfterProductListParse(Sender: TObject);
    procedure DoBeforeCategoryLoad(Sender: TObject);
    procedure DoBeforeProductLoad(Sender: TObject);
    procedure DoBeforeProductListLoad(Sender: TObject);
    procedure DoOnProductListParseComplete(Sender: TObject);
    procedure DoOnCategoryParseComplete(Sender: TObject);
    procedure DoOnParseError(Sender: TObject);
    procedure DoOnProductParseComplete(Sender: TObject);
    function GetCategoryParser: TCategoryParser;
    function GetCategoryPath(AID: Integer): string;
    function GetPageParser: TPageParser;
    function GetProductListParser: TProductListParser;
    function GetProductParser: TProductParser;
    procedure SetStatus(const Value: TStatus);
    procedure StartGrab;
    procedure StartParsing(AID: Integer);
    procedure StartProductParsing(AID: Integer);
    procedure StopGrab;
    { Private declarations }
  protected
    property CategoryParser: TCategoryParser read GetCategoryParser;
    property PageParser: TPageParser read GetPageParser;
    property ProductListParser: TProductListParser read GetProductListParser;
  public
    property ProductParser: TProductParser read GetProductParser;
    property Status: TStatus read FStatus write SetStatus;
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  WebLoader, FireDAC.Comp.Client, ParserManager, NotifyEvents, System.StrUtils;

{$R *.dfm}

procedure TMainForm.actStartGrabExecute(Sender: TObject);
begin
  StartGrab;
end;

procedure TMainForm.actStopGrabExecute(Sender: TObject);
begin
  StopGrab;
end;

procedure TMainForm.AddToLog(const S: string);
begin
  cxMemo1.Lines.Add(S);
end;

procedure TMainForm.DoAfterCategoryParse(Sender: TObject);
var
  ANotifyObj: TNotifyObj;
begin
  FCategoryDS.W.AppendFrom(CategoryParser.W);
  FViewCategory.MyApplyBestFit;

  ANotifyObj := Sender as TNotifyObj;

  if FCategoryW.HREF.Locate(ANotifyObj.URL, []) then
  begin
    // Если результат парсинга успешен
    if CategoryParser.W.RecordCount > 0 then
    begin
      FCategoryW.TryEdit;
      FCategoryW.Status.F.AsInteger := 1;
      FCategoryW.TryPost;
    end;
  end;
end;

procedure TMainForm.DoAfterProductParse(Sender: TObject);
var
  ANotifyObj: TNotifyObj;
begin
  FProductsDS.W.AppendFrom(ProductParser.W);
  FViewProducts.MyApplyBestFit;

  ANotifyObj := Sender as TNotifyObj;

  if FProductListW.HREF.Locate(ANotifyObj.URL, []) then
  begin
    // Если результат парсинга успешен
    if ProductParser.W.RecordCount > 0 then
    begin
      FProductListW.TryEdit;
      FProductListW.Status.F.AsInteger := 1;
      FProductListW.TryPost;
    end;
  end;

end;

procedure TMainForm.DoAfterProductListParse(Sender: TObject);
var
  ANotifyObj: TNotifyObj;
begin
  FProductListDS.W.AppendFrom(ProductListParser.W);
  FViewProductList.MyApplyBestFit;

  ANotifyObj := Sender as TNotifyObj;

  if FCategoryW.HREF.Locate(ANotifyObj.URL, []) then
  begin
    // Если результат парсинга списка товаров успешен
    if ProductListParser.W.RecordCount > 0 then
    begin
      FCategoryW.TryEdit;
      FCategoryW.Status.F.AsInteger := 2;
      FCategoryW.TryPost;
    end;
  end;
  {
    // Тут уже можно запустить парсинг по товарам
    if (FProductListW.DataSet.RecordCount > 0) and (not FProductParseStarted)
    then
    StartProductParsing(FProductListW.ID.F.AsInteger);
  }
end;

procedure TMainForm.DoBeforeCategoryLoad(Sender: TObject);
begin
  AddToLog(Format('%s - %s %s', [GetCategoryPath(FCategoryNode.ID),
    'поиск подкатегорий', FCh]));
end;

procedure TMainForm.DoBeforeProductLoad(Sender: TObject);
begin

end;

procedure TMainForm.DoBeforeProductListLoad(Sender: TObject);
begin
  AddToLog(Format('%s - %s %s', [GetCategoryPath(FCategoryNode.ID),
    'поиск товаров', FCh]));
end;

procedure TMainForm.DoOnProductListParseComplete(Sender: TObject);
var
  AParentID: Integer;
  AID: Integer;
begin
  AID := 0;
  FCategoryW.DataSet.Filtered := False;

  // Переходим на ту категорию, содержимое которой парсили
  FCategoryW.ID.Locate(FCategoryNode.ID, [], True);

  // Если для этой категории не были найдены товары
  if FCategoryW.Status.F.AsInteger = 0 then
  begin
    // добавить эту категорию в список категорий с ошибками!
    FCategoryW.TryEdit;
    FCategoryW.Status.F.AsInteger := 100;
    FCategoryW.TryPost;
  end;

  if (FProductListW.DataSet.RecordCount > 0) then
    StartProductParsing(FProductListW.ID.F.AsInteger);

  Exit;

  AParentID := FCategoryNode.ParentID;

  FCategoryW.FilterByParentIDAndNotDone(AParentID);
  try
    // Если на этом уровне не все категории ещё обработаны
    if FCategoryW.DataSet.RecordCount > 0 then
      AID := FCategoryW.ID.F.AsInteger;
  finally
    FCategoryW.DataSet.Filtered := False;
  end;

  // Возвращаемся по дереву категорий к дочерним
  while (AID = 0) and (AParentID > 0) do
  begin
    // Переходим на дочернюю категорию
    FCategoryW.ID.Locate(AParentID, [], True);
    // Дочерняя должна быть успешно обработана
    Assert(FCategoryW.Status.F.AsInteger > 0);

    AParentID := FCategoryW.ParentID.F.AsInteger;

    // У дочерней нет дочерней
    if AParentID = 0 then
      break;

    // Ищем, есть ли на этом уровне не обработанные категории
    FCategoryW.FilterByParentIDAndNotDone(AParentID);
    try
      // Если на этом уровне не все категории ещё обработаны
      if FCategoryW.DataSet.RecordCount > 0 then
        AID := FCategoryW.ID.F.AsInteger;
    finally
      FCategoryW.DataSet.Filtered := False;
    end;
    if AID > 0 then
      break;
  end;

  // Если нашли категрию которую ещё не парсили
  if AID > 0 then
    StartParsing(AID)
  else
  begin
    Status := Stoped;
    ShowMessage('Парсинг окончен');
  end;
end;

procedure TMainForm.DoOnCategoryParseComplete(Sender: TObject);
var
  PM: TParserManager;
begin
  // Переходим на ту категорию, содержимое которой парсили
  FCategoryW.ID.Locate(FCategoryNode.ID, [], True);

  // Если для этой категории не были найдены подкатегории
  if FCategoryW.Status.F.AsInteger = 0 then
  begin
    // Пробуем поискать список товаров в этой категории
    PM := TParserManager.Create(Self, FCategoryW.HREF.F.AsString,
      ProductListParser, PageParser, FCategoryW.ID.F.AsInteger);

    TNotifyEventWrap.Create(PM.OnError, DoOnParseError);
    TNotifyEventWrap.Create(PM.BeforeLoad, DoBeforeProductListLoad);
    TNotifyEventWrap.Create(PM.AfterParse, DoAfterProductListParse);
    TNotifyEventWrap.Create(PM.OnParseComplete, DoOnProductListParseComplete);
  end
  else
  begin
    // Ищем дочернюю категорию
    FCategoryW.ParentID.Locate(FCategoryNode.ID, [], True);
    // Начинаем парсинг этой дочерней категории
    StartParsing(FCategoryW.ID.F.AsInteger);
  end;
end;

procedure TMainForm.DoOnParseError(Sender: TObject);
var
  AErrorNotify: TErrorNotify;
begin
  AErrorNotify := Sender as TErrorNotify;
  AddToLog(Format('%s %s', [AErrorNotify.URL, AErrorNotify.ErrorMessage]));
end;

procedure TMainForm.DoOnProductParseComplete(Sender: TObject);
begin
  // Если ещё есть необработанные записи о товарах
  if (FProductListW.DataSet.RecordCount > 0) then
    StartProductParsing(FProductListW.ID.F.AsInteger)
  else
    ShowMessage('Обработка всех товаров закончена');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FViewCategory := TfrmGrid.Create(Self);
  FViewCategory.Name := 'ViewCategory1';
  FViewCategory.Place(cxTabSheetCategory);

  FViewProductList := TfrmGrid.Create(Self);
  FViewProductList.Name := 'ViewProductList1';
  FViewProductList.Place(cxTabSheetProductList);

  FViewProducts := TfrmGrid.Create(Self);
  FViewProducts.Name := 'ViewProducts';
  FViewProducts.Place(cxTabSheetProducts);

  FCategoryDS := TCategoryDS.Create(Self);
  FCategoryW := TCategoryW.Create(FCategoryDS.W.AddClone(''));
  FViewCategory.DSWrap := FCategoryDS.W;

  FProductListDS := TProductListDS.Create(Self);
  FProductListW := TProductListW.Create(FProductListDS.W.AddClone(''));
  FProductListW.FilterByNotDone;
  FViewProductList.DSWrap := FProductListDS.W;

  FProductsDS := TProductsDS.Create(Self);
  FViewProducts.DSWrap := FProductsDS.W;

  FCategoryNode := TCategoryNode.Create;

  FCh := '-';
  Status := Stoped;
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
    FCategoryW.LocateByPK(ID, True);
    Result := FCategoryW.Caption.F.AsString + IfThen(Result.IsEmpty, '',
      '\') + Result;
    ID := FCategoryW.ParentID.F.AsInteger;
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

function TMainForm.GetProductParser: TProductParser;
begin
  if FProductParser = nil then
    FProductParser := TProductParser.Create(Self);

  Result := FProductParser;
end;

procedure TMainForm.SetStatus(const Value: TStatus);
begin
  FStatus := Value;
  if FStatus = Stoped then
  begin
    Timer1.Enabled := False;
    dxBarButton1.Action := actStartGrab;

    actStopGrab.Caption := 'Остановить';
    actStopGrab.Enabled := True;
  end;

  if FStatus = Parsing then
  begin
    dxBarButton1.Action := actStopGrab;
    Timer1.Enabled := True;
  end;

  if FStatus = Stoping then
  begin
    actStopGrab.Caption := 'Останавливаюсь';
    actStopGrab.Enabled := False;
    dxBarButton1.Action := actStopGrab;
    Timer1.Enabled := False;
  end;
end;

procedure TMainForm.StartGrab;
begin
  Status := Parsing;
  FCategoryDS.W.TryAppend;
  FCategoryDS.W.Caption.F.AsString := 'Промышленные соединители Han®';
  FCategoryDS.W.HREF.F.AsString :=
    'https://b2b.harting.com/ebusiness/ru/ru/13991';
  FCategoryDS.W.TryPost;
  FViewCategory.MyApplyBestFit;

  StartParsing(FCategoryDS.W.ID.F.AsInteger);
end;

procedure TMainForm.StartParsing(AID: Integer);
var
  PM: TParserManager;
begin
  Assert(AID > 0);
  // Ищем запись о этой категории
  FCategoryW.DataSet.Filtered := False;
  FCategoryW.ID.Locate(AID, [], True);
  // Она должна быть ещё не обработана
  Assert(FCategoryW.Status.F.AsInteger = 0);

  FCategoryNode.ID := FCategoryW.ID.F.AsInteger;
  FCategoryNode.ParentID := FCategoryW.ParentID.F.AsInteger;

  PM := TParserManager.Create(Self, FCategoryW.HREF.F.AsString, CategoryParser,
    nil, FCategoryW.ID.F.AsInteger);

  TNotifyEventWrap.Create(PM.OnError, DoOnParseError);
  TNotifyEventWrap.Create(PM.BeforeLoad, DoBeforeCategoryLoad);
  TNotifyEventWrap.Create(PM.AfterParse, DoAfterCategoryParse);
  TNotifyEventWrap.Create(PM.OnParseComplete, DoOnCategoryParseComplete);
end;

procedure TMainForm.StartProductParsing(AID: Integer);
var
  PM: TParserManager;
begin
  Assert(AID > 0);
  // Ищем запись о этом товаре
  FProductListW.ID.Locate(AID, [], True);
  // Она должна быть ещё не обработана
  Assert(FProductListW.Status.F.AsInteger = 0);

  PM := TParserManager.Create(Self, FProductListW.HREF.F.AsString,
    ProductParser, nil, FProductListW.ID.F.AsInteger);

  AddToLog(Format('%s - %s',
    [GetCategoryPath(FProductListW.ParentID.F.AsInteger) + '\' +
    FProductListW.Caption.F.AsString, 'получаем характеристики товара']));

  TNotifyEventWrap.Create(PM.OnError, DoOnParseError);
  TNotifyEventWrap.Create(PM.BeforeLoad, DoBeforeProductLoad);
  TNotifyEventWrap.Create(PM.AfterParse, DoAfterProductParse);
  TNotifyEventWrap.Create(PM.OnParseComplete, DoOnProductParseComplete);
end;

procedure TMainForm.StopGrab;
begin
  Status := Stoping;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
{
  var
  c: Char;
  S: string;
}
begin
  {
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
  }
end;

end.
