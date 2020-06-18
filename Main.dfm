object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 669
  ClientWidth = 877
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 18
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 28
    Width = 877
    Height = 641
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheetLog
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 637
    ClientRectLeft = 4
    ClientRectRight = 873
    ClientRectTop = 29
    object cxTabSheetLog: TcxTabSheet
      Caption = #1046#1091#1088#1085#1072#1083' '#1089#1086#1073#1099#1090#1080#1081
      ImageIndex = 2
      object cxMemo1: TcxMemo
        Left = 0
        Top = 0
        Align = alClient
        TabOrder = 0
        Height = 608
        Width = 869
      end
    end
    object cxTabSheetCategory: TcxTabSheet
      Caption = #1050#1072#1090#1077#1075#1086#1088#1080#1080' '#1080' '#1087#1086#1076#1082#1072#1090#1077#1075#1086#1088#1080#1080
      ImageIndex = 0
    end
    object cxTabSheetProductList: TcxTabSheet
      Caption = #1057#1087#1080#1089#1082#1080' '#1090#1086#1074#1072#1088#1086#1074
      ImageIndex = 1
    end
    object cxTabSheetProducts: TcxTabSheet
      Caption = #1058#1086#1074#1072#1088#1099
      ImageIndex = 3
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
    object actStopGrab: TAction
      Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
      OnExecute = actStopGrabExecute
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 176
    Top = 40
  end
end
