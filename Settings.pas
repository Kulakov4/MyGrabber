unit Settings;

interface

uses
  saver, System.Classes, System.Generics.Collections;

type
  TURLs = class;

  TURLInfo = class(TCollectionItem)
  private
    FCaption: string;
    FURL: string;
  public
    constructor Create(AURLs: TURLs; const ACaption, AURL: string); reintroduce;
  published
    property Caption: string read FCaption write FCaption;
    property URL: string read FURL write FURL;
  end;

  TURLs = class(TCollection)
  private
    function GetItems(Index: Integer): TURLInfo;
  public
    procedure DeleteByCaption(const ACaption: string);
    property Items[Index: Integer]: TURLInfo read GetItems;
  published
  end;

  TWebGrabberSettings = class(TOptions)
  private
    FDownloadDocs: Boolean;
    FURLs: TURLs;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DownloadDocs: Boolean read FDownloadDocs write FDownloadDocs;
    property URLs: TURLs read FURLs write FURLs;
  end;

implementation

uses
  System.IOUtils, MyDir;

constructor TWebGrabberSettings.Create(AOwner: TComponent);
begin
  inherited;
//  FileName := TPath.Combine(TMyDir.AppDir, 'WebGrabberSettings.txt');

  DownloadDocs := True;

  FURLs := TURLs.Create(TURLInfo);
end;

procedure TURLs.DeleteByCaption(const ACaption: string);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[i].Caption = ACaption then
    begin
      Delete(I);
      break;
    end;
  end;
end;

function TURLs.GetItems(Index: Integer): TURLInfo;
begin
  Result := inherited Items[Index] as TURLInfo;
end;

constructor TURLInfo.Create(AURLs: TURLs; const ACaption, AURL: string);
begin
  inherited Create(AURLs);
  FCaption := ACaption;
  FURL := AURL;
end;

end.
