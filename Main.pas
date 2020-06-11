unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, MSHTML, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, dxSkinsDefaultPainters, cxTextEdit, cxMemo, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, Vcl.ExtCtrls,
  GridFrame, CategoryInfoDataSet, ProductListInfoDataSet;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FCategoryInfoDS: TCategoryInfoDS;
    FProductListInfoDS: TProductListInfoDS;
    FViewCategory: TfrmGrid;
    FViewProductList: TfrmGrid;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  CategoryParser, WebLoader, FireDAC.Comp.Client, ProductListParser;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FViewCategory := TfrmGrid.Create(Self);
  FViewCategory.Name := 'ViewCategory1';
  FViewCategory.Place(Panel1);

  FViewProductList := TfrmGrid.Create(Self);
  FViewProductList.Name := 'ViewProductList1';
  FViewProductList.Place(Panel2);

  FCategoryInfoDS := TCategoryInfoDS.Create(Self);
  FViewCategory.DSWrap := FCategoryInfoDS.W;

  FProductListInfoDS := TProductListInfoDS.Create(Self);
  FViewProductList.DSWrap := FProductListInfoDS.W;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  AProductListParser: TProductListParser;
  AURL: string;
  ACategoryParser: TCategoryParser;
  WW: TCategoryInfoW;
begin
  AURL := 'https://b2b.harting.com/ebusiness/ru/ru/13991';

  ACategoryParser := TCategoryParser.Create(Self, TWebDM.Instance);
  try
    ACategoryParser.Parse(AURL, FCategoryInfoDS, 0);

    WW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
    try
      WW.FilterByParentID(0);
      WW.DataSet.First;
      while not WW.DataSet.Eof do
      begin
        ACategoryParser.Parse(WW.HREF.F.AsString, FCategoryInfoDS,
          WW.ID.F.AsInteger);
        WW.DataSet.Next;
      end;
    finally
      FCategoryInfoDS.W.DropClone(WW.DataSet as TFDMemTable);
    end;
  finally
    FreeAndNil(ACategoryParser);
  end;

  AProductListParser := TProductListParser.Create(Self, TWebDM.Instance);
  try
    WW := TCategoryInfoW.Create(FCategoryInfoDS.W.AddClone(''));
    try
      WW.FilterByParentID(1);
      WW.DataSet.First;
      // while not WW.DataSet.Eof do
      // begin
      AProductListParser.Parse(WW.HREF.F.AsString, FProductListInfoDS,
        WW.ID.F.AsInteger);
      // WW.DataSet.Next;
      // end;
    finally
      FCategoryInfoDS.W.DropClone(WW.DataSet as TFDMemTable);
    end;
  finally
    FreeAndNil(AProductListParser);
  end;

  FCategoryInfoDS.First;
  FProductListInfoDS.First;
  FViewCategory.MyApplyBestFit;
  FViewProductList.MyApplyBestFit;
end;

end.
