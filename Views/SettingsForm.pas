unit SettingsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, dxSkinsDefaultPainters,
  cxControls, cxContainer, cxEdit, cxCheckBox, cxGroupBox, Vcl.StdCtrls,
  cxButtons, Settings, System.Actions, Vcl.ActnList;

type
  TfrmSettings = class(TForm)
    cxButton1: TcxButton;
    cxGroupBox1: TcxGroupBox;
    cxCheckBox1: TcxCheckBox;
    cxCheckBox2: TcxCheckBox;
    cxCheckBox3: TcxCheckBox;
    cxCheckBox4: TcxCheckBox;
    cxCheckBox5: TcxCheckBox;
    cxCheckBox6: TcxCheckBox;
    cxCheckBox7: TcxCheckBox;
    cxCheckBox8: TcxCheckBox;
    cxLoadDocs: TcxCheckBox;
    ActionList1: TActionList;
    actClose: TAction;
    procedure actCloseExecute(Sender: TObject);
    procedure cxCheckBox1Click(Sender: TObject);
    procedure cxCheckBox2Click(Sender: TObject);
    procedure cxCheckBox3Click(Sender: TObject);
    procedure cxCheckBox4Click(Sender: TObject);
    procedure cxCheckBox5Click(Sender: TObject);
    procedure cxCheckBox6Click(Sender: TObject);
    procedure cxCheckBox7Click(Sender: TObject);
    procedure cxCheckBox8Click(Sender: TObject);
    procedure cxLoadDocsClick(Sender: TObject);
  private
    FSettings: TWebGrabberSettings;
    { Private declarations }
  protected
    procedure UpdateView;
  public
    constructor Create(AOwner: TComponent); override;
    procedure OnCheckBoxClick(ACheckBox: TcxCheckBox; const AURL: string);
    class function ShowAsModal(ASettings: TWebGrabberSettings): Boolean; static;
    { Public declarations }
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.dfm}

constructor TfrmSettings.Create(AOwner: TComponent);
begin
  inherited;
  FSettings := AOwner as TWebGrabberSettings;
  UpdateView;
end;

procedure TfrmSettings.actCloseExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmSettings.cxCheckBox1Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/ru/ru/13991');
end;

procedure TfrmSettings.cxCheckBox2Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/en-gb/de/34260');
end;

procedure TfrmSettings.cxCheckBox3Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/ru/ru/34262');
end;

procedure TfrmSettings.cxCheckBox4Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/ru/ru/34266');
end;

procedure TfrmSettings.cxCheckBox5Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/ru/ru/37428');
end;

procedure TfrmSettings.cxCheckBox6Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/ru/ru/34261');
end;

procedure TfrmSettings.cxCheckBox7Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/ru/ru/34265');
end;

procedure TfrmSettings.cxCheckBox8Click(Sender: TObject);
begin
  OnCheckBoxClick(Sender as TcxCheckBox, 'https://b2b.harting.com/ebusiness/ru/ru/34259');
end;

procedure TfrmSettings.cxLoadDocsClick(Sender: TObject);
begin
  FSettings.DownloadDocs := (Sender as TcxCheckBox).Checked;
end;

procedure TfrmSettings.OnCheckBoxClick(ACheckBox: TcxCheckBox; const AURL:
    string);
begin
  if ACheckBox.Checked then
    TURLInfo.Create(FSettings.URLs, ACheckBox.Caption, AURL)
  else
    FSettings.URLs.DeleteByCaption(ACheckBox.Caption);

  UpdateView;
end;

class function TfrmSettings.ShowAsModal(ASettings: TWebGrabberSettings):
    Boolean;
var
  AfrmSettings: TfrmSettings;
begin
  AfrmSettings := TfrmSettings.Create(ASettings);
  try
    Result := AfrmSettings.ShowModal = mrOK;
  finally
    FreeAndNil(AfrmSettings);
  end;
end;

procedure TfrmSettings.UpdateView;
begin
  actClose.Enabled := FSettings.URLs.Count > 0;
end;

end.
