unit WebGrabberState;

interface

uses
  Status, saver, System.Classes;

type
  TWebGrabberState = class(TOptions)
  private
    FID: Integer;
    FMaxID: Integer;
    FThreadStatus: TThreadStatus;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Save(AThreadStatus: TThreadStatus; AID, AMaxID: Integer);
  published
    property ID: Integer read FID write FID;
    property MaxID: Integer read FMaxID write FMaxID;
    property ThreadStatus: TThreadStatus read FThreadStatus write FThreadStatus;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, AppDataDirHelper;

constructor TWebGrabberState.Create(AOwner: TComponent);
begin
  inherited;

  FileName := TPath.Combine(TMyDir.AppDataDir, 'WebGrabberState.dat');
end;

procedure TWebGrabberState.Save(AThreadStatus: TThreadStatus; AID, AMaxID:
    Integer);
begin
  ID := AID;
  ThreadStatus := AThreadStatus;
  MaxID := AMaxID;
  Saver.Save;
end;

end.
