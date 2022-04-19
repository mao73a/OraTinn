object FrmQueryGrid: TFrmQueryGrid
  Left = 441
  Top = 374
  Caption = 'FrmQueryGrid'
  ClientHeight = 263
  ClientWidth = 511
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
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 505
    Height = 257
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 56
    ExplicitTop = 24
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
  object ActionList1: TActionList
    Left = 32
    Top = 80
    object acBestFit: TAction
      Caption = 'Best Fit'
      OnExecute = acBestFitExecute
    end
    object Action1: TAction
      Caption = 'Action1'
      ShortCut = 16451
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 32
    Top = 128
    object BestFit1: TMenuItem
      Action = acBestFit
    end
  end
end
