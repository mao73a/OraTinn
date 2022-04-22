object FrmCompileErrors: TFrmCompileErrors
  Left = 360
  Top = 268
  Caption = 'Error messages'
  ClientHeight = 66
  ClientWidth = 407
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object btNext: TSpeedButton
    Left = 3
    Top = 35
    Width = 33
    Height = 22
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
    Left = 42
    Top = 0
    Width = 365
    Height = 66
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 61
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
    OnDblClick = mMemoDblClick
    ExplicitHeight = 61
  end
end
