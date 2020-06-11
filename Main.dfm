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
  DesignSize = (
    877
    669)
  PixelsPerInch = 96
  TextHeight = 19
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 137
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 8
    Top = 48
    Width = 861
    Height = 393
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 1
    ExplicitHeight = 401
  end
  object Panel2: TPanel
    Left = 8
    Top = 446
    Width = 861
    Height = 215
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Panel2'
    TabOrder = 2
    ExplicitTop = 455
  end
end
