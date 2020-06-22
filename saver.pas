unit Saver;

interface

uses System.Classes;

type
  TSaver = class(TObject)
  private
    FComponent: TComponent;
  protected
    procedure AfterSave(AOutputStream: TStream); virtual;
    function CreateInputStream: TStream; virtual;
    function CreateOutputStream: TStream; virtual;
    procedure FreeInputStream(AStream: TStream); virtual;
    procedure FreeOutputStream(AStream: TStream); virtual;
  public
    constructor Create(AComponent: TComponent = nil);
    procedure Load;
    procedure Save;
    property Component: TComponent read FComponent write FComponent;
  end;

  TOptions = class(TComponent)
  private
    FAutoLoadOptions: Boolean;
    FAutoSaveOptions: Boolean;
    FFileName: string;
    FSaver: TSaver;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    property AutoLoadOptions: Boolean read FAutoLoadOptions write FAutoLoadOptions;
    property AutoSaveOptions: Boolean read FAutoSaveOptions write FAutoSaveOptions;
    property Saver: TSaver read FSaver;
  published
    property FileName: string read FFileName write FFileName;
  end;

  TFileSaver = class(TSaver)
  private
    FFileName: string;
    procedure SetFileName(const Value: string);
  protected
    function CreateInputStream: TStream; override;
    function CreateOutputStream: TStream; override;
  public
    constructor Create(AComponent: TComponent = nil; AFileName: string = '');
    property FileName: string read FFileName write SetFileName;
  end;

  TMemorySaver = class(TSaver)
  private
    FInputStream: TStream;
    FOutputStream: TStream;
  protected
    function CreateInputStream: TStream; override;
    function CreateOutputStream: TStream; override;
    procedure FreeInputStream(AStream: TStream); override;
    procedure FreeOutputStream(AStream: TStream); override;
  public
    property InputStream: TStream read FInputStream write FInputStream;
    property OutputStream: TStream read FOutputStream write FOutputStream;
  end;

implementation

uses SysUtils;

constructor TSaver.Create(AComponent: TComponent = nil);
begin
  inherited Create;
  FComponent := AComponent;
end;

procedure TSaver.AfterSave(AOutputStream: TStream);
begin
  // TODO -cMM: TSaver.AfterSave default body inserted
end;

function TSaver.CreateInputStream: TStream;
begin
  // Создаём поток в памяти для чтения
  Result := TMemoryStream.Create; ;
end;

function TSaver.CreateOutputStream: TStream;
begin
  // Создаём поток в памяти для записи
  Result := TMemoryStream.Create;
end;

procedure TSaver.FreeInputStream(AStream: TStream);
begin
  AStream.Free;
end;

procedure TSaver.FreeOutputStream(AStream: TStream);
begin
  AStream.Free;
end;

procedure TSaver.Load;
var
  ms: TMemoryStream;
  AInputStream: TStream;
begin
  Assert(Component <> nil);
  ms := TMemoryStream.Create;
  AInputStream := CreateInputStream;
  try
    if AInputStream <> nil then // Если есть откуда считывать данные
    begin
      ObjectTextToBinary(AInputStream, ms);
      ms.position := 0;
      ms.ReadComponent(Component);
    end;
  finally
    ms.Free;
    FreeInputStream(AInputStream);
  end;
end;

procedure TSaver.Save;
var
  ms: TMemoryStream;
  AOutputStream: TStream;
begin
  Assert(Component <> nil);
  AOutputStream := CreateOutputStream;
  ms := TMemoryStream.Create;
  try
    ms.WriteComponent(Component);
    ms.position := 0;
    ObjectBinaryToText(ms, AOutputStream);
    AfterSave(AOutputStream);
  finally
    ms.Free;
    FreeOutputStream(AOutputStream);
  end;
end;

constructor TOptions.Create(AOwner: TComponent);
begin
  inherited;
  FAutoSaveOptions := True;
end;

destructor TOptions.Destroy;
begin
  if (FAutoSaveOptions) and (FSaver <> nil) then
    FSaver.Save;

  FreeAndNil(FSaver);
  inherited;
end;

procedure TOptions.AfterConstruction;
begin
  inherited;

  if FileName.IsEmpty then
    Exit;

  // Создаём сохраняльщика для себя
  FSaver := TFileSaver.Create(Self, FileName);

  //Предпологаем что опции надо загрузить из файла по окончании конструктора
  FAutoLoadOptions := FileExists(FileName);

  if (FAutoLoadOptions) and (FSaver <> nil) then
    FSaver.Load;
end;

constructor TFileSaver.Create(AComponent: TComponent = nil; AFileName: string
  = '');
begin
  inherited Create(AComponent);
  if AFileName = '' then
    FFileName := ChangeFileExt(ParamStr(0), '.txt')
  else
  begin
    FFileName := AFileName;
    if ExtractFilePath(FileName) = '' then
      FileName := ExtractFilePath(ParamStr(0)) + FileName;
  end;
end;

function TFileSaver.CreateInputStream: TStream;
begin
  // Создаём файловый поток для чтения
  Result := TFileStream.Create(FFileName, fmOpenRead);
end;

function TFileSaver.CreateOutputStream: TStream;
begin
  // Создаём файловый поток для записи
  Result := TFileStream.Create(FFileName, fmCreate or fmOpenWrite);
end;

procedure TFileSaver.SetFileName(const Value: string);
begin
  if FFileName <> Value then
  begin
    FFileName := Value;
  end;
end;

function TMemorySaver.CreateInputStream: TStream;
begin
  // Создаём поток в памяти для чтения
  if FInputStream = nil then
  begin
    Result := inherited CreateInputStream;
  end
  else
  begin
    Result := FInputStream;
    Result.Position := 0;
  end;
end;

function TMemorySaver.CreateOutputStream: TStream;
begin
  // Создаём поток в памяти для чтения
  if FOutputStream = nil then
  begin
    Result := inherited CreateInputStream;
  end
  else
  begin
    Result := FOutputStream;
    Result.Position := 0;
  end;
end;

procedure TMemorySaver.FreeInputStream(AStream: TStream);
begin
  if AStream <> InputStream then
    AStream.Free;
end;

procedure TMemorySaver.FreeOutputStream(AStream: TStream);
begin
  if AStream <> OutputStream then
    AStream.Free;
end;

end.

