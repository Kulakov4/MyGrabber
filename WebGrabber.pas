unit WebGrabber;

interface

uses
  System.Classes, Status, DownloadManagerEx, NotifyEvents, ProductListDataSet,
  ProductParser, ProductsDataSet, CategoryDataSet, System.Generics.Collections,
  System.SysUtils, LogInterface, System.StrUtils, CategoryParser,
  ParserManager, PageParser, ProductListParser, FinalDataSet, ErrorDataSet,
  WebGrabberState, LogDataSet, Settings;

type
  TWebGrabber = class(TComponent)
  private
    FCategoryDS: TCategoryDS;
    FCategoryParser: TCategoryParser;
    FCategoryW: TCategoryW;
    FDownloadDocs: Boolean;
    FDownloadLogID: Integer;
    FDownloadManagerEx: TDownloadManagerEx;
    FErrorDS: TErrorDS;
    FFinalDataSet: TFinalDataSet;
    FLogDS: TLogDS;
    FOnStatusChange: TNotifyEventsEx;
    FOnManyErrors: TNotifyEventsEx;
    FOnGrabComplete: TNotifyEventsEx;
    FPageParser: TPageParser;
    FParserManager: TParserManager;
    FProductListDS: TProductListDS;
    FProductListParser: TProductListParser;
    FProductListW: TProductListW;
    FProductParser: TProductParser;
    FProductsDS: TProductsDS;
    FProductW: TProductW;
    FStatus: TStatus;
    FThreadStatus: TThreadStatus;
    FWaitObjectCount: Integer;
    FWebGrabberState: TWebGrabberState;
    procedure AddFinal(AIDProduct: Integer);
    function CheckRunning: Boolean;
    procedure CreateDocDir;
    procedure DoAfterParse(Sender: TObject);
    procedure DoBeforeLoad(Sender: TObject);
    procedure DoOnParseComplete(Sender: TObject);
    procedure DoOnParseError(Sender: TObject);
    function GetCategoryParser: TCategoryParser;
    function GetCategoryPath(AID: Integer): string;
    function GetCategoryW: TCategoryW;
    function GetDownloadManagerEx: TDownloadManagerEx;
    function GetErrorW: TErrorW;
    function GetFinalW: TFinalW;
    function GetLogW: TLogW;
    function GetPageParser: TPageParser;
    function GetParserManager: TParserManager;
    function GetProductListParser: TProductListParser;
    function GetProductListW: TProductListW;
    function GetProductParser: TProductParser;
    function GetProductW: TProductW;
    procedure OnDownloadComplete(Sender: TObject);
    procedure OnDownloadError(ADownloadError: TDownloadError);
    procedure SetStatus(const Value: TStatus);
    procedure StartCategoryParsing(AID: Integer);
    procedure StartDocumentDownload(AIDProduct: Integer);
    procedure StartProductListParsing(AID: Integer);
    procedure StartProductParsing(AID: Integer);
    procedure TryParseNextCategory(const ParentID: Integer);
  protected
    property CategoryParser: TCategoryParser read GetCategoryParser;
    property DownloadManagerEx: TDownloadManagerEx read GetDownloadManagerEx;
    property PageParser: TPageParser read GetPageParser;
    property ProductListParser: TProductListParser read GetProductListParser;
    property ProductParser: TProductParser read GetProductParser;
  public
    constructor Create(AOwner: TComponent); override;
    function ContinueGrab: Boolean;
    procedure SaveState;
    procedure LoadState;
    procedure StartGrab(ASettings: TWebGrabberSettings);
    function StateExists: Boolean;
    procedure StopGrab;
    property CategoryW: TCategoryW read GetCategoryW;
    property OnStatusChange: TNotifyEventsEx read FOnStatusChange;
    property OnManyErrors: TNotifyEventsEx read FOnManyErrors;
    property OnGrabComplete: TNotifyEventsEx read FOnGrabComplete;
    property ErrorW: TErrorW read GetErrorW;
    property FinalW: TFinalW read GetFinalW;
    property LogW: TLogW read GetLogW;
    property ParserManager: TParserManager read GetParserManager;
    property ProductListW: TProductListW read GetProductListW;
    property ProductW: TProductW read GetProductW;
    property Status: TStatus read FStatus write SetStatus;
  end;

implementation

uses
  System.IOUtils, MyDir, NounUnit;

constructor TWebGrabber.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLogDS := TLogDS.Create(Self);

  FCategoryDS := TCategoryDS.Create(Self);
  FCategoryW := TCategoryW.Create(FCategoryDS.W.AddClone(''));

  FProductListDS := TProductListDS.Create(Self);
  FProductListW := TProductListW.Create(FProductListDS.W.AddClone(''));
  FProductListW.FilterByNotDone;

  // Товары
  FProductsDS := TProductsDS.Create(Self);
  FProductW := TProductW.Create(FProductsDS.W.AddClone(''));
  FProductW.FilterByNotDone;

  FFinalDataSet := TFinalDataSet.Create(Self);

  FOnStatusChange := TNotifyEventsEx.Create(Self);
  FOnManyErrors := TNotifyEventsEx.Create(Self);
  FOnGrabComplete := TNotifyEventsEx.Create(Self);

  FErrorDS := TErrorDS.Create(Self);

  FStatus := Stoped;

  FWebGrabberState := TWebGrabberState.Create(Self);

  LoadState;
end;

procedure TWebGrabber.AddFinal(AIDProduct: Integer);
var
  L: TList<String>;
begin
  L := TList<String>.Create;
  try
    FProductW.LocateByPK(AIDProduct, True);
    FProductListDS.W.LocateByPK(FProductW.ParentID.F.AsInteger, True);
    FCategoryDS.W.LocateByPK(FProductListDS.W.ParentID.F.AsInteger, True);
    L.Add(FCategoryDS.W.Caption.F.AsString);
    while FCategoryDS.W.ParentID.F.AsInteger > 0 do
    begin
      FCategoryDS.W.LocateByPK(FCategoryDS.W.ParentID.F.AsInteger, True);
      L.Insert(0, FCategoryDS.W.Caption.F.AsString);
    end;

    with FFinalDataSet.W do
    begin
      TryAppend;
      Category1.F.AsString := L[0];
      if L.Count > 1 then
        Category2.F.AsString := L[1];
      if L.Count > 2 then
        Category3.F.AsString := L[2];
      if L.Count > 3 then
        Category4.F.AsString := L[3];
      // if L.Count > 4 then
      // raise Exception.Create('Слишком большая вложенность категорий');
      ItemNumber.F.AsString := FProductW.ItemNumber.F.AsString.Replace(' ', '');
      Description.F.AsString := FProductW.Description.F.AsString;
      Image.F.AsString := FProductW.ImageFileName.F.AsString;
      Specification.F.AsString := FProductW.SpecificationFileName.F.AsString;
      Drawing.F.AsString := FProductW.DrawingFileName.F.AsString;
      TemperatureRange.F.AsString := FProductW.TemperatureRange.F.AsString;
      TryPost;
    end;
  finally
    FreeAndNil(L);
  end;

  Assert(FProductW.Status.F.AsInteger = 0);
  FProductW.SetStatus(1);
end;

function TWebGrabber.CheckRunning: Boolean;
begin
  Result := Status = Runing;
  if Result then
    Exit;

  Dec(FWaitObjectCount);
  if FWaitObjectCount = 0 then
    Status := Stoped;
end;

function TWebGrabber.ContinueGrab: Boolean;
begin
  Result := True;
  if FWebGrabberState.ThreadStatus = tsComplete then
  begin
    Result := False;
    OnGrabComplete.CallEventHandlers(Self);
    Exit;
  end;

  CreateDocDir;

  Status := Runing;

  // Очищаем все ошибки
  FErrorDS.EmptyDataSet;

  // Если есть необработанные товары
  if FProductW.DataSet.RecordCount > 0 then
    // Начинаем загрузку документации
    StartDocumentDownload(FProductW.ID.F.AsInteger);

  case FWebGrabberState.ThreadStatus of
    tsCategory:
      StartCategoryParsing(FWebGrabberState.ID);
    tsProductList:
      StartProductListParsing(FWebGrabberState.ID);
    tsProducts:
      StartProductParsing(FWebGrabberState.ID);
  end;
end;

procedure TWebGrabber.CreateDocDir;
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
end;

procedure TWebGrabber.DoAfterParse(Sender: TObject);
var
  ANotifyObj: TNotifyObj;
begin
  ANotifyObj := Sender as TNotifyObj;

  case FThreadStatus of
    tsCategory:
      begin
        if CategoryParser.W.RecordCount = 0 then
        begin
          FLogDS.W.SetState(ANotifyObj.LogID, 'подкатегории не найдены');
          Exit;
        end;
        FCategoryDS.W.AppendFrom(CategoryParser.W);

        FLogDS.W.SetState(ANotifyObj.LogID,
          Format('%s %d %s', [TNoun.Get(CategoryParser.W.RecordCount, 'найдена',
          'найдено', 'найдено'), CategoryParser.W.RecordCount,
          TNoun.Get(CategoryParser.W.RecordCount, 'подкатегория',
          'подкатегории', 'подкатегорий')]));

        if FCategoryW.HREF.Locate(ANotifyObj.URL, []) then
          FCategoryW.SetStatus(1); // Нашли подкатегории

        // FViewCategory.MyApplyBestFit;
      end;
    tsProductList:
      begin
        // Если результат парсинга списка товаров не успешен
        if ProductListParser.W.RecordCount = 0 then
        begin
          FLogDS.W.SetState(ANotifyObj.LogID, 'товары не найдены');
          Exit;
        end;

        FProductListDS.W.AppendFrom(ProductListParser.W);

        FLogDS.W.SetState(ANotifyObj.LogID,
          Format('%s %d %s', [TNoun.Get(ProductListParser.W.RecordCount,
          'найден', 'найдено', 'найдено'), ProductListParser.W.RecordCount,
          TNoun.Get(ProductListParser.W.RecordCount, 'товар', 'товара',
          'товаров')]));

        if FCategoryW.HREF.Locate(ANotifyObj.URL, []) then
          FCategoryW.SetStatus(2); // Нашли список товаров

        // FViewProductList.MyApplyBestFit;
      end;
    tsProducts:
      begin
        // Если результат парсинга не успешен
        if ProductParser.W.RecordCount = 0 then
        begin
          FLogDS.W.SetState(ANotifyObj.LogID,
            'характеристики товара не найдены');
          Exit;
        end;

        FProductsDS.W.AppendFrom(ProductParser.W);
        FLogDS.W.SetState(ANotifyObj.LogID, 'характеристики товара найдены');

        // Если есть что загружать и сейчас не идёт загрузка
        if (Status = Runing) and (FProductW.DataSet.RecordCount > 0) and
          (not DownloadManagerEx.Downloading) then
          StartDocumentDownload(FProductW.ID.F.AsInteger);

        if FProductListW.HREF.Locate(ANotifyObj.URL, []) then
          FProductListW.SetStatus(1); // Нашли характеристики товара

        // FViewProducts.MyApplyBestFit;
      end;
  end;

end;

procedure TWebGrabber.DoBeforeLoad(Sender: TObject);
var
  ALogID: Integer;
  PM: TParserManager;
begin
  ALogID := 0;
  PM := Sender as TParserManager;
  case FThreadStatus of
    tsCategory:
      ALogID := FLogDS.W.Add(GetCategoryPath(PM.ParentID),
        'поиск подкатегорий');
    tsProductList:
      ALogID := FLogDS.W.Add(GetCategoryPath(PM.ParentID), 'поиск товаров');
    tsProducts:
      ALogID := FLogDS.W.Add(GetCategoryPath(FProductListW.ParentID.F.AsInteger)
        + '\' + FProductListW.Caption.F.AsString,
        'получаем характеристики товара');
  end;
  if ALogID > 0 then
    PM.LogID := ALogID;
end;

procedure TWebGrabber.DoOnParseComplete(Sender: TObject);
var
  PM: TParserManager;
begin
  PM := Sender as TParserManager;

  case FThreadStatus of
    tsCategory:
      begin
        // Если в ходе парсинга возникли ошибки
        if PM.Errors.Count > 0 then
        begin
          // Пробуем запустить парсинг ещё раз
          StartCategoryParsing(PM.ParentID);
          Exit;
        end;

        FCategoryW.DataSet.Filtered := False;
        // Переходим на ту категорию, содержимое которой парсили
        FCategoryW.ID.Locate(PM.ParentID, [], True);

        // Если для этой категории не были найдены подкатегории
        if FCategoryW.Status.F.AsInteger = 0 then
        begin
          // Пробуем поискать список товаров в этой категории
          StartProductListParsing(PM.ParentID);
        end
        else
        begin
          // Ищем дочернюю категорию
          FCategoryW.ParentID.Locate(PM.ParentID, [], True);
          // Начинаем парсинг этой дочерней категории
          StartCategoryParsing(FCategoryW.ID.F.AsInteger);
        end;
      end;
    tsProductList:
      begin
        // Если в ходе парсинга возникли ошибки
        if PM.Errors.Count > 0 then
        begin
          // Пробуем запустить парсинг ещё раз
          StartProductListParsing(PM.ParentID);
          Exit;
        end;

        FCategoryW.DataSet.Filtered := False;

        // Переходим на ту категорию, содержимое которой парсили
        FCategoryW.ID.Locate(PM.ParentID, [], True);

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
              TryParseNextCategory(FCategoryW.ParentID.F.AsInteger);
            end;
        else
          Assert(False);
        end;
      end;
    tsProducts:
      begin
        // Если в ходе парсинга возникли ошибки
        if PM.Errors.Count > 0 then
        begin
          // Пробуем запустить парсинг ещё раз
          StartProductParsing(PM.ParentID);
          Exit;
        end;

        // Если ещё есть необработанные записи о товарах
        if (FProductListW.DataSet.RecordCount > 0) then
          StartProductParsing(FProductListW.ID.F.AsInteger)
        else
        begin
          // Переходим к последнему элементу списка товаров, который мы парсили
          FProductListDS.W.LocateByPK(PM.ParentID, True);

          FCategoryW.DataSet.Filtered := False;
          // Переходим на ту категорию, содержимое которой парсили
          FCategoryW.ID.Locate(FProductListDS.W.ParentID.F.AsInteger, [], True);

          // Пробуем найти и начать парсинг следующей категории
          TryParseNextCategory(FCategoryW.ParentID.F.AsInteger);
        end;
      end;
  end;

end;

procedure TWebGrabber.DoOnParseError(Sender: TObject);
var
  AErrorNotify: TErrorNotify;
begin
  AErrorNotify := Sender as TErrorNotify;
  FLogDS.W.SetState(AErrorNotify.LogID, AErrorNotify.ErrorMessage);

  with FErrorDS.W do
  begin
    TryAppend;
    URL.F.AsString := AErrorNotify.URL;
    ErrorText.F.AsString := AErrorNotify.ErrorMessage;
    TryPost;
  end;
end;

function TWebGrabber.GetCategoryParser: TCategoryParser;
begin
  if FCategoryParser = nil then
    FCategoryParser := TCategoryParser.Create(Self);
  Result := FCategoryParser;
end;

function TWebGrabber.GetCategoryPath(AID: Integer): string;
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

function TWebGrabber.GetCategoryW: TCategoryW;
begin
  Result := FCategoryDS.W;
end;

function TWebGrabber.GetDownloadManagerEx: TDownloadManagerEx;
begin
  if FDownloadManagerEx = nil then
  begin
    FDownloadManagerEx := TDownloadManagerEx.Create(Self);

    // TNotifyEventWrap.Create(FDownloadManagerEx.OnError, OnDownloadError);

    TNotifyEventWrap.Create(FDownloadManagerEx.OnDownloadComplete,
      OnDownloadComplete);
  end;

  Result := FDownloadManagerEx;
end;

function TWebGrabber.GetErrorW: TErrorW;
begin
  Result := FErrorDS.W;
end;

function TWebGrabber.GetFinalW: TFinalW;
begin
  Result := FFinalDataSet.W;
end;

function TWebGrabber.GetLogW: TLogW;
begin
  Result := FLogDS.W;
end;

function TWebGrabber.GetPageParser: TPageParser;
begin
  if FPageParser = nil then
    FPageParser := TPageParser.Create(Self);

  Result := FPageParser;
end;

function TWebGrabber.GetParserManager: TParserManager;
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

function TWebGrabber.GetProductListParser: TProductListParser;
begin
  if FProductListParser = nil then
    FProductListParser := TProductListParser.Create(Self);
  Result := FProductListParser;
end;

function TWebGrabber.GetProductListW: TProductListW;
begin
  Result := FProductListDS.W;
end;

function TWebGrabber.GetProductParser: TProductParser;
begin
  if FProductParser = nil then
    FProductParser := TProductParser.Create(Self);

  Result := FProductParser;
end;

function TWebGrabber.GetProductW: TProductW;
begin
  Result := FProductsDS.W;
end;

procedure TWebGrabber.OnDownloadComplete(Sender: TObject);
var
  ADM: TDownloadManagerEx;
  AErrorList: TList<TDownloadError>;
  AStateText: string;
  i: Integer;
begin
  ADM := Sender as TDownloadManagerEx;
  AStateText := 'документация успешно загружена';
  // Обрабатываем ошибки загрузки
  AErrorList := ADM.ErrorList.LockList;
  try
    if AErrorList.Count > 0 then
    begin
      for i := 0 to AErrorList.Count - 1 do
      begin
        OnDownloadError(AErrorList[i]);
      end;
      AStateText := 'ошибка при загрузке документации';
    end;
  finally
    ADM.ErrorList.UnlockList;
  end;

  // Добавляем конечную информацию о продукте
  AddFinal(ADM.ID);

  // Загрузили документацию
  FLogDS.W.SetState(FDownloadLogID, AStateText);

  // Если продолжать загрузку не надо!
  if not CheckRunning then
    Exit;

  // Если есть необработанные товары
  if FProductW.DataSet.RecordCount > 0 then
    // Начинаем загрузку документации
    StartDocumentDownload(FProductW.ID.F.AsInteger)
end;

procedure TWebGrabber.OnDownloadError(ADownloadError: TDownloadError);
var
  AFileName: string;
begin
  FErrorDS.W.TryAppend;
  FErrorDS.W.URL.F.AsString := ADownloadError.URL;
  FErrorDS.W.ErrorText.F.AsString := ADownloadError.ErrorMessage;
  FErrorDS.W.FileName.F.AsString := ADownloadError.FileName;
  FErrorDS.W.TryPost;

  FProductW.LocateByPK(ADownloadError.ID, True);

  Assert(FProductW.Status.F.AsInteger = 0);

  AFileName := TPath.GetFileName(ADownloadError.FileName);

  FProductW.TryEdit;

  if FProductW.ImageFileName.F.AsString = AFileName then
    FProductW.ImageFileName.F.AsString := '';

  if FProductW.SpecificationFileName.F.AsString = AFileName then
    FProductW.SpecificationFileName.F.AsString := '';

  if FProductW.DrawingFileName.F.AsString = AFileName then
    FProductW.DrawingFileName.F.AsString := '';

  FProductW.TryPost;
end;

procedure TWebGrabber.SaveState;
begin
  Assert(FStatus = Stoped);
  FLogDS.Save;
  FCategoryDS.Save;
  FProductListDS.Save;
  FProductsDS.Save;
  FErrorDS.Save;
  FFinalDataSet.Save;
end;

procedure TWebGrabber.LoadState;
begin
  Assert(FStatus = Stoped);

  if not StateExists then
    Exit;

  FWebGrabberState.Saver.Load;
  FDownloadDocs := FWebGrabberState.DownloadDocs;

  FCategoryDS.ID := FWebGrabberState.MaxID;
  Assert(FProductListDS.ID = FWebGrabberState.MaxID);
  Assert(FProductsDS.ID = FWebGrabberState.MaxID);
  Assert(FLogDS.ID = FWebGrabberState.MaxID);

  FLogDS.Load;
  FCategoryDS.Load;
  FProductListDS.Load;
  FProductsDS.Load;
  FErrorDS.Load;
  FFinalDataSet.Load;
end;

procedure TWebGrabber.SetStatus(const Value: TStatus);
begin
  FStatus := Value;
  if FStatus = Stoped then
  begin
    SaveState;
  end;

  if FStatus = Runing then
  begin
  end;

  if FStatus = Stoping then
  begin
    FWaitObjectCount := 1;
    if DownloadManagerEx.Downloading then
      FWaitObjectCount := 2;
  end;

  FOnStatusChange.CallEventHandlers(Self);
end;

procedure TWebGrabber.StartCategoryParsing(AID: Integer);
begin
  Assert(AID > 0);
  // Ищем запись о этой категории
  FCategoryW.DataSet.Filtered := False;
  FCategoryW.ID.Locate(AID, [], True);
  // Она должна быть ещё не обработана
  Assert(FCategoryW.Status.F.AsInteger = 0);

  FThreadStatus := tsCategory;

  if FErrorDS.W.HaveManyErrors then
    OnManyErrors.CallEventHandlers(Self);

  // Если продолжать не надо
  if not CheckRunning then
  begin
    FWebGrabberState.Save(FThreadStatus, AID, FCategoryDS.ID, FDownloadDocs);
    Exit;
  end;

  // Запускаем парсер категорий в потоке
  ParserManager.Start(FCategoryW.HREF.F.AsString, FCategoryW.ID.F.AsInteger,
    CategoryParser, nil);
end;

procedure TWebGrabber.StartDocumentDownload(AIDProduct: Integer);
var
  AFileName: string;
  APath: string;
  AProgramPath: string;
  L: TList<TDMRec>;
begin
  FProductW.LocateByPK(AIDProduct, True);

  // Если документацию загружать не надо
  if not FDownloadDocs then
  begin
    // Добавляем конечную информацию о продукте
    AddFinal(AIDProduct);
    Exit;
  end;

  // Загрузка документации об этом продукте ещё не производилась
  Assert(FProductW.Status.F.AsInteger = 0);

  AProgramPath := TMyDir.AppDir;

  L := TList<TDMRec>.Create;
  try
    if FProductW.ImageURL.F.AsString <> '' then
    begin
      APath := TPath.Combine(AProgramPath, 'Изображение');
      AFileName := FProductW.ItemNumber.F.AsString.Replace(' ', '_') + '.jpg';

      FProductW.TryEdit;
      FProductW.ImageFileName.F.AsString := AFileName;
      FProductW.TryPost;

      AFileName := TPath.Combine(APath, AFileName);
      L.Add(TDMRec.Create(FProductW.ImageURL.F.AsString, AFileName));
    end;

    if FProductW.SpecificationURL.F.AsString <> '' then
    begin
      APath := TPath.Combine(AProgramPath, 'Спецификация');
      AFileName := FProductW.ItemNumber.F.AsString.Replace(' ', '_') + '.pdf';

      FProductW.TryEdit;
      FProductW.SpecificationFileName.F.AsString := AFileName;
      FProductW.TryPost;

      AFileName := TPath.Combine(APath, AFileName);
      L.Add(TDMRec.Create(FProductW.SpecificationURL.F.AsString, AFileName));
    end;

    if FProductW.DrawingURL.F.AsString <> '' then
    begin
      APath := TPath.Combine(AProgramPath, 'Чертёж');
      AFileName := FProductW.ItemNumber.F.AsString.Replace(' ', '') + '.pdf';

      FProductW.TryEdit;
      FProductW.DrawingFileName.F.AsString := AFileName;
      FProductW.TryPost;

      AFileName := TPath.Combine(APath, AFileName);
      L.Add(TDMRec.Create(FProductW.DrawingURL.F.AsString, AFileName));
    end;

    // Если есть хоть один файл для загрузки
    if L.Count > 0 then
    begin
      FProductListDS.W.LocateByPK(FProductW.ParentID.F.AsInteger, True);

      FDownloadLogID :=
        FLogDS.W.Add(GetCategoryPath(FProductListDS.W.ParentID.F.AsInteger) +
        '\' + FProductListDS.W.Caption.F.AsString, 'загружаем документацию');

      DownloadManagerEx.StartDownload(AIDProduct, L.ToArray)
    end
    else
    begin
      // Добавляем конечную информацию о продукте
      AddFinal(AIDProduct);
      Exit;
    end;
  finally
    FreeAndNil(L);
  end;
end;

procedure TWebGrabber.StartGrab(ASettings: TWebGrabberSettings);
var
  i: Integer;
begin
  Assert(ASettings.URLs.Count > 0);
  FLogDS.EmptyDataSet;
  FCategoryDS.EmptyDataSet;
  FProductListDS.EmptyDataSet;
  FProductsDS.EmptyDataSet;
  FFinalDataSet.EmptyDataSet;

  for i := 0 to ASettings.URLs.Count - 1 do
  begin
    FCategoryDS.W.TryAppend;
    FCategoryDS.W.Caption.F.AsString := ASettings.URLs.Items[i].Caption;
    FCategoryDS.W.HREF.F.AsString := ASettings.URLs.Items[i].URL;
    FCategoryDS.W.TryPost;
  end;
  FDownloadDocs := ASettings.DownloadDocs;

  FWebGrabberState.ThreadStatus := tsCategory;
  FWebGrabberState.ID := FCategoryDS.W.ID.F.AsInteger;

  ContinueGrab;
end;

procedure TWebGrabber.StartProductListParsing(AID: Integer);
begin
  if FErrorDS.W.HaveManyErrors then
    OnManyErrors.CallEventHandlers(Self);

  // Если продолжать не надо
  if not CheckRunning then
    Exit;

  // Переходим на ту категорию, содержимое которой парсили
  FCategoryW.ID.Locate(AID, [], True);

  FThreadStatus := tsProductList;

  if not CheckRunning then
  begin
    FWebGrabberState.Save(FThreadStatus, AID, FProductListDS.ID, FDownloadDocs);
    Exit;
  end;

  // Запускаем парсер списка товаров в потоке
  ParserManager.Start(FCategoryW.HREF.F.AsString, FCategoryW.ID.F.AsInteger,
    ProductListParser, PageParser);
end;

procedure TWebGrabber.StartProductParsing(AID: Integer);
begin
  Assert(AID > 0);
  // Ищем запись о этом товаре
  FProductListW.ID.Locate(AID, [], True);

  // Она должна быть ещё не обработана
  Assert(FProductListW.Status.F.AsInteger = 0);

  FThreadStatus := tsProducts;

  if FErrorDS.W.HaveManyErrors then
    OnManyErrors.CallEventHandlers(Self);

  if not CheckRunning then
  begin
    FWebGrabberState.Save(FThreadStatus, AID, FProductsDS.ID, FDownloadDocs);
    Exit;
  end;

  // Запускаем парсер товара в потоке
  ParserManager.Start(FProductListW.HREF.F.AsString,
    FProductListW.ID.F.AsInteger, ProductParser, nil);
end;

function TWebGrabber.StateExists: Boolean;
begin
  Result := False;

  if not TFile.Exists(FWebGrabberState.FileName) then
    Exit;

  if not TFile.Exists(FLogDS.FullFileName) then
    Exit;

  if not TFile.Exists(FCategoryDS.FullFileName) then
    Exit;

  Result := True;
end;

procedure TWebGrabber.StopGrab;
begin
  Status := Stoping;
end;

procedure TWebGrabber.TryParseNextCategory(const ParentID: Integer);
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
    FWebGrabberState.Save(tsComplete, 0, FCategoryDS.ID, FDownloadDocs);
    Status := Stoped;
    FOnGrabComplete.CallEventHandlers(Self);
  end;
end;

end.
