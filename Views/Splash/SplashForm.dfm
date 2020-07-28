object frmSplash: TfrmSplash
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1046#1076#1080#1090#1077'...'
  ClientHeight = 73
  ClientWidth = 435
  Color = clSkyBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  Visible = True
  PixelsPerInch = 96
  TextHeight = 18
  object GridPanel: TGridPanel
    Left = 0
    Top = 0
    Width = 435
    Height = 73
    Align = alClient
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = cxLabel
        Row = 0
      end
      item
        Column = 0
        Control = ProgressBar
        Row = 1
      end>
    RowCollection = <
      item
        Value = 49.999848851465470000
      end
      item
        Value = 50.000151148534530000
      end>
    TabOrder = 0
    DesignSize = (
      435
      73)
    object cxLabel: TcxLabel
      Left = 1
      Top = 1
      Align = alClient
      AutoSize = False
      Caption = #1046#1076#1080#1090#1077'...'
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 35
      Width = 433
      AnchorX = 218
      AnchorY = 19
    end
    object ProgressBar: TProgressBar
      Left = 38
      Top = 44
      Width = 358
      Height = 20
      Anchors = []
      TabOrder = 1
    end
  end
end
