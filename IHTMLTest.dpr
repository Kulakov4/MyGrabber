program IHTMLTest;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  MyHTMLParser in 'MyHTMLParser.pas',
  WebLoaderInterface in 'WebLoaderInterface.pas',
  WebLoader in 'WebLoader.pas' {WebDM: TDataModule},
  CategoryParser in 'CategoryParser.pas',
  CategoryInfoDataSet in 'CategoryInfoDataSet.pas',
  DSWrap in 'DSWrap.pas',
  GridFrame in 'GridFrame.pas' {frmGrid: TFrame},
  DragHelper in 'DragHelper.pas',
  ParserDataSet in 'ParserDataSet.pas',
  ProductListParser in 'ProductListParser.pas',
  ProductListInfoDataSet in 'ProductListInfoDataSet.pas',
  MyHTMLLoader in 'MyHTMLLoader.pas',
  URLHelper in 'URLHelper.pas',
  GridSort in 'GridSort.pas',
  NotifyEvents in 'NotifyEvents.pas',
  DBRecordHolder in 'DBRecordHolder.pas',
  PageParser in 'PageParser.pas',
  ParserManager in 'ParserManager.pas',
  ParserInterface in 'ParserInterface.pas',
  PageParserInterface in 'PageParserInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
