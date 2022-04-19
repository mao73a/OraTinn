object FrmConnect: TFrmConnect
  Left = 389
  Top = 300
  BorderStyle = bsDialog
  Caption = 'Connect'
  ClientHeight = 339
  ClientWidth = 518
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnActivate = FormActivate
  PixelsPerInch = 98
  TextHeight = 13
  object Label1: TLabel
    Left = 392
    Top = 9
    Width = 22
    Height = 13
    Caption = 'User'
  end
  object Label2: TLabel
    Left = 392
    Top = 57
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label3: TLabel
    Left = 392
    Top = 105
    Width = 22
    Height = 13
    Caption = 'Host'
  end
  object btOK: TBitBtn
    Left = 361
    Top = 308
    Width = 72
    Height = 25
    TabOrder = 1
    OnClick = btOKClick
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 440
    Top = 308
    Width = 73
    Height = 25
    TabOrder = 2
    OnClick = BitBtn2Click
    Kind = bkCancel
  end
  object edUser: TEdit
    Left = 392
    Top = 24
    Width = 114
    Height = 21
    TabOrder = 3
  end
  object edPass: TEdit
    Left = 392
    Top = 72
    Width = 114
    Height = 21
    PasswordChar = '*'
    TabOrder = 4
  end
  object edHost: TEdit
    Left = 392
    Top = 120
    Width = 114
    Height = 21
    TabOrder = 5
  end
  object panelFilter: TPanel
    Left = 17
    Top = 305
    Width = 336
    Height = 17
    Hint = 'Press backspace to cancel'
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = 'Filter'
    Color = clInactiveCaption
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    Visible = False
  end
  object Panel1: TPanel
    Left = 17
    Top = 16
    Width = 337
    Height = 290
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    object KeyList: TListView
      Left = 0
      Top = 0
      Width = 337
      Height = 290
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'User'
        end
        item
          AutoSize = True
          Caption = 'Host'
        end
        item
          AutoSize = True
          Caption = 'Date'
        end
        item
          Caption = 'Pass'
          Width = 0
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnColumnClick = KeyListColumnClick
      OnCompare = KeyListCompare
      OnDblClick = KeyListDblClick
      OnKeyPress = sgConnKeyPress
      OnSelectItem = KeyListSelectItem
    end
  end
end
