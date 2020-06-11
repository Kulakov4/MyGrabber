unit CategoryInfoDataSet;

interface

uses
  FireDAC.Comp.DataSet, DSWrap, System.Classes, FireDAC.Comp.Client,
  ParserDataSet;

type
  TCategoryInfoW = class(TParserW)
  private
    FCaption: TFieldWrap;
    FHREF: TFieldWrap;
    FParentID: TFieldWrap;
  public
    constructor Create(AOwner: TComponent); override;
    procedure FilterByParentID(AParentID: Integer);
    property Caption: TFieldWrap read FCaption;
    property HREF: TFieldWrap read FHREF;
    property ParentID: TFieldWrap read FParentID;
  end;

  TCategoryInfoDS = class(TParserDS)
  private
    FW: TCategoryInfoW;
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TCategoryInfoW read FW;
  end;

implementation

uses
  Data.DB, System.SysUtils;

constructor TCategoryInfoW.Create(AOwner: TComponent);
begin
  inherited;
  FParentID := TFieldWrap.Create(Self, 'ParentID', '��� ��������');
  FHREF := TFieldWrap.Create(Self, 'HREF', '������');
  FCaption := TFieldWrap.Create(Self, 'Caption', '������������');
end;

procedure TCategoryInfoW.FilterByParentID(AParentID: Integer);
begin
  DataSet.Filter := Format('%s = %d', [ParentID.FieldName, AParentID]);
  DataSet.Filtered := True;
end;

constructor TCategoryInfoDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TCategoryInfoW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.Caption.FieldName, ftWideString, 200);
  FieldDefs.Add(W.FHREF.FieldName, ftWideString, 100);
  FieldDefs.Add(W.ParentID.FieldName, ftInteger);

  CreateDataSet;

end;

function TCategoryInfoDS.CreateWrap: TParserW;
begin
  Result := TCategoryInfoW.Create(Self);
end;

end.
