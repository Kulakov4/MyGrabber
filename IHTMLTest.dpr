program IHTMLTest;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  MyHTMLParser in 'Parser\MyHTMLParser.pas',
  WebLoaderInterface in 'Interfaces\WebLoaderInterface.pas',
  WebLoader in 'Web\WebLoader.pas' {WebDM: TDataModule},
  CategoryParser in 'Parser\CategoryParser.pas',
  CategoryDataSet in 'DataSets\CategoryDataSet.pas',
  DSWrap in 'Helpers\DSWrap.pas',
  GridFrame in 'Helpers\GridFrame.pas' {frmGrid: TFrame},
  DragHelper in 'Helpers\DragHelper.pas',
  ParserDataSet in 'DataSets\ParserDataSet.pas',
  ProductListParser in 'Parser\ProductListParser.pas',
  ProductListDataSet in 'DataSets\ProductListDataSet.pas',
  URLHelper in 'Helpers\URLHelper.pas',
  GridSort in 'Helpers\GridSort.pas',
  NotifyEvents in 'Helpers\NotifyEvents.pas',
  DBRecordHolder in 'Helpers\DBRecordHolder.pas',
  PageParser in 'Parser\PageParser.pas',
  ParserManager in 'Parser\ParserManager.pas',
  ParserInterface in 'Interfaces\ParserInterface.pas',
  PageParserInterface in 'Interfaces\PageParserInterface.pas',
  Status in 'Status.pas',
  ProductParser in 'Parser\ProductParser.pas',
  ProductsDataSet in 'DataSets\ProductsDataSet.pas',
  StrHelper in 'Helpers\StrHelper.pas',
  TextRectHelper in 'Helpers\TextRectHelper.pas',
  DialogUnit in 'Helpers\DialogUnit.pas',
  DownloadManager in 'Web\DownloadManager.pas',
  DownloadManagerEx in 'Web\DownloadManagerEx.pas',
  WebLoader2 in 'Web\WebLoader2.pas',
  WebGrabber in 'WebGrabber.pas',
  LogInterface in 'Interfaces\LogInterface.pas',
  FinalDataSet in 'DataSets\FinalDataSet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
