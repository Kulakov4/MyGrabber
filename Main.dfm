object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 669
  ClientWidth = 877
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 19
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 28
    Width = 877
    Height = 641
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheetCategory
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 637
    ClientRectLeft = 4
    ClientRectRight = 873
    ClientRectTop = 30
    object cxTabSheetCategory: TcxTabSheet
      Caption = #1050#1072#1090#1077#1075#1086#1088#1080#1080' '#1080' '#1087#1086#1076#1082#1072#1090#1077#1075#1086#1088#1080#1080
      ImageIndex = 0
    end
    object cxTabSheetProductList: TcxTabSheet
      Caption = #1057#1087#1080#1089#1082#1080' '#1090#1086#1074#1072#1088#1086#1074
      ImageIndex = 1
    end
  end
  object dxBarManager1: TdxBarManager
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
    Left = 480
    Top = 48
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      28
      0)
    object dxBarManager1Bar1: TdxBar
      Caption = 'Main'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 905
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton1'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarButton1: TdxBarButton
      Action = actStartGrab
      Category = 0
    end
  end
  object ActionList1: TActionList
    Left = 640
    Top = 64
    object actStartGrab: TAction
      Caption = #1053#1072#1095#1072#1090#1100
      OnExecute = actStartGrabExecute
    end
  end
end
