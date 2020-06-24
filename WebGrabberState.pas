unit WebGrabberState;

interface

uses
  Status, saver, System.Classes;

type
  TWebGrabberState = class(TOptions)
  private
    FDownloadDocs: Boolean;
    FID: Integer;
    FMaxID: Integer;
    FThreadStatus: TThreadStatus;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Save(AThreadStatus: TThreadStatus; AID, AMaxID: Integer;
        ADownloadDocs: Boolean);
  published
    property DownloadDocs: Boolean read FDownloadDocs write FDownloadDocs;
    property ID: Integer read FID write FID;
    property MaxID: Integer read FMaxID write FMaxID;
    property ThreadStatus: TThreadStatus read FThreadStatus write FThreadStatus;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, MyDir;

constructor TWebGrabberState.Create(AOwner: TComponent);
begin
  inherited;
  AutoSaveOptions := False;

  FileName := TPath.Combine(TMyDir.AppDataDir, 'WebGrabberState.dat');
end;

procedure TWebGrabberState.Save(AThreadStatus: TThreadStatus; AID, AMaxID:
    Integer; ADownloadDocs: Boolean);
begin
  ID := AID;
  ThreadStatus := AThreadStatus;
  MaxID := AMaxID;
  DownloadDocs := ADownloadDocs;
  Saver.Save;
end;

end.
