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
  OnShow = FormShow
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
  object SpeedButton1: TSpeedButton
    Left = 491
    Top = 10
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000FFFFFFFDFDFF
      FCFCFFFFFFFFE2E2F87070D73232C02222B62222B63232C07070D7E2E2F8FFFF
      FFFDFDFEFDFDFFFFFFFFF9F9FEFFFFFFFFFFFF7070D72121BB3D40D96067EF74
      7CFD7780FE696EEF4145D82323BB7070D7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      4B4BCB2A2BCD4A4FEB595EFE595EFE595EFE595EFE595EFE595EFE595EFE2B2C
      CD4B4BCBFFFFFFFBFBFFFFFFFF7070D72324D01719FF1719FF2222B54B50FF4B
      50FF4B50FF4B50FF2222B51719FF1719FF282ACD7070D7FFFFFFE2E2F81F1FBB
      1719FF1719FF2222B5FEFEFD2222B54B50FF4B50FF2222B5FEFEFD2222B51719
      FF3135E72020BBE2E2F87070D7191AD11719FF2222B5FEFEFEF7F7FCFFFFFF22
      22B52222B5FFFFFFF7F7FCFEFEFE2222B51719FF2425D77070D73232C02C2DEB
      1719FF1719FF2222B5FFFFFFFAFAFDFFFFFFFFFFFFFAFAFDFFFFFF2222B51719
      FF1B1BFE1C1DE93232C02222B64343F91B1AFF1B1AFF1B1AFF2222B5FEFEFEF5
      F5FBF5F5FBFEFEFE2222B51719FF1F1FFF1719FF1A1AFB2222B62222B64041F9
      4849FB4545FF4849FB2222B5FEFEFEF5F5FCF5F5FCFEFEFE2222B51719FF2425
      FF1719FF1C1BFA2222B63232C04748F94849FB4849FB2222B5FFFFFFFAFAFDFF
      FFFFFFFFFFFAFAFDFFFFFF2222B51719FF1415FE1313E93232C07070D72F2FD9
      3333E12222B5FEFEFEF8F9FDFFFFFF2222B52222B5FFFFFFF9F9FDFEFEFE2222
      B51719FF3334D57070D7E2E2F81F1FBB5C60F95C60F92222B5FEFEFD2222B5AF
      B8FFAFB8FF2222B5FEFEFD2222B58C8BEF8C8BEF2424BBE2E2F8FFFFFF7070D7
      2A2BD05C60F95C60F92222B5AFB8FFAFB8FFAFB8FFAFB8FF2222B58080F58080
      F53636CD7070D7FFFFFFFFFFFFFFFFFF4B4BCB3133CDB7C0FFB7C0FFB7C0FFB7
      C0FFB7C0FFB7C0FFB7C0FFB7C0FF3939CD4B4BCBFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF7070D72424BB5255D78B93EDA7AFF9A4AAF9878BED5456D72424BC7070
      D7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE2E2F87070D73232C022
      22B62222B63232C07070D7E2E2F8FFFFFFFFFFFFFFFFFFFFFFFF}
    Spacing = 0
    OnClick = SpeedButton1Click
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
      OnDblClick = KeyListDblClick
      OnKeyDown = KeyListKeyDown
      OnSelectItem = KeyListSelectItem
    end
  end
  object edFilter: TEdit
    Left = 47
    Top = 11
    Width = 434
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = pmDb
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
