object FrmJumpProc: TFrmJumpProc
  Left = 656
  Top = 255
  BorderStyle = bsDialog
  Caption = 'Procedure List'
  ClientHeight = 538
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 98
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
    Width = 513
    Height = 500
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object KeyList: TListView
      Left = 0
      Top = 0
      Width = 513
      Height = 500
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'Procedure'
        end
        item
          Alignment = taRightJustify
          AutoSize = True
          Caption = 'Line'
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnColumnClick = KeyListColumnClick
      OnCompare = KeyListCompare
      OnDblClick = KeyListDblClick
      OnSelectItem = KeyListSelectItem
    end
  end
  object edFilter: TEdit
    Left = 47
    Top = 11
    Width = 458
    Height = 21
    TabOrder = 0
    OnChange = edFilterChange
    OnKeyDown = edFilterKeyDown
    OnKeyUp = edFilterKeyUp
  end
end
