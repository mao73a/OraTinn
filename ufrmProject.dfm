object frmProject: TfrmProject
  Left = 424
  Top = 202
  Width = 208
  Height = 284
  Caption = 'frmProject'
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object tvProjectFiles: TTreeView
    Left = 0
    Top = 0
    Width = 200
    Height = 255
    Align = alClient
    HotTrack = True
    Indent = 19
    ReadOnly = True
    SortType = stText
    TabOrder = 0
    OnDblClick = tvProjectFilesDblClick
  end
end
