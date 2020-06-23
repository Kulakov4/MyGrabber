unit MyDir;

interface

type
  TMyDir = class(TObject)
  public
    class function AppDataDir: string; static;
  end;

implementation

uses
  System.IOUtils, System.SysUtils;

class function TMyDir.AppDataDir: string;
begin
  Result := TPath.GetHomePath;

  Result := TPath.Combine(Result, TPath.GetFileNameWithoutExtension
    (GetModuleName(0)));

  TDirectory.CreateDirectory(Result);
end;

end.
