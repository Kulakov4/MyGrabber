object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093' '#1089' Harting.com'
  ClientHeight = 277
  ClientWidth = 738
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 18
  object cxButton1: TcxButton
    Left = 598
    Top = 214
    Width = 123
    Height = 41
    Action = actClose
    TabOrder = 0
  end
  object cxGroupBox1: TcxGroupBox
    Left = 16
    Top = 16
    Caption = ' '#1050#1086#1088#1085#1077#1074#1099#1077' '#1082#1072#1090#1072#1083#1086#1075#1080' '
    TabOrder = 1
    Height = 177
    Width = 705
    object cxCheckBox1: TcxCheckBox
      Left = 16
      Top = 32
      Caption = #1055#1088#1086#1084#1099#1096#1083#1077#1085#1085#1099#1077' '#1089#1086#1077#1076#1080#1085#1080#1090#1077#1083#1080' Han'#174
      TabOrder = 0
      OnClick = cxCheckBox1Click
    end
    object cxCheckBox2: TcxCheckBox
      Left = 16
      Top = 64
      Caption = 'RFID'
      TabOrder = 1
      OnClick = cxCheckBox2Click
    end
    object cxCheckBox3: TcxCheckBox
      Left = 16
      Top = 96
      Caption = #1048#1085#1090#1077#1088#1092#1077#1081#1089#1085#1099#1077' '#1089#1086#1077#1076#1080#1085#1080#1090#1077#1083#1080
      TabOrder = 2
      OnClick = cxCheckBox3Click
    end
    object cxCheckBox4: TcxCheckBox
      Left = 16
      Top = 128
      Caption = #1048#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099
      TabOrder = 3
      OnClick = cxCheckBox4Click
    end
    object cxCheckBox5: TcxCheckBox
      Left = 376
      Top = 32
      Caption = 'HARTING MICA'
      TabOrder = 4
      OnClick = cxCheckBox5Click
    end
    object cxCheckBox6: TcxCheckBox
      Left = 376
      Top = 64
      Caption = #1057#1086#1077#1076#1080#1085#1080#1090#1077#1083#1080' '#1076#1083#1103' '#1087#1077#1095#1072#1090#1085#1099#1093' '#1087#1083#1072#1090
      TabOrder = 5
      OnClick = cxCheckBox6Click
    end
    object cxCheckBox7: TcxCheckBox
      Left = 376
      Top = 96
      Caption = #1048#1079#1084#1077#1088#1077#1085#1080#1077' '#1089#1080#1083#1099' '#1090#1086#1082#1072
      TabOrder = 6
      OnClick = cxCheckBox7Click
    end
    object cxCheckBox8: TcxCheckBox
      Left = 376
      Top = 128
      Caption = #1055#1088#1086#1084#1099#1096#1083#1077#1085#1085#1099#1077' '#1082#1086#1084#1084#1091#1090#1072#1090#1086#1088#1099' Ethernet'
      TabOrder = 7
      OnClick = cxCheckBox8Click
    end
  end
  object cxLoadDocs: TcxCheckBox
    Left = 32
    Top = 214
    Caption = #1047#1072#1075#1088#1091#1078#1072#1090#1100' '#1076#1086#1082#1091#1084#1077#1085#1090#1072#1094#1080#1102
    State = cbsChecked
    TabOrder = 2
    OnClick = cxLoadDocsClick
  end
  object ActionList1: TActionList
    Left = 392
    Top = 208
    object actClose: TAction
      Caption = #1054#1050
      OnExecute = actCloseExecute
    end
  end
end
