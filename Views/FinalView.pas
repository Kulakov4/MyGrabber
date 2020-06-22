unit FinalView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GridFrame, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, dxBarBuiltInMenu,
  cxGridCustomPopupMenu, cxGridPopupMenu, Vcl.Menus, System.Actions,
  Vcl.ActnList, cxClasses, dxBar, Vcl.ComCtrls, cxGridLevel, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridBandedTableView,
  cxGridDBBandedTableView, cxGrid, FinalDataSet, System.ImageList, Vcl.ImgList,
  cxImageList;

type
  TViewFinal = class(TfrmGrid)
    actSave: TAction;
    cxImageList: TcxImageList;
    dxBarButton1: TdxBarButton;
    procedure actSaveExecute(Sender: TObject);
  private
    function GetclDescription: TcxGridDBBandedColumn;
    function GetFileName: string;
    function GetW: TFinalW;
    function ShowSaveDialog(const AFileName: string): Boolean;
    { Private declarations }
  protected
    procedure InitColumns(AView: TcxGridDBBandedTableView); override;
  public
    procedure InitView(AView: TcxGridDBBandedTableView); override;
    property clDescription: TcxGridDBBandedColumn read GetclDescription;
    property W: TFinalW read GetW;
    { Public declarations }
  end;

implementation

uses
  DialogUnit;

{$R *.dfm}

procedure TViewFinal.actSaveExecute(Sender: TObject);
var
  AFileName: string;
begin
  inherited;
  AFileName := GetFileName;
  if not ShowSaveDialog(AFileName) then
    Exit;

  ExportViewToExcel(MainView, AFileName);
end;

function TViewFinal.GetclDescription: TcxGridDBBandedColumn;
begin
  Result := MainView.GetColumnByFieldName(W.Description.FieldName);
end;

function TViewFinal.GetFileName: string;
var
  ADay: Word;
  AHour: Word;
  AMin: Word;
  AMonth: Word;
  AMSec: Word;
  ASec: Word;
  AYear: Word;
begin
  DecodeDate(Date, AYear, AMonth, ADay);
  DecodeTime(Time, AHour, AMin, ASec, AMSec);
  Result := Format('Harting %d-%d-%d %d-%d.xls',
    [AYear, AMonth, ADay, AHour, AMin]);
end;

function TViewFinal.GetW: TFinalW;
begin
  Result := DSWrap as TFinalW;
end;

procedure TViewFinal.InitColumns(AView: TcxGridDBBandedTableView);
begin
  clDescription.BestFitMaxWidth := 300;
  inherited;
end;

procedure TViewFinal.InitView(AView: TcxGridDBBandedTableView);
begin
  inherited;
  AView.OptionsView.CellAutoHeight := True;
end;

function TViewFinal.ShowSaveDialog(const AFileName: string): Boolean;
var
  ASaveDialog: TExcelFileSaveDialog;
begin
  ASaveDialog := TExcelFileSaveDialog.Create(Self);
  try
    ASaveDialog.FileName := AFileName;
    Result := ASaveDialog.Execute(Application.MainForm.Handle);
  finally
    FreeAndNil(ASaveDialog)
  end;
end;

end.
