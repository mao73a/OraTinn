object FrmJumpObj: TFrmJumpObj
  Left = 656
  Top = 255
  BorderStyle = bsNone
  Caption = 'Procedure List'
  ClientHeight = 567
  ClientWidth = 519
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    519
    567)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 14
    Width = 23
    Height = 13
    Caption = 'Find:'
  end
  object Panel1: TPanel
    Left = 0
    Top = 38
    Width = 519
    Height = 529
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object KeyList: TListView
      Left = 0
      Top = 0
      Width = 519
      Height = 529
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'Object'
        end
        item
          Alignment = taRightJustify
          AutoSize = True
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      PopupMenu = pmDb
      TabOrder = 0
      ViewStyle = vsReport
      OnColumnClick = KeyListColumnClick
      OnCompare = KeyListCompare
      OnKeyDown = KeyListKeyDown
      OnSelectItem = KeyListSelectItem
    end
  end
  object edFilter: TEdit
    Left = 47
    Top = 11
    Width = 450
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = edFilterChange
    OnKeyDown = edFilterKeyDown
    OnKeyUp = edFilterKeyUp
  end
  object pmDb: TPopupMenu
    Left = 44
    Top = 64
    object LoadSpc1: TMenuItem
      Caption = 'Load Spc'
      ShortCut = 114
      OnClick = LoadSpc1Click
    end
    object LoadBody1: TMenuItem
      Caption = 'Load Body'
      ShortCut = 115
      OnClick = LoadBody1Click
    end
  end
end
