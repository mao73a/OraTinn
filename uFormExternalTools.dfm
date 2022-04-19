object FormExternalTools: TFormExternalTools
  Left = 475
  Top = 432
  Width = 378
  Height = 173
  Caption = 'External Command'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 105
  TextHeight = 13
  object Label1: TLabel
    Left = 9
    Top = 26
    Width = 28
    Height = 13
    Caption = 'Name'
  end
  object Label2: TLabel
    Left = 7
    Top = 66
    Width = 47
    Height = 13
    Caption = 'Command'
  end
  object Label7: TLabel
    Left = 56
    Top = 88
    Width = 293
    Height = 13
    Caption = 'You can use Use: <user>, <password>, <host>, <file>, <word>'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object edCommand: TEdit
    Left = 56
    Top = 64
    Width = 300
    Height = 21
    Hint = 
      'External program name and parameters: <user>, <password>, <host>' +
      ', <file>'
    Anchors = [akLeft, akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object Button1: TButton
    Left = 6
    Top = 112
    Width = 73
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Add'
    ModalResult = 6
    TabOrder = 2
  end
  object edName: TComboBox
    Left = 56
    Top = 24
    Width = 301
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
  end
  object Button2: TButton
    Left = 102
    Top = 112
    Width = 73
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Modify'
    ModalResult = 7
    TabOrder = 3
  end
  object Button3: TButton
    Left = 198
    Top = 112
    Width = 73
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    ModalResult = 3
    TabOrder = 4
  end
  object btCancel: TButton
    Left = 290
    Top = 112
    Width = 73
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 5
  end
end
