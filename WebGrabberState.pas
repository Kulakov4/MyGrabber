unit WebGrabberState;

interface

uses
  Status, saver, System.Classes;

type
  TWebGrabberState = class(TOptions)
  private
    FID: Integer;
    FThreadStatus: TThreadStatus;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Save(AThreadStatus: TThreadStatus; AID: Integer);
  published
    property ID: Integer read FID write FID;
    property ThreadStatus: TThreadStatus read FThreadStatus write FThreadStatus;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

constructor TWebGrabberState.Create(AOwner: TComponent);
var
  AppDataDir: string;
begin
  inherited;
  AppDataDir := TPath.GetHomePath;

  AppDataDir := TPath.Combine(AppDataDir,
    TPath.GetFileNameWithoutExtension(GetModuleName(0)));

  TDirectory.CreateDirectory(AppDataDir);
  FileName := TPath.Combine(AppDataDir, 'WebGrabberState');
end;

procedure TWebGrabberState.Save(AThreadStatus: TThreadStatus; AID: Integer);
begin
  ID := AID;
  ThreadStatus := AThreadStatus;
  Saver.Save;
end;

end.
