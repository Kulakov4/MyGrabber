unit ProductParser;

interface

uses
  System.Classes, ParserInterface, DSWrap, MSHTML, ProductsDataSet,
  MyHTMLParser, System.Generics.Collections;

type
  TProductParser = class(TComponent, IParser)
  strict private
    function GetW: TDSWrap;
    procedure Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
      AParentID: Integer);
  private
    FProductsDS: TProductsDS;
    FSpecifications: TList<String>;
    FDrawings: TList<String>;
    FTemperatureList: TList<String>;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property W: TDSWrap read GetW;
  end;

implementation

uses
  System.Variants, System.SysUtils, URLHelper;

constructor TProductParser.Create(AOwner: TComponent);
begin
  inherited;
  FProductsDS := TProductsDS.Create(Self);

  FSpecifications := TList<String>.Create;
  FSpecifications.Add('������������');
  FSpecifications.Add('Datenblatt');

  FDrawings := TList<String>.Create;
  FDrawings.Add('�����');
  FDrawings.Add('Typenblatt');

  FTemperatureList := TList<String>.Create;
  FTemperatureList.Add('���������� �����������');
  FTemperatureList.Add('������� �����������');
  FTemperatureList.Add('Grenztemperatur ��');
  FTemperatureList.Add('����������� ���������� �����');
  FTemperatureList.Add('Betriebstemperatur');
end;

destructor TProductParser.Destroy;
begin
  FreeAndNil(FSpecifications);
  FreeAndNil(FDrawings);
  inherited;
end;

function TProductParser.GetW: TDSWrap;
begin
  Result := FProductsDS.W;
end;

procedure TProductParser.Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
  AParentID: Integer);
var
  A: IHTMLElement;
  AList: TArray<IHTMLElement>;
  ADataDownload: OleVariant;
  ADIV: TArray<IHTMLElement>;
  AFileNameURL: string;
  LI: IHTMLElement;
  AHTMLImgElement: IHTMLImgElement;
  AIMG: TArray<IHTMLElement>;
  B: TArray<IHTMLElement>;
  LIList: TArray<IHTMLElement>;
  P: TArray<IHTMLElement>;
  S: string;
  SPAN: TArray<IHTMLElement>;
  SPAN2: TArray<IHTMLElement>;
  UL: TArray<IHTMLElement>;
begin
  FProductsDS.EmptyDataSet;

  FProductsDS.W.TryAppend;
  try
    P := TMyHTMLParser.Parse(AHTMLDocument.all, 'P',
      'product-info__short-description', 1);
    FProductsDS.W.Description.F.AsString := P[0].innerText;

    // �������� ���� � ������������ ������
    ADIV := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV',
      'product-image-block', 1);

    ADIV := TMyHTMLParser.Parse(ADIV[0].all as IHTMLElementCollection, 'DIV',
      'product-image-block__image', 1);

    AIMG := TMyHTMLParser.Parse(ADIV[0].all as IHTMLElementCollection, 'IMG',
      'product-image-block__image-element');

    // ���� ����� ����-�� ���� ��������
    if Length(AIMG) > 0 then
    begin
      AHTMLImgElement := AIMG[0] as IHTMLImgElement;
      FProductsDS.W.ImageURL.F.AsString :=
        TURLHelper.GetURL(AHTMLImgElement.src);

      // ���� ����������� �����������
      if FProductsDS.W.ImageURL.F.AsString.StartsWith
        ('/_ui/desktop/common/images/') then
        FProductsDS.W.ImageURL.F.AsString := '';
    end;

    // �������� ���� � ���������
    P := TMyHTMLParser.Parse(AHTMLDocument.all as IHTMLElementCollection, 'P',
      'product-info__part-number-label', 1);

    B := TMyHTMLParser.Parse(P[0].all as IHTMLElementCollection, 'B',
      'product-info__part-number', 1);

    FProductsDS.W.ItemNumber.F.AsString := B[0].innerText;

    // �������� ������ ��������. �� ������ ���� ���� ��� ��� (����������� �����������)
    UL := TMyHTMLParser.Parse(AHTMLDocument.all, 'UL', 'downloads-list-block');

    if Length(UL) > 0 then
    begin

      // �������� ��� �������� ������
      LIList := TMyHTMLParser.Parse(UL[0].all as IHTMLElementCollection, 'LI',
        'downloads-list-item-block');
      for LI in LIList do
      begin
        // ���� ������ �� ������������
        AList := TMyHTMLParser.Parse(LI.all as IHTMLElementCollection, 'A',
          'downloads-format-icons__element');

        for A in AList do
        begin
          ADataDownload := A.getAttribute('data-download', 0);
          if VarIsNull(ADataDownload) then
            Continue;

          AFileNameURL := ADataDownload;

          AFileNameURL := TURLHelper.GetURL(AFileNameURL);

          // �� ����� ������ PDF-��
          if not AFileNameURL.EndsWith('.pdf', True) then
            Continue;

          SPAN := TMyHTMLParser.Parse(LI.all as IHTMLElementCollection, 'SPAN',
            'downloads-list-item-block__titel', 1);

          S := SPAN[0].innerText;

          // ���� ��� �������� ������������
          if FSpecifications.IndexOf(S) >= 0 then
            FProductsDS.W.SpecificationURL.F.AsString := AFileNameURL;

          // ���� ��� �������� �������
          if FDrawings.IndexOf(S) >= 0 then
            FProductsDS.W.DrawingURL.F.AsString := AFileNameURL;
        end;

      end;
    end;

    // ������� ����� ���� � ������������ ����������������
    ADIV := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV',
      'technical-data-categorie-table-block-list-wrapper');
    if Length(ADIV) > 0 then
    begin
      // ������� ����� ������ ����������� �������������
      UL := TMyHTMLParser.Parse(ADIV[0].all as IHTMLElementCollection, 'UL',
        'technical-data-categorie-table-block-list');
      if Length(UL) > 0 then
      begin
        // �������� �������� ������ ����������� �������������
        LIList := TMyHTMLParser.Parse(UL[0].all as IHTMLElementCollection, 'LI',
          'technical-data-categorie-table-block-row');
        for LI in LIList do
        begin
          // ���� ���� ����������� ��������������
          SPAN := TMyHTMLParser.Parse(LI.all as IHTMLElementCollection, 'SPAN',
            'technical-data-categorie-table-block-row__inner-element technical-data-categorie-table-block-row__inner-element--first-child');
          if Length(SPAN) > 0 then
          begin
            S := SPAN[0].innerText;
            // ���� ��� �������� �������������� ���������
            if FTemperatureList.IndexOf(S) >= 0 then
            begin
              // ���� ���� �������� ����������� ��������������
              SPAN2 := TMyHTMLParser.Parse(LI.all as IHTMLElementCollection,
                'SPAN', 'technical-data-categorie-table-block-row__inner-element');
              if Length(SPAN2) > 0 then
              begin
                S := SPAN2[0].innerText;
                FProductsDS.W.TemperatureRange.F.AsString := S;
              end;
            end;
          end;
        end;
      end;
    end;
    FProductsDS.W.ParentID.F.AsInteger := AParentID;
    FProductsDS.W.TryPost;
  except
    FProductsDS.W.TryCancel;
    raise;
  end;
end;

end.
