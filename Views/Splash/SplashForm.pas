unit SplashForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, Vcl.ComCtrls,
  Vcl.ExtCtrls, dxSkinsCore, dxSkinsDefaultPainters;

type
  TfrmSplash = class(TForm)
    GridPanel: TGridPanel;
    cxLabel: TcxLabel;
    ProgressBar: TProgressBar;
  private
    FTotalCount: Integer;
    { Private declarations }
  public
    class procedure ShowWait(const AMessage: String; ATotalCount: Integer = 0);
        static;
    class procedure HideWait; static;
    class procedure ShowProgress(ARecNo: Integer); static;
    { Public declarations }
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.dfm}

class procedure TfrmSplash.ShowWait(const AMessage: String; ATotalCount:
    Integer = 0);
begin
  Assert(frmSplash = nil);
  frmSplash := TfrmSplash.Create(nil);
  try
    frmSplash.FTotalCount := ATotalCount;
    frmSplash.Caption := AMessage;
    frmSplash.cxLabel.Caption := AMessage;
    if ATotalCount <= 1 then
      frmSplash.GridPanel.RowCollection.Items[1].Value := 0;
    frmSplash.Show;
    frmSplash.Update;
  except
    FreeAndNil(frmSplash);
    raise;
  end;
end;

class procedure TfrmSplash.HideWait;
begin
  Assert(frmSplash <> nil);
  try
    FreeAndNil(frmSplash);
  except
    frmSplash := nil;
    raise;
  end;
end;

class procedure TfrmSplash.ShowProgress(ARecNo: Integer);
begin
  Assert(frmSplash <> nil);
  if frmSplash.FTotalCount <= 1 then
    Exit;

  frmSplash.ProgressBar.Position :=  Round(ARecNo * 100 / frmSplash.FTotalCount);
  frmSplash.Update;
end;

end.
