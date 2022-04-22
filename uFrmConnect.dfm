object FrmConnect: TFrmConnect
  Left = 389
  Top = 300
  Caption = 'Connect'
  ClientHeight = 483
  ClientWidth = 612
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnActivate = FormActivate
  DesignSize = (
    612
    483)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 465
    Top = 9
    Width = 22
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'User'
    ExplicitLeft = 392
  end
  object Label2: TLabel
    Left = 465
    Top = 57
    Width = 46
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Password'
    ExplicitLeft = 392
  end
  object Label3: TLabel
    Left = 465
    Top = 105
    Width = 22
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Host'
    ExplicitLeft = 392
  end
  object btOK: TBitBtn
    Left = 444
    Top = 445
    Width = 72
    Height = 25
    Anchors = [akRight, akBottom]
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
    OnClick = btOKClick
    ExplicitLeft = 371
    ExplicitTop = 320
  end
  object BitBtn2: TBitBtn
    Left = 523
    Top = 445
    Width = 73
    Height = 25
    Anchors = [akRight, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
    OnClick = BitBtn2Click
    ExplicitLeft = 450
    ExplicitTop = 320
  end
  object edUser: TEdit
    Left = 465
    Top = 24
    Width = 114
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 3
    ExplicitLeft = 392
  end
  object edPass: TEdit
    Left = 465
    Top = 72
    Width = 114
    Height = 21
    Anchors = [akTop, akRight]
    PasswordChar = '*'
    TabOrder = 4
    ExplicitLeft = 392
  end
  object edHost: TEdit
    Left = 465
    Top = 120
    Width = 114
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 5
    ExplicitLeft = 392
  end
  object panelFilter: TPanel
    Left = 17
    Top = 446
    Width = 399
    Height = 17
    Hint = 'Press backspace to cancel'
    Alignment = taLeftJustify
    Anchors = [akLeft, akRight, akBottom]
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
    ExplicitTop = 305
    ExplicitWidth = 336
  end
  object Panel1: TPanel
    Left = 17
    Top = 16
    Width = 400
    Height = 431
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitWidth = 337
    ExplicitHeight = 290
    object KeyList: TListView
      Left = 0
      Top = 0
      Width = 400
      Height = 431
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
      ExplicitWidth = 337
      ExplicitHeight = 290
    end
  end
end
