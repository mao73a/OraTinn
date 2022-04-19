object dlgSearchInFiles: TdlgSearchInFiles
  Left = 234
  Top = 168
  BorderStyle = bsDialog
  Caption = 'Search In Files'
  ClientHeight = 253
  ClientWidth = 331
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 52
    Height = 13
    Caption = '&Search for:'
  end
  object cbSearchText: TComboBox
    Left = 96
    Top = 8
    Width = 228
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object gbSearchOptions: TGroupBox
    Left = 8
    Top = 36
    Width = 154
    Height = 85
    Caption = 'Options'
    TabOrder = 1
    object cbSearchCaseSensitive: TCheckBox
      Left = 8
      Top = 20
      Width = 140
      Height = 17
      Caption = 'C&ase sensitivity'
      TabOrder = 0
    end
    object cbSearchWholeWords: TCheckBox
      Left = 8
      Top = 40
      Width = 140
      Height = 17
      Caption = '&Whole words only'
      TabOrder = 1
    end
    object cbRegularExpression: TCheckBox
      Left = 8
      Top = 60
      Width = 140
      Height = 17
      Caption = '&Regular expressions'
      TabOrder = 2
      OnClick = cbRegularExpressionClick
    end
  end
  object gbxWhere: TGroupBox
    Left = 168
    Top = 36
    Width = 157
    Height = 85
    Caption = 'Where'
    TabOrder = 2
    object cbOpenFiles: TCheckBox
      Left = 8
      Top = 20
      Width = 133
      Height = 17
      Caption = 'Search all &opened files'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbDirectories: TCheckBox
      Left = 8
      Top = 40
      Width = 141
      Height = 17
      Caption = 'Search in &directories'
      TabOrder = 1
      OnClick = cbDirectoriesClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 124
    Width = 317
    Height = 89
    Caption = 'Directory Search Options'
    TabOrder = 3
    object lblDirectory: TLabel
      Left = 16
      Top = 24
      Width = 42
      Height = 13
      Caption = 'Directory'
      Enabled = False
    end
    object lblFileMask: TLabel
      Left = 16
      Top = 48
      Width = 45
      Height = 13
      Caption = 'File Mask'
      Enabled = False
    end
    object sbtnDirectory: TSpeedButton
      Left = 288
      Top = 20
      Width = 23
      Height = 22
      Caption = '...'
      Enabled = False
      OnClick = sbtnDirectoryClick
    end
    object comboDirectories: TComboBox
      Left = 68
      Top = 20
      Width = 217
      Height = 21
      Enabled = False
      ItemHeight = 13
      TabOrder = 0
    end
    object comboFileMasks: TComboBox
      Left = 68
      Top = 44
      Width = 217
      Height = 21
      Enabled = False
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        '*.*')
    end
    object cbSubdirectories: TCheckBox
      Left = 68
      Top = 68
      Width = 137
      Height = 17
      Caption = 'Search sub directories'
      Enabled = False
      TabOrder = 2
    end
  end
  object BitBtn1: TBitBtn
    Left = 168
    Top = 220
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    NumGlyphs = 2
  end
  object BitBtn2: TBitBtn
    Left = 248
    Top = 220
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    NumGlyphs = 2
  end
end
