unit MyDir;

interface

type
  TMyDir = class(TObject)
  public
    class function AppDataDir: string; static;
    class function AppDir: string; static;
  end;

implementation

uses
  System.IOUtils, System.SysUtils;

class function TMyDir.AppDataDir: string;
begin
(*
  Result := TPath.GetHomePath;

  Result := TPath.Combine(Result, TPath.GetFileNameWithoutExtension
    (GetModuleName(0)));
*)

  Result := TPath.GetDirectoryName(GetModuleName(0));

  Result := TPath.Combine(Result, 'DAT');

  TDirectory.CreateDirectory(Result);
end;

class function TMyDir.AppDir: string;
begin
  Result := TPath.GetDirectoryName(GetModuleName(0));
end;

end.
