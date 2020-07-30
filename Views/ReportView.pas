unit ReportView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GridFrame, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, dxBarBuiltInMenu,
  System.ImageList, Vcl.ImgList, cxImageList, cxGridCustomPopupMenu,
  cxGridPopupMenu, Vcl.Menus, System.Actions, Vcl.ActnList, dxBar, cxClasses,
  Vcl.ComCtrls, cxGridLevel, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridBandedTableView, cxGridDBBandedTableView, cxGrid,
  NotifyEvents, ReportDataSet;

type
  TViewReport = class(TfrmGrid)
    actRefresh: TAction;
    dxBarButton1: TdxBarButton;
    actSave: TAction;
    dxBarButton3: TdxBarButton;
    procedure actRefreshExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
  private
    FOnRefreshReport: TNotifyEventsEx;
    procedure DoAfterPost(Sender: TObject);
    function GetFileName: string;
    function GetOnRefreshReport: TNotifyEventsEx;
    function GetW: TReportW;
    procedure SetW(const Value: TReportW);
    function ShowSaveDialog(var AFileName: string): Boolean;
    { Private declarations }
  public
    destructor Destroy; override;
    property W: TReportW read GetW write SetW;
    property OnRefreshReport: TNotifyEventsEx read GetOnRefreshReport;
    { Public declarations }
  end;


implementation

uses
  DialogUnit, MyDir, ExcelDataModule;

{$R *.dfm}

destructor TViewReport.Destroy;
begin
  if FOnRefreshReport <> nil then
    FreeAndNil(FOnRefreshReport);

  inherited;
end;

procedure TViewReport.actRefreshExecute(Sender: TObject);
begin
  inherited;
  if FOnRefreshReport = nil then
    Exit;

  FOnRefreshReport.CallEventHandlers(Self);
  MainView.ApplyBestFit;
end;

procedure TViewReport.actSaveExecute(Sender: TObject);
var
  AFileName: string;
begin
  AFileName := GetFileName;
  if not ShowSaveDialog(AFileName) then
    Exit;

  MainView.ApplyBestFit;

  ExportViewToExcel(MainView, AFileName);

  // Замораживаем заголовок
  TExcelDM.FreezePanes(AFileName, 1, 0);
end;

procedure TViewReport.DoAfterPost(Sender: TObject);
begin
  StatusBar.SimpleText := Format('Всего товаров: %d', [W.DataSet.RecordCount]);
end;

function TViewReport.GetFileName: string;
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
  Result := Format('Отчёт %.*d-%.*d-%.*d %.*d-%.*d.xls',
    [4, AYear, 2, AMonth, 2, ADay, 2, AHour, 2, AMin]);
end;

function TViewReport.GetOnRefreshReport: TNotifyEventsEx;
begin
  if FOnRefreshReport = nil then
    FOnRefreshReport := TNotifyEventsEx.Create(Self);

  Result := FOnRefreshReport;
end;

function TViewReport.GetW: TReportW;
begin
  Result := DSWrap as TReportW;
end;

procedure TViewReport.SetW(const Value: TReportW);
begin
  DSWrap := Value;
  TNotifyEventWrap.Create( DSWrap.AfterPostM, DoAfterPost, DSWrap.EventList );
  DoAfterPost(nil);
end;

function TViewReport.ShowSaveDialog(var AFileName: string): Boolean;
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
