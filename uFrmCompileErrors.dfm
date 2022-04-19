object FrmCompileErrors: TFrmCompileErrors
  Left = 360
  Top = 268
  Width = 423
  Height = 100
  Caption = 'Error messages'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 105
  TextHeight = 13
  object btNext: TSpeedButton
    Left = 3
    Top = 35
    Width = 33
    Height = 22
    Anchors = [akLeft, akBottom]
    Caption = 'Next'
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = btNextClick
  end
  object btPrev: TSpeedButton
    Left = 3
    Top = 12
    Width = 33
    Height = 22
    Caption = 'Prev'
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = btPrevClick
  end
  object mMemo: TMemo
    Left = 40
    Top = 0
    Width = 375
    Height = 70
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 70
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
    OnDblClick = mMemoDblClick
  end
end
