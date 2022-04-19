object GotoBox: TGotoBox
  Left = 477
  Top = 255
  BorderStyle = bsDialog
  Caption = 'Go to Line Number'
  ClientHeight = 79
  ClientWidth = 235
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 235
    Height = 45
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 20
      Width = 60
      Height = 13
      Caption = 'Line Number'
    end
    object spLine: TSpinEdit
      Left = 88
      Top = 16
      Width = 137
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 1
      OnKeyDown = spLineKeyDown
    end
  end
  object BitBtn1: TBitBtn
    Left = 40
    Top = 52
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = BitBtn1Click
    NumGlyphs = 2
  end
  object BitBtn2: TBitBtn
    Left = 120
    Top = 52
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
    NumGlyphs = 2
  end
end
