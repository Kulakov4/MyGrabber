unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, dxSkinsDefaultPainters, cxTextEdit, cxMemo, Vcl.ExtCtrls,
  GridFrame, dxBarBuiltInMenu, System.Actions, Vcl.ActnList, cxClasses, dxBar,
  cxPC, PageParser, cxLabel, System.Generics.Collections, Status, LogInterface,
  WebGrabber, NotifyEvents, FinalView, FireDAC.Stan.StorageJSON,
  FireDAC.Stan.StorageBin, Settings, SplashForm, HRTimer;

{$DEFINE MYDEBUG}

const
  WM_NEED_STOP = WM_USER + 1;
  WM_BEST_FIT = WM_USER + 2;

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
    actStopGrab: TAction;
    cxTabSheetLog: TcxTabSheet;
    cxTabSheetProducts: TcxTabSheet;
    cxTabSheetFinal: TcxTabSheet;
    cxTabSheetErrors: TcxTabSheet;
    actContinueGrab: TAction;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDStanStorageBinLink1: TFDStanStorageBinLink;
    cxTabSheetLog2: TcxTabSheet;
    procedure FormDestroy(Sender: TObject);
    procedure actContinueGrabExecute(Sender: TObject);
    procedure actStartGrabExecute(Sender: TObject);
    procedure actStopGrabExecute(Sender: TObject);
    procedure cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  strict private
  private
    FAfterLogPostEnable: Boolean;
    FAfterFinalPostEnable: Boolean;
    FClosing: Boolean;
    FHRTimer: THRTimer;
    FLastFinalPostTime: TDateTime;
    FLastLogPostTime: TDateTime;
    FSettings: TWebGrabberSettings;
{$IFDEF MYDEBUG}
    FViewCategory: TfrmGrid;
    FViewProducts: TfrmGrid;
    FViewProductList: TfrmGrid;
{$ENDIF}
    FViewFinal: TViewFinal;
    FViewErrors: TfrmGrid;
    FViewLog: TfrmGrid;
    FViewLog2: TfrmGrid;
    FWebGrabber: TWebGrabber;
    procedure AfterFinalPost(Sender: TObject);
    procedure AfterErrorPost(Sender: TObject);
    procedure AfterLogPost(Sender: TObject);
    procedure AfterSaveState(Sender: TObject);
    procedure ApplyBestFit;
    procedure BeforeSaveState(Sender: TObject);
    procedure DisableAllDataSource;
    procedure DoOnGrabComplete(Sender: TObject);
    procedure DoOnManyErrors(Sender: TObject);
    procedure DoOnStatusChange(Sender: TObject);
    procedure OnNewPage(NewPage: TcxTabSheet);
    { Private declarations }
  protected
    procedure BestFitMessage(var Message: TMessage); message WM_BEST_FIT;
    procedure NeedStopMsg(var Message: TMessage); message WM_NEED_STOP;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  SettingsForm;

{$R *.dfm}

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FHRTimer);
end;

procedure TMainForm.actContinueGrabExecute(Sender: TObject);
begin
  if not FWebGrabber.ContinueGrab then
    Exit;
  actStartGrab.Visible := False;
  actStopGrab.Visible := True;
end;

procedure TMainForm.actStartGrabExecute(Sender: TObject);
begin
  if FSettings <> nil then
    FreeAndNil(FSettings);

  FSettings := TWebGrabberSettings.Create(nil);

  if not TfrmSettings.ShowAsModal(FSettings) then
    Exit;

  FWebGrabber.StartGrab(FSettings);
  actContinueGrab.Visible := False;
  actStopGrab.Visible := True;
end;

procedure TMainForm.actStopGrabExecute(Sender: TObject);
begin
  FWebGrabber.StopGrab;

end;

procedure TMainForm.AfterFinalPost(Sender: TObject);
var
  d: Double;
  T: TDateTime;
begin
  if not FAfterFinalPostEnable then
    Exit;

  T := Now;

  if (T - FLastFinalPostTime < (1 / 24 / 60)) and
    (FViewFinal.MainView.ViewData.RowCount > 1) then
    Exit;

  FLastFinalPostTime := T;

  // TfrmSplash.ShowWait('Подбираю оптимальную ширину столбцов');
  FHRTimer.StartTimer;
  FViewFinal.MainView.ApplyBestFit;
  d := FHRTimer.ReadTimer;
  FAfterFinalPostEnable := d < 500;
  // TfrmSplash.HideWait;
end;

procedure TMainForm.AfterErrorPost(Sender: TObject);
begin
  FViewErrors.MainView.ApplyBestFit;
end;

procedure TMainForm.AfterLogPost(Sender: TObject);
var
  d: Double;
  T: TDateTime;
begin
  if not FAfterLogPostEnable then
    Exit;

  T := Now;

  if (T - FLastLogPostTime < (1 / 24 / 60 / 3)) and
    (FViewLog.MainView.ViewData.RowCount > 1) then
    Exit;

  FLastLogPostTime := T;

  // TfrmSplash.ShowWait('Подбираю оптимальную ширину столбцов');

  // FHRTimer.StartTimer;
  FViewLog.MainView.ApplyBestFit;
  d := FHRTimer.ReadTimer;
  FAfterLogPostEnable := d < 500;
  // TfrmSplash.HideWait;
end;

procedure TMainForm.AfterSaveState(Sender: TObject);
begin
  TfrmSplash.HideWait;
end;

procedure TMainForm.ApplyBestFit;
begin
  TfrmSplash.ShowWait('Подбираю оптимальную ширину столбцов');
  FViewLog.MainView.ApplyBestFit;
  FViewLog2.MainView.ApplyBestFit;
  FViewFinal.MainView.ApplyBestFit;
  FViewErrors.MainView.ApplyBestFit;
{$IFDEF MYDEBUG}
  FViewCategory.MainView.ApplyBestFit;
  FViewProducts.MainView.ApplyBestFit;
  FViewProductList.MainView.ApplyBestFit;
{$ENDIF}
  TfrmSplash.HideWait;
end;

procedure TMainForm.BeforeSaveState(Sender: TObject);
begin
  TfrmSplash.ShowWait('Идёт сохранение промежуточных данных');
end;

procedure TMainForm.BestFitMessage(var Message: TMessage);
begin
  inherited;
  ApplyBestFit;
end;

procedure TMainForm.cxPageControl1PageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  DisableAllDataSource;
  OnNewPage(NewPage);
end;

procedure TMainForm.DisableAllDataSource;
begin
  FWebGrabber.LogW.DataSource.Enabled := False;
  FWebGrabber.LogW2.DataSource.Enabled := False;
  FWebGrabber.CategoryW.DataSource.Enabled := False;
  FWebGrabber.ProductListW.DataSource.Enabled := False;
  FWebGrabber.ProductW.DataSource.Enabled := False;
  FWebGrabber.FinalW.DataSource.Enabled := False;
end;

procedure TMainForm.DoOnGrabComplete(Sender: TObject);
begin
  ApplyBestFit;

  ShowMessage('Сбор информации закончен');
end;

procedure TMainForm.DoOnManyErrors(Sender: TObject);
begin
  ShowMessage('Обнаружено много ошибок');
  FWebGrabber.StopGrab;
end;

procedure TMainForm.DoOnStatusChange(Sender: TObject);
begin
  case FWebGrabber.Status of
    Runing:
      begin
        actStartGrab.Enabled := False;
        actContinueGrab.Enabled := False;
        actStopGrab.Caption := 'Остановить';
        actStopGrab.Enabled := True;
      end;
    Stoping:
      begin
        actStopGrab.Enabled := False;
        actStopGrab.Caption := 'Останавливаюсь';
      end;
    Stoped:
      begin
        PostMessage(Handle, WM_BEST_FIT, 0, 0);
        actStartGrab.Enabled := True;
        actContinueGrab.Enabled := True;

        actStopGrab.Enabled := False;
        actStopGrab.Visible := False;
        actStopGrab.Caption := 'Остановить';

        actStartGrab.Visible := True;
        actContinueGrab.Visible := True;

        if FClosing then
          Close;
      end;
  end;

end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FWebGrabber.Status = Stoped;

  // Если прямо сейчас нельзя закрыть форму, то запоминаем что её нужно закрыть
  if not CanClose then
  begin
    FClosing := True;
    PostMessage(Handle, WM_NEED_STOP, 0, 0);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FHRTimer := THRTimer.Create(False);

{$IFNDEF MYDEBUG}
  cxTabSheetCategory.Free;
  cxTabSheetProductList.Free;
  cxTabSheetProducts.Free;
{$ENDIF}
  FWebGrabber := TWebGrabber.Create(Self);
  TNotifyEventWrap.Create(FWebGrabber.OnStatusChange, DoOnStatusChange);
  TNotifyEventWrap.Create(FWebGrabber.OnManyErrors, DoOnManyErrors);
  TNotifyEventWrap.Create(FWebGrabber.OnGrabComplete, DoOnGrabComplete);
  TNotifyEventWrap.Create(FWebGrabber.BeforeSaveState, BeforeSaveState);
  TNotifyEventWrap.Create(FWebGrabber.AfterSaveState, AfterSaveState);

  DisableAllDataSource;

  FViewLog := TfrmGrid.Create(Self);
  FViewLog.Name := 'ViewLog';
  FViewLog.Place(cxTabSheetLog);
  FViewLog.DSWrap := FWebGrabber.LogW;

  FViewLog2 := TfrmGrid.Create(Self);
  FViewLog2.Name := 'ViewLog2';
  FViewLog2.Place(cxTabSheetLog2);
  FViewLog2.DSWrap := FWebGrabber.LogW2;

  FAfterLogPostEnable := True;
  TNotifyEventWrap.Create(FWebGrabber.LogW.AfterPostM, AfterLogPost,
    FWebGrabber.LogW.EventList);

{$IFDEF MYDEBUG}
  FViewCategory := TfrmGrid.Create(Self);
  FViewCategory.Name := 'ViewCategory1';
  FViewCategory.Place(cxTabSheetCategory);
  FViewCategory.DSWrap := FWebGrabber.CategoryW;

  FViewProductList := TfrmGrid.Create(Self);
  FViewProductList.Name := 'ViewProductList1';
  FViewProductList.Place(cxTabSheetProductList);
  FViewProductList.DSWrap := FWebGrabber.ProductListW;

  FViewProducts := TfrmGrid.Create(Self);
  FViewProducts.Name := 'ViewProducts';
  FViewProducts.Place(cxTabSheetProducts);
  FViewProducts.DSWrap := FWebGrabber.ProductW;
{$ENDIF}
  FViewFinal := TViewFinal.Create(Self);
  FViewFinal.Place(cxTabSheetFinal);
  FViewFinal.W := FWebGrabber.FinalW;
  FAfterFinalPostEnable := True;
  TNotifyEventWrap.Create(FWebGrabber.FinalW.AfterPostM, AfterFinalPost,
    FWebGrabber.FinalW.EventList);

  FViewErrors := TfrmGrid.Create(Self);
  FViewErrors.Name := 'ViewErrors';
  FViewErrors.Place(cxTabSheetErrors);
  FViewErrors.DSWrap := FWebGrabber.ErrorW;
  TNotifyEventWrap.Create(FWebGrabber.ErrorW.AfterPostM, AfterErrorPost,
    FWebGrabber.ErrorW.EventList);

  actStopGrab.Enabled := False;
  actStopGrab.Visible := False;

  // Продолжить можем если найдено предыдущее состояние
  actContinueGrab.Enabled := FWebGrabber.StateExists;

  OnNewPage(cxPageControl1.ActivePage);
end;

procedure TMainForm.NeedStopMsg(var Message: TMessage);
begin
  inherited;
  FWebGrabber.StopGrab;
end;

procedure TMainForm.OnNewPage(NewPage: TcxTabSheet);
begin
  if NewPage = cxTabSheetLog then
    FWebGrabber.LogW.DataSource.Enabled := True;

  if NewPage = cxTabSheetLog2 then
    FWebGrabber.LogW2.DataSource.Enabled := True;

  if NewPage = cxTabSheetCategory then
    FWebGrabber.CategoryW.DataSource.Enabled := True;

  if NewPage = cxTabSheetProductList then
    FWebGrabber.ProductListW.DataSource.Enabled := True;

  if NewPage = cxTabSheetProducts then
    FWebGrabber.ProductW.DataSource.Enabled := True;

  if NewPage = cxTabSheetFinal then
    FWebGrabber.FinalW.DataSource.Enabled := True;
end;

end.
