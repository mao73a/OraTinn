object frmSearchResults: TfrmSearchResults
  Left = 286
  Top = 283
  Width = 350
  Height = 206
  Caption = 'Search Results'
  Color = clBtnFace
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object synSearchResults: TSynEdit
    Left = 0
    Top = 0
    Width = 342
    Height = 179
    Cursor = crDefault
    Align = alClient
    ActiveLineColor = clActiveCaption
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    OnDblClick = synSearchResultsDblClick
    BorderStyle = bsNone
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.Visible = False
    Options = [eoNoCaret, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces]
    ReadOnly = True
    RightEdge = 0
    SelectionMode = smLine
    OnSpecialLineColors = synSearchResultsSpecialLineColors
  end
end
