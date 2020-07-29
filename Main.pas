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
  // ������ �� �����
  TCheckMethod = reference to function: Boolean;

  TMyView = class(TComponent)
  private
    FCheckMethod: TCheckMethod;
    FEnable: Boolean;
    FHRTimer: THRTimer;
    FLastApplyBestFitTime: TDateTime;
    FView: TfrmGrid;
  public
    constructor Create(AOwner: TComponent; ACheckMethod: TCheckMethod;
      AView: TfrmGrid); reintroduce;
    destructor Destroy; override;
    procedure TryApplyBestFit;
    property View: TfrmGrid read FView;
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
    procedure actContinueGrabExecute(Sender: TObject);
    procedure actStartGrabExecute(Sender: TObject);
    procedure actStopGrabExecute(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  strict private
  private
    FClosing: Boolean;
    FMyFinal: TMyView;
    FMyLog1: TMyView;
    FMyLog2: TMyView;
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
    procedure AfterLog2Post(Sender: TObject);
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
begin
  FMyFinal.TryApplyBestFit;
end;

procedure TMainForm.AfterErrorPost(Sender: TObject);
begin
  FViewErrors.MainView.ApplyBestFit;
end;

procedure TMainForm.AfterLogPost(Sender: TObject);
begin
  FMyLog1.TryApplyBestFit;
end;

procedure TMainForm.AfterLog2Post(Sender: TObject);
begin
  FMyLog2.TryApplyBestFit;
end;

procedure TMainForm.AfterSaveState(Sender: TObject);
begin
  TfrmSplash.HideWait;
end;

procedure TMainForm.ApplyBestFit;
begin
  TfrmSplash.ShowWait('�������� ����������� ������ ��������');
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
  TfrmSplash.ShowWait('��� ���������� ������������� ������');
end;

procedure TMainForm.BestFitMessage(var Message: TMessage);
begin
  inherited;
  ApplyBestFit;
end;

procedure TMainForm.cxPageControl1Change(Sender: TObject);
begin
  if cxPageControl1.ActivePage = cxTabSheetLog then
    FMyLog1.TryApplyBestFit;

  if cxPageControl1.ActivePage = cxTabSheetLog2 then
    FMyLog2.TryApplyBestFit;

  if cxPageControl1.ActivePage = cxTabSheetFinal then
    FMyFinal.TryApplyBestFit;
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

  ShowMessage('���� ���������� ��������');
end;

procedure TMainForm.DoOnManyErrors(Sender: TObject);
begin
  ShowMessage('���������� ����� ������');
  FWebGrabber.StopGrab;
end;

procedure TMainForm.DoOnStatusChange(Sender: TObject);
begin
  case FWebGrabber.Status of
    Runing:
      begin
        actStartGrab.Enabled := False;
        actContinueGrab.Enabled := False;
        actStopGrab.Caption := '����������';
        actStopGrab.Enabled := True;
      end;
    Stoping:
      begin
        actStopGrab.Enabled := False;
        actStopGrab.Caption := '��������������';
      end;
    Stoped:
      begin
        PostMessage(Handle, WM_BEST_FIT, 0, 0);
        actStartGrab.Enabled := True;
        actContinueGrab.Enabled := True;

        actStopGrab.Enabled := False;
        actStopGrab.Visible := False;
        actStopGrab.Caption := '����������';

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

  // ���� ����� ������ ������ ������� �����, �� ���������� ��� � ����� �������
  if not CanClose then
  begin
    FClosing := True;
    PostMessage(Handle, WM_NEED_STOP, 0, 0);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
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

  TNotifyEventWrap.Create(FWebGrabber.LogW.AfterPostM, AfterLogPost,
    FWebGrabber.LogW.EventList);

  TNotifyEventWrap.Create(FWebGrabber.LogW2.AfterPostM, AfterLog2Post,
    FWebGrabber.LogW2.EventList);

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

  // ���������� ����� ���� ������� ���������� ���������
  actContinueGrab.Enabled := FWebGrabber.StateExists;

  FMyFinal := TMyView.Create(Self,
    function: Boolean
    begin
      Result := cxPageControl1.ActivePage = cxTabSheetFinal;
    end, FViewFinal);

  FMyLog1 := TMyView.Create(Self,
    function: Boolean
    begin
      Result := cxPageControl1.ActivePage = cxTabSheetLog;
    end, FViewLog);

  FMyLog2 := TMyView.Create(Self,
    function: Boolean
    begin
      Result := cxPageControl1.ActivePage = cxTabSheetLog2;
    end, FViewLog2);

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

constructor TMyView.Create(AOwner: TComponent; ACheckMethod: TCheckMethod;
AView: TfrmGrid);
begin
  inherited Create(AOwner);
  FHRTimer := THRTimer.Create(False);
  FCheckMethod := ACheckMethod;
  FView := AView;
  FEnable := True;
  FLastApplyBestFitTime := 0;
end;

destructor TMyView.Destroy;
begin
  FreeAndNil(FHRTimer);
  inherited;
end;

procedure TMyView.TryApplyBestFit;
var
  d: Double;
  OK: Boolean;
begin
  if not FCheckMethod then
    Exit;

  if not FEnable then
    Exit;

  OK := (FView.MainView.ViewData.RowCount < 250) or
    (Now - FLastApplyBestFitTime > (1 / 24 / 60));

  if not OK then
    Exit;

  FLastApplyBestFitTime := Now;

  FHRTimer.StartTimer;
  FView.MainView.ApplyBestFit;
  d := FHRTimer.ReadTimer;
  FEnable := d < 500;
end;

end.
