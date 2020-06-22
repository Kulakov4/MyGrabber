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
  WebGrabber, NotifyEvents, FinalView;

const
  WM_NEED_STOP = WM_USER + 1;

type
  TMainForm = class(TForm, ILog)
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
    cxMemo1: TcxMemo;
    cxTabSheetProducts: TcxTabSheet;
    cxTabSheetFinal: TcxTabSheet;
    cxTabSheetErrors: TcxTabSheet;
    procedure actStartGrabExecute(Sender: TObject);
    procedure actStopGrabExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FClosing: Boolean;
    FViewCategory: TfrmGrid;
    FViewProducts: TfrmGrid;
    FViewProductList: TfrmGrid;
    FViewFinal: TViewFinal;
    FViewErrors: TfrmGrid;
    FWebGrabber: TWebGrabber;
    procedure Add(const S: string);
    procedure AfterFinalPost(Sender: TObject);
    procedure AfterErrorPost(Sender: TObject);
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

procedure TMainForm.actStartGrabExecute(Sender: TObject);
begin
  FWebGrabber.StartGrab;
end;

procedure TMainForm.actStopGrabExecute(Sender: TObject);
begin
  FWebGrabber.StopGrab;
end;

procedure TMainForm.Add(const S: string);
begin
  cxMemo1.Lines.Add(S);
end;

procedure TMainForm.AfterFinalPost(Sender: TObject);
begin
  FViewFinal.MainView.ApplyBestFit;
end;

procedure TMainForm.AfterErrorPost(Sender: TObject);
begin
  FViewErrors.MainView.ApplyBestFit;
end;

procedure TMainForm.DoOnStatusChange(Sender: TObject);
begin
  case FWebGrabber.Status of
    Runing:
      begin
        actStopGrab.Caption := 'Остановить';
        actStopGrab.Enabled := True;
        dxBarButton1.Action := actStopGrab;
      end;
    Stoping:
      begin
        actStopGrab.Enabled := False;
        actStopGrab.Caption := 'Останавливаюсь';
      end;
    Stoped:
      begin
        dxBarButton1.Action := actStartGrab;
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

  FWebGrabber := TWebGrabber.Create(Self, Self);
  TNotifyEventWrap.Create(FWebGrabber.OnStatusChange, DoOnStatusChange);

  FViewCategory.DSWrap := FWebGrabber.CategoryW;

  FViewProductList.DSWrap := FWebGrabber.ProductListW;

  FViewProducts.DSWrap := FWebGrabber.ProductW;

  FViewFinal.DSWrap := FWebGrabber.FinalW;
  TNotifyEventWrap.Create(FWebGrabber.FinalW.AfterPostM, AfterFinalPost,
    FWebGrabber.FinalW.EventList);

  FViewErrors.DSWrap := FWebGrabber.ErrorW;
  TNotifyEventWrap.Create(FWebGrabber.ErrorW.AfterPostM, AfterErrorPost,
    FWebGrabber.ErrorW.EventList);

end;

procedure TMainForm.NeedStopMsg(var Message: TMessage);
begin
  inherited;
  FWebGrabber.StopGrab;
end;

end.
