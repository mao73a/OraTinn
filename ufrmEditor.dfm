object frmEditor: TfrmEditor
  Left = 274
  Top = 154
  Caption = 'frmEditor'
  ClientHeight = 448
  ClientWidth = 818
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesigned
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object synEditor: TSynEdit
    Left = 0
    Top = 0
    Width = 818
    Height = 448
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    PopupMenu = MainPopup
    TabOrder = 0
    OnClick = synEditorClick
    OnEndDrag = synEditorEndDrag
    OnKeyDown = synEditorKeyDown
    OnKeyUp = synEditorKeyUp
    OnMouseDown = synEditorMouseDown
    OnMouseMove = synEditorMouseMove
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.GradientStartColor = clBtnFace
    MaxScrollWidth = 2147483646
    Options = [eoAutoIndent, eoAutoSizeMaxScrollWidth, eoDragDropEditing, eoGroupUndo, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabIndent, eoTabsToSpaces, eoTrimTrailingSpaces]
    WantTabs = True
    OnChange = synEditorChange
    OnGutterClick = synEditorGutterClick
    OnGutterGetText = synEditorGutterGetText
    OnPaint = synEditorPaint
    OnReplaceText = synEditorReplaceText
    OnScroll = synEditorScroll
    OnStatusChange = synEditorStatusChange
    OnPaintTransient = synEditorPaintTransient
    ExplicitWidth = 643
    ExplicitHeight = 465
  end
  object MainMenu1: TMainMenu
    Images = frmTinnMain.ToolbarImages
    Left = 40
    Top = 40
    object File1: TMenuItem
      Caption = '&File'
      GroupIndex = 1
      object New1: TMenuItem
        Action = FileNewCmd
      end
      object Open1: TMenuItem
        Action = frmTinnMain.FileOpenCmd
      end
      object Save1: TMenuItem
        Action = FileSaveCmd
      end
      object SaveAll1: TMenuItem
        Action = frmTinnMain.actSaveAll
      end
      object SaveAs1: TMenuItem
        Action = FileSaveAsCmd
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object Close1: TMenuItem
        Caption = '&Close'
        OnClick = Close1Click
      end
      object CloseAll1: TMenuItem
        Action = frmTinnMain.actCloseAll
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object actReload1: TMenuItem
        Action = actReload
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Print1: TMenuItem
        Action = frmTinnMain.Print
      end
      object PrintPreview1: TMenuItem
        Action = frmTinnMain.actPrintPreview
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object OpenallfilesinMRU1: TMenuItem
        Action = frmTinnMain.actOpenMRU
        GroupIndex = 1
      end
      object miRecentFiles: TMenuItem
        Caption = 'Recent Files'
        GroupIndex = 1
      end
      object N1: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object Exit1: TMenuItem
        Action = frmTinnMain.FileExitCmd
        GroupIndex = 1
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      GroupIndex = 1
      object Undo2: TMenuItem
        Action = EditUndo
      end
      object Redo1: TMenuItem
        Action = actRedo
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object Cut2: TMenuItem
        Action = EditCut
      end
      object Copy2: TMenuItem
        Action = EditCopy
      end
      object Paste2: TMenuItem
        Action = EditPaste
      end
      object SelectAllmenu: TMenuItem
        Action = EditSelectAll
      end
    end
    object Format1: TMenuItem
      Caption = 'Fo&rmat'
      GroupIndex = 1
      object Block1: TMenuItem
        Caption = 'Block'
        object IndentBlockCtrlShiftI1: TMenuItem
          Action = actIndentBlock
        end
        object UnindentBlockCtrlShiftU1: TMenuItem
          Action = actUnindentBlock
        end
        object N14: TMenuItem
          Caption = '-'
        end
        object CommentBlock1: TMenuItem
          Action = actBlockComment
        end
        object UncommentBlock1: TMenuItem
          Action = actBlockUncomment
        end
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Word1: TMenuItem
        Caption = 'Word'
        object UppercaseWord1: TMenuItem
          Action = actUpper
        end
        object LowercaseWord1: TMenuItem
          Action = actLower
        end
        object InvertCase1: TMenuItem
          Action = actInvertCase
        end
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object Selection1: TMenuItem
        Caption = 'Selection'
        object UppercaseSelection1: TMenuItem
          Action = actUpperCaseSelection
        end
        object LowercaseSelection1: TMenuItem
          Action = actLowercaseSelection
        end
        object InvertSelection1: TMenuItem
          Action = actInvertSelection
        end
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object DateTimeStamp1: TMenuItem
        Action = actMatchBracket
      end
      object InsertDateTimeStamp1: TMenuItem
        Action = actDateStamp
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object SelectionMode1: TMenuItem
        Caption = 'Selection Mode'
        object ColumnSelect1: TMenuItem
          Action = actColumnSelect
          RadioItem = True
        end
        object LineSelect1: TMenuItem
          Action = actLineSelect
          RadioItem = True
        end
        object NormalSelect1: TMenuItem
          Action = actNormalSelect
          Checked = True
          RadioItem = True
        end
      end
    end
    object Search1: TMenuItem
      Caption = '&Search'
      GroupIndex = 8
      object Find1: TMenuItem
        Action = Find
      end
      object FindAgain1: TMenuItem
        Caption = 'Find Again'
        ShortCut = 114
        OnClick = FindAgainExecute
      end
      object Replace1: TMenuItem
        Action = Replace
      end
      object GoTo1: TMenuItem
        Action = GotoLine
      end
      object SaveAll2: TMenuItem
        Action = frmTinnMain.actSearchInFiles
      end
    end
  end
  object MainPopup: TPopupMenu
    Images = frmTinnMain.ToolbarImages
    MenuAnimation = [maLeftToRight, maTopToBottom]
    Left = 92
    Top = 40
    object Close2: TMenuItem
      Caption = '&Close'
      OnClick = Close1Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object popCut: TMenuItem
      Action = EditCut
    end
    object popCopy: TMenuItem
      Action = EditCopy
    end
    object popPaste: TMenuItem
      Action = EditPaste
    end
    object popUndo: TMenuItem
      Action = EditUndo
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object mpopReadOnly1: TMenuItem
      Action = frmTinnMain.ToggleReadOnly
    end
    object Reload1: TMenuItem
      Action = actReload
    end
    object mpopSplit: TMenuItem
      Caption = 'Split Window'
      Visible = False
      OnClick = mpopSplitClick
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object RefactorRename1: TMenuItem
      Caption = 'Refactor Rename'
      OnClick = RefactorRename1Click
    end
    object Blockselect1: TMenuItem
      Caption = 'Block select'
      ShortCut = 49218
      OnClick = Blockselect1Click
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object Highlight1: TMenuItem
      Caption = 'Highlight'
      OnClick = Highlight1Click
    end
    object aMmoveTo: TMenuItem
      Caption = 'MoveWindowTo'
      Visible = False
    end
  end
  object alEdit: TActionList
    Images = frmTinnMain.ToolbarImages
    Left = 76
    Top = 108
    object EditUndo: TEditUndo
      Category = 'Edit'
      Caption = '&Undo'
      ImageIndex = 24
      ShortCut = 16474
      OnExecute = EditUndoExecute
    end
    object actRedo: TAction
      Category = 'Edit'
      Caption = 'Redo'
      Enabled = False
      ImageIndex = 18
      ShortCut = 24666
      OnExecute = actRedoExecute
    end
    object EditCopy: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy'
      ImageIndex = 21
      ShortCut = 16451
      OnExecute = EditCopyExecute
    end
    object EditCut: TEditCut
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut'
      ImageIndex = 22
      ShortCut = 16472
      OnExecute = EditCutExecute
    end
    object EditPaste: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste'
      ImageIndex = 23
      ShortCut = 16470
      OnExecute = EditPasteExecute
    end
    object EditSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select &All'
      ShortCut = 16449
      OnExecute = EditSelectAllExecute
    end
    object Find: TAction
      Category = 'Edit'
      Caption = 'Find'
      ImageIndex = 8
      ShortCut = 16454
      OnExecute = FindExecute
    end
    object GotoLine: TAction
      Category = 'Edit'
      Caption = 'Go To'
      ImageIndex = 14
      ShortCut = 16455
      OnExecute = GotoLineExecute
    end
    object Replace: TAction
      Category = 'Edit'
      Caption = 'Replace'
      ImageIndex = 10
      ShortCut = 16466
      OnExecute = ReplaceExecute
    end
  end
  object alFile: TActionList
    Images = frmTinnMain.ToolbarImages
    Left = 32
    Top = 104
    object FileNewCmd: TAction
      Category = 'File'
      Caption = '&New'
      Hint = 'Create a new file'
      ImageIndex = 0
      ShortCut = 16462
      OnExecute = FileNewCmdExecute
    end
    object FileOpenCmd: TAction
      Category = 'File'
      Caption = '&Open...'
      Hint = 'Open an existing file'
      ImageIndex = 1
      ShortCut = 16463
    end
    object FileSaveCmd: TAction
      Category = 'File'
      Caption = '&Save'
      Hint = 'Save current file'
      ImageIndex = 2
      ShortCut = 16467
      OnExecute = FileSaveCmdExecute
    end
    object FileSaveAsCmd: TAction
      Category = 'File'
      Caption = 'Save &As...'
      Hint = 'Save current file under a new name'
      OnExecute = FileSaveAsCmdExecute
    end
    object FilePrintCmd: TAction
      Category = 'File'
      Caption = '&Print'
      Hint = 'Print current file'
      ImageIndex = 3
      ShortCut = 16464
    end
    object FilePrintPreviewCmd: TAction
      Category = 'File'
      Caption = 'PrintPreview'
      Hint = 'Preview before print'
    end
    object actReload: TAction
      Category = 'File'
      Caption = 'Reload'
      Hint = 'Reload file'
      ImageIndex = 34
      OnExecute = actReloadExecute
    end
  end
  object alFormat: TActionList
    Left = 124
    Top = 104
    object actDateStamp: TAction
      Caption = 'Date/Time Stamp'
      OnExecute = actDateStampExecute
    end
    object actIndentBlock: TAction
      Caption = 'Indent Block'
      ShortCut = 24649
      OnExecute = actIndentBlockExecute
    end
    object actUnindentBlock: TAction
      Caption = 'Unindent Block'
      ShortCut = 24661
      OnExecute = actUnindentBlockExecute
    end
    object actUpper: TAction
      Caption = 'Uppercase Word'
      ShortCut = 49226
      OnExecute = actUpperExecute
    end
    object actLower: TAction
      Caption = 'Lowercase Word'
      ShortCut = 49227
      OnExecute = actLowerExecute
    end
    object actInvertCase: TAction
      Caption = 'Invert Case'
      ShortCut = 49224
      OnExecute = actInvertCaseExecute
    end
    object actMatchBracket: TAction
      Caption = 'Match Bracket'
      ShortCut = 24642
      OnExecute = actMatchBracketExecute
    end
    object actColumnSelect: TAction
      Caption = 'Column'
      ShortCut = 24643
      OnExecute = actColumnSelectExecute
    end
    object actLineSelect: TAction
      Caption = 'Line'
      ShortCut = 24652
      OnExecute = actLineSelectExecute
    end
    object actNormalSelect: TAction
      Caption = 'Normal'
      ShortCut = 24654
      OnExecute = actNormalSelectExecute
    end
    object actUpperCaseSelection: TAction
      Caption = 'Uppercase Selection'
      OnExecute = actUpperCaseSelectionExecute
    end
    object actLowercaseSelection: TAction
      Caption = 'Lowercase Selection'
      OnExecute = actLowercaseSelectionExecute
    end
    object actInvertSelection: TAction
      Caption = 'Invert Selection'
      OnExecute = actInvertSelectionExecute
    end
    object actBlockComment: TAction
      Caption = 'Comment Block'
      ShortCut = 49342
      OnExecute = actBlockCommentExecute
    end
    object actBlockUncomment: TAction
      Caption = 'Uncomment Block'
      ShortCut = 49340
      OnExecute = actBlockUncommentExecute
    end
  end
  object timerSplit: TTimer
    Enabled = False
    Interval = 5
    OnTimer = timerSplitTimer
    Left = 280
    Top = 44
  end
  object alSearch: TActionList
    Left = 184
    Top = 104
    object FindBackwards: TAction
      Caption = 'FindBackwards'
      ShortCut = 8306
      OnExecute = FindBackwardsExecute
    end
    object FindAgain: TAction
      Caption = 'FindAgain'
      ShortCut = 114
      OnExecute = FindAgainExecute
    end
    object actSearchAndReplace: TAction
      Caption = 'actSearchAndReplace'
      ShortCut = 16456
      OnExecute = actSearchAndReplaceExecute
    end
  end
  object SynEditSearch: TSynEditSearch
    Left = 400
    Top = 64
  end
  object SynEditRegexSearch: TSynEditRegexSearch
    Left = 404
    Top = 112
  end
end
