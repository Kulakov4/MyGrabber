unit DialogUnit;

interface

uses Vcl.Dialogs, System.Classes, Winapi.Windows, System.IOUtils, Vcl.ExtDlgs;

{$WARN SYMBOL_PLATFORM OFF}

type
  TFileOpenDialogClass = class of TFileOpenDialog;
  TOpenDialogClass = class of TOpenDialog;

  TOpenFolderDialog = class(TOpenDialog)
  private
    procedure DoOnShow(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TExcelFilesFolderOpenDialog = class(TOpenFolderDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;

type
  TDatabaselFilesFolderOpenDialog = class(TOpenFolderDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;

type
  TPDFFilesFolderOpenDialog = class(TOpenFolderDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TDialog = class(TObject)
  private
    class var Instance: TDialog;
  public
    function DeleteRecordsDialog(const AText: string): Boolean;
    procedure ErrorMessageDialog(const AErrorMessage: String);
    class function NewInstance: TObject; override;
    function ShowDialog(AOpenDialogClass: TOpenDialogClass;
      const AInitialDir, AInitialFileName: string;
      var AFileName: String): Boolean;
  end;

  TExcelFileOpenDialog = class(TOpenDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TExcelFileSaveDialog = class(TSaveDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TMyOpenPictureDialog = class(TOpenPictureDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses Vcl.Forms, System.SysUtils, Winapi.ShlObj,
  Winapi.Messages, System.Contnrs{, CountNameHelper};

var
  SingletonList: TObjectList;

function TDialog.DeleteRecordsDialog(const AText: string): Boolean;
begin
  Result := Application.MessageBox(PWideChar(AText), 'Удаление',
    MB_YESNO + MB_ICONQUESTION) = IDYES;
end;

procedure TDialog.ErrorMessageDialog(const AErrorMessage: String);
begin
  Application.MessageBox(PChar(AErrorMessage), 'Ошибка', MB_OK + MB_ICONSTOP);
end;

class function TDialog.NewInstance: TObject;
begin
  if not Assigned(Instance) then
  begin
    Instance := TDialog(inherited NewInstance);
    SingletonList.Add(Instance);
  end;

  Result := Instance;
end;

function TDialog.ShowDialog(AOpenDialogClass: TOpenDialogClass;
  const AInitialDir, AInitialFileName: string; var AFileName: String): Boolean;
var
  fod: TOpenDialog;
begin
  AFileName := '';
  fod := AOpenDialogClass.Create(nil);
  try
    if not AInitialFileName.IsEmpty then
      fod.FileName := AInitialFileName;

    if not AInitialDir.IsEmpty then
      fod.InitialDir := AInitialDir;

    Result := fod.Execute(Application.ActiveFormHandle);
    if Result then
    begin
      AFileName := fod.FileName;
    end;
  finally
    FreeAndNil(fod);
  end;
end;

{ TExcelFilesFolderOpenDialog }
constructor TExcelFilesFolderOpenDialog.Create(AOwner: TComponent);
begin
  inherited;
  Self.FileName := '*.xls;*.xlsx';
end;

{ TDatabaselFilesFolderOpenDialog }
constructor TDatabaselFilesFolderOpenDialog.Create(AOwner: TComponent);
begin
  inherited;
  Self.FileName := '*.db';
end;

{ TPDFFilesFolderOpenDialog }
constructor TPDFFilesFolderOpenDialog.Create(AOwner: TComponent);
begin
  inherited;
  Self.FileName := '*.pdf;*.gif;*.jpg;*.png;*.bmp';
end;

{ TOpenFolderDialog }
constructor TOpenFolderDialog.Create(AOwner: TComponent);
begin
  inherited;
  // указывая имя файла как маску заставляем фильтровать по нему
  Options := Options + [ofNoValidate];
  // Обработчик события OnShow
  OnShow := DoOnShow;
end;

procedure TOpenFolderDialog.DoOnShow(Sender: TObject);
const
  // Названия констант по ссылке в MSDN, значения в Dlgs.h и WinUser.h
  stc3: Integer = $442; // Лэйбл к имени текущего файла
  cmb13: Integer = $47C; // Комбобокс с именем текущего файла
  edt1: Integer = $480; // Поле ввода с именем текущего файла

  stc2: Integer = $441; // Лэйбл к комбобоксу
  cmb1: Integer = $470; // Комбобокс со списком фильтров
var
  fod: TOpenDialog;
  H: THandle;
begin
  fod := Sender as TOpenDialog;
  if Assigned(fod) then
  begin
    H := GetParent(fod.Handle);

    // убрать первую строку надпись имя файла, эдит ввода и комбобокс
    SendMessage(H, WM_USER + 100 + 5, stc3, 0);
    SendMessage(H, WM_USER + 100 + 5, cmb13, 0);
    SendMessage(H, WM_USER + 100 + 5, edt1, 0);

    // убрать вторую строку - фильтр
    SendMessage(H, WM_USER + 100 + 5, cmb1, 0);
    SendMessage(H, WM_USER + 100 + 5, stc2, 0);
  end;
end;

{ TExcelFileOpenDialog }
constructor TExcelFileOpenDialog.Create(AOwner: TComponent);
begin
  inherited;
  Filter := 'Документы (*.xls, *.xlsx)|*.xls;*.xlsx|' + 'Все файлы (*.*)|*.*';
  FilterIndex := 0;
  Options := [ofFileMustExist];
end;

{ TExcelFileSaveDialog }
constructor TExcelFileSaveDialog.Create(AOwner: TComponent);
begin
  inherited;
  Filter := 'Документы (*.xls, *.xlsx)|*.xls;*.xlsx|' + 'Все файлы (*.*)|*.*';
  FilterIndex := 0;
  Options := [ofFileMustExist];
end;

{ TMyOpenPictureDialog }
constructor TMyOpenPictureDialog.Create(AOwner: TComponent);
begin
  inherited;
  Filter := 'Изображения и pdf файлы (*.jpg,*.jpeg,*.gif,*.png,*.pdf)|*.jpg;*.jpeg;*.gif;*.png;*.pdf|'
    + 'Изображения (*.jpg,*.jpeg,*.gif,*.png,*.tif)|*.jpg;*.jpeg;*.gif;*.png;*.tif|'
    + 'Документы (*.pdf, *.doc, *.hmtl)|*.pdf;*.doc;*.hmtl|' +
    'Все файлы (*.*)|*.*';
  FilterIndex := 0;
  Options := [ofFileMustExist];
end;

initialization

SingletonList := TObjectList.Create(True);

finalization

FreeAndNil(SingletonList);

end.
