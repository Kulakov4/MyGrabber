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
  Status, ProductsDataSet, ProductParser, ParserManager, DownloadManagerEx;

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
    FDownloadManagerEx: TDownloadManagerEx;
    FManagerCount: Integer;
    FPageParser: TPageParser;
    FParserManager: TParserManager;
    FProductsDS: TProductsDS;
    FProductListDS: TProductListDS;
    FProductListW: TProductListW;
    FProductListParser: TProductListParser;
    FProductParser: TProductParser;
    FProductW: TProductW;
    FStatus: TStatus;
    FThreadStatus: TThreadStatus;
    FViewCategory: TfrmGrid;
    FViewProducts: TfrmGrid;
    FViewProductList: TfrmGrid;
    procedure AddToLog(const S: string);
    function CheckRunning: Boolean;
    procedure DoAfterParse(Sender: TObject);
    procedure DoBeforeLoad(Sender: TObject);
    procedure DoOnParseComplete(Sender: TObject);
    procedure DoOnParseError(Sender: TObject);
    function GetCategoryParser: TCategoryParser;
    function GetCategoryPath(AID: Integer): string;
    function GetDownloadManagerEx: TDownloadManagerEx;
    function GetPageParser: TPageParser;
    function GetParserManager: TParserManager;
    function GetProductListParser: TProductListParser;
    function GetProductParser: TProductParser;
    procedure OnDownloadComplete(Sender: TObject);
    procedure SetStatus(const Value: TStatus);
    procedure StartDocumentDownload(AIDProduct: Integer);
    procedure StartGrab;
    procedure StartCategoryParsing(AID: Integer);
    procedure StartProductListParsing(AID: Integer);
    procedure StartProductParsing(AID: Integer);
    procedure StopGrab;
    procedure TryParseNextCategory(const ParentID: Integer);
    { Private declarations }
  protected
    property CategoryParser: TCategoryParser read GetCategoryParser;
    property DownloadManagerEx: TDownloadManagerEx read GetDownloadManagerEx;
    property PageParser: TPageParser read GetPageParser;
    property ProductListParser: TProductListParser read GetProductListParser;
    property ProductParser: TProductParser read GetProductParser;
  public
    property ParserManager: TParserManager read GetParserManager;
    property Status: TStatus read FStatus write SetStatus;
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  WebLoader, FireDAC.Comp.Client, NotifyEvents, System.StrUtils, System.IOUtils;

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

function TMainForm.CheckRunning: Boolean;
begin
  Result := Status = Runing;
  if Result then
    Exit;

  Dec(FManagerCount);
  if FManagerCount = 0 then
    Status := Stoped;
end;

procedure TMainForm.DoAfterParse(Sender: TObject);
var
  ANotifyObj: TNotifyObj;
begin
  ANotifyObj := Sender as TNotifyObj;

  case FThreadStatus of
    tsCategory:
      begin
        if CategoryParser.W.RecordCount = 0 then
          Exit;
        FCategoryDS.W.AppendFrom(CategoryParser.W);

        if FCategoryW.HREF.Locate(ANotifyObj.URL, []) then
          FCategoryW.SetStatus(1); // Нашли подкатегории

        FViewCategory.MyApplyBestFit;
      end;
    tsProductList:
      begin
        // Если результат парсинга списка товаров не успешен
        if ProductListParser.W.RecordCount = 0 then
          Exit;

        FProductListDS.W.AppendFrom(ProductListParser.W);
        if FCategoryW.HREF.Locate(ANotifyObj.URL, []) then
          FCategoryW.SetStatus(2); // Нашли список товаров

        FViewProductList.MyApplyBestFit;
      end;
    tsProducts:
      begin
        // Если результат парсинга успешен
        if ProductParser.W.RecordCount = 0 then
          Exit;

        FProductsDS.W.AppendFrom(ProductParser.W);
        // Если есть что загружать и сейчас не идёт загрузка
        if (Status = Runing) and (FProductW.DataSet.RecordCount > 0) and
          (not DownloadManagerEx.Downloading) then
          StartDocumentDownload(FProductW.ID.F.AsInteger);

        if FProductListW.HREF.Locate(ANotifyObj.URL, []) then
          FProductListW.SetStatus(1); // Нашли характеристики товара

        FViewProducts.MyApplyBestFit;
      end;
    tsDownloadFiles:
      begin

      end;
  end;

end;

procedure TMainForm.DoBeforeLoad(Sender: TObject);
begin
  case FThreadStatus of
    tsCategory:
      AddToLog(Format('%s - %s', [GetCategoryPath(FCategoryNode.ID),
        'поиск подкатегорий']));
    tsProductList:
      AddToLog(Format('%s - %s', [GetCategoryPath(FCategoryNode.ID),
        'поиск товаров']));
    tsProducts:
      AddToLog(Format('%s - %s',
        [GetCategoryPath(FProductListW.ParentID.F.AsInteger) + '\' +
        FProductListW.Caption.F.AsString, 'получаем характеристики товара']));
    tsDownloadFiles:
      AddToLog(Format('%s - %s',
        [GetCategoryPath(FProductListW.ParentID.F.AsInteger) + '\' +
        FProductListW.Caption.F.AsString, 'загружаем документацию']));
  end;

end;

procedure TMainForm.DoOnParseComplete(Sender: TObject);
begin
  // Если продолжать не надо
  if not CheckRunning then
    Exit;

  case FThreadStatus of
    tsCategory:
      begin
        // Переходим на ту категорию, содержимое которой парсили
        FCategoryW.ID.Locate(FCategoryNode.ID, [], True);

        // Если для этой категории не были найдены подкатегории
        if FCategoryW.Status.F.AsInteger = 0 then
        begin
          // Пробуем поискать список товаров в этой категории
          StartProductListParsing(FCategoryNode.ID);
        end
        else
        begin
          // Ищем дочернюю категорию
          FCategoryW.ParentID.Locate(FCategoryNode.ID, [], True);
          // Начинаем парсинг этой дочерней категории
          StartCategoryParsing(FCategoryW.ID.F.AsInteger);
        end;
      end;
    tsProductList:
      begin
        FCategoryW.DataSet.Filtered := False;

        // Переходим на ту категорию, содержимое которой парсили
        FCategoryW.ID.Locate(FCategoryNode.ID, [], True);

        case FCategoryW.Status.F.AsInteger of
          2:
            // Если для этой категории были найдены товары
            begin
              Assert(FProductListW.DataSet.RecordCount > 0);
              // Пробуем парсить товары
              StartProductParsing(FProductListW.ID.F.AsInteger);
            end;
          0:
            // Если для этой категории не были найдены товары
            begin
              // добавить эту категорию в список категорий с ошибками!
              FCategoryW.SetStatus(100);

              // Пробуем найти и начать парсинг следующей категории
              TryParseNextCategory(FCategoryNode.ParentID);
            end;
        else
          Assert(False);
        end;
      end;
    tsProducts:
      begin
        // Если ещё есть необработанные записи о товарах
        if (FProductListW.DataSet.RecordCount > 0) then
          StartProductParsing(FProductListW.ID.F.AsInteger)
        else
          // Пробуем найти и начать парсинг следующей категории
          TryParseNextCategory(FCategoryNode.ParentID);
      end;
    tsDownloadFiles:
      begin
      end;
  end;

end;

procedure TMainForm.DoOnParseError(Sender: TObject);
var
  AErrorNotify: TErrorNotify;
begin
  AErrorNotify := Sender as TErrorNotify;
  AddToLog(Format('%s %s', [AErrorNotify.URL, AErrorNotify.ErrorMessage]));
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

  // Товары
  FProductsDS := TProductsDS.Create(Self);
  FProductW := TProductW.Create(FProductsDS.W.AddClone(''));
  FProductW.FilterByNotDone;
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

function TMainForm.GetDownloadManagerEx: TDownloadManagerEx;
begin
  if FDownloadManagerEx = nil then
  begin
    FDownloadManagerEx := TDownloadManagerEx.Create(Self);
    TNotifyEventWrap.Create(FDownloadManagerEx.OnDownloadComplete,
      OnDownloadComplete);
  end;

  Result := FDownloadManagerEx;
end;

function TMainForm.GetPageParser: TPageParser;
begin
  if FPageParser = nil then
    FPageParser := TPageParser.Create(Self);

  Result := FPageParser;
end;

function TMainForm.GetParserManager: TParserManager;
begin
  if FParserManager = nil then
  begin
    FParserManager := TParserManager.Create(Self);
    TNotifyEventWrap.Create(FParserManager.OnError, DoOnParseError);
    TNotifyEventWrap.Create(FParserManager.BeforeLoad, DoBeforeLoad);
    TNotifyEventWrap.Create(FParserManager.AfterParse, DoAfterParse);
    TNotifyEventWrap.Create(FParserManager.OnParseComplete, DoOnParseComplete);
  end;
  Result := FParserManager;
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

procedure TMainForm.OnDownloadComplete(Sender: TObject);
var
  ADM: TDownloadManagerEx;
begin
  ADM := Sender as TDownloadManagerEx;

  FProductW.LocateByPK(ADM.ID, True);
  Assert(FProductW.Status.F.AsInteger = 0);
  FProductW.SetStatus(1); // Загрузили документацию

  // Если продолжать загрузку не надо!
  if not CheckRunning then
    Exit;

  // Если есть необработанные товары
  if FProductW.DataSet.RecordCount > 0 then
    // Начинаем загрузку документации
    StartDocumentDownload(FProductW.ID.F.AsInteger)
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

  if FStatus = Runing then
  begin
    dxBarButton1.Action := actStopGrab;
    Timer1.Enabled := True;
  end;

  if FStatus = Stoping then
  begin
    actStopGrab.Caption := 'Останавливаюсь';
    actStopGrab.Enabled := False;
    dxBarButton1.Action := actStopGrab;
    FManagerCount := 1;
    if DownloadManagerEx.Downloading then
      FManagerCount := 2;
    Timer1.Enabled := False;
  end;
end;

procedure TMainForm.StartDocumentDownload(AIDProduct: Integer);
var
  AFileName: string;
  APath: string;
  AProgramPath: string;
  L: TList<TDMRec>;
begin
  FProductW.LocateByPK(AIDProduct, True);
  // Загрузка документации об этом продукте ещё не производилась
  Assert(FProductW.Status.F.AsInteger = 0);

  AProgramPath := TPath.GetDirectoryName(ParamStr(0));

  L := TList<TDMRec>.Create;
  try
    if FProductW.Image.F.AsString <> '' then
    begin
      APath := TPath.Combine(AProgramPath, 'Изображение');
      AFileName := FProductW.ItemNumber.F.AsString.Replace(' ', '_') + '.jpg';
      AFileName := TPath.Combine(APath, AFileName);
      L.Add(TDMRec.Create(FProductW.Image.F.AsString, AFileName));
    end;

    if FProductW.Specification.F.AsString <> '' then
    begin
      APath := TPath.Combine(AProgramPath, 'Спецификация');
      AFileName := FProductW.ItemNumber.F.AsString.Replace(' ', '_') + '.pdf';
      AFileName := TPath.Combine(APath, AFileName);
      L.Add(TDMRec.Create(FProductW.Specification.F.AsString, AFileName));
    end;

    if FProductW.Drawing.F.AsString <> '' then
    begin
      APath := TPath.Combine(AProgramPath, 'Чертёж');
      AFileName := FProductW.ItemNumber.F.AsString.Replace(' ', '') + '.pdf';
      AFileName := TPath.Combine(APath, AFileName);
      L.Add(TDMRec.Create(FProductW.Drawing.F.AsString, AFileName));
    end;

    if L.Count > 0 then
    begin
      FProductListDS.W.LocateByPK(FProductW.ParentID.F.AsInteger, True);

      AddToLog(Format('%s - %s',
        [GetCategoryPath(FProductListDS.W.ParentID.F.AsInteger) + '\' +
        FProductListDS.W.Caption.F.AsString, 'загружаем документацию']));

      // FThreadStatus := tsDownloadFiles;
      DownloadManagerEx.StartDownload(AIDProduct, L.ToArray)
    end
    else
    begin
      // Если есть необработанные товары
      if FProductW.DataSet.RecordCount > 0 then
        // Начинаем загрузку документации
        StartDocumentDownload(FProductW.ID.F.AsInteger)
    end;
  finally
    FreeAndNil(L);
  end;
end;

procedure TMainForm.StartGrab;
var
  APath: string;
  AProgramPath: string;
begin
  // Создаём необходимые папки
  AProgramPath := TPath.GetDirectoryName(ParamStr(0));
  APath := TPath.Combine(AProgramPath, 'Изображение');
  TDirectory.CreateDirectory(APath);
  APath := TPath.Combine(AProgramPath, 'Спецификация');
  TDirectory.CreateDirectory(APath);
  APath := TPath.Combine(AProgramPath, 'Чертёж');
  TDirectory.CreateDirectory(APath);

  Status := Runing;

  // Если есть необработанные товары
  if FProductW.DataSet.RecordCount > 0 then
    // Начинаем загрузку документации
    StartDocumentDownload(FProductW.ID.F.AsInteger)


  FCategoryDS.W.TryAppend;
  FCategoryDS.W.Caption.F.AsString := 'Промышленные соединители Han®';
  FCategoryDS.W.HREF.F.AsString :=
    'https://b2b.harting.com/ebusiness/ru/ru/13991';
  FCategoryDS.W.TryPost;
  FViewCategory.MyApplyBestFit;

  StartCategoryParsing(FCategoryDS.W.ID.F.AsInteger);
end;

procedure TMainForm.StartCategoryParsing(AID: Integer);
begin
  Assert(AID > 0);
  // Ищем запись о этой категории
  FCategoryW.DataSet.Filtered := False;
  FCategoryW.ID.Locate(AID, [], True);
  // Она должна быть ещё не обработана
  Assert(FCategoryW.Status.F.AsInteger = 0);

  FThreadStatus := tsCategory;

  FCategoryNode.ID := FCategoryW.ID.F.AsInteger;
  FCategoryNode.ParentID := FCategoryW.ParentID.F.AsInteger;

  // Запускаем парсер категорий в потоке
  ParserManager.Start(FCategoryW.HREF.F.AsString, FCategoryW.ID.F.AsInteger,
    CategoryParser, nil);
end;

procedure TMainForm.StartProductListParsing(AID: Integer);
begin
  // Переходим на ту категорию, содержимое которой парсили
  FCategoryW.ID.Locate(AID, [], True);

  FThreadStatus := tsProductList;

  // Запускаем парсер списка товаров в потоке
  ParserManager.Start(FCategoryW.HREF.F.AsString, FCategoryW.ID.F.AsInteger,
    ProductListParser, PageParser);
end;

procedure TMainForm.StartProductParsing(AID: Integer);
begin
  Assert(AID > 0);
  // Ищем запись о этом товаре
  FProductListW.ID.Locate(AID, [], True);

  // Она должна быть ещё не обработана
  Assert(FProductListW.Status.F.AsInteger = 0);

  FThreadStatus := tsProducts;

  // Запускаем парсер товара в потоке
  ParserManager.Start(FProductListW.HREF.F.AsString,
    FProductListW.ID.F.AsInteger, ProductParser, nil);
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

procedure TMainForm.TryParseNextCategory(const ParentID: Integer);
var
  AID: Integer;
  AParentID: Integer;
begin
  AID := 0;
  AParentID := ParentID;
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
    StartCategoryParsing(AID)
  else
  begin
    Status := Stoped;
    ShowMessage('Парсинг окончен');
  end;
end;

end.
