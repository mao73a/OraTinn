object dlgAppOptions: TdlgAppOptions
  Left = 634
  Top = 311
  BorderStyle = bsDialog
  Caption = 'Application Options'
  ClientHeight = 351
  ClientWidth = 319
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 4
    Top = 4
    Width = 312
    Height = 309
    Caption = 'Misc Options'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 75
      Height = 13
      Caption = 'MRU List Count'
    end
    object Label2: TLabel
      Left = 16
      Top = 48
      Width = 84
      Height = 13
      Caption = 'Search List Count'
    end
    object Label3: TLabel
      Left = 16
      Top = 72
      Width = 48
      Height = 13
      Caption = 'Line width'
      Visible = False
    end
    object Label4: TLabel
      Left = 152
      Top = 72
      Width = 102
      Height = 13
      Caption = '(Requires App restart)'
      Visible = False
    end
    object sbColor: TSpeedButton
      Left = 88
      Top = 169
      Width = 23
      Height = 22
      Caption = '...'
      OnClick = sbColorClick
    end
    object Label5: TLabel
      Left = 16
      Top = 216
      Width = 83
      Height = 13
      Caption = 'Starting Comment'
    end
    object Label6: TLabel
      Left = 16
      Top = 236
      Width = 80
      Height = 13
      Caption = 'Ending Comment'
    end
    object SpeedButton1: TSpeedButton
      Left = 232
      Top = 169
      Width = 23
      Height = 22
      Caption = '...'
      OnClick = sbColorClick
    end
    object spMRU: TSpinEdit
      Left = 108
      Top = 20
      Width = 37
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object spSearchListMax: TSpinEdit
      Left = 108
      Top = 44
      Width = 37
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object cbRememberSearchList: TCheckBox
      Left = 156
      Top = 48
      Width = 125
      Height = 17
      Caption = 'Remember Search List'
      TabOrder = 2
    end
    object cbRemoveExtentions: TCheckBox
      Left = 16
      Top = 112
      Width = 177
      Height = 17
      Caption = 'Remove Extentions for Save As'
      TabOrder = 3
    end
    object cbUndoAfterSave: TCheckBox
      Left = 16
      Top = 132
      Width = 97
      Height = 17
      Caption = 'Undo After Save'
      TabOrder = 4
    end
    object btnMRUClear: TButton
      Left = 156
      Top = 20
      Width = 75
      Height = 25
      Caption = 'Clear MRU'
      TabOrder = 5
      OnClick = btnMRUClearClick
    end
    object cbMinimizeTinn: TCheckBox
      Left = 16
      Top = 92
      Width = 217
      Height = 17
      Caption = 'Minimize Tinn after last file is closed'
      TabOrder = 6
    end
    object edLineWidth: TEdit
      Left = 72
      Top = 68
      Width = 73
      Height = 21
      TabOrder = 7
      Visible = False
      OnKeyDown = edLineWidthKeyDown
    end
    object cbHighlighted: TCheckBox
      Left = 16
      Top = 152
      Width = 129
      Height = 17
      Caption = 'Active Line Highlighted'
      TabOrder = 8
    end
    object edColor: TEdit
      Left = 48
      Top = 169
      Width = 33
      Height = 21
      BorderStyle = bsNone
      Color = clSilver
      ReadOnly = True
      TabOrder = 9
    end
    object cbWordWrap: TCheckBox
      Left = 16
      Top = 192
      Width = 81
      Height = 17
      Caption = 'Word Wrap'
      TabOrder = 10
    end
    object edStartComment: TEdit
      Left = 104
      Top = 212
      Width = 37
      Height = 21
      TabOrder = 11
    end
    object edEndComment: TEdit
      Left = 104
      Top = 236
      Width = 37
      Height = 21
      TabOrder = 12
    end
    object cbHighlightedWH: TCheckBox
      Left = 164
      Top = 152
      Width = 129
      Height = 17
      Caption = 'All Words Highlighted'
      TabOrder = 13
    end
    object edColorWH: TEdit
      Left = 192
      Top = 169
      Width = 33
      Height = 21
      BorderStyle = bsNone
      Color = clSilver
      ReadOnly = True
      TabOrder = 14
    end
  end
  object BitBtn1: TBitBtn
    Left = 164
    Top = 320
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    NumGlyphs = 2
    TabOrder = 0
  end
  object BitBtn2: TBitBtn
    Left = 240
    Top = 320
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    NumGlyphs = 2
    TabOrder = 1
  end
  object ColorDialog: TColorDialog
    Left = 128
    Top = 168
  end
end
