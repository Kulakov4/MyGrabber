object frmGrid: TfrmGrid
  Left = 0
  Top = 0
  Width = 893
  Height = 491
  TabOrder = 0
  object cxGrid: TcxGrid
    Left = 0
    Top = 0
    Width = 893
    Height = 472
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfFlat
    LookAndFeel.NativeStyle = False
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
    ShowHint = False
    UseSystemFont = True
    Left = 440
    Top = 120
    PixelsPerInch = 96
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
      ItemLinks = <>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = False
      WholeRow = False
    end
  end
  object ActionList: TActionList
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
end
