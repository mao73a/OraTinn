unit ufrmEditor;

{
 The contents of this file are subject to the terms and conditions found under
 the GNU General Public License Version 2 or later (the "GPL").
 See http://www.opensource.org/licenses/gpl-license.html or
 http://www.fsf.org/copyleft/gpl.html for further information.

 Copyright Russell May
 http://www.solarvoid.com

}

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SynEdit, Menus, StdActns, ActnList, SynRegExpr, StdCtrls, SynEditHighlighter,
  SynHighlighterMulti, ExtCtrls, SynEditTypes, SynEditRegexSearch,
  SynEditMiscClasses, SynEditSearch, SynCompletionProposal, ImgList;

const
 TSynSpecialChars = ['Ŕ'..'Ö', 'Ř'..'ö', 'ř'..'˙'];
 TSynValidStringChars = ['_', '0'..'9', 'A'..'Z', 'a'..'z'] + TSynSpecialChars;



type
  TFunctionCall=record
    Name, Package : String;
    BufferCoord : TBufferCoord;
    DisplayPoint : TPoint;
    Underlined : String;
  end;


type
  TfrmEditor = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Close1: TMenuItem;
    N3: TMenuItem;
    miRecentFiles: TMenuItem;
    MainPopup: TPopupMenu;
    popUndo: TMenuItem;
    popCopy: TMenuItem;
    popCut: TMenuItem;
    popPaste: TMenuItem;
    alEdit: TActionList;
    EditCopy: TEditCopy;
    EditCut: TEditCut;
    EditPaste: TEditPaste;
    EditUndo: TEditUndo;
    Edit1: TMenuItem;
    Paste2: TMenuItem;
    Copy2: TMenuItem;
    Cut2: TMenuItem;
    N6: TMenuItem;
    Undo2: TMenuItem;
    alFile: TActionList;
    FileNewCmd: TAction;
    FileOpenCmd: TAction;
    FileSaveCmd: TAction;
    FilePrintCmd: TAction;
    FileSaveAsCmd: TAction;
    Find: TAction;
    GotoLine: TAction;
    Replace: TAction;
    PrintPreview1: TMenuItem;
    FilePrintPreviewCmd: TAction;
    mpopReadOnly1: TMenuItem;
    Format1: TMenuItem;
    InsertDateTimeStamp1: TMenuItem;
    alFormat: TActionList;
    actDateStamp: TAction;
    actIndentBlock: TAction;
    IndentBlockCtrlShiftI1: TMenuItem;
    N4: TMenuItem;
    actUnindentBlock: TAction;
    UnindentBlockCtrlShiftU1: TMenuItem;
    actUpper: TAction;
    actLower: TAction;
    N7: TMenuItem;
    UppercaseWord1: TMenuItem;
    LowercaseWord1: TMenuItem;
    actMatchBracket: TAction;
    DateTimeStamp1: TMenuItem;
    actInvertCase: TAction;
    InvertCase1: TMenuItem;
    Close2: TMenuItem;
    CloseAll1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    mpopSplit: TMenuItem;
    timerSplit: TTimer;
    N10: TMenuItem;
    SaveAll1: TMenuItem;
    alSearch: TActionList;
    Search1: TMenuItem;
    Find1: TMenuItem;
    FindAgain1: TMenuItem;
    Replace1: TMenuItem;
    GoTo1: TMenuItem;
    actColumnSelect: TAction;
    actLineSelect: TAction;
    actNormalSelect: TAction;
    N5: TMenuItem;
    SelectionMode1: TMenuItem;
    ColumnSelect1: TMenuItem;
    NormalSelect1: TMenuItem;
    LineSelect1: TMenuItem;
    SynEditSearch: TSynEditSearch;
    SynEditRegexSearch: TSynEditRegexSearch;
    actRedo: TAction;
    Redo1: TMenuItem;
    EditSelectAll: TEditSelectAll;
    actUpperCaseSelection: TAction;
    UppercaseSelection1: TMenuItem;
    N11: TMenuItem;
    actLowercaseSelection: TAction;
    LowercaseSelection1: TMenuItem;
    actInvertSelection: TAction;
    InvertSelection1: TMenuItem;
    actReload: TAction;
    N12: TMenuItem;
    actReload1: TMenuItem;
    N13: TMenuItem;
    Reload1: TMenuItem;
    FindBackwards: TAction;
    FindAgain: TAction;
    synEditor: TSynEdit;
    SaveAll2: TMenuItem;
    OpenallfilesinMRU1: TMenuItem;
    actSearchAndReplace: TAction;
    actBlockComment: TAction;
    Block1: TMenuItem;
    Word1: TMenuItem;
    Selection1: TMenuItem;
    actBlockUncomment: TAction;
    CommentBlock1: TMenuItem;
    UncommentBlock1: TMenuItem;
    N14: TMenuItem;
    SelectAllmenu: TMenuItem;
    Highlight1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Tile1Click(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure ArrangeAll1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure synEditorChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure synEditorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure synEditorStatusChange(Sender: TObject;
      Changes: TSynStatusChanges);
    procedure File1Click(Sender: TObject);
    procedure EditCopyExecute(Sender: TObject);
    procedure EditPasteExecute(Sender: TObject);
    procedure FileSaveAsCmdExecute(Sender: TObject);
    procedure FileSaveCmdExecute(Sender: TObject);
    procedure FileNewCmdExecute(Sender: TObject);
    procedure FindExecute(Sender: TObject);
    procedure GotoLineExecute(Sender: TObject);
    procedure FindAgainExecute(Sender: TObject);
    procedure ReplaceExecute(Sender: TObject);
    procedure synEditorKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure popCutClick(Sender: TObject);
    procedure actDateStampExecute(Sender: TObject);
    procedure actIndentBlockExecute(Sender: TObject);
    procedure actUnindentBlockExecute(Sender: TObject);
    procedure actUpperExecute(Sender: TObject);
    procedure actLowerExecute(Sender: TObject);
    procedure actMatchBracketExecute(Sender: TObject);
    procedure actInvertCaseExecute(Sender: TObject);
    procedure Close2Click(Sender: TObject);
    procedure SplitPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SplitPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SplitPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SplitPanelDblClick(Sender: TObject);
    procedure mpopSplitClick(Sender: TObject);
    procedure timerSplitTimer(Sender: TObject);
    procedure synEditorClick(Sender: TObject);
    procedure EditCutExecute(Sender: TObject);
    procedure actColumnSelectExecute(Sender: TObject);
    procedure actLineSelectExecute(Sender: TObject);
    procedure actNormalSelectExecute(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure actUpperCaseSelectionExecute(Sender: TObject);
    procedure actLowercaseSelectionExecute(Sender: TObject);
    procedure actInvertSelectionExecute(Sender: TObject);
    procedure actReloadExecute(Sender: TObject);
    procedure FindBackwardsExecute(Sender: TObject);
    procedure actSearchAndReplaceExecute(Sender: TObject);
    procedure synEditorPaintTransient(Sender: TObject; Canvas: TCanvas;
      TransientType: TTransientType);
    procedure EditUndoExecute(Sender: TObject);
    procedure synEditorEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure synEditorGutterClick(Sender: TObject; Button: TMouseButton;
      X, Y, Line: Integer; Mark: TSynEditMark);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actBlockCommentExecute(Sender: TObject);
    procedure actBlockUncommentExecute(Sender: TObject);
    procedure EditSelectAllExecute(Sender: TObject);
    procedure synEditorReplaceText(Sender: TObject; const ASearch,
      AReplace: String; Line, Column: Integer;
      var Action: TSynReplaceAction);
    procedure synEditorMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure synEditorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure synEditorGutterGetText(Sender: TObject; aLine: Integer;
      var aText: String);
    procedure synEditorPaint(Sender: TObject; ACanvas: TCanvas);
    procedure synEditorScroll(Sender: TObject; ScrollBar: TScrollBarKind);
    procedure Highlight1Click(Sender: TObject);

  private
    { Private declarations }
    forceBlockRepaint : Boolean;
    functionCall : TFunctionCall;
    fSearchFromCaret: boolean;
    SizeStart : Integer;
    LinePos : TPoint;
    Sizing : Boolean;
    NeedsErase : boolean;
    WindowIsSplitHoriz : boolean;
    WindowIsSplitVert : boolean;
    SplitPanel : TPanel;
    HasFileBeenSaved : boolean;
    fCurrentLine : integer;

    procedure DoSearchReplaceText(AReplace: boolean; ABackwards: boolean);
    procedure ShowSearchReplaceDialog(AReplace: boolean);
    function SaveModifiedFileQuery : boolean;
    procedure WMMDIActivate(var Msg: TWMMDIActivate);
    message WM_MDIACTIVATE;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    function GetColorForIdx(pIdx : Integer) : Integer;

  public
    { Public declarations }
    gbSearchBackwards: boolean;
    gbSearchCaseSensitive: boolean;
    gbSearchFromCaret: boolean;
    gbSearchSelectionOnly: boolean;
    gbSearchTextAtCaret: boolean;
    gbSearchWholeWords: boolean;
    gbSearchRegex: boolean;
    gbtempSearchBackwards : boolean; // Used for F3 and Shift-F3 so the search is done with a temp change to the search options box

    gsSearchText: string;
    gsReplaceText: string;
    gsReplaceTextHistory: string;

    FileName : string;
    synEditor2 : TSynEdit;
    ActiveEditor : string;
    explorerState : TMemoryStream;
    procedure EnableSave;
    procedure SetTitle;
    procedure CheckSaveStatus;
    procedure SetHighlighterFromFileExt(Extension : string);
    procedure SetHighlighterStatus(Sender: TObject);
    procedure SetSyntaxHighlighter(iSynName : string);
    function SetHighlighterID : integer;
    procedure WindowSplit(boolSplitHoriz : boolean = true);
    procedure SetHighlighterFromTag(iTag : integer);
    procedure ToggleLineNumbers;
    procedure ToggleSpecialChars(iChecked : boolean);
    function ScrubCaption(iCap : string) : string;
    procedure ToggleWordWrap(iChecked : boolean);

   protected
    procedure Loaded; override;
  end;

const
	ctrlKey : integer = 0;
  shiftKey : integer = 0;

var
  frmEditor: TfrmEditor;


//resourcestring
//  STextNotFound = 'Text not found';

implementation

uses ufrmMain, uDMSyn, uGotoBox, dlgSearchText, dlgReplaceText,
  dlgConfirmReplace, ufrmPrintPreview, synEditKeyCmds;

{$R *.DFM}


procedure TfrmEditor.WMMDIActivate;
var
  Style: Longint;
begin
  if (Msg.ActiveWnd = Handle) and (biSystemMenu in BorderIcons) then
  begin
    Style := GetWindowLong(Handle, GWL_STYLE);
    if (Style and WS_MAXIMIZE <> 0) and (Style and WS_SYSMENU = 0) then
      SetWindowLong(Handle, GWL_STYLE, Style or WS_SYSMENU);
      //SendMessage(Handle, WM_SIZE, SIZE_RESTORED, 0);
  end;
  inherited;
end;

procedure TfrmEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmTinnMain.RemoveTab(ScrubCaption(Caption));
  // All files closed
  if (frmTinnMain.pgFiles.PageCount = 0) then
  begin
    // Clear part of the status bar for the size
    frmTinnMain.StatusBar.Panels[2].Text := '';
    // Check the file open maxed setting
    if (frmTinnMain.miStartFileMaxed.Checked) then
      frmTinnMain.boolOpenMaxed := true;
    // Gray out the Split Window
    frmTinnMain.actSplitWindowVert.Enabled := false;
    frmTinnMain.actSplitWindowHoriz.Enabled := false;
    FileSaveCmd.Enabled := false;
    frmTinnMain.actSaveAll.Enabled := false;
    frmTinnMain.actCloseAll.Enabled := false;
    frmTinnMain.tbSave.Enabled := false;
    frmTinnMain.miToggleReadOnly.Checked := false;
    frmTinnMain.tbFind.Enabled := false;
    frmTinnMain.tbReplace.Enabled := false;
    frmTinnMain.tbGoto.Enabled := false;
    frmTinnMain.tbPrint.Enabled := false;
    frmTinnMain.tbsRegExFilter.Enabled := false;
    frmTinnMain.actPlay.Enabled := false;
    frmTinnMain.actRecord.Enabled := false;
    frmTinnMain.ToggleReadOnly.Enabled := false;
    frmTinnMain.MinimizeTinnAfterLastFile;
    actReload.Enabled := false;
  end;
  explorerState.Clear;
  explorerState.Free;
  Action := caFree;
end;

procedure TfrmEditor.Tile1Click(Sender: TObject);
begin
 frmTinnMain.WindowTileVertical1Execute(Sender);
end;

procedure TfrmEditor.Cascade1Click(Sender: TObject);
begin
 frmTinnMain.WindowCascade1Execute(Sender);
end;

procedure TfrmEditor.ArrangeAll1Click(Sender: TObject);
begin
 frmTinnMain.WindowArrange1Execute(Sender);
end;

procedure TfrmEditor.SetTitle;
var
 Stat : string;
begin
  Stat := '';
  if synEditor.Modified = true then
  	Stat := '*';
  Caption := Format('%s%s', [FileName, Stat]);
  frmTinnMain.SetTabTitle(Stat);
end;

procedure TfrmEditor.CheckSaveStatus;
begin
 	if (synEditor.Modified = true) then
  begin
		FileSaveCmd.Enabled := true;
    frmTinnMain.tbSave.Enabled := true;
    frmTinnMain.actSaveAll.Enabled := true;
  end
  else
  begin
 		FileSaveCmd.Enabled := false;
    frmTinnMain.tbSave.Enabled := false;
  end;
end;

procedure TfrmEditor.Close1Click(Sender: TObject);
begin
 Close;
end;

procedure TfrmEditor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := true;
  if synEditor.Modified then
  begin
    BringToFront;
    CanClose := SaveModifiedFileQuery;
  end;

end;

function TfrmEditor.SaveModifiedFileQuery : boolean;
var
  SaveResp: Integer;
begin
  result := false;
  SaveResp := MessageDlg(Format('Save changes to %s?', [FileName]),
    mtConfirmation, [mbYes, mbNo, mbCancel], 0); //mbYesNoCancel  , mbYesToAll, mbNoToAll
  case SaveResp of
    idYes:
      begin
        FileSaveCmdExecute(Self);
        result := true;
      end;
    idNo: result := true;
    idCancel: result := false; //Abort;
  end;
end;

procedure TfrmEditor.FileSaveAsCmdExecute(Sender: TObject);
var
	tmpName : string;
  periodPos : integer;
begin
 	frmTinnMain.SaveDialog.InitialDir := frmTinnMain.WorkingDir;
  tmpName := StringReplace(Self.Caption, '*', '', [rfReplaceAll]);
  if (frmTinnMain.boolRemoveExtentions) then
  begin
    periodPos := pos('.', tmpName);
    if (periodPos > 0) then
    begin
  	  tmpName := copy(tmpName, 1, periodPos - 1);
    end;
  end;
 	frmTinnMain.SaveDialog.FileName := tmpName;
 	if frmTinnMain.SaveDialog.Execute then
 	begin
 		tmpName := frmTinnMain.SaveDialog.FileName + frmTinnMain.SaveAsFileExt ;
    //if (tmpName = '') then
    //	tmpName := frmTinnMain.SaveDialog.FileName;

    if FileExists(tmpName) then
    if MessageDlg(Format('OK to overwrite %s', [tmpName]),
    	mtConfirmation, mbYesNoCancel, 0) <> idYes then Exit;
    synEditor.Lines.SaveToFile(tmpName);
    frmTinnMain.UpdateMRU(miRecentFiles, tmpName);
    FileName := tmpName;
    frmTinnMain.pgFiles.Pages[frmTinnMain.pgFiles.ActivePageIndex].Caption := frmTinnMain.StripPath(FileName);
    frmTinnMain.pgFiles.Pages[frmTinnMain.pgFiles.ActivePageIndex].Hint := FileName;
    synEditor.Modified := False;
    if (synEditor.ReadOnly) then
      frmTinnMain.ToggleReadOnlyExecute(Self);
    frmTinnMain.StatusBar.Panels[1].Text := 'Insert';
    frmTinnMain.WorkingDir := frmTinnMain.StripFileName(tmpName);
    SetHighlighterFromFileExt(ExtractFileExt(FileName));
    FileSaveCmd.Enabled := false;
    frmTinnMain.tbSave.Enabled := false;
    SetTitle;
    if (frmTinnMain.boolUndoAfterSave = false) then
      synEditor.UndoList.Clear;
    HasFileBeenSaved := true;
    frmTinnMain.SetFileSizeinStatusBar(FileName);
 	end;
  frmTinnMain.SaveAsFileExt := '';
end;

procedure TfrmEditor.synEditorChange(Sender: TObject);
begin
	frmTinnMain.UpdateCursorPos(Sender as TsynEdit);
  if synEditor.CanRedo then
		actRedo.Enabled := true
  else
  	actRedo.Enabled := false;
  //frmTinnMain.UpdateCursorPos(synEditor);
  if synEditor2 <> Nil then
  begin
  	if ((Sender as TsynEdit).Name) = 'synEditor' then
    begin
      ActiveEditor := 'synEditor';
      //frmTinnMain.SynMR.Editor := synEditor;
    end
    else
    begin
      ActiveEditor := 'synEditor2';
      //frmTinnMain.SynMR.Editor := synEditor2;
    end;
  end;
end;

procedure TfrmEditor.FormCreate(Sender: TObject);
begin

 if (frmTinnMain.boolOpenMaxed = false) then
 	Self.WindowState := wsNormal
 else
 begin
  // Only do this with the first file opened
  // Did this to avoid the icon problems
  PostMessage( handle, wm_syscommand, sc_maximize, 0 );
 	//Self.WindowState := wsMaximized;
  frmTinnMain.boolOpenMaxed := false;
 end;

  FileName := 'Untitled' + IntToStr(frmTinnMain.FileCount)+'.bdy';
  //SetHighlighterFromFileExt('txt');
  frmTinnMain.UpdateCursorPos(synEditor);
  synEditor.Font.Name := frmTinnMain.FontName;
  synEditor.Font.Size := frmTinnMain.FontSize;
  synEditor.Gutter.ShowLineNumbers := frmTinnMain.miShowLineNum.Checked;
  if (frmTinnMain.actShowSpecialChar.Checked) then
  	synEditor.Options := synEditor.Options + [eoShowSpecialChars];

  ActiveEditor := 'synEditor';
  //actReload.Enabled := false;
  frmTinnMain.BuildMRU(miRecentFiles);
  frmTinnMain.actSplitWindowVert.Enabled := true;
  frmTinnMain.actSplitWindowHoriz.Enabled := true;
  if (synEditor.ReadOnly = false) then
  begin
  	FileSaveCmd.Enabled := true;
  	frmTinnMain.actCloseAll.Enabled := true;
  	frmTinnMain.tbSave.Enabled := true;
  end;
  frmTinnMain.tbFind.Enabled := true;
  frmTinnMain.tbReplace.Enabled := true;
 	frmTinnMain.tbGoto.Enabled := true;
 	frmTinnMain.tbPrint.Enabled := true;
 	frmTinnMain.tbsRegExFilter.Enabled := true;
  frmTinnMain.actPlay.Enabled := true;
  frmTinnMain.actRecord.Enabled := true;
  frmTinnMain.ToggleReadOnly.Enabled := true;
  frmTinnMain.SynMR.Editor := SynEditor;
  if Assigned(frmTinnMain.frmExplorer) then
    frmTinnMain.frmExplorer.Editor:=SynEditor;

  // Search Settings
  gbSearchBackwards := frmTinnMain.boolSearchBackwards;
  gbSearchCaseSensitive := frmTinnMain.boolSearchCaseSensitive;
  gbSearchFromCaret := frmTinnMain.boolSearchFromCaret;
  gbSearchSelectionOnly := frmTinnMain.boolSearchSelectionOnly;
  gbSearchTextAtCaret := frmTinnMain.boolSearchTextAtCaret;
  gbSearchWholeWords := frmTinnMain.boolSearchWholeWords;
  gbSearchRegex := frmTinnMain.boolSearchRegex;
  //gsSearchTextHistory := frmTinnMain.strSearchTextHistory;
  SetTitle;

  explorerState := TMemoryStream.Create;
end;

procedure TfrmEditor.FormActivate(Sender: TObject);
var
 tmpstr : string;
 i : integer;
 Done : boolean;
begin
  tmpstr := FileName;
  i := 0;
  Done := false;
 	while Not(Done) do
 	begin
  	if (i > frmTinnMain.pgFiles.PageCount -1) then
    	Done := True
    else
    begin
      if (frmTinnMain.pgFiles.Pages[i].Hint = ScrubCaption(Caption)) then
      begin
        frmTinnMain.pgFiles.ActivePageIndex := i;
        Done := true;
      end;
      inc(i);
  	end;
 	end;
 	frmTinnMain.UpdateCursorPos(synEditor);
  if (frmTinnMain.pgFiles.ActivePage <> nil) then
  begin
  	if (frmTinnMain.pgFiles.ActivePage.Tag = -1) then
  		SetHighlighterFromFileExt(ExtractFileExt(FileName))
  	else
    	SetHighlighterFromTag(frmTinnMain.pgFiles.ActivePage.Tag);
  end
  else
  	SetHighlighterFromFileExt(ExtractFileExt(FileName));
  
  if synEditor.ReadOnly = false then
  begin
   	frmTinnMain.StatusBar.Panels[1].Text := 'Insert';
   	frmTinnMain.miToggleReadOnly.Checked := false;
    mpopReadOnly1.Checked := false;
  end
  else
  begin
   	frmTinnMain.StatusBar.Panels[1].Text := 'Read Only';
   	frmTinnMain.miToggleReadOnly.Checked := true;
    mpopReadOnly1.Checked := true;
  end;
	CheckSaveStatus;
  frmTinnMain.SetFileSizeinStatusBar(FileName);
end;

procedure TfrmEditor.synEditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

begin
  if (Shift = [ssShift]) then
  	shiftKey := 16
  else
  	shiftKey := 0;

 	if (Key = VK_INSERT) and (not(Shift = [ssCtrl])) and (not(Shift = [ssShift])) then
 	begin

    if synEditor.ReadOnly = False then
    begin
      if frmTinnMain.StatusBar.Panels[1].Text = 'Overwrite' then
        frmTinnMain.StatusBar.Panels[1].Text := 'Insert'
      else
        frmTinnMain.StatusBar.Panels[1].Text := 'Overwrite';
    end;
    
 end
 else if (Key = VK_INSERT) and (Shift = [ssShift]) then
 begin
  EnableSave;
 end
 else begin
  //showMessage(IntToStr(Key));  //9 is tab, 16 is shift, 18 is alt

  if not(Shift = [ssAlt]) then
  begin
    case Key of
      // Trying accept valid keys and disregard the rest
      8, 9, 13, 32, 46, 48..90, 96..111, 166..228 :
        begin
          if (ctrlKey = 0) then
          begin
            if synEditor.ReadOnly = False then
            begin
              EnableSave;
            end;
          end;
        end;
    end;
  end;
  if (Shift = [ssCtrl]) then
  	ctrlKey := 17;
  if (Shift = [ssShift, ssCtrl]) then
  	shiftKey := 16;
 end;
end;

procedure TfrmEditor.SetHighlighterFromFileExt(Extension : string);
var
 synName : Tstringlist;
 Line : string;
 i : integer;
 DefaultFilter : string;
begin
  synName := Tstringlist.Create;
  if (Extension <> '') then
  begin
    // Set up the extention to be used as a RegEx statement
    Extension := LowerCase(Extension);
    Extension := '\' + Extension + '[)|;]';
    // Loop through the DMsymn components looking for Highlighters
    for i := 0 to DMsyn.ComponentCount - 1 do
    begin
      if not (DMsyn.Components[i] is TSynCustomHighlighter) then
        continue;
      DefaultFilter := (DMsyn.Components[i] as TSynCustomHighlighter).DefaultFilter;
      // Regex the extention against the filter
      if ExecRegExpr(Extension, DefaultFilter) then
      begin
        // If there is a match, get the highlighter name
        synName.Text := (DMsyn.Components[i] as TSynCustomHighlighter).GetLanguageName;
        if (synName.Text = 'General Multi-Highlighter') then
        synName.Text := (DMsyn.Components[i] as TSynMultiSyn).DefaultLanguageName;
        break;
      end;
    end;
  end;

  {if ExecRegExpr('pas|dpr|dpk' , Extension) then
   synName.Text := DMsyn.SynPas.GetLanguageName
  else if ExecRegExpr('^\.html?$' , Extension) then
   synName.Text := DMsyn.SynHTMLComplex.DefaultLanguageName
  else if ExecRegExpr('js' , Extension) then
   synName.Text := DMsyn.SynJScript.GetLanguageName
  else if ExecRegExpr('php|phtml|inc' , Extension) then
   synName.Text := DMsyn.SynPHPcomplex.DefaultLanguageName
  else if ExecRegExpr('aspx' , Extension) then
   synName.Text := DMsyn.SynASPNET.DefaultLanguageName
  else if ExecRegExpr('asp' , Extension) then
   synName.Text := DMsyn.SynASP.DefaultLanguageName
  else if ExecRegExpr('asmx' , Extension) then
   synName.Text := DMsyn.SynCS.GetLanguageName
  else if ExecRegExpr('cs' , Extension) then
   synName.Text := DMsyn.SynCS.GetLanguageName
  else if ExecRegExpr('sql' , Extension) then
   synName.Text := DMsyn.SynSQL.GetLanguageName
  else if ExecRegExpr('css' , Extension) then
   synName.Text := DMsyn.SynCSS.GetLanguageName
  else if ExecRegExpr('pl|pm|cgi' , Extension) then
   synName.Text := DMsyn.SynPerl.GetLanguageName
  else if ExecRegExpr('^\.c$', Extension) then
   synName.Text := DMsyn.SynCpp.GetLanguageName
  else if ExecRegExpr('cpp|cxx|h|hpp' , Extension) then
   synName.Text := DMsyn.SynCpp.GetLanguageName
  else if ExecRegExpr('java' , Extension) then
   synName.Text := DMsyn.SynJava.GetLanguageName
  else if ExecRegExpr('ini' , Extension) then
   synName.Text := DMsyn.SynIni.GetLanguageName
  else if ExecRegExpr('\.conf' , Extension) then
   synName.Text := DMsyn.SynPerl.GetLanguageName
  else if ExecRegExpr('\.xml' , Extension) then
   synName.Text := DMsyn.SynXML.GetLanguageName
  else if ExecRegExpr('\.asm' , Extension) then
   synName.Text := DMsyn.SynAsmSyn.GetLanguageName
  }
  if (synName.Text = '') then
  begin
  // I am going to check the first few lines to see what is in the file
    Line := self.synEditor.Lines.Strings[0];
    Line := Line + self.synEditor.Lines.Strings[1];
    Line := Line + self.synEditor.Lines.Strings[2];
    if (ExecRegExpr('<html>', Line)) then
      synName.Text := DMsyn.SynHTMLComplex.DefaultLanguageName
    else if (ExecRegExpr('<html', Line)) then
      synName.Text := DMsyn.SynHTMLComplex.DefaultLanguageName
    else if (ExecRegExpr('<HTML', Line)) then
      synName.Text := DMsyn.SynHTMLComplex.DefaultLanguageName
    else if (ExecRegExpr('<?php', Line)) then
      synName.Text := DMsyn.SynPHPsimple.GetLanguageName
    else
      synName.Text := DMsyn.SynGeneralSyn1.GetLanguageName;

  end;
  SetHighlighterStatus(synName);
end;

procedure TfrmEditor.SetHighlighterStatus(Sender: TObject);
var
 SynName : string;
begin
 if (Sender is TMenuItem) then
   SynName := StringReplace((Sender as TMenuItem).Caption,'&','',[rfReplaceAll])
 else if (Sender is TComboBox) then
   SynName := Trim((Sender as TComboBox).Text)
 else
   SynName := Trim((Sender as TStringList).text);
 frmTinnMain.SetSyntaxMenuItem(SynName);
 frmTinnMain.SetSyntaxComboBox(SynName);
 SetSyntaxHighlighter(SynName);
end;

procedure TfrmEditor.SetSyntaxHighlighter(iSynName : string);
var
 i : integer;
 Highlightname : string;
begin
 for i := 0 to DMsyn.ComponentCount - 1 do
 begin
   if not (DMsyn.Components[i] is TSynCustomHighlighter) then
     continue;
   Highlightname := (DMsyn.Components[i] as TSynCustomHighlighter).GetLanguageName;
   if (Highlightname = iSynName) then
     synEditor.Highlighter := (DMsyn.Components[i] as TSynCustomHighlighter);
   if (Highlightname = 'General Multi-Highlighter') then
   begin
    Highlightname := (DMsyn.Components[i] as TSynMultiSyn).DefaultLanguageName;
    if (Highlightname = iSynName) then
     synEditor.Highlighter := (DMsyn.Components[i] as TSynMultiSyn);
   end;
 end;

 if synEditor2 <> Nil then
 	synEditor2.Highlighter := synEditor.Highlighter;
end;

procedure TfrmEditor.synEditorStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  frmTinnMain.UpdateCursorPos(Sender as TsynEdit);
  fCurrentLine := (Sender as TsynEdit).CaretX;
end;

procedure TfrmEditor.File1Click(Sender: TObject);
begin
 frmTinnMain.BuildMRU(miRecentFiles);
end;

procedure TfrmEditor.EditCopyExecute(Sender: TObject);
begin
	if (synEditor2 <> Nil) then
  begin
  	if (ActiveEditor = 'synEditor') then
  		synEditor.CopyToClipboard
    else
    	synEditor2.CopyToClipboard;
  end
  else
  	synEditor.CopyToClipboard;
end;

procedure TfrmEditor.EditPasteExecute(Sender: TObject);
begin
	if (synEditor2 <> Nil) then
  begin
  	if (ActiveEditor = 'synEditor') then
  		synEditor.PasteFromClipboard
    else
    	synEditor2.PasteFromClipboard;
  end
  else
  	synEditor.PasteFromClipboard;
  EnableSave;
end;

procedure TfrmEditor.FileSaveCmdExecute(Sender: TObject);
begin
try
   if ExecRegExpr('^Untitled' , FileName) then
   begin
     FileSaveAsCmdExecute(Sender);
     frmTinnMain.UpdateMRU(miRecentFiles,frmTinnMain.SaveDialog.FileName);
     if (frmTinnMain.pgFiles.ActivePage.Tag = -1) then
     	SetHighlighterFromFileExt(ExtractFileExt(frmTinnMain.SaveDialog.FileName));
     frmTinnMain.WorkingDir := frmTinnMain.StripFileName(frmTinnMain.SaveDialog.FileName);
     frmTinnMain.SetFileSizeinStatusBar(frmTinnMain.SaveDialog.FileName);
   end
   else
   begin
     if synEditor.ReadOnly = false then
     begin
       synEditor.Lines.SaveToFile(FileName);
       synEditor.Modified := False;
       //actReload.Enabled := false;
       SetTitle;
       FileSaveCmd.Enabled := false;
       frmTinnMain.tbSave.Enabled := false;
       if (frmTinnMain.pgFiles.ActivePage.Tag = -1) then
       	SetHighlighterFromFileExt(ExtractFileExt(FileName));
       frmTinnMain.WorkingDir := ExtractFilePath(FileName);
       if (frmTinnMain.boolUndoAfterSave = false) then
        synEditor.UndoList.Clear;
       HasFileBeenSaved := true;
       frmTinnMain.SetFileSizeinStatusBar(FileName);
     end
     else
     begin
       MessageDlg(Format('%s', [FileName]) + #13#10 + 'This file exists with Read Only attributes.' + #10#13 + 'Please use a different file name.', mtWarning, [mbOK], 0);
     end;
   end;
 except
   on e : exception do
     ShowMessage('Error : ' + e.message);
 end;
end;

procedure TfrmEditor.FileNewCmdExecute(Sender: TObject);
begin
 frmTinnMain.FileNewItem1Click(Sender);
end;

procedure TfrmEditor.FindExecute(Sender: TObject);
begin
 // Show find box
 gbtempSearchBackwards := false;
 ShowSearchReplaceDialog(FALSE);
end;

procedure TfrmEditor.GotoLineExecute(Sender: TObject);
var
 GotoBox : TGotoBox;
 LineNumber : TPoint;
begin
	GotoBox := TGotoBox.Create(application);
	if GotoBox.ShowModal = mrOK then
 	begin
  	LineNumber.y := GotoBox.spLine.Value;
   	LineNumber.x := 1;
   	if (synEditor2 <> Nil) then
  	begin
  		if (ActiveEditor = 'synEditor') then
  			synEditor.ExecuteCommand(17, 'A', @LineNumber)
    	else
    		synEditor2.ExecuteCommand(17, 'A', @LineNumber);
  	end
  	else
  		synEditor.ExecuteCommand(17, 'A', @LineNumber);
 end;
 GotoBox.Free;
end;

// This is ripped right from the SynEdit demo files, with a few modifications, thanks guys!
procedure TfrmEditor.ShowSearchReplaceDialog(AReplace: boolean);
var
  dlg: TTextSearchDialog;
  vTmp : String;
begin

  if AReplace then
    dlg := TTextReplaceDialog.Create(Self)
  else
    dlg := TTextSearchDialog.Create(Self);
  with dlg do try
    // assign search options
    SearchBackwards := False; //(gbSearchBackwards or gbtempSearchBackwards);
    SearchCaseSensitive := gbSearchCaseSensitive;
    SearchFromCursor := gbSearchFromCaret;
    SearchInSelectionOnly := False;//gbSearchSelectionOnly;
    SearchRegularExpression := gbSearchRegex;
    gbSearchTextAtCaret := true;
    // start with last search text
    SearchText := gsSearchText;
    if gbSearchTextAtCaret then begin
      // if something is selected search for that text
      if (ActiveEditor = 'synEditor') then
      begin
        if SynEditor.SelAvail then
          SearchInSelectionOnly := true;
      	if SynEditor.SelAvail and (SynEditor.BlockBegin.Char = SynEditor.BlockEnd.Char)
      	then
        	SearchText := SynEditor.SelText
      	else begin
          vTmp:=SynEditor.GetWordAtRowCol(SynEditor.CaretXY);
          if vTmp<>'' then
           	SearchText := vTmp;
        end;
      end
      else
      begin
        if SynEditor2.SelAvail then
          SearchInSelectionOnly := true;
      	if SynEditor2.SelAvail and (SynEditor2.BlockBegin.Char = SynEditor2.BlockEnd.Char)
      	then
        	SearchText := SynEditor2.SelText
      	else
        	SearchText := SynEditor2.GetWordAtRowCol(SynEditor2.CaretXY);
      end;
    end;
    {if gbSearchTextAtCaret then begin
      // if something is selected search for that text
      if SynEditor.SelAvail and (SynEditor.BlockBegin.Y = SynEditor.BlockEnd.Y)
      then
        SearchText := SynEditor.SelText
      else
        SearchText := SynEditor.GetWordAtRowCol(SynEditor.CaretXY);
    end;}
    SearchTextHistory := frmTinnMain.strSearchTextHistory;
    if AReplace then with dlg as TTextReplaceDialog do begin
      ReplaceText := gsReplaceText;
      ReplaceTextHistory := gsReplaceTextHistory;
    end;
    SearchWholeWords := gbSearchWholeWords;
    if ShowModal = mrOK then begin
      if not(gbtempSearchBackwards) then
        gbSearchBackwards := SearchBackwards;
      gbSearchCaseSensitive := SearchCaseSensitive;
      gbSearchFromCaret := SearchFromCursor;
      gbSearchSelectionOnly := SearchInSelectionOnly;
      gbSearchWholeWords := SearchWholeWords;
      gbSearchRegex := SearchRegularExpression;
      gsSearchText := SearchText;
      //gsSearchTextHistory := SearchTextHistory;
      frmTinnMain.strSearchTextHistory := SearchTextHistory;
      if AReplace then with dlg as TTextReplaceDialog do begin
        gsReplaceText := ReplaceText;
        gsReplaceTextHistory := ReplaceTextHistory;
      end;
      fSearchFromCaret := gbSearchFromCaret;
      if gsSearchText <> '' then begin
        DoSearchReplaceText(AReplace, gbSearchBackwards);
        fSearchFromCaret := TRUE;
      end;

      // Remember search settings
      frmTinnMain.boolSearchBackwards := gbSearchBackwards;
      frmTinnMain.boolSearchCaseSensitive := gbSearchCaseSensitive;
      frmTinnMain.boolSearchFromCaret := gbSearchFromCaret;
      frmTinnMain.boolSearchSelectionOnly := gbSearchSelectionOnly;
      frmTinnMain.boolSearchTextAtCaret := gbSearchTextAtCaret;
      frmTinnMain.boolSearchWholeWords := gbSearchWholeWords;
      frmTinnMain.boolSearchRegex := gbSearchRegex;
      //frmTinnMain.strSearchTextHistory := gsSearchTextHistory;

    end;
  finally
    dlg.Free;
  end;
end;

procedure TfrmEditor.DoSearchReplaceText(AReplace: boolean;
  ABackwards: boolean);
var
  Options: TSynSearchOptions;
begin
  if AReplace then
    Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else
    Options := [];
  if ABackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if not fSearchFromCaret then
    Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then
    Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);

  // If "Search selected text only' is checked, but there is no text selected
  // break out of the method
  if (ActiveEditor = 'synEditor') then
  begin
    if ((SynEditor.SelLength = 0) and gbSearchSelectionOnly) then
    begin
      ShowMessage('No selection for search');
      exit;
    end;
  	if gbSearchRegex then
    	SynEditor.SearchEngine := SynEditRegexSearch
  	else
    	SynEditor.SearchEngine := SynEditSearch;
    if SynEditor.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  	begin
    	MessageBeep(MB_ICONASTERISK);
    	ShowMessage('Text not found');
    	if ssoBackwards in Options then
      	SynEditor.BlockEnd := SynEditor.BlockBegin
    	else
      	SynEditor.BlockBegin := SynEditor.BlockEnd;
    	SynEditor.CaretXY := SynEditor.BlockBegin;
  	end;
  end
  else
  begin
    if ((SynEditor2.SelLength = 0) and gbSearchSelectionOnly) then
    begin
      ShowMessage('No selection for search');
      exit;
    end;
  	if gbSearchRegex then
    	SynEditor2.SearchEngine := SynEditRegexSearch
  	else
    	SynEditor2.SearchEngine := SynEditSearch;
  	if SynEditor2.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  	begin
    	MessageBeep(MB_ICONASTERISK);
    	ShowMessage('Text not found');
    	if ssoBackwards in Options then
      	SynEditor2.BlockEnd := SynEditor2.BlockBegin
    	else
      	SynEditor2.BlockBegin := SynEditor2.BlockEnd;
    	SynEditor2.CaretXY := SynEditor2.BlockBegin;
  	end;
  end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;


procedure TfrmEditor.FindAgainExecute(Sender: TObject);
begin
  gbtempSearchBackwards := false;
	if (gsSearchText = '') then
		ShowSearchReplaceDialog(FALSE)
  else
 		DoSearchReplaceText(FALSE, false);
end;

procedure TfrmEditor.ReplaceExecute(Sender: TObject);
begin
 if (SynEditor.ReadOnly = false) then
 begin
  ShowSearchReplaceDialog(TRUE);
  if (ActiveEditor = 'synEditor2') then
    synEditor.Lines := synEditor2.Lines
  else if (synEditor2 <> nil) then
    synEditor2.Lines := synEditor.Lines;
  FileSaveCmd.Enabled := true;
  frmTinnMain.tbSave.Enabled := true;
  SetTitle;
 end
 else
  ShowMessage('File is read-only. Search/Replace will not work on an read-only file.');
end;

procedure TfrmEditor.synEditorKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  tmpLineNumber : TPoint;
begin

	if (ctrlKey = 17) then
  begin
    if ((Key = 86) or (Key = 88) or (Key = 89) or (Key = 90)) then  // Key 90 = z for undo after saves
    begin
      EnableSave;
    end;
    ctrlKey := 0;
  end;


  if (synEditor2 <> Nil) then
  begin
  	if ((synEditor.UndoList.ItemCount = 0) and (synEditor2.UndoList.ItemCount = 0)) then
    begin
      if HasFileBeenSaved = false then
      begin
        synEditor.Modified := false;
        CheckSaveStatus;
      end;
      SetTitle;
    end;
    if (ActiveEditor = 'synEditor') then
    begin
      tmpLineNumber.y := synEditor2.DisplayY;
      tmpLineNumber.x := synEditor2.DisplayX;
    	synEditor2.Lines.Text := synEditor.Lines.Text;
      synEditor2.GotoLineAndCenter(tmpLineNumber.y);
      //synEditor2.ExecuteCommand(17, 'A', @tmpLineNumber);
    end
    else
    begin
      tmpLineNumber.y := synEditor.DisplayY;
      tmpLineNumber.x := synEditor.DisplayX;
      synEditor.Lines.Text := synEditor2.Lines.Text;
      synEditor.GotoLineAndCenter(tmpLineNumber.y);
    end;
  end
  else
  begin
    if (synEditor.UndoList.ItemCount = 0) then
    begin
      if HasFileBeenSaved = false then
      begin
        synEditor.Modified := false;
        CheckSaveStatus;
      end;
      SetTitle;
    end;
  end;
  if synEditor.Cursor=crHandPoint then
  begin
    functionCall.Name:='';
    functionCall.Package:='';
    functionCall.BufferCoord.Char:=0; functionCall.BufferCoord.Line:=0;
    synEditor.Invalidate;
    functionCall.Underlined:='';
    synEditor.Cursor:=crIBeam;
  end;
end;

function TfrmEditor.SetHighlighterID : integer;
var
	j : integer;
  tmpName : string;
  synName : string;
  foundHighlighter : boolean;
begin
  {synName := synEditor.Highlighter.DefaultFilter;
  foundHighlighter := false;
	for j := 0 to dmSyn.ComponentCount - 1 do
 	begin
    if not (dmSyn.Components[j] is TSynCustomHighlighter) then
      continue;
    tmpName := (dmSyn.Components[j] as TSynCustomHighlighter).DefaultFilter;
    if (tmpName = synName) then
    begin
      foundHighlighter := true;
      break;
    end;
  end; }
  synName := synEditor.Highlighter.GetLanguageName;
  if (synName = 'General Multi-Highlighter') then
    synName := (synEditor.Highlighter as TSynMultiSyn).DefaultLanguageName;
  foundHighlighter := false;
	for j := 0 to dmSyn.ComponentCount - 1 do
 	begin
    if not (dmSyn.Components[j] is TSynCustomHighlighter) then
      continue;
    tmpName := (dmSyn.Components[j] as TSynCustomHighlighter).GetLanguageName;
    if (tmpName = 'General Multi-Highlighter') then
      tmpName := (dmSyn.Components[j] as TSynMultiSyn).DefaultLanguageName;
    if (tmpName = synName) then
    begin
      foundHighlighter := true;
      break;
    end;
  end;
  if foundHighlighter then
    result := j
  else
    result := -1;

end;

procedure TfrmEditor.popCutClick(Sender: TObject);
begin
  synEditor.CutToClipboard;
	EnableSave;
end;

procedure TfrmEditor.EnableSave;
begin
	synEditor.Modified := true;
 	FileSaveCmd.Enabled := true;
 	frmTinnMain.tbSave.Enabled := true;
  frmTinnMain.actSaveAll.Enabled := true;
  actReload.Enabled := true;
 	SetTitle;
end;

procedure TfrmEditor.actDateStampExecute(Sender: TObject);
var
	//LineNumber : TPoint;
  LineNumber : TBufferCoord;
begin
	//synEditor.CaretXY
  if (synEditor.ReadOnly) then exit;
  if (ActiveEditor = 'synEditor2') then
  begin
  	LineNumber := synEditor2.CaretXY;
  	synEditor2.SelText:= DateTimeToStr(Now);
    synEditor.Lines.Text := synEditor2.Lines.Text;
  end
  else
  begin
  	LineNumber := synEditor.CaretXY;
  	//synEditor.Lines.Insert(LineNumber.Y-1, DateTimeToStr(Now));
    synEditor.SelText:= DateTimeToStr(Now);
    if (synEditor2 <> Nil) then
    	synEditor2.Lines.Text := synEditor.Lines.Text;
  end;
  EnableSave;
end;

procedure TfrmEditor.actIndentBlockExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
		synEditor2.ExecuteCommand(ecBlockIndent, 'A', @synEditor.lines)
  else
  	synEditor.ExecuteCommand(ecBlockIndent, 'A', @synEditor.lines);;
  EnableSave;
end;

procedure TfrmEditor.actUnindentBlockExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
		synEditor2.ExecuteCommand(ecBlockUnindent, 'A', @synEditor.lines)
  else
  	synEditor.ExecuteCommand(ecBlockUnindent, 'A', @synEditor.lines);;
  EnableSave;
end;

procedure TfrmEditor.actUpperExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
  begin
		synEditor2.ExecuteCommand(ecUpperCase, 'A', @synEditor.lines);
    synEditor.Lines.Text := synEditor2.Lines.Text;
  end
  else
  begin
  	synEditor.ExecuteCommand(ecUpperCase, 'A', @synEditor.lines);
    if (synEditor2 <> Nil) then
    	synEditor2.Lines.Text := synEditor.Lines.Text;
  end;
  EnableSave;
end;

procedure TfrmEditor.actLowerExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
  begin
		synEditor2.ExecuteCommand(ecLowerCase, 'A', @synEditor.lines);
    synEditor.Lines.Text := synEditor2.Lines.Text;
  end
  else
  begin
  	synEditor.ExecuteCommand(ecLowerCase, 'A', @synEditor.lines);
    if (synEditor2 <> Nil) then
    	synEditor2.Lines.Text := synEditor.Lines.Text;
  end;
  EnableSave;
end;

procedure TfrmEditor.actMatchBracketExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
		synEditor2.ExecuteCommand(ecMatchBracket, 'A', @synEditor.lines)
  else
  	synEditor.ExecuteCommand(ecMatchBracket, 'A', @synEditor.lines);
end;

procedure TfrmEditor.actInvertCaseExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
  begin
		synEditor2.ExecuteCommand(ecToggleCase, 'A', @synEditor.lines);
    synEditor.Lines.Text := synEditor2.Lines.Text;
  end
  else
  begin
  	synEditor.ExecuteCommand(ecToggleCase, 'A', @synEditor.lines);
    if (synEditor2 <> Nil) then
    	synEditor2.Lines.Text := synEditor.Lines.Text;
  end;
  EnableSave;
end;

procedure TfrmEditor.Close2Click(Sender: TObject);
begin
	Close;
end;

procedure TfrmEditor.WindowSplit(boolSplitHoriz : boolean = true);
begin
	// All this is taken and tweaked from another program
  if (boolSplitHoriz) then
  begin
    WindowIsSplitHoriz := not(WindowIsSplitHoriz);
    mpopSplit.Checked := WindowIsSplitHoriz;
  end
  else
  begin
    WindowIsSplitVert := not(WindowIsSplitVert);
    mpopSplit.Checked := WindowIsSplitVert;
  end;
  frmTinnMain.actSplitWindowVert.Enabled := Not(WindowIsSplitHoriz);
  frmTinnMain.actSplitWindowHoriz.Enabled := Not(WindowIsSplitVert);

  if WindowIsSplitVert or WindowIsSplitHoriz then
  begin

    if (boolSplitHoriz) then
    begin
      synEditor.Align := alBottom;
      synEditor.Height := (synEditor.Height div 2);
    end
    else
    begin
      synEditor.Align := alLeft;
      synEditor.Width := (synEditor.Width div 2);
    end;
    SplitPanel := TPanel.Create(Self);
    with SplitPanel do
    begin
      if (boolSplitHoriz) then
      begin
        Align := alBottom;
        Height := 8;
        Cursor := crVSplit;
      end
      else
      begin
        Align := alLeft;
        Width := 8;
        Cursor := crHSplit;
      end;
      OnMouseDown := SplitPanelMouseDown;
      OnMouseUp := SplitPanelMouseUp;
      OnMouseMove := SplitPanelMouseMove;
      OnDblClick := SplitPanelDblClick;
      Parent := Self;
    end;
    synEditor2 := TSynEdit.Create(Self);
    with synEditor2 do
    begin
      Align := alClient;
      //BorderStyle := bsNone;
      HideSelection := False;
      ReadOnly := synEditor.ReadOnly;
      Parent := Self;
      OnStatusChange := synEditorStatusChange;
      OnChange := synEditorChange;
      OnKeyDown := synEditorKeyDown;
      OnKeyUp := synEditorKeyUp;
      onClick := synEditorClick;
      onEndDrag := synEditorEndDrag;
      onGutterClick := synEditorGutterClick;
      onPaintTransient := synEditorPaintTransient;
      onReplaceText := synEditorReplaceText;
      PopupMenu := MainPopup;
      Options := synEditor.Options;
      Gutter := synEditor.Gutter;
      Font := synEditor.Font;
      Highlighter := synEditor.Highlighter;
      Lines.text := synEditor.Lines.Text;
      SelectionMode := synEditor.SelectionMode;
      Options := synEditor.Options;
      WantTabs := synEditor.WantTabs;
      WordWrap := synEditor.WordWrap;
      ActiveLineColor := synEditor.ActiveLineColor;
      TabWidth := synEditor.TabWidth;
      RightEdge := synEditor.RightEdge;
      RightEdgeColor := synEditor.RightEdgeColor;
    end;
    ActiveEditor := 'synEditor';
	end
  else
  begin
    synEditor2.Free;
    SplitPanel.Free;
    synEditor2 := nil;
    SplitPanel := nil;
    synEditor.Align := alClient;
    ActiveEditor := 'synEditor';
  end;
end;

procedure TfrmEditor.SplitPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SPos : TPoint;
begin
  Sizing := True;
  SPos := SplitPanel.ClientToScreen(Point(X, Y));
  SizeStart := SPos.Y;
  LinePos := SPos;                                                     
end;

procedure TfrmEditor.SplitPanelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  NewHeight : Integer;
  DC : hDC;
begin
  if NeedsErase then begin
    DC := GetDC(0);
    PatBlt(DC, LinePos.X, LinePos.Y, ClientWidth, 1, DstInvert );
    ReleaseDC(0, DC);
    NeedsErase := False;
  end;
  NewHeight := synEditor.Height + SizeStart - LinePos.Y;
  synEditor.Height := NewHeight;
  Sizing := False;
end;

procedure TfrmEditor.SplitPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  DC : HDC;
  SPos, CPos : TPoint;
begin
  if Sizing then
  begin
    SPos := SplitPanel.ClientToScreen(Point(SplitPanel.Left, Y));
    CPos := ClientOrigin;
    if SPos.Y <= CPos.Y + 3 then Exit;
    if SPos.Y >= CPos.Y + ClientHeight - 3 then Exit;
    if NeedsErase then
    begin
      DC := GetDC(0);
      PatBlt(DC, SPos.X, LinePos.Y, ClientWidth, 1, DstInvert);
      ReleaseDC(0, DC);
      NeedsErase := False;
    end;
    DC := GetDC(0);
    PatBlt(DC, SPos.X, SPos.Y, ClientWidth, 1, DstInvert);
    ReleaseDC(0, DC);
    NeedsErase := True;
    LinePos := SPos;
  end;
end;

procedure TfrmEditor.SplitPanelDblClick(Sender: TObject);
begin
	timerSplit.Enabled := true;
end;

procedure TfrmEditor.mpopSplitClick(Sender: TObject);
begin
 WindowSplit;
end;

procedure TfrmEditor.timerSplitTimer(Sender: TObject);
begin
	WindowSplit;
  timerSplit.Enabled := false;
end;

procedure TfrmEditor.synEditorClick(Sender: TObject);
begin
	if (Sender as TsynEdit).Name = 'synEditor' then
  begin
  	ActiveEditor := 'synEditor';
    frmTinnMain.SynMR.Editor := synEditor;
  end
  else
  begin
  	ActiveEditor := 'synEditor2';
    frmTinnMain.SynMR.Editor := synEditor2;
  end;
end;

procedure TfrmEditor.EditCutExecute(Sender: TObject);
begin
	inherited;
  if (synEditor2 <> Nil) then
  begin
    if (ActiveEditor = 'synEditor') then
    begin
      synEditor.CutToClipboard;
      synEditor2.Lines.Text := synEditor.Lines.Text;
    end
    else
    begin
      synEditor2.CutToClipboard;
      synEditor.Lines.Text := synEditor2.Lines.Text;
    end;
  end
  else
  	synEditor.CutToClipboard;

end;

procedure TfrmEditor.SetHighlighterFromTag(iTag : integer);
var
	tmpName : string;
	synName : Tstringlist;
begin
	synName := TStringList.Create;
  try
    tmpName := (dmSyn.Components[iTag] as TSynCustomHighlighter).GetLanguageName;
    if (tmpName = 'General Multi-Highlighter') then
      tmpName := (dmSyn.Components[iTag] as TSynMultiSyn).DefaultLanguageName;

    synName.Text := tmpName;
    SetHighlighterStatus(synName);
  finally
  	synName.Free;
  end;
end;

procedure TfrmEditor.actColumnSelectExecute(Sender: TObject);
begin
	if (synEditor2 <> Nil) then
  begin
  	synEditor.SelectionMode := smColumn;
  	synEditor2.SelectionMode := smColumn;
  end
  else
		synEditor.SelectionMode := smColumn;
  ColumnSelect1.Checked := true;
end;

procedure TfrmEditor.actLineSelectExecute(Sender: TObject);
begin
	if (synEditor2 <> Nil) then
  begin
    synEditor.SelectionMode := smLine;
  	synEditor2.SelectionMode := smLine;
  end
  else
		synEditor.SelectionMode := smLine;
  LineSelect1.Checked := true;
end;

procedure TfrmEditor.actNormalSelectExecute(Sender: TObject);
begin
	if (synEditor2 <> Nil) then
  begin
  	synEditor.SelectionMode := smNormal;
  	synEditor2.SelectionMode := smNormal;
  end
  else
		synEditor.SelectionMode := smNormal;
  NormalSelect1.Checked := true;
end;

procedure TfrmEditor.ToggleLineNumbers;
begin
	if (synEditor2 <> Nil) then
  begin
  	synEditor.Gutter.ShowlineNumbers := Not(synEditor.Gutter.ShowlineNumbers);
  	synEditor2.Gutter.ShowlineNumbers := synEditor.Gutter.ShowlineNumbers;
  end
  else
		synEditor.Gutter.ShowlineNumbers := Not(synEditor.Gutter.ShowlineNumbers);
end;

procedure TfrmEditor.ToggleSpecialChars(iChecked : boolean);
begin

	if (synEditor2 <> Nil) then
  begin
  	if iChecked then
    begin
  		synEditor.Options := synEditor.Options + [eoShowSpecialChars];
    	synEditor2.Options := synEditor2.Options + [eoShowSpecialChars];
    end
    else
    begin
    	synEditor.Options := synEditor.Options - [eoShowSpecialChars];
    	synEditor2.Options := synEditor2.Options - [eoShowSpecialChars];
    end;
  end
  else
  begin
  	if iChecked then
  		synEditor.Options := synEditor.Options + [eoShowSpecialChars]
    else
    	synEditor.Options := synEditor.Options - [eoShowSpecialChars];
  end;
end;

procedure TfrmEditor.actRedoExecute(Sender: TObject);
begin
	if synEditor.CanRedo then
  	synEditor.Redo;
end;

procedure TfrmEditor.actUpperCaseSelectionExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
  begin
		synEditor2.ExecuteCommand(ecUpperCaseBlock, 'A', @synEditor.lines);
    synEditor.Lines.Text := synEditor2.Lines.Text;
  end
  else
  begin
  	synEditor.ExecuteCommand(ecUpperCaseBlock, 'A', @synEditor.lines);
    if (synEditor2 <> Nil) then
    	synEditor2.Lines.Text := synEditor.Lines.Text;
  end;
  EnableSave;

end;

procedure TfrmEditor.actLowercaseSelectionExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
  begin
		synEditor2.ExecuteCommand(ecLowerCaseBlock, 'A', @synEditor.lines);
    synEditor.Lines.Text := synEditor2.Lines.Text;
  end
  else
  begin
  	synEditor.ExecuteCommand(ecLowerCaseBlock, 'A', @synEditor.lines);
    if (synEditor2 <> Nil) then
    	synEditor2.Lines.Text := synEditor.Lines.Text;
  end;
  EnableSave;
end;

procedure TfrmEditor.actInvertSelectionExecute(Sender: TObject);
begin
	if (ActiveEditor = 'synEditor2') then
  begin
		synEditor2.ExecuteCommand(ecToggleCaseBlock, 'A', @synEditor.lines);
    synEditor.Lines.Text := synEditor2.Lines.Text;
  end
  else
  begin
  	synEditor.ExecuteCommand(ecToggleCaseBlock, 'A', @synEditor.lines);
    if (synEditor2 <> Nil) then
    	synEditor2.Lines.Text := synEditor.Lines.Text;
  end;
  EnableSave;
end;

procedure TfrmEditor.actReloadExecute(Sender: TObject);
var
	boolReload : boolean;
  SaveResp: Integer;
  //CurPos : TPoint;
  CurPos : TBufferCoord;
begin
	// Reload file from disk
  // Check for modification
  boolReload := true;
  if (synEditor.Modified) then
  begin
  	boolReload := false;
  	SaveResp := MessageDlg(Format('If you reload this file, you will loose all changes.' + #13#10 + 'Do you want to reload the file?', [FileName]),
    mtConfirmation, mbYesNoCancel, 0);
  	case SaveResp of
    	idYes: boolReload := true;
    	idNo: {Nothing};
    	idCancel: Abort;
  	end;
  end;
  if (boolReload) then
  begin
    CurPos := synEditor.CaretXY;
  	synEditor.Lines.LoadFromFile(FileName);
    synEditor.Modified := false;
    CheckSaveStatus;
    SetTitle;
    synEditor.ExecuteCommand(17, 'A', @CurPos);
    frmTinnMain.SetFileSizeinStatusBar(FileName);
  end;
end;

procedure TfrmEditor.FindBackwardsExecute(Sender: TObject);
begin
	gbtempSearchBackwards := true;
	if (gsSearchText = '') then
		ShowSearchReplaceDialog(FALSE)
  else
 		DoSearchReplaceText(FALSE, TRUE);
end;

procedure TfrmEditor.actSearchAndReplaceExecute(Sender: TObject);
begin
  if (gsSearchText = '') then
		ShowSearchReplaceDialog(True)
  else
 		DoSearchReplaceText(True, false);
end;

function TfrmEditor.ScrubCaption(iCap: string): string;
var
  tmpCap : string;
begin
  // Remove fancy markings on the Caption
  tmpCap := iCap;
  tmpCap := StringReplace(tmpCap, '*', '', [rfReplaceAll]);
  tmpCap := StringReplace(tmpCap, '<', '', [rfReplaceAll]);
  tmpCap := StringReplace(tmpCap, '>', '', [rfReplaceAll]);
  tmpCap := StringReplace(tmpCap, '&', '&&', [rfReplaceAll]);

  result := tmpCap;
end;
procedure TfrmEditor.EditUndoExecute(Sender: TObject);
begin
  if (synEditor2 <> Nil) then
  begin
    if (ActiveEditor = 'synEditor') then
      synEditor.ExecuteCommand(ecUndo, 'A', @synEditor.lines)
    else
      synEditor2.ExecuteCommand(ecUndo, 'A', @synEditor.lines);
  end
  else
    synEditor.ExecuteCommand(ecUndo, 'A', @synEditor.lines);
  EnableSave;
end;

procedure TfrmEditor.synEditorEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  EnableSave;
end;

procedure TfrmEditor.synEditorGutterClick(Sender: TObject;
  Button: TMouseButton; X, Y, Line: Integer; Mark: TSynEditMark);
begin
  // Select the entire line
  synEditor.ExecuteCommand(ecSelLineEnd, 'A', @synEditor.lines);
end;

procedure TfrmEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) then
  begin
    ctrlKey := 17;

  end;
end;

procedure TfrmEditor.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ctrlKey = 17) then
  begin
    if (Key = 87) then // Ctrl-W has been detected
      Self.Close;
    ctrlKey := 0;
  end;
end;

procedure TfrmEditor.WMSysCommand(var Msg: TWMSysCommand);
begin
  // Code from Marco -- Thanks!
  Case Msg.CmdType of
      SC_NextWindow:
       begin
         if frmTinnMain.pgFiles.ActivePageIndex = frmTinnMain.pgFiles.PageCount -1
            then frmTinnMain.pgFiles.ActivePageIndex := 0
            else frmTinnMain.pgFiles.ActivePageIndex := frmTinnMain.pgFiles.ActivePageIndex + 1;
       frmTinnMain.pgFilesChange(Self);
       end;
      SC_PREVWINDOW:
       begin
         if frmTinnMain.pgFiles.ActivePageIndex = 0
            then  frmTinnMain.pgFiles.ActivePageIndex := frmTinnMain.pgFiles.PageCount - 1
            else frmTinnMain.pgFiles.ActivePageIndex := frmTinnMain.pgFiles.ActivePageIndex - 1;
       frmTinnMain.pgFilesChange(Self);
       end
      else inherited;
   end;
end;

procedure TfrmEditor.Loaded;
begin
  inherited;
  Width := frmTinnMain.width;
  Height := frmTinnMain.height;
end;

procedure TfrmEditor.ToggleWordWrap(iChecked : boolean);
begin
  if (synEditor2 <> Nil) then
  begin
  	synEditor.WordWrap := iChecked;
    synEditor2.WordWrap := iChecked;
  end
  else
    synEditor.WordWrap := iChecked;
end;

procedure TfrmEditor.actBlockCommentExecute(Sender: TObject);
var
  strTemp       : string;
  i, tpLine     : integer;
  StartComment  : string;
  EndComment    : string;
  OptSelMode    : TSynSelectionMode;
  PosX, PosY    : integer;

  procedure CommentBlockSynEditor;
  begin
    with synEditor do
    begin
      if (EndComment = '') then
      begin
        // With no end comment set, assume the start comment is to be placed on the start of each line
        i:= Pos(strTemp,' '); //length(StartComment),1,1);
        if (i > 1) then
        begin
          SelText:= StringReplace(StartComment,' ', SelText,[]);
          EnableSave;
        end
        else
        begin
          SelText:= StartComment + StringReplace(SelText,
                    #13#10, #13#10 + StartComment, [rfReplaceAll, rfIgnoreCase]);
          EnableSave;
        end;
      end
      else
      begin
        // Otherwise, put a start comment at the beginning of the block and an end comment at the end
        SelText := StartComment + SelText + EndComment;
        EnableSave;
      end;
    end
  end;

  procedure CommentBlockSynEditor2;
  begin
    with synEditor2 do
    begin
      if (EndComment = '') then
      begin
        // With no end comment set, assume the start comment is to be placed on the start of each line
        i:= pos(strTemp, ' '); //FastPos(strTemp,' ',length(StartComment),1,1);
        if (i > 1) then
        begin
          SelText:= StringReplace(StartComment,' ', SelText,[]);
          EnableSave;
        end
        else
        begin
          SelText:= StartComment + StringReplace(SelText,
                    #13#10, #13#10 + StartComment, [rfReplaceAll, rfIgnoreCase]);
          EnableSave;
        end;
      end
      else
      begin
        // Otherwise, put a start comment at the beginning of the block and an end comment at the end
        SelText := StartComment + SelText + EndComment;
        EnableSave;
      end;
    end;
  end;
begin
  // Code taken from Tinn-R project and tweaked for my needs
  StartComment  := frmTinnMain.gStartComment;
  EndComment    := frmTinnMain.gEndComment;
  if (StartComment = '') then
  begin
    if MessageDlg('The default comment/uncomment symbol is not defined!' + #13'Would you like to set it now?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      frmTinnMain.actShowAppOptionsExecute(self);
      StartComment  := frmTinnMain.gStartComment;
      EndComment    := frmTinnMain.gEndComment;
    end
    else
      exit;
  end;

  if (ActiveEditor = 'synEditor') then
  begin
  //store selection..
    with SynEditor do
    begin
      if SelText = '' then
        exit;
      OptSelMode:= SelectionMode;
      if (OptSelMode <> smNormal) then
        SelectionMode:= smNormal;
      posX:= CaretX;
      PosY:= CaretY;
      tpLine:= TopLine;
      CommentBlockSynEditor;
      //restore previous..
      SelectionMode:= OptSelMode;
      TopLine:= tpLine;
      CaretX:= PosX + 1;
      CaretY:= PosY;
    end;
  end
  else
  begin
    //store selection..
    with SynEditor2 do
    begin
      if SelText = '' then
        exit;
      OptSelMode:= SelectionMode;
      if (OptSelMode <> smNormal) then
        SelectionMode:= smNormal;
      posX:= CaretX;
      PosY:= CaretY;
      tpLine:= TopLine;
      CommentBlockSynEditor2;
      //restore previous..
      SelectionMode:= OptSelMode;
      TopLine:= tpLine;
      CaretX:= PosX + 1;
      CaretY:= PosY;
    end;
  end;
end;

procedure TfrmEditor.actBlockUncommentExecute(Sender: TObject);
var
  tpLine        : integer;
  S             : string;
  OptSelMode    : TSynSelectionMode;
  PosX, PosY    : integer;
  StartComment  : string;
  EndComment    : string;

  procedure UncommentBlockSynEDitor;
  begin
    if (StartComment = EmptyStr) then
      exit;
    S := StringReplace(synEditor.SelText, {#13#10 +} StartComment, '', [rfReplaceAll, rfIgnoreCase]);
    if (EndComment <> '') then
    begin
      S := StringReplace(S, {#13#10 +} EndComment, '', [rfReplaceAll, rfIgnoreCase]);
    end;
    synEditor.SelText :=  S;
    EnableSave;
  end;

  procedure UncommentBlockSynEDitor2;
  begin
    if (StartComment = EmptyStr) then
      exit;
    S := StringReplace(synEditor2.SelText, {#13#10 +} StartComment, '', [rfReplaceAll, rfIgnoreCase]);
    if (EndComment <> '') then
    begin
      S := StringReplace(S, {#13#10 +} EndComment, '', [rfReplaceAll, rfIgnoreCase]);
    end;
    synEditor2.SelText :=  S;
    EnableSave;
  end;

begin
  StartComment  := frmTinnMain.gStartComment;
  EndComment    := frmTinnMain.gEndComment;

  if StartComment = '' then
  begin
    if MessageDlg('The default comment/uncomment symbol is not defined!' + #13'Would you like to set it now?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      frmTinnMain.actShowAppOptionsExecute(self);
      StartComment  := frmTinnMain.gStartComment;
      EndComment    := frmTinnMain.gEndComment;
    end
    else
      exit;
  end;

  if (ActiveEditor = 'synEditor') then
  begin
    //store selection..
    with SynEditor do
    begin
      if SelText = '' then
        exit;
      OptSelMode:= SelectionMode;
      if (OptSelMode <> smNormal) then
        SelectionMode:= smNormal;
      posX:= CaretX;
      PosY:= CaretY;
      tpLine:= TopLine;
      UncommentBlockSynEDitor;
      //restore previous..
      SelectionMode:= OptSelMode;
      TopLine:= tpLine;
      CaretX:= PosX + 1;
      CaretY:= PosY;
    end;
  end
  else
  begin
    //store selection..
    with SynEditor2 do
    begin
      if SelText = '' then
        exit;
      OptSelMode:= SelectionMode;
      if (OptSelMode <> smNormal) then
        SelectionMode:= smNormal;
      posX:= CaretX;
      PosY:= CaretY;
      tpLine:= TopLine;
      UncommentBlockSynEDitor;
      //restore previous..
      SelectionMode:= OptSelMode;
      TopLine:= tpLine;
      CaretX:= PosX + 1;
      CaretY:= PosY;
    end;
  end;
end;

procedure TfrmEditor.EditSelectAllExecute(Sender: TObject);
begin
  if (ActiveEditor = 'synEditor2') then
   SynEditor2.SelectAll
  else
   SynEditor.SelectAll;
end;

// From jcfaria
procedure TfrmEditor.synEditorReplaceText(Sender: TObject; const ASearch,
  AReplace: String; Line, Column: Integer; var Action: TSynReplaceAction);
var
  APos      : TPoint;
  EditRect  : TRect;
  Editor    : TSynEdit;
begin
  if ASearch = AReplace then
    Action := raSkip
  else
  begin
    Editor := TSynEdit(Sender);

    APos := SynEditor.ClientToScreen(Editor.RowColumnToPixels
                                    (Editor.BufferToDisplayPos
                                    (BufferCoord(Column, Line))));
    EditRect              := ClientRect;
    EditRect.TopLeft      := ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight  := ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
    ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
        APos.Y + SynEditor.LineHeight, ASearch);
    case ConfirmReplaceDialog.ShowModal of
      mrYes       : Action := raReplace;
      mrYesToAll  : Action := raReplaceAll;
      mrNo        : Action := raSkip;
      else          Action := raCancel;
    end;
  end;
end;

procedure TfrmEditor.synEditorMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
 vDc : TDisplayCoord;
 vBc : TBufferCoord;
 locLine : String;
 TmpX, dotPos : Integer;
 FoundMatch : Boolean;
begin
 if (Shift = [ssCtrl]) and Assigned(frmTinnMain.frmExplorer) then
 begin
     vDc:=synEditor.PixelsToRowColumn(X,Y);
     vBc:=synEditor.WordStartEx(synEditor.DisplayToBufferPos(vDc));
     if (vBc.Char<>functionCall.BufferCoord.Char) or
        (vBc.Line<>functionCall.BufferCoord.Line) then
     begin
       //find function name and position
       functionCall.Name:=synEditor.GetWordAtRowCol(synEditor.DisplayToBufferPos(vDc));
       functionCall.BufferCoord:=vBc;
       functionCall.DisplayPoint:=synEditor.RowColumnToPixels(
          synEditor.BufferToDisplayPos(vBc));
       //find DB package name
       locLine :=synEditor.Lines[functionCall.BufferCoord.Line-1 ];
       //go back from the beginning of function name and find the first dot
       TmpX:=functionCall.BufferCoord.Char-1; FoundMatch:=False;
       if Length(locLine)-1<TmpX then exit;
       //Dec(TmpX);
       if locLine[TmpX] = '.' then
           FoundMatch:=True;

       if FoundMatch then begin
         //find the name of package
         dotPos:=TmpX;
         Dec(TmpX); Dec(TmpX);
         while (TmpX > 0) and CharInSet(locLine[TmpX], TSynValidStringChars) do
         //(locLine[TmpX] in TSynValidStringChars) do
           Dec(TmpX);
         if TmpX>=0 then
         begin
           Inc(TmpX);
           functionCall.Package:=LowerCase(Copy(LocLine,
                    TmpX, dotPos - TmpX));
         end;
       end
       else
        functionCall.Package:='';

       if frmTinnMain.frmExplorer.isFunction(functionCall.Name) then
       begin
         synEditor.Invalidate;
         synEditor.Cursor:=crHandPoint;
       end
       else if frmTinnMain.frmExplorer.isPackage(functionCall.Package) then
       begin
         synEditor.Invalidate;
         synEditor.Cursor:=crHandPoint;
       end
       else if frmTinnMain.frmExplorer.isFunction(functionCall.Package) then
       begin
         functionCall.Name:=functionCall.Package;
         functionCall.Package:='';
         synEditor.Invalidate;
         synEditor.Cursor:=crHandPoint;
       end
       else
       begin
         functionCall.Name:='';
         functionCall.Package:='';
         synEditor.Cursor:=crIBeam;
         if functionCall.Underlined<>'' then synEditor.Invalidate;
       end;
     end;
 end
 else if functionCall.Underlined<>'' then
 begin
   functionCall.Name:='';
   functionCall.Package:='';
   functionCall.BufferCoord.Char:=0; functionCall.BufferCoord.Line:=0;
   synEditor.Invalidate;
   functionCall.Underlined:='';
   synEditor.Cursor:=crIBeam;
 end
 else if synEditor.Cursor=crHandPoint then
   synEditor.Cursor:=crIBeam;
end;

procedure TfrmEditor.synEditorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Assigned(frmTinnMain.frmExplorer) then exit;
  if functionCall.Underlined<>'' then
  begin
 
    frmTinnMain.frmExplorer.GotoFunction(functionCall.Package,functionCall.Name);

    synEditor.Cursor:=crIBeam;
    functionCall.Name:='';
//  	frmTinnMain.pgFiles.ActivePageIndex := frmTinnMain.pgFiles.PageCount -1;
  end;
    //ShowMessage('Goto: package='+functionCall.Package+' function='+functionCall.Name);
end;


procedure TfrmEditor.synEditorGutterGetText(Sender: TObject;
  aLine: Integer; var aText: String);
var
  vLineMarks : TSynEditMarks;
  i:Integer;
begin
  if Assigned(synEditor) then begin
    synEditor.Marks.GetMarksForLine(aLine, vLineMarks);

    for i:=1 to MAX_MARKS do begin
      if Assigned(vLineMarks[i]) then begin
        if not vLineMarks[i].IsBookmark then begin
          if AText[1]<>'|' then
            aText:='|'+AText;
        end;
      end
      else
        exit;
    end;
  end;
end;


function TfrmEditor.GetColorForIdx(pIdx : Integer) : Integer;
begin
  //array('yellow','#7FFFD4','#33CCFF','#00CCFF','#66FF99','#FAEBD7','#FF00FF');
  case pIdx of
    0 : result:=frmTinnMain.colorHighlightAllWords;
    1 : result:=clYellow;
    2 : result:=$7FFFD4;
    3 : result:=$33CCFF;
    4 : result:=$00CCDD;
//    5 : result:=$66FF99;
    5 : result:=clRed;
    6 : result:=$FAEBD7;
    7 : result:=$FF00FF;
    8 : result:=$eecbad;
    9 : result:=$ffdab9;
    10 : result:=$adff2f;
    11 : result:=$7cfc00;
    12 : result:=$60a4f4;
    13 : result:=$ffe4e1;
  else
    result:=clWhite;
  end;
end;

procedure TfrmEditor.synEditorPaintTransient(Sender: TObject;
  Canvas: TCanvas; TransientType: TTransientType);

// I had used code from another project, the synEditor project, but I was having problems with
// the split window. So I took and tweaked the code from the synEdit component examples.
// This seems to be working better.
// And then jcfaria reworked it to something even more simple, I tweaked that just slightly
// Marco made some improvements.
// And jcfaria made some more improvements.

var
  Editor             : TSynEdit;
  openChar           : array of Char;
  closeChar          : array of Char;
  editCurPos         : TBufferCoord;
  matchBracketPos    : TBufferCoord;
  Pix                : TPoint;
  Symbol             : string;
  Attrib             : TSynHighlighterAttributes;
  ArrayLength        : integer;
  tmpCharA, tmpCharB : Char;
  i                  : integer;
  vColor             : TColor;

const
  AllBrackets = ['{','[','(','<','}',']',')','>'];

  function CharToPixels(BC: TBufferCoord): TPoint;
  begin
    Result := Editor.RowColumnToPixels(Editor.BufferToDisplayPos(BC));
  end;

begin
  Editor := TSynEdit(Sender);
  //if TSynEdit(Sender).SelAvail then Exit;
  if functionCall.Name<>'' then
  begin
    Editor.GetHighlighterAttriAtRowCol(functionCall.BufferCoord, Symbol, Attrib);
    Editor.Canvas.Font.Style := Attrib.Style;
    Editor.Canvas.Font.Color:=clBlue;
    Editor.Canvas.Font.Style := Editor.Canvas.Font.Style+[fsUnderline];
    Editor.Canvas.Brush.Color := Attrib.Background;
    Editor.Canvas.TextOut(functionCall.DisplayPoint.X, functionCall.DisplayPoint.Y,
         functionCall.Name);
    functionCall.Underlined:=functionCall.Name;
  end;

  //highlihgt active words
  if frmTinnMain.boolHighlightAllWords and (Editor.SelText='') and
     Assigned(frmTinnMain.frmExplorer) and
     (Length(frmTinnMain.frmExplorer.fHighilightWordArr)>0) then begin
    for i:=0 to Length(frmTinnMain.frmExplorer.fHighilightWordArr)-1 do begin
      Editor.GetHighlighterAttriAtRowCol(frmTinnMain.frmExplorer.fHighilightWordArr[i].BufferCoord,
         Symbol, Attrib);
      if Assigned(Attrib) then begin
        Editor.Canvas.Font.Style := Attrib.Style;
        Editor.Canvas.Brush.Color := GetColorForIdx(frmTinnMain.frmExplorer.fHighilightWordArr[i].ColorIdx);

        Pix:=Editor.RowColumnToPixels(Editor.BufferToDisplayPos(
          frmTinnMain.frmExplorer.fHighilightWordArr[i].BufferCoord));
        Editor.Canvas.TextOut(Pix.X, Pix.Y, frmTinnMain.frmExplorer.fHighilightWordArr[i].Word);
      end;
    end;
  end;

  ArrayLength:= 4;

  SetLength(openChar, ArrayLength);
  SetLength(closeChar, ArrayLength);

  for i := 0 to ArrayLength - 1 do
    Case i of
      0: begin
           openChar[i]  := '(';
           closeChar[i] := ')';
         end;
      1: begin
           openChar[i]  := '{';
           closeChar[i] := '}';
         end;
      2: begin
           openChar[i]  := '[';
           closeChar[i] := ']';
         end;
      3: begin
           openChar[i]  := '<';
           closeChar[i] := '>';
         end;
    end;

  editCurPos := Editor.CaretXY;

  {Begin Marco de Groot: Thanks Marco!}
  if (Editor.CaretXY.Line <= Editor.Lines.Count) and
     ((Editor.CaretXY.Char-1) <= Length(Editor.Lines[Editor.CaretXY.Line-1])) and
     (Length(Editor.Lines[Editor.CaretXY.Line-1]) > 0) then
    tmpCharA:= Editor.Lines[Editor.CaretXY.Line-1][Editor.CaretXY.Char-1]
  else tmpCharA := #0;

  if (Editor.CaretXY.Line <= Editor.Lines.Count) and
     ((Editor.CaretXY.Char-1) <= Length(Editor.Lines[Editor.CaretXY.Line-1])) and
     (Length(Editor.Lines[Editor.CaretXY.Line-1]) > 0) then
    tmpCharB := Editor.Lines[Editor.CaretXY.Line-1][Editor.CaretXY.Char]
  else tmpCharB := #0;
  {End Marco de Groot}

  if //not(tmpCharA in AllBrackets) and
     not CharInSet(tmpCharA , AllBrackets) and
     //not(tmpCharB in AllBrackets)
     not CharInSet(tmpCharB, AllBrackets) then Exit;

  Symbol := tmpCharB;
  if
  //not(tmpCharB in AllBrackets)
  not CharInSet(tmpCharB, AllBrackets)
  then
  begin
    editCurPos.Char := editCurPos.Char - 1;
    Symbol := tmpCharA;
  end;

  Editor.GetHighlighterAttriAtRowCol(editCurPos, Symbol, Attrib);

  if (Editor.Highlighter.SymbolAttribute = Attrib) then
  begin
    for i := low(openChar) to High(openChar) do
    begin
      if (Symbol = openChar[i]) or
         (Symbol = closeChar[i]) then
      begin
        matchBracketPos := Editor.GetMatchingBracketEx(editCurPos);

        Pix := CharToPixels(editCurPos);

        Editor.Canvas.Font.Assign(Editor.Font);
        Editor.Canvas.Font.Style := Attrib.Style;

        vColor:=Attrib.Background;
        if (TransientType = ttAfter) then
        begin  //occur just when FIND a symbol (going to right/up or left/down)
          if (matchBracketPos.Char > 0) and
             (matchBracketPos.Line > 0) then
            vColor:=clLime
          else
            vColor:=$00A9BEF1;//clFuchsia;
          Editor.Canvas.Font.Style := [fsBold];
          if vColor=clLime then
            Editor.Canvas.Font.Color := clBlue
          else
            Editor.Canvas.Font.Color := clRed;
          if (frmTinnMain.boolHighlightActiveLine) then
            Editor.Canvas.Brush.Color := frmTinnMain.colorHighlightActiveLive
          else
            //This soluction (line below) is not the ideal but work fine IF the
            //Background of symbols of ALL languages is set to same color the
            //Editor.Color = White
            Editor.Canvas.Brush.Color := vColor//Attrib.Background;//Editor.Color;  //Attrib.Background;
        end
        else
        begin  //occur just when LEAVE from a symbol (going to right/up or left/down)
          Editor.Canvas.Font.Color := Attrib.Foreground;
          if (frmTinnMain.boolHighlightActiveLine) then
            Editor.Canvas.Brush.Color := frmTinnMain.colorHighlightActiveLive
          else
            //Idem comment above
            Editor.Canvas.Brush.Color := Attrib.Background;//Editor.Color;  //Attrib.Background;
        end;

        Editor.Canvas.TextOut(Pix.X, Pix.Y, Symbol);

        if (Editor.CaretY = matchBracketPos.Line) then
        begin
          if (frmTinnMain.boolHighlightActiveLine) then
            Editor.Canvas.Brush.Color := frmTinnMain.colorHighlightActiveLive
        end
        else
          //Idem comment above
          Editor.Canvas.Brush.Color := vColor;// Editor.Color;  //Attrib.Background;

        if (editCurPos.Char > 0) and
           (editCurPos.Line > 0) then
        begin
          Pix := CharToPixels(matchBracketPos);
          if Pix.X > Editor.Gutter.Width then
          begin
            if Symbol = openChar[i] then
              Editor.Canvas.TextOut(Pix.X, Pix.Y, CloseChar[i])
            else
              Editor.Canvas.TextOut(Pix.X, Pix.Y, OpenChar[i]);
          end;
        end;
      end;
    end;
  end;


// old code
{var
    Editor             : TSynEdit;
    OpenChars          : array of Char;
    CloseChars         : array of Char;
    BC                 : TBufferCoord;
    Pix                : TPoint;
    DC                 : TDisplayCoord;
    S                  : string;
    I                  : integer;
    Attri              : TSynHighlighterAttributes;
    ArrayLength        : integer;
    TmpCharA, TmpCharB : char;

const
  //AllBrackets = ['{','[','(','<','}//',']',')','>'];
  {
  function CharToPixels(BC: TBufferCoord): TPoint;
  begin
    Result := Editor.RowColumnToPixels(Editor.BufferToDisplayPos(BC));
  end;

begin

  if TSynEdit(Sender).SelAvail then
    exit;

  Editor := TSynEdit(Sender);
  ArrayLength:= 4;

  SetLength(OpenChars, ArrayLength);
  SetLength(CloseChars, ArrayLength);

  for i := 0 to ArrayLength - 1 do
    Case i of
      0: begin
           OpenChars[i]  := '(';
           CloseChars[i] := ')';
         end;
      1: begin
           OpenChars[i]  := '{';
           CloseChars[i] := '}//';
           {
         end;
      2: begin
           OpenChars[i]  := '[';
           CloseChars[i] := ']';
         end;
      3: begin
           OpenChars[i]  := '<';
           CloseChars[i] := '>';
         end;
    end;
    
  BC := Editor.CaretXY;
  DC := Editor.DisplayXY;

  // Marco's changes
  IF (Editor.CaretXY.Line <= Editor.Lines.Count) AND ((Editor.CaretXY.Char-1) <= Length(Editor.Lines[Editor.CaretXY.Line-1])) AND (Length(Editor.Lines[Editor.CaretXY.Line-1]) > 0)
     THEN TmpCharA:= Editor.Lines[Editor.CaretXY.Line-1][Editor.CaretXY.Char-1]
     ELSE TmpCharA := #0;

  IF (Editor.CaretXY.Line <= Editor.Lines.Count) AND ((Editor.CaretXY.Char-1) <= Length(Editor.Lines[Editor.CaretXY.Line-1])) AND (Length(Editor.Lines[Editor.CaretXY.Line-1]) > 0)
     THEN TmpCharB := Editor.Lines[Editor.CaretXY.Line-1][Editor.CaretXY.Char]
     ELSE TmpCharB := #0;

  if not(TmpCharA in AllBrackets) and
     not(TmpCharB in AllBrackets) then
    exit;  //exit se o caracter a direita ou a esquerda do cursor nao for s�bolo..
  // end Marco's changes

  S := TmpCharB;
  if not(TmpCharB in AllBrackets) then
  begin
    BC.Char := BC.Char - 1;
    S := TmpCharA;
  end;

  Editor.GetHighlighterAttriAtRowCol(BC, S, Attri);

  if (Editor.Highlighter.SymbolAttribute = Attri) then
  begin
    for i := low(OpenChars) to High(OpenChars) do
    begin
      if (S = OpenChars[i]) or
         (S = CloseChars[i]) then
      begin
        Pix := CharToPixels(BC);

        Editor.Canvas.Brush.Style := bsSolid;//Clear;
        Editor.Canvas.Font.Assign(Editor.Font);
        Editor.Canvas.Font.Style := Attri.Style;

        if (TransientType = ttAfter) then
        begin  // ttAfter
          Editor.Canvas.Font.Style := [fsBold];
          if (Attri.Foreground = clRed) then
            Editor.Canvas.Font.Color := clNavy //$FFFFFF - Attri.Foreground it is the inverse color!
          else
            Editor.Canvas.Font.Color := clRed;
          //Editor.Canvas.Brush.Color := frmTinnMain.colorHighlightActiveLive;
        end
        else
        begin  //ttBefore
          Editor.Canvas.Font.Color := Attri.Foreground;
          //Editor.Canvas.Brush.Color := frmTinnMain.colorHighlightActiveLive;;
        end;

        if Editor.Canvas.Font.Color = clNone then
          Editor.Canvas.Font.Color := Editor.Font.Color;

        if Editor.Canvas.Brush.Color = clNone then
          Editor.Canvas.Brush.Color := Editor.Color;

        Editor.Canvas.TextOut(Pix.X, Pix.Y, S);

        BC := Editor.GetMatchingBracketEx(BC);

        if BC.Line <> Editor.CaretY then
         Editor.Canvas.Brush.Color := Editor.Color; //Attri.Background;

        if (BC.Char > 0) and
           (BC.Line > 0) then
        begin
          Pix := CharToPixels(BC);
          if Pix.X > Editor.Gutter.Width then
          begin
            if S = OpenChars[i] then
              Editor.Canvas.TextOut(Pix.X, Pix.Y, CloseChars[i])
            else
              Editor.Canvas.TextOut(Pix.X, Pix.Y, OpenChars[i]);
          end;
        end;
      end;
    end;
    Editor.Canvas.Brush.Style := bsSolid;  //Estilo do editor (fundo)
  end;
 }
end;




procedure TfrmEditor.synEditorPaint(Sender: TObject; ACanvas: TCanvas);
var
  Editor:TSynEdit;
  locLIne : String;
  vPoint, vePoint : TPoint;
  vsline : Integer;
  function CharToPixels(BC: TBufferCoord): TPoint;
  begin
    Result := Editor.RowColumnToPixels(Editor.BufferToDisplayPos(BC));
  end;
  function FirstCharPos(ALine : String) : Integer;
   var vvTmp, vvSize : Integer;
  begin
    vvSize := Length(ALine);
    vvTmp:=0;
    //find first non white character
    while (vvTmp < vvSize-1)
     //and not (ALine[vvTmp] in TSynValidStringChars) do
       and not CharInSet(ALine[vvTmp], TSynValidStringChars) do
         Inc(vvTmp);
    if vvTmp = vvSize then
      result:=-1
    else
     result:=vvTmp;
  end;

begin
   if frmTinnMain.frmExplorer.BlockPaint.Valid then begin
     Editor := TSynEdit(Sender);
     ACanvas.Pen.Color:=clYellow;
     ACanvas.Brush.Color:=clYellow;
     ACanvas.Pen.Style:=psSolid;
     ACanvas.Pen.Width:=1;
     with frmTinnMain.frmExplorer.BlockPaint do begin
         vPoint:=CharToPixels(StartBC);
         vePoint:=CharToPixels(EndBC);

         if vePoint.x < vPoint.x then vsline := vePoint.x else vsline := vPoint.x;

         ACanvas.MoveTo(vsline, vPoint.y+10);
         ACanvas.LineTo(vsline, vePoint.y+6);
         ACanvas.Rectangle(vsline-2, vPoint.y+8, vsline+2, vPoint.y+12);
         ACanvas.Rectangle(vsline-2, vePoint.y+4, vsline+2, vePoint.y+8);
      end;
    end;
    forceBlockRepaint:=False;
end;

procedure TfrmEditor.synEditorScroll(Sender: TObject;
  ScrollBar: TScrollBarKind);
begin
  forceBlockRepaint:=True;
end;

procedure TfrmEditor.Highlight1Click(Sender: TObject);
begin
  frmTinnMain.tbsHghlight.Down:=False;
  if frmTinnMain.edHighlight.Text='' then
    frmTinnMain.edHighlight.Text:=SynEditor.SelText
  else
    frmTinnMain.edHighlight.Text:=frmTinnMain.edHighlight.Text+' '+SynEditor.SelText;
  frmTinnMain.tbsHghlight.Down:=True;
  frmTinnMain.tbsHghlightClick(nil);
end;

end.


