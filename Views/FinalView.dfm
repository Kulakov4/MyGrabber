inherited ViewFinal: TViewFinal
  inherited cxGrid: TcxGrid
    Top = 28
    Height = 444
    ExplicitTop = 28
    ExplicitHeight = 444
  end
  inherited StatusBar: TStatusBar
    SimplePanel = True
    Visible = True
  end
  inherited dxBarManager: TdxBarManager
    Font.Charset = RUSSIAN_CHARSET
    Font.Name = 'Tahoma'
    ShowHint = True
    UseSystemFont = False
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      28
      0)
    inherited dxbrMain: TdxBar
      Images = cxImageList
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton1'
        end>
      Visible = True
    end
    object dxBarButton1: TdxBarButton
      Action = actSave
      Category = 0
      PaintStyle = psCaptionGlyph
    end
  end
  inherited ActionList: TActionList
    Images = cxImageList
    object actSave: TAction
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1076#1086#1082#1091#1084#1077#1085#1090' Excel'
      ImageIndex = 0
      OnExecute = actSaveExecute
    end
  end
  inherited cxStyleRepository: TcxStyleRepository
    PixelsPerInch = 96
  end
  object cxImageList: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 12583160
    ImageInfo = <
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000001D744558745469746C65004578706F72743B586C733B45
          78706F7274546F586C733B4CA099FE0000006249444154785EDD92410AC02010
          03FB6A5FB07FE8133CF908AF7E2A25070F81A56DC083B830ACA0C906F5022044
          041C52839F75AA01F10D4ABD61901BB0B24EDAE853F36AC083A901EB33C114B3
          AB48F7FC043AD9BA03594B82E5AFA06083AFECF000F45847D02BC325FC000000
          0049454E44AE426082}
      end>
  end
end
