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
  FireDAC.Stan.StorageBin;

const
  WM_NEED_STOP = WM_USER + 1;

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
    dxBarButton4: TdxBarButton;
    actSave: TAction;
    actLoad: TAction;
    dxBarButton5: TdxBarButton;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDStanStorageBinLink1: TFDStanStorageBinLink;
    procedure actContinueGrabExecute(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actStartGrabExecute(Sender: TObject);
    procedure actStopGrabExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  strict private
  private
    FClosing: Boolean;
    FViewCategory: TfrmGrid;
    FViewProducts: TfrmGrid;
    FViewProductList: TfrmGrid;
    FViewFinal: TViewFinal;
    FViewErrors: TfrmGrid;
    FViewLog: TfrmGrid;
    FWebGrabber: TWebGrabber;
    procedure AfterFinalPost(Sender: TObject);
    procedure AfterErrorPost(Sender: TObject);
    procedure AfterLogPost(Sender: TObject);
    procedure DoOnManyErrors(Sender: TObject);
    procedure DoOnStatusChange(Sender: TObject);
    { Private declarations }
  protected
    procedure NeedStopMsg(var Message: TMessage); message WM_NEED_STOP;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.actContinueGrabExecute(Sender: TObject);
begin
  FWebGrabber.ContinueGrab;
  actStartGrab.Visible := False;
  actStopGrab.Visible := True;
end;

procedure TMainForm.actLoadExecute(Sender: TObject);
begin
  FWebGrabber.LoadState;
  FViewLog.MainView.ApplyBestFit;
  FViewFinal.MainView.ApplyBestFit;
  FViewErrors.MainView.ApplyBestFit;
  FViewCategory.MainView.ApplyBestFit;
  FViewProducts.MainView.ApplyBestFit;
  FViewProductList.MainView.ApplyBestFit;
end;

procedure TMainForm.actSaveExecute(Sender: TObject);
begin
  FWebGrabber.SaveState;
end;

procedure TMainForm.actStartGrabExecute(Sender: TObject);
begin
  FWebGrabber.StartGrab;
  actContinueGrab.Visible := False;
  actStopGrab.Visible := True;
end;

procedure TMainForm.actStopGrabExecute(Sender: TObject);
begin
  FWebGrabber.StopGrab;

end;

procedure TMainForm.AfterFinalPost(Sender: TObject);
begin
  FViewFinal.MainView.ApplyBestFit;
end;

procedure TMainForm.AfterErrorPost(Sender: TObject);
begin
  FViewErrors.MainView.ApplyBestFit;
end;

procedure TMainForm.AfterLogPost(Sender: TObject);
begin
  FViewLog.MainView.ApplyBestFit;
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
  FViewLog := TfrmGrid.Create(Self);
  FViewLog.Name := 'ViewLog';
  FViewLog.Place(cxTabSheetLog);

  FViewCategory := TfrmGrid.Create(Self);
  FViewCategory.Name := 'ViewCategory1';
  FViewCategory.Place(cxTabSheetCategory);

  FViewProductList := TfrmGrid.Create(Self);
  FViewProductList.Name := 'ViewProductList1';
  FViewProductList.Place(cxTabSheetProductList);

  FViewProducts := TfrmGrid.Create(Self);
  FViewProducts.Name := 'ViewProducts';
  FViewProducts.Place(cxTabSheetProducts);

  FViewFinal := TViewFinal.Create(Self);
  FViewFinal.Place(cxTabSheetFinal);

  FViewErrors := TfrmGrid.Create(Self);
  FViewErrors.Name := 'ViewErrors';
  FViewErrors.Place(cxTabSheetErrors);

  FWebGrabber := TWebGrabber.Create(Self);
  TNotifyEventWrap.Create(FWebGrabber.OnStatusChange, DoOnStatusChange);
  TNotifyEventWrap.Create(FWebGrabber.OnManyErrors, DoOnManyErrors);

  FViewLog.DSWrap := FWebGrabber.LogW;

  FViewCategory.DSWrap := FWebGrabber.CategoryW;

  FViewProductList.DSWrap := FWebGrabber.ProductListW;

  FViewProducts.DSWrap := FWebGrabber.ProductW;

  FViewFinal.W := FWebGrabber.FinalW;
  TNotifyEventWrap.Create(FWebGrabber.FinalW.AfterPostM, AfterFinalPost,
    FWebGrabber.FinalW.EventList);

  FViewErrors.DSWrap := FWebGrabber.ErrorW;
  TNotifyEventWrap.Create(FWebGrabber.ErrorW.AfterPostM, AfterErrorPost,
    FWebGrabber.ErrorW.EventList);

  TNotifyEventWrap.Create(FWebGrabber.LogW.AfterPostM, AfterLogPost,
    FWebGrabber.logW.EventList);

  actStopGrab.Enabled := False;
  actStopGrab.Visible := False;
end;

procedure TMainForm.NeedStopMsg(var Message: TMessage);
begin
  inherited;
  FWebGrabber.StopGrab;
end;

end.
