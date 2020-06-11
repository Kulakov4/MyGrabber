unit ProductListInfoDataSet;

interface

uses
  ParserDataSet, DSWrap, System.Classes;

type
  TProductListInfoW = class(TParserW)
  private
    FHREF: TFieldWrap;
    FItemNumber: TFieldWrap;
    FCaption: TFieldWrap;
    FParentID: TFieldWrap;
  public
    constructor Create(AOwner: TComponent); override;
    property HREF: TFieldWrap read FHREF;
    property ItemNumber: TFieldWrap read FItemNumber;
    property Caption: TFieldWrap read FCaption;
    property ParentID: TFieldWrap read FParentID;
  end;

  TProductListInfoDS = class(TParserDS)
  private
    FW: TProductListInfoW;
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TProductListInfoW read FW;
  end;
implementation

uses
  Data.DB;

constructor TProductListInfoW.Create(AOwner: TComponent);
begin
  inherited;
  FParentID := TFieldWrap.Create(Self, 'ParentID', 'Код родителя');
  FHREF := TFieldWrap.Create(Self, 'HREF', 'Ссылка');
  FItemNumber := TFieldWrap.Create(Self, 'ItemNumber', 'Артикул');
  FCaption := TFieldWrap.Create(Self, 'Caption', 'Наименование');
end;

constructor TProductListInfoDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TProductListInfoW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.FHREF.FieldName, ftWideString, 100);
  FieldDefs.Add(W.ItemNumber.FieldName, ftWideString, 30);
  FieldDefs.Add(W.Caption.FieldName, ftWideString, 100);
  FieldDefs.Add(W.ParentID.FieldName, ftInteger);

  CreateDataSet;
end;

function TProductListInfoDS.CreateWrap: TParserW;
begin
  Result := TProductListInfoW.Create(Self);
end;

end.
