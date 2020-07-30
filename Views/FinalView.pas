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
  cxImageList, cxDataControllerConditionalFormattingRulesManagerDialog,
  NotifyEvents;

type
  TViewFinal = class(TfrmGrid)
    actSave: TAction;
    dxBarButton1: TdxBarButton;
    procedure actSaveExecute(Sender: TObject);
  private
    procedure DoAfterPost(Sender: TObject);
    function GetclDescription: TcxGridDBBandedColumn;
    function GetFileName: string;
    function GetW: TFinalW;
    procedure SetW(const Value: TFinalW);
    function ShowSaveDialog(var AFileName: string): Boolean;
    { Private declarations }
  protected
    procedure InitColumns(AView: TcxGridDBBandedTableView); override;
  public
    procedure InitView(AView: TcxGridDBBandedTableView); override;
    property clDescription: TcxGridDBBandedColumn read GetclDescription;
    property W: TFinalW read GetW write SetW;
    { Public declarations }
  end;

implementation

uses
  DialogUnit, System.IOUtils, MyDir, ExcelDataModule;

{$R *.dfm}

procedure TViewFinal.actSaveExecute(Sender: TObject);
var
  AFileName: string;
begin
  inherited;
  AFileName := GetFileName;
  if not ShowSaveDialog(AFileName) then
    Exit;

  MainView.ApplyBestFit;

  ExportViewToExcel(MainView, AFileName);

  // Замораживаем заголовок
  TExcelDM.FreezePanes(AFileName, 1, 0);
end;

procedure TViewFinal.DoAfterPost(Sender: TObject);
begin
  StatusBar.SimpleText := Format('Всего товаров: %d', [W.DataSet.RecordCount]);
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
  Result := Format('Harting %.*d-%.*d-%.*d %.*d-%.*d.xls',
    [4, AYear, 2, AMonth, 2, ADay, 2, AHour, 2, AMin]);
end;

function TViewFinal.GetW: TFinalW;
begin
  Result := DSWrap as TFinalW;
end;

procedure TViewFinal.InitColumns(AView: TcxGridDBBandedTableView);
begin
  clDescription.BestFitMaxWidth := 400;
  inherited;
end;

procedure TViewFinal.InitView(AView: TcxGridDBBandedTableView);
begin
  inherited;
  AView.OptionsView.CellAutoHeight := True;
end;

procedure TViewFinal.SetW(const Value: TFinalW);
begin
  DSWrap := Value;
  TNotifyEventWrap.Create( DSWrap.AfterPostM, DoAfterPost, DSWrap.EventList );
  DoAfterPost(nil);
end;

function TViewFinal.ShowSaveDialog(var AFileName: string): Boolean;
var
  ASaveDialog: TExcelFileSaveDialog;
begin
  ASaveDialog := TExcelFileSaveDialog.Create(Self);
  try
    ASaveDialog.InitialDir := TMyDir.AppDir;
    ASaveDialog.FileName := AFileName;
    Result := ASaveDialog.Execute(Application.MainForm.Handle);
    AFileName := ASaveDialog.FileName;
  finally
    FreeAndNil(ASaveDialog)
  end;
end;

end.
