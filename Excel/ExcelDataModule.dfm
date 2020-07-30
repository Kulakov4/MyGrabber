object ExcelDM: TExcelDM
  OldCreateOrder = False
  Height = 150
  Width = 215
  object EA: TExcelApplication
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    AutoQuit = False
    Left = 16
    Top = 16
  end
  object EWS: TExcelWorksheet
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 144
    Top = 16
  end
  object EWB: TExcelWorkbook
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 80
    Top = 16
  end
end
