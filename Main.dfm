object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Harting.com'
  ClientHeight = 669
  ClientWidth = 1008
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 18
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 28
    Width = 1008
    Height = 641
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheetLog
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 637
    ClientRectLeft = 4
    ClientRectRight = 1004
    ClientRectTop = 29
    object cxTabSheetLog: TcxTabSheet
      Caption = #1046#1091#1088#1085#1072#1083' '#1089#1086#1073#1099#1090#1080#1081
      ImageIndex = 2
    end
    object cxTabSheetCategory: TcxTabSheet
      Caption = #1050#1072#1090#1077#1075#1086#1088#1080#1080' '#1080' '#1087#1086#1076#1082#1072#1090#1077#1075#1086#1088#1080#1080
      ImageIndex = 0
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object cxTabSheetProductList: TcxTabSheet
      Caption = #1057#1087#1080#1089#1082#1080' '#1090#1086#1074#1072#1088#1086#1074
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object cxTabSheetProducts: TcxTabSheet
      Caption = #1058#1086#1074#1072#1088#1099
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object cxTabSheetFinal: TcxTabSheet
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object cxTabSheetErrors: TcxTabSheet
      Caption = #1054#1096#1080#1073#1082#1080
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
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
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarButton3'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = True
      Visible = True
      WholeRow = False
    end
    object dxBarButton1: TdxBarButton
      Action = actStartGrab
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = actContinueGrab
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Action = actStopGrab
      Category = 0
    end
  end
  object ActionList1: TActionList
    Left = 640
    Top = 64
    object actStartGrab: TAction
      Caption = #1053#1086#1074#1099#1081' '#1089#1073#1086#1088
      Hint = #1053#1072#1095#1072#1090#1100' '#1089#1073#1086#1088' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080
      OnExecute = actStartGrabExecute
    end
    object actStopGrab: TAction
      Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1073#1086#1088
      Hint = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1073#1086#1088' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080
      OnExecute = actStopGrabExecute
    end
    object actContinueGrab: TAction
      Caption = #1055#1088#1086#1076#1086#1083#1078#1080#1090#1100' '#1089#1073#1086#1088
      Hint = #1055#1088#1086#1076#1086#1083#1078#1080#1090#1100' '#1089#1073#1086#1088' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080
      OnExecute = actContinueGrabExecute
    end
    object actSave: TAction
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      OnExecute = actSaveExecute
    end
    object actLoad: TAction
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
      OnExecute = actLoadExecute
    end
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 524
    Top = 417
  end
  object FDStanStorageBinLink1: TFDStanStorageBinLink
    Left = 548
    Top = 489
  end
end
