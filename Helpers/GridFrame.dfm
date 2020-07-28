object frmGrid: TfrmGrid
  Left = 0
  Top = 0
  Width = 893
  Height = 491
  TabOrder = 0
  object cxGrid: TcxGrid
    Left = 0
    Top = 28
    Width = 893
    Height = 444
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfFlat
    LookAndFeel.NativeStyle = False
    ExplicitTop = 0
    ExplicitHeight = 472
    object cxGridDBBandedTableView: TcxGridDBBandedTableView
      OnKeyDown = cxGridDBBandedTableViewKeyDown
      OnMouseDown = cxGridDBBandedTableViewMouseDown
      Navigator.Buttons.CustomButtons = <>
      OnEditKeyDown = cxGridDBBandedTableViewEditKeyDown
      OnSelectionChanged = cxGridDBBandedTableViewSelectionChanged
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      DataController.OnDetailExpanded = cxGridDBBandedTableViewDataControllerDetailExpanded
      OptionsBehavior.CopyCaptionsToClipboard = False
      OptionsCustomize.ColumnSorting = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.CellMultiSelect = True
      OptionsSelection.InvertSelect = False
      OptionsView.GroupByBox = False
      OptionsView.BandHeaders = False
      Styles.OnGetHeaderStyle = cxGridDBBandedTableViewStylesGetHeaderStyle
      OnCustomDrawColumnHeader = cxGridDBBandedTableViewCustomDrawColumnHeader
      Bands = <
        item
        end>
    end
    object cxGridLevel: TcxGridLevel
      GridView = cxGridDBBandedTableView
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 472
    Width = 893
    Height = 19
    Panels = <>
    Visible = False
    OnResize = StatusBarResize
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 440
    Top = 120
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      28
      0)
    object dxbrMain: TdxBar
      Caption = 'Main'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 903
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      Images = cxImageList10
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton2'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarButton2: TdxBarButton
      Action = actApplyBestFit
      Category = 0
    end
  end
  object ActionList: TActionList
    Images = cxImageList10
    Left = 512
    Top = 120
    object actCopyToClipboard: TAction
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      Hint = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      ImageIndex = 12
      OnExecute = actCopyToClipboardExecute
    end
    object actDeleteEx: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Hint = #1059#1076#1072#1083#1080#1090#1100
      ImageIndex = 2
      OnExecute = actDeleteExExecute
    end
    object actApplyBestFit: TAction
      Caption = #1055#1086#1076#1086#1073#1088#1072#1090#1100' '#1086#1087#1090#1080#1084#1072#1083#1100#1085#1091#1102' '#1096#1080#1088#1080#1085#1091' '#1082#1086#1083#1086#1085#1086#1082
      Hint = #1055#1086#1076#1086#1073#1088#1072#1090#1100' '#1086#1087#1090#1080#1084#1072#1083#1100#1085#1091#1102' '#1096#1080#1088#1080#1085#1091' '#1082#1086#1083#1086#1085#1086#1082
      ImageIndex = 0
      OnExecute = actApplyBestFitExecute
    end
  end
  object pmGrid: TPopupMenu
    Left = 440
    Top = 184
    object N1: TMenuItem
      Action = actCopyToClipboard
    end
  end
  object cxGridPopupMenu: TcxGridPopupMenu
    Grid = cxGrid
    PopupMenus = <
      item
        GridView = cxGridDBBandedTableView
        HitTypes = [gvhtCell]
        Index = 0
        PopupMenu = pmGrid
      end>
    OnPopup = cxGridPopupMenuPopup
    Left = 512
    Top = 184
  end
  object cxStyleRepository: TcxStyleRepository
    Left = 40
    Top = 64
    PixelsPerInch = 96
    object cxHeaderStyle: TcxStyle
      AssignedValues = [svColor]
      Color = clActiveCaption
    end
  end
  object cxImageList10: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 9437360
    ImageInfo = <
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C00000017744558745469746C6500426573744669743B4669743B
          477269643BD86A6B8B0000016149444154785EA593BD6ADC401446CF1D69F383
          BBA4CC9B381007B6C86BB8741F8C3B895D7095260F90CA2FE017B0B1D96EDFC0
          A953A4721148F05A33733F83060609138CF1857B117738673E9064927849D9E3
          7E5CFFD93BE006345F7F6C2F2D3407082803CD07687682E7B4F97EF471D902CD
          CDCFDF07A7275F08C10A2C5021AA43133C6771DC9F7F02DA16083126FEDE277E
          DDDEB168026D63042B2D3402298B213943763EBC7B434A0920B480C521723F38
          7FFE45546F557DAE3B841CDEEF2D48712A88A9D8A3230A58218117BA8A870C39
          67006B01DF65BBEEBF5D7CE619A5576F3740322000AF8105604FBFBE1A26023B
          93C4FEF2509AC335BF668C81EA4EDBAB336B01DC7DC2A933B1AE201391E8406B
          A96663221082CE60E5B02E9CA67140AC8451243341AE796580545124CACE3084
          60C5D89A0B0CCC61654E27309B7D81A5BC506B508F5015C81D61207A3715D0C6
          0112E5084658EA81AA7DF1EFFC0090B9E8A9E752FBFE0000000049454E44AE42
          6082}
      end>
  end
end
