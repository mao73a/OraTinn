object FormVariableRefactoringChoice: TFormVariableRefactoringChoice
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Refactoring variable rename'
  ClientHeight = 183
  ClientWidth = 294
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object RadioGroup1: TRadioGroup
    Left = 32
    Top = 16
    Width = 217
    Height = 97
    Caption = 'Choose replacement scope'
    Items.Strings = (
      'A'
      'B'
      'C'
      'D'
      'E')
    TabOrder = 0
  end
  object btOK: TButton
    Left = 46
    Top = 140
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 158
    Top = 140
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
