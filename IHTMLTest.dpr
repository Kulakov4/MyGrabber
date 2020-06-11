program IHTMLTest;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  MyHTMLParser in 'MyHTMLParser.pas',
  WebLoaderInterface in 'WebLoaderInterface.pas',
  WebLoader in 'WebLoader.pas' {WebDM: TDataModule},
  HTMLPageParser in 'HTMLPageParser.pas',
  CategoryParser in 'CategoryParser.pas',
  CategoryInfoDataSet in 'CategoryInfoDataSet.pas',
  DSWrap in 'DSWrap.pas',
  GridFrame in 'GridFrame.pas' {frmGrid: TFrame},
  DragHelper in 'DragHelper.pas',
  ParserDataSet in 'ParserDataSet.pas',
  ProductListParser in 'ProductListParser.pas',
  ProductListInfoDataSet in 'ProductListInfoDataSet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
