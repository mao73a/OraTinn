unit ufrmMain;

{
 The contents of this file are subject to the terms and conditions found under
 the GNU General Public License Version 2 or later (the "GPL").
 See http://www.opensource.org/licenses/gpl-license.html or
 http://www.fsf.org/copyleft/gpl.html for further information.

 ASCII Chart from the JediEdit project. Thanks guys!
 Directory selector from syn Text Editor. Thanks!

 Copyright Russell May
 http://www.solarvoid.com

}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, ToolWin, StdActns, ActnList, ImgList, StdCtrls, ExtCtrls, ClipBrd, uAbout, inifiles,
  SynEdit, SynEditPrint, SynEditHighlighter, SynRegExpr,
  SynHighlighterMulti, SynEditTypes, Buttons, SynEditPlugins, SynMacroRecorder,
  SynEditOptionsDialog, ufrmSearchResults, ufrmProject, ufrmCodeCompletion,
  SynCompletionProposal, uTypesE, uFormExternalTools;

const
 WM_OPENEDITOR = WM_USER + 1;
 WM_NOTEXISTS = WM_USER + 2;
 WM_RESTOREAPP = WM_USER + 3;
 MyUniqueConst = $137848;

var
 WM_FINDINSTANCE : integer;


type

  TfrmTinnMain = class(TForm)
    alStandard: TActionList;
    WindowArrange1: TWindowArrange;
    WindowCascade1: TWindowCascade;
    WindowMinimizeAll1: TWindowMinimizeAll;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowTileVertical1: TWindowTileVertical;
    ControlBar1: TControlBar;
    StatusBar: TStatusBar;
    SaveDialog: TSaveDialog;
    tbFileBar: TToolBar;
    tbNew: TToolButton;
    tbOpen: TToolButton;
    tbSave: TToolButton;
    tbPrint: TToolButton;
    CurrentTime: TTimer;
    pmMRU: TPopupMenu;
    ToolbarImages: TImageList;
    ActionList3: TActionList;
    OnTopcmd: TAction;
    IncFindcmd: TAction;
    ShowFileBar: TAction;
    ShowSearchBar: TAction;
    ShowSettingsBar: TAction;
    SetOptions: TAction;
    tbSearchBar: TToolBar;
    tbFind: TToolButton;
    tbReplace: TToolButton;
    tbGoto: TToolButton;
    pmShowBar: TPopupMenu;
    pmShowFileBar1: TMenuItem;
    pmShowSearchBar1: TMenuItem;
    pmShowSettingsBar1: TMenuItem;
    MainMenu1: TMainMenu;
    FileMenu1: TMenuItem;
    FileNewItem1: TMenuItem;
    FileOpenItem1: TMenuItem;
    N2: TMenuItem;
    miRecentFile1: TMenuItem;
    N3: TMenuItem;
    FileExitItem1: TMenuItem;
    Options1: TMenuItem;
    Toolabrs1: TMenuItem;
    FileBar1: TMenuItem;
    SearchBar1: TMenuItem;
    SettingsBar1: TMenuItem;
    AlwaysOnTop1: TMenuItem;
    miSetSytax: TMenuItem;
    N6: TMenuItem;
    HelpMenu1: TMenuItem;
    HelpAboutItem1: TMenuItem;
    Window1: TMenuItem;
    ArrangeIcons1: TMenuItem;
    Cascade1: TMenuItem;
    MinimizeAll1: TMenuItem;
    TileHorizontally1: TMenuItem;
    TileVertically1: TMenuItem;
    alFile: TActionList;
    FileOpenCmd: TAction;
    FileExitCmd: TAction;
    About: TAction;
    ToggleReadOnly: TAction;
    miToggleReadOnly: TMenuItem;
    pgFiles: TPageControl;
    PrintDialog1: TPrintDialog;
    Print: TAction;
    SynEditPrint1: TSynEditPrint;
    actPrintPreview: TAction;
    TabStyle1: TMenuItem;
    tsStandard1: TMenuItem;
    tsButtons1: TMenuItem;
    tsFlatButtons1: TMenuItem;
    actTsStandard: TAction;
    actTsButtons: TAction;
    actTsFlat: TAction;
    TabPosition: TMenuItem;
    tabPosUp1: TMenuItem;
    tabPosDown1: TMenuItem;
    actTabPosTop: TAction;
    actTabPosBottom: TAction;
    actToggleLineNumbers: TAction;
    N1: TMenuItem;
    miShowLineNum: TMenuItem;
    miStartwithnewfile: TMenuItem;
    actToggleNewFileStart: TAction;
    timerStartNewFile: TTimer;
    actOpenMaxed: TAction;
    miStartFileMaxed: TMenuItem;
    Startup1: TMenuItem;
    actCloseAll: TAction;
    actSaveAll: TAction;
    tbMacroBar: TToolBar;
    pmShowRegExBar: TMenuItem;
    ShowRegExBar: TAction;
    ShowGrepBar1: TMenuItem;
    actSyntaxColors: TAction;
    actSyntaxColors1: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    N4: TMenuItem;
    actNewProject: TAction;
    View1: TMenuItem;
    N5: TMenuItem;
    StatusBar1: TMenuItem;
    actStatusBar: TAction;
    N7: TMenuItem;
    SplitWindow1: TMenuItem;
    actSplitWindowVert: TAction;
    actShowSpecialChar: TAction;
    ShowSpecialCharacters1: TMenuItem;
    SynMR: TSynMacroRecorder;
    tbRegExFilterBar: TToolBar;
    tbsRegExFilter: TToolButton;
    ToolButton8: TToolButton;
    edRegEx: TEdit;
    tbsRecord: TToolButton;
    alMacro: TActionList;
    actRecord: TAction;
    actPlay: TAction;
    tbsPlay: TToolButton;
    actToggleMacroBar: TAction;
    ToggleMacroBar1: TMenuItem;
    pmMacroBar: TMenuItem;
    Tools: TMenuItem;
    Macro1: TMenuItem;
    Play1: TMenuItem;
    Record1: TMenuItem;
    EditorOptions1: TMenuItem;
    actShowEditorOptions: TAction;
    SynEditOptionsDialog1: TSynEditOptionsDialog;
    actToggleTabVisible: TAction;
    actToggleTabVisible1: TMenuItem;
    actShowAppOptions: TAction;
    ApplicationOptions1: TMenuItem;
    alMisc: TActionList;
    actAsciiChart: TAction;
    actAsciiChart1: TMenuItem;
    panSearchResults: TPanel;
    splitterBottom: TSplitter;
    actSearchInFiles: TAction;
    SearchInFiles1: TMenuItem;
    SearchMain1: TMenuItem;
    actOpenMRU: TAction;
    OpenallMRU1: TMenuItem;
    ToolButton1: TToolButton;
    tbReload: TToolButton;
    panProjectDockSite: TPanel;
    leftSplitter: TSplitter;
    Project1: TMenuItem;
    New1: TMenuItem;
    miProjectOpen1: TMenuItem;
    alProject: TActionList;
    actProjectNew: TAction;
    actProjectSave: TAction;
    actProjectAddCurrentFile: TAction;
    actProjectAdd: TAction;
    actProjectRemove: TAction;
    actProjectAddCurrentFile1: TMenuItem;
    actProjectOpen: TAction;
    Save1: TMenuItem;
    N8: TMenuItem;
    actProjectRemove1: TMenuItem;
    actProjectClose: TAction;
    Close1: TMenuItem;
    actSplitWindowHoriz: TAction;
    ToggleHorizontalWindowSplit1: TMenuItem;
    N9: TMenuItem;
    actProjectOpenAllFiles: TAction;
    Openallprojectfiles1: TMenuItem;
    N10: TMenuItem;
    actProjectCloseAllFiles: TAction;
    CloseAllFiles1: TMenuItem;
    miProjectReopen1: TMenuItem;
    actExecCmd: TAction;
    actToggleWordWrap: TAction;
    WindowExplorer: TAction;
    CC1: TMenuItem;
    OracleToolbar: TToolBar;
    tbCompile: TToolButton;
    tbConnect: TToolButton;
    TToolbarImages2: TImageList;
    alOracle: TActionList;
    actCompile: TAction;
    actConnect: TAction;
    ToolButton7: TToolButton;
    actSQLPlus: TAction;
    ToolButton9: TToolButton;
    actDisconnect: TAction;
    Free1: TMenuItem;
    tbExternalTools: TToolButton;
    actExtTool: TAction;
    Reload1: TMenuItem;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    actMarkJump: TAction;
    ToolBar1: TToolBar;
    ToolButton14: TToolButton;
    tbsHghlight: TToolButton;
    edHighlight: TEdit;
    actSQLExecute: TAction;
    actSQLExecuteToHTML: TAction;
    tbSettingsBar: TToolBar;
    tbOnTop: TToolButton;
    ToolButton10: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    cbSyntax: TComboBox;
    aJumpProcedure: TAction;
    ToolButton13: TToolButton;
    SynEditOptionsDialog2: TSynEditOptionsDialog;
    aDuplicateLine: TAction;
    aMoveBlockDown: TAction;
    Copyinipath1: TMenuItem;
    procedure WindowArrange1Execute(Sender: TObject);
    procedure WindowCascade1Execute(Sender: TObject);
    procedure WindowMinimizeAll1Execute(Sender: TObject);
    procedure WindowTileVertical1Execute(Sender: TObject);
    procedure WindowTileHorizontal1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileOpenCmdExecute(Sender: TObject);
    procedure FileExitCmdExecute(Sender: TObject);
    procedure OnTopcmdExecute(Sender: TObject);
    procedure RecentFileClick(Sender: TObject);
    procedure Highlighter1Click(Sender: TObject);
    procedure SetFileFilter(iFilter : string);
    procedure FileNewItem1Click(Sender: TObject);
    procedure tbSaveClick(Sender: TObject);
    procedure ShowSearchBarExecute(Sender: TObject);
    procedure ShowSettingsBarExecute(Sender: TObject);
    procedure ShowFileBarExecute(Sender: TObject);
    procedure AboutExecute(Sender: TObject);
    procedure tbFindClick(Sender: TObject);
    procedure tbReplaceClick(Sender: TObject);
    procedure tbGotoClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ToggleReadOnlyExecute(Sender: TObject);
    procedure pgFilesChange(Sender: TObject);
    procedure PrintExecute(Sender: TObject);
    procedure actPrintPreviewExecute(Sender: TObject);
    procedure actTsStandardExecute(Sender: TObject);
    procedure actTsButtonsExecute(Sender: TObject);
    procedure actTsFlatExecute(Sender: TObject);
    procedure actTabPosTopExecute(Sender: TObject);
    procedure actTabPosBottomExecute(Sender: TObject);
    procedure actToggleLineNumbersExecute(Sender: TObject);
    procedure actToggleNewFileStartExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure timerStartNewFileTimer(Sender: TObject);
    procedure actOpenMaxedExecute(Sender: TObject);
    procedure actCloseAllExecute(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure tbsRegExFilterClick(Sender: TObject);
    procedure ShowRegExBarExecute(Sender: TObject);
    procedure actSyntaxColorsExecute(Sender: TObject);
    procedure actStatusBarExecute(Sender: TObject);
    procedure actSplitWindowVertExecute(Sender: TObject);
    procedure actShowSpecialCharExecute(Sender: TObject);
    procedure actRecordExecute(Sender: TObject);
    procedure actPlayExecute(Sender: TObject);
    procedure actToggleMacroBarExecute(Sender: TObject);
    procedure actShowEditorOptionsExecute(Sender: TObject);
    procedure SaveDialogTypeChange(Sender: TObject);
    procedure actToggleTabVisibleExecute(Sender: TObject);
    procedure actShowAppOptionsExecute(Sender: TObject);
    procedure actAsciiChartExecute(Sender: TObject);
    procedure panSearchResultsGetSiteInfo(Sender: TObject;
      DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
      var CanDock: Boolean);
    procedure panSearchResultsDockDrop(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer);
    procedure panSearchResultsUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure splitterBottomMoved(Sender: TObject);
    procedure actSearchInFilesExecute(Sender: TObject);
    procedure actOpenMRUExecute(Sender: TObject);
    procedure SynMRStateChange(Sender: TObject);
    procedure tbReloadClick(Sender: TObject);
    procedure panProjectDockSiteDockDrop(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer);
    procedure actProjectNewExecute(Sender: TObject);
    procedure panProjectDockSiteGetSiteInfo(Sender: TObject;
      DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
      var CanDock: Boolean);
    procedure panProjectDockSiteUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure actProjectAddCurrentFileExecute(Sender: TObject);
    procedure actProjectOpenExecute(Sender: TObject);
    procedure actProjectSaveExecute(Sender: TObject);
    procedure actProjectRemoveExecute(Sender: TObject);
    procedure actProjectCloseExecute(Sender: TObject);
    procedure actSplitWindowHorizExecute(Sender: TObject);
    procedure actProjectOpenAllFilesExecute(Sender: TObject);
    procedure actProjectCloseAllFilesExecute(Sender: TObject);
    procedure pgFilesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pgFilesDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure pgFilesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure actExecCmdExecute(Sender: TObject);
    procedure actToggleWordWrapExecute(Sender: TObject);
    procedure WindowExplorerExecute(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actSQLPlusExecute(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure Free1Click(Sender: TObject);
    procedure actExtToolExecute(Sender: TObject);
    procedure Reload1Click(Sender: TObject);
    procedure Stop1Click(Sender: TObject);
    procedure actMarkJumpExecute(Sender: TObject);
    procedure tbsHghlightClick(Sender: TObject);
    procedure actSQLExecuteExecute(Sender: TObject);
    procedure actSQLExecuteToHTMLExecute(Sender: TObject);
    procedure aJumpProcedureExecute(Sender: TObject);
    procedure aDuplicateLineExecute(Sender: TObject);
    procedure aMoveBlockDownExecute(Sender: TObject);
    procedure Copyinipath1Click(Sender: TObject);

  private
    { Private declarations }

    vPrevWidth : Integer;
    iniFile : TIniFile;
    iniFilePath : string;
    FileFilters : string;
    StartingUp  : boolean;
    FEditorOptions : TSynEditorOptionsContainer;
    //FLineWidth : integer;
    FilterList : TStringList;
    frmResults : TfrmSearchResults;
    frmProjectSpace : TfrmProject;
    gTimerCounter : integer;
    gboolUseRegEx : boolean;
    gboolSearchWholeWords : boolean;
    gboolCaseSensitivity : boolean;
    gboolSearchOpenFiles : boolean;
    SearchRegEx : TRegExpr;
    InExecute: Boolean;


    procedure FindIniFilePath;
    procedure ReadIniFile;
    procedure WriteIniFile;
    procedure SetTabOptions;
    procedure CheckForNewFileStart;
    procedure SetDefaultEditorOptions;
    procedure SearchInOpenFiles(const ioResultList : TStrings; var ioFileCount, ioMatchCount : integer);
    procedure SearchInDirectories(const ioResultList : TStrings; iDir, iMask : string; var ioFileCount, ioMatchCount, ioTotFileCount : integer);
    function StripRegExPower(iSearchText : string) : string;
    procedure SetupSearchParameters(iSearchText : string);
    procedure TraverseDir(iPath : string; var ioFileList : TStringList; iMask : string);
    procedure RecordActions(Action: TBasicAction; var Handled: Boolean);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    function SaveModifiedProjectQuery : boolean;
    procedure ModifyOnCreate;
    procedure HandleException(Sender: TObject; E: Exception);
  public
    { Public declarations }
    denyUpdateMRU : Boolean;
    frmExplorer : TFrmCodeCompletion;
    externalTools : TExternalToolsManager;
    WorkingDir : string;
    FileCount : integer;
    MRUList : TStringList;
    ProjectMRUList : TStringList;
    FontName : string;
    FontSize : integer;
    FontColor : TColor;
    boolOpenMaxed : boolean;
    SaveAsFileExt : string;
    MRUmax : integer;
    SearchListMax : integer;
    // search settings
    boolSearchFromCaret : boolean;
    boolSearchBackwards : boolean;
    boolSearchCaseSensitive : boolean;
    boolSearchSelectionOnly : boolean;
    boolSearchTextAtCaret : boolean;
    boolSearchWholeWords : boolean;
    boolSearchRegex : boolean;
    boolRememberSearchList : boolean;
    strSearchTextHistory : string;
    gboolSearchInSub : boolean;
    gboolSearchDirectory : boolean;
    strSearchDirHistory : string;
    strSearchFileMaskHistory : string;
    //gsSearchTextHistory: string;
    // end search settings
    boolRemoveExtentions : boolean;
    boolUndoAfterSave : boolean;
    boolMinimizeTinnAfterLastFile : boolean;
    AsciiString : string;
    ProjectName : string;

    boolHighlightActiveLine : boolean;
    colorHighlightActiveLive : TColor;

    colorHighlightAllWords : TColor;
    boolHighlightAllWords : boolean;

    gStartComment : string;
    gEndComment : string;
    fLastMarkIdx : Integer;
    
    procedure LoadFile(iFileName : string; CreateNewChild : boolean = true);
    procedure OpenFileIntoTinn(iFile : string; iLineNumberJump : integer = 0);
    procedure UpdateCursorPos(Sender : TSynEdit);
    procedure SetSyntaxMenuItem(iSynName : string);
    procedure SetSyntaxComboBox(iSynName : string);
    procedure BuildMRU(var ioMenuItem : TMenuItem);
    procedure UpdateMRU(var ioMenuItem : TMenuItem; iFileName : string);
    procedure DefaultHandler(var Message); Override;
    function IsWindowOnTaskabr : Boolean;
    Procedure ShowApplication;
    function FindTopWindow : integer;
    function FindWindowByName(iName : string) : integer;
    function StripPath(iFileName : string) : string;
    function StripFileName(iFileName : string) : string;
    procedure SetFileSizeinStatusBar(iFileName : string);
    procedure SetTabTitle(iStat : string);
    procedure RemoveTab(iTabCaption : string);
    procedure ClearMRU;
    procedure MinimizeTinnAfterLastFile;
    procedure OpenProjectIntoTinn(iProjectName : string);
    procedure BuildProjectMRU(var ioMenuItem : TMenuItem);
    procedure UpdateProjectMRU(var ioMenuItem : TMenuItem; iFileName : string);
    procedure RecentProjectFileClick(Sender: TObject);
    procedure RefactorRename(Sender: TObject);
  end;

var
  frmTinnMain: TfrmTinnMain;

implementation

uses
 ShellAPI, ufrmEditor, uDMSyn, ufrmPrintPreview, ufrmSynColor,
  udlgAppOptions, AsciiChart, udlgSearchInFiles, uActionMacro, uFrmConnect, uFrmJumpProc, math;

{$R *.DFM}


procedure TfrmTinnMain.FileNewItem1Click(Sender: TObject);
begin
	inc(FileCount);
 	with TfrmEditor.Create(Self) do
 	begin
    SetDefaultEditorOptions;
  	FEditorOptions.AssignTo(synEditor);
   	synEditor.ReadOnly := false;
    //synEditor.MaxScrollWidth := FLineWidth;
    if (boolHighlightActiveLine) then
      synEditor.ActiveLineColor := TColor(colorHighlightActiveLive)
    else
      synEditor.ActiveLineColor := TColor(clNone);
    if (actToggleWordWrap.Checked) then
      synEditor.WordWrap := actToggleWordWrap.Checked;
   	StatusBar.Panels[1].Text := 'Insert';
   	miToggleReadOnly.Checked := false;
   	with TTabSheet.Create(Self) do
   	begin
 			PageControl := pgFiles;
  		Caption := 'Untitled' + IntToStr(FileCount)+'.bdy';
    	Hint := Caption;
    	ShowHint := True;
  		pgFiles.ActivePageIndex := pgFiles.PageCount -1;
    	pgFiles.ActivePage.Tag := -1;
 	 	end;
   	FileSaveCmd.Enabled := true;
 	end;
 	tbSave.Enabled := true;
end;

procedure TfrmTinnMain.FileOpenCmdExecute(Sender: TObject);
var
  od : TOpenDialog;
begin
  // I had been using a visual component for the Open Dialog, but it was doing
  // weird things with the WorkingDir, mainly not changing to it everytime.
  // So I tried creating it on the fly. Slower, sure, but it works.
  {OpenDialog.InitialDir := '';
	OpenDialog.InitialDir := WorkingDir;
 	if (OpenDialog.Execute) then
 	begin
  	OpenFileIntoTinn(ExpandFileName(OpenDialog.FileName));
  end;
  }
  od := TOpenDialog.Create(self);
  try
    od.InitialDir := WorkingDir;
    od.Filter := SaveDialog.Filter;
    if (od.Execute) then
 	begin
  	OpenFileIntoTinn(ExpandFileName(od.FileName));
  end;
  finally
    od.Free;
  end;

  Self.Repaint;

end;


procedure TfrmTinnMain.OpenFileIntoTinn(iFile : string; iLineNumberJump : integer = 0);
// Modifications done by Marco.
var
 	tmpstr : string;
 	i, j : integer;
  LineNumber : TPoint;
  boolFileExists : boolean;
  lnewFile: TStringList;
  //lFileContentsChanged: Boolean;
  lEditor: TSynEdit;

  //!! 2 new variables
  lLoadFileFromDisk: Boolean;
  lOverwriteCurrentContents: Boolean;

  intPos1, intPos2, intPos3, intPos4: integer;
  vUser, vPass, vDB, vObType, vObject : String;
  vConnected : Boolean;
begin
  //!! init of the variables
  lLoadFileFromDisk := True;
  lOverwriteCurrentContents := False;

  intPos1 := pos('/', iFile);
  intPos2 := pos('@', iFile);

  if (intPos1>0) and (intPos2>0) then begin
      intPos3 := pos(';', iFile);
      intPos4 := pos(':', iFile);
      if intPos3=0 then begin
         intPos3:=99999;
      end;
      vUser:=UpperCase(copy(iFile, 1, intPos1-1));
      vPass:=copy(iFile, intPos1+1, intPos2-intPos1-1);
      vDB:=UpperCase(copy(iFile, intPos2+1, intPos3-intPos2-1));
      vConnected:=frmExplorer.Connect(vUser+'@'+vDB, vUser, vPass, vDB);
       if not vConnected then
         Application.MessageBox(PChar('Cannot connect to database'),PChar('Oracle error'),MB_ICONHAND+MB_OK);

      if intPos3<>99999 then begin
        vObType:=copy(iFile, intPos3+1, intPos4-intPos3-1);
        vObject:=copy(iFile, intPos4+1, 999999);
        if (vObType<>'') and ( vObject<>'') then
           frmExplorer.Load(UpperCase(vObject), UpperCase(vObType));
      end;
      exit;
  end;
  // Check to see if the file is already opened
  tmpstr := iFile;
  i := FindWindowByName(tmpstr);
  if (i > -1) then // if the file is already open, bring it to the front
  begin
    //!! removed, done in activate and btw, do not change if user set it manually
    // (Self.MDIChildren[i] as TfrmEditor).SetHighlighterFromFileExt(ExtractFileExt(tmpstr));
    UpdateMRU(miRecentFile1, tmpstr);
    UpdateMRU((Self.MDIChildren[i] as TfrmEditor).miRecentFiles, tmpstr);
    lEditor := (Self.MDIChildren[i] as TfrmEditor).synEditor;
    //!! set after the calls to Self.MDIChildren[i] because the bring to front changes the order of the MDIChildren
    Self.MDIChildren[i].BringToFront;
    for j := 0 to pgFiles.PageCount -1 do
    begin
      if (pgFiles.Pages[j].Hint = tmpstr) then
        pgFiles.ActivePageIndex := j;
    end;
    pgFiles.Hint := tmpstr;
    pgFiles.ActivePage.Tag := -1;

    //!! Check contents of new file
    lnewFile := TStringList.Create;
    lnewFile.LoadFromFile(iFile);
    // Contents changed
    if not lnewFile.Equals(lEditor.Lines) then
    begin
      if MessageDlg('Reload file?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        lLoadFileFromDisk := False
      else
      begin
        lOverwriteCurrentContents := True;
        // Remember current line
        iLineNumberJump := lEditor.CaretY;
      end;
    end
    else
      lLoadFileFromDisk := False;

    lnewFile.Free;
  end;

  //!! if added
  if lLoadFileFromDisk then
  begin
    // If an Untitled is on top
    i := FindTopWindow;
    boolFileExists := false;
    if (pgFiles.PageCount > 0) then
      boolFileExists := FileExists(pgFiles.ActivePage.Hint);
    if Not(boolFileExists) and (ExecRegExpr('Untitled[1-9]+$', pgFiles.ActivePage.Caption))  then
    begin
      if ((Self.MDIChildren[i] as TfrmEditor).synEditor.Modified = False) then // Check for modification
        LoadFile(tmpstr, false) // Load the file into that
      else
        LoadFile(tmpstr, true);
    end
    else // else just load the file
      LoadFile(tmpstr, NOT lOverwriteCurrentContents); //!! boolean added
  end;


  if (iLineNumberJump > 0) then
  begin
    LineNumber.y := iLineNumberJump;
    LineNumber.x := 1;
    i := FindTopWindow;
    (Self.MDIChildren[i] as TfrmEditor).synEditor.ExecuteCommand(17, 'A', @LineNumber);
  end;

  SynMR.Editor := (Self.MDIChildren[FindTopWindow] as TfrmEditor).synEditor;
  if Assigned(frmExplorer) then
    frmExplorer.Editor:=SynMR.Editor;

  (Self.MDIChildren[FindTopWindow] as TfrmEditor).CheckSaveStatus;

end;
{var
 	tmpstr : string;
 	i, j : integer;
  LineNumber : TPoint;
  boolFileExists : boolean;
begin
  // Check to see if the file is already opened
  tmpstr := iFile;
  i := FindWindowByName(tmpstr);
  if i > -1 then // if the file is already open, bring it to the front
  begin
    Self.MDIChildren[i].BringToFront;
    (Self.MDIChildren[i] as TfrmEditor).SetHighlighterFromFileExt(ExtractFileExt(tmpstr));
    UpdateMRU(miRecentFile1, tmpstr);
    UpdateMRU((Self.MDIChildren[i] as TfrmEditor).miRecentFiles, tmpstr);
    for j := 0 to pgFiles.PageCount -1 do
    begin
    if (pgFiles.Pages[j].Hint = tmpstr) then
      pgFiles.ActivePageIndex := j;
    end;
    pgFiles.Hint := tmpstr;
    pgFiles.ActivePage.Tag := -1;

  end
  else
  begin
    // If an Untitled is on top
    i := FindTopWindow;
    boolFileExists := false;
    if (pgFiles.PageCount > 0) then
      boolFileExists := FileExists(pgFiles.ActivePage.Hint);
    if Not(boolFileExists) and (ExecRegExpr('Untitled[1-9]+$', pgFiles.ActivePage.Caption))  then
    begin
      if ((Self.MDIChildren[i] as TfrmEditor).synEditor.Modified = False) then // Check for modification
        LoadFile(tmpstr, false) // Load the file into that
      else
        LoadFile(tmpstr, true);
    end
    else // else just load the file
      LoadFile(tmpstr, true);
  end;


  if (iLineNumberJump > 0) then
  begin
    LineNumber.y := iLineNumberJump;
    LineNumber.x := 1;
    i := FindTopWindow;
    (Self.MDIChildren[i] as TfrmEditor).synEditor.ExecuteCommand(17, 'A', @LineNumber);
  end;

  SynMR.Editor := (Self.MDIChildren[FindTopWindow] as TfrmEditor).synEditor;

  (Self.MDIChildren[FindTopWindow] as TfrmEditor).CheckSaveStatus;

end; }

procedure TfrmTinnMain.FileExitCmdExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmTinnMain.WindowArrange1Execute(Sender: TObject);
begin
 ArrangeIcons;
end;

procedure TfrmTinnMain.WindowCascade1Execute(Sender: TObject);
begin
 Cascade;
end;

procedure TfrmTinnMain.WindowMinimizeAll1Execute(Sender: TObject);
var
 i : integer;
begin
  for  i := Self.MDIChildCount - 1 downto 0 do
  begin
    Self.MDIChildren[i].WindowState := wsMinimized;
  end;
end;

procedure TfrmTinnMain.WindowTileVertical1Execute(Sender: TObject);
begin
 TileMode := tbVertical;
 Tile;
end;

procedure TfrmTinnMain.WindowTileHorizontal1Execute(Sender: TObject);
begin
 TileMode := tbHorizontal;
 Tile;
end;

procedure TfrmTinnMain.Highlighter1Click(Sender: TObject);
var
 i : integer;
begin
 if (Self.MDIChildCount > 0) then
 begin
   for i := Self.MDIChildCount - 1 downto 0 do
   begin
     if (Self.MDIChildren[i].Active) then
       break;
   end;
   (Self.MDIChildren[i] as TfrmEditor).SetHighlighterStatus(Sender);
   pgFiles.ActivePage.Tag := (Self.MDIChildren[i] as TfrmEditor).SetHighlighterID;
 end
 else
 begin
   if Sender is TComboBox then
     SetSyntaxMenuItem(Trim((Sender as TComboBox).Text))
   else
     SetSyntaxComboBox(StringReplace((Sender as TMenuItem).Caption,'&','', [])); //[rfReplaceAll]));
 end;
end;

procedure TfrmTinnMain.tbSaveClick(Sender: TObject);
var
 i : integer;
begin
	if (pgFiles.PageCount > 0) then
  begin
 		i := FindTopWindow;
 		(Self.MDIChildren[i] as tfrmEditor).FileSaveCmdExecute(Sender);
  end;
end;

procedure TfrmTinnMain.ShowSearchBarExecute(Sender: TObject);
begin
 tbSearchBar.Visible        := Not(tbSearchBar.Visible);
 SearchBar1.Checked         := tbSearchBar.Visible;
 pmShowSearchBar1.Checked   := tbSearchBar.Visible;
end;

procedure TfrmTinnMain.ShowSettingsBarExecute(Sender: TObject);
begin
 tbSettingsBar.Visible      := Not(tbSettingsBar.Visible);
 SettingsBar1.Checked       := tbSettingsBar.Visible;
 pmShowSettingsBar1.Checked := tbSettingsBar.Visible;
end;

procedure TfrmTinnMain.ShowFileBarExecute(Sender: TObject);
begin
 tbFileBar.Visible          := Not(tbFileBar.Visible);
 FileBar1.Checked           := tbFileBar.Visible;
 pmShowFileBar1.Checked     := tbFileBar.Visible;
end;

procedure TfrmTinnMain.ShowRegExBarExecute(Sender: TObject);
begin
	tbRegExFilterBar.Visible  := Not(tbRegExFilterBar.Visible);
 	ShowGrepBar1.Checked      := tbRegExFilterBar.Visible;
 	pmShowRegExBar.Checked    := tbRegExFilterBar.Visible;
end;

procedure TfrmTinnMain.AboutExecute(Sender: TObject);
begin
 with TAboutBox.Create(Self) do
 try
   ShowModal;
 finally
   Free;
 end;
end;

procedure TfrmTinnMain.WMDropFiles(var Msg: TWMDropFiles);
var
  //CFileName: array[0..MAX_PATH] of Char;
  i : integer;
  pntTmp: PChar;
  Size, Count: Integer;
  FileList: TStringList;
begin
 try
  pntTmp := '';
  Count := DragQueryFile(Msg.Drop, $FFFFFFFF, pntTmp, 255);
  FileList := TStringList.Create;
  try
    for i := 0 to Count - 1 do
    begin
    	Size := DragQueryFile(Msg.Drop, i, nil, 0) + 1;
    	pntTmp := StrAlloc(Size);

    	try
    		DragQueryFile(Msg.Drop, i, pntTmp, Size);

    		if FileExists(pntTmp) then
    			FileList.Add(ExpandFileName(pntTmp));
    		finally
    			StrDispose(pntTmp);
    		end;
    	end;

    for i := 0 to FileList.Count - 1 do
    begin
    	OpenFileIntoTinn(FileList.Strings[i]);
    end;
  finally
   	FileList.Free;
  end;
 finally
   DragFinish(Msg.Drop);
 end;
end;


{The basic code contained in the next procedurea,
         which works with the DPR code to allow file association
         and open doubleclicked file in the running instance of app
       was written by Andrius Adamonis.

       I got it and changed to suit my needs.}
procedure TfrmTinnMain.DefaultHandler(var Message);
var
  S: String;
  //handle: THandle;
	//curFile: WIN32_FIND_DATA;
  tmpInfo : TStringList;
  LineNumberJump : integer;
Begin
  With TMessage(Message) Do
  Begin
    If Integer(Msg) = WM_FINDINSTANCE Then begin
      if IsWindowOnTaskabr then
        Result := MyUniqueConst
      else
        result := 0;
    end Else If Msg = WM_OPENEDITOR Then
    begin
      if not IsWindowOnTaskabr then begin
        exit;
      end;
      tmpInfo := TStringList.create;
      SetLength(S, MAX_PATH);
      GlobalGetAtomName(WPARAM, PChar(S), MAX_PATH);
      SetLength(S, StrLen(PChar(S)));
      ShowApplication;
      //ShowMessage(S);

      tmpInfo.CommaText := S;
    	if (tmpInfo.Count = 2) then
      begin
        LineNumberJump := StrToIntDef(tmpInfo.Strings[1], 0);
      	OpenFileIntoTinn(tmpInfo.Strings[0], LineNumberJump);
      end
      else
      	OpenFileIntoTinn(tmpInfo.Strings[0]);
      tmpInfo.Free;
    end
    else if Msg = WM_RESTOREAPP then
    begin
      PostMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
    end
    else
    	Inherited DefaultHandler(Message);
  End;
End;

procedure CorrectFormPosition(fForm: TForm);
begin
  fForm.Left := MIN(MAX(-7,fForm.left-Screen.DesktopLeft),Screen.DesktopWidth-fForm.Width+7)+Screen.DesktopLeft;
  fForm.top := MIN(MAX(0,fForm.top),Screen.DesktopHeight-fForm.Height);
  fForm.Width := MIN(fForm.Width,Screen.DesktopWidth);
  fForm.Height := MIN(fForm.Height,Screen.DesktopHeight);
end;

Procedure TfrmTinnMain.ShowApplication;
Begin
	If IsIconic(Application.Handle) then
  	Application.Restore
  else
    Application.BringToFront;


End;

procedure TfrmTinnMain.LoadFile(iFileName : string; CreateNewChild : boolean = true);
var
 Attributes : word;
 i : integer;
 tmpStr : string;
begin
  if CreateNewChild then
  begin
    TfrmEditor.Create(Self);
    with TTabSheet.Create(Self) do
    begin
      PageControl := pgFiles;
      pgFiles.ActivePageIndex := pgFiles.PageCount -1;
    end;
  end;
  with (Self.MDIChildren[FindTopWindow] as TfrmEditor) do
  begin
    FileName := iFileName;
    WorkingDir := ExtractFilePath(iFileName);
    if FileExists(iFileName) then
    begin
      synEditor.Lines.LoadFromFile(FileName);
      Attributes := FileGetAttr(FileName);
      if ((Attributes and faReadOnly) = faReadOnly) = true then
      begin
        synEditor.ReadOnly := True;
        StatusBar.Panels[1].Text := 'Read Only';
        miToggleReadOnly.Checked := true;
        mpopReadOnly1.Checked := true;
      end;
      SetFileSizeinStatusBar(FileName);
    end;
    synEditor.WordWrap := actToggleWordWrap.Checked;
    SetHighlighterFromFileExt(ExtractFileExt(iFileName));
    synEditor.Modified := False;
    synEditor.SetFocus;
    UpdateCursorPos(synEditor);
    FEditorOptions.AssignTo(synEditor);
    //synEditor.MaxScrollWidth := FLineWidth;
    if (boolHighlightActiveLine) then
      synEditor.ActiveLineColor := TColor(colorHighlightActiveLive)
    else
      synEditor.ActiveLineColor := TColor(clNone);
    SetTitle;
   end;
   tmpStr := StringReplace(iFileName,'&','&&', [rfReplaceAll]);

   pgFiles.Hint := tmpStr;
   pgFiles.ActivePage.Hint := tmpStr;

   if (miToggleReadOnly.Checked) then
   	pgFiles.ActivePage.Caption := '<' + StripPath(pgFiles.ActivePage.Hint) + '>'
   else
   	pgFiles.ActivePage.Caption := StripPath(iFileName);
   pgFiles.ActivePage.Tag := -1;

  UpdateMRU(miRecentFile1, iFileName);
  i := FindTopWindow;
  if i > -1 then
    UpdateMRU((Self.MDIChildren[i] as TfrmEditor).miRecentFiles, iFileName);
end;

procedure TfrmTinnMain.SetFileSizeinStatusBar(iFileName : string);
var
	fileInfo:   _WIN32_FILE_ATTRIBUTE_DATA;
  totalSize:  double; //Int64;
  strSize : string;
  strBitCount : string;
  len : integer;
begin
  if GetFileAttributesEx(PChar(iFileName), GetFileExInfoStandard, @fileInfo) then
  begin
    //totalSize := fileInfo.nFileSizeHigh shl 32 or fileInfo.nFileSizeLow;
    totalSize := fileInfo.nFileSizeHigh shl 32;
    strBitCount := ' KB';
    if (totalSize = 0) then
    begin
      totalSize := fileInfo.nFileSizeLow;
      totalSize := totalSize / 1024;
      strBitCount := ' KB';
    end;
    strSize := 'File size : ' + FormatFloat('#,##0', totalSize) + strBitCount;
    len := length(strSize);

    StatusBar.Panels[2].Width := 80 + len;
    StatusBar.Panels[2].Text := strSize;
  end
  else
    StatusBar.Panels[2].Text := '';


end;

procedure TfrmTinnMain.ToggleReadOnlyExecute(Sender: TObject);
var
 fileAtt : Word;
 fileName : string;
 intCurrentWindow : integer;
begin
	intCurrentWindow := FindTopWindow;
 	(Self.MDIChildren[intCurrentWindow] as tfrmEditor).synEditor.ReadOnly := not((Self.MDIChildren[intCurrentWindow] as tfrmEditor).synEditor.ReadOnly);

 	if ((Self.MDIChildren[intCurrentWindow] as tfrmEditor).synEditor2 <> Nil) then
 		(Self.MDIChildren[intCurrentWindow] as tfrmEditor).synEditor2.ReadOnly := not((Self.MDIChildren[intCurrentWindow] as tfrmEditor).synEditor2.ReadOnly);


 	fileName := (Self.MDIChildren[intCurrentWindow] as tfrmEditor).FileName;
 	fileAtt := FileGetAttr(fileName);
 	if StatusBar.Panels[1].Text = 'Insert' then
 	begin
  	StatusBar.Panels[1].Text := 'Read Only';
   	fileAtt := fileAtt or faReadOnly;
 	end
 	else
 	begin
  	StatusBar.Panels[1].Text := 'Insert';
   	fileAtt := fileAtt and not faReadOnly;
 	end;
	miToggleReadOnly.Checked := not(miToggleReadOnly.Checked);
	(Self.MDIChildren[intCurrentWindow] as tfrmEditor).mpopReadOnly1.Checked := miToggleReadOnly.Checked;

 	FileSetAttr(fileName, fileAtt);

  if (Self.MDIChildren[intCurrentWindow] as tfrmEditor).synEditor.Modified then
  begin
		SetTabTitle('*');
    (Self.MDIChildren[intCurrentWindow] as tfrmEditor).CheckSaveStatus;
  end
  else
  begin
  	SetTabTitle('');
    (Self.MDIChildren[intCurrentWindow] as tfrmEditor).CheckSaveStatus;

  end

end;

procedure TfrmTinnMain.FormCreate(Sender: TObject);
var
 i, j : integer;
 SyntaxItem : TMenuItem;
 tstr : string;
 tmpName : string;
begin
 DragAcceptFiles(Handle, True);
 StartingUp := True;
 MRUList := TStringList.Create;
 ProjectMRUList := TStringList.Create;
 FEditorOptions := TSynEditorOptionsContainer.Create(nil);
 ReadIniFile;
 SetDefaultEditorOptions;
 FilterList := TStringList.create;


 // Make sure that we have some filters
 FileFilters := dmSyn.SynSQL.DefaultFilter;//'All Files (*.*)|*.*|Text Files (*.txt)|*.txt';
 i := 0;
 for j := 0 to dmSyn.ComponentCount - 1 do
 begin
   if not (dmSyn.Components[j] is TSynCustomHighlighter) then
     continue;
   tmpName := (dmSyn.Components[j] as TSynCustomHighlighter).GetLanguageName;
   if (tmpName = 'Java') then
    begin
      if ((dmSyn.Components[j] as TSynCustomHighlighter).Name = 'SynCSharp') then
        tmpName := 'C Sharp';
    end;

   if (tmpName = 'General Multi-Highlighter') then
   begin
    tmpName := (dmSyn.Components[j] as TSynMultiSyn).DefaultLanguageName;
   end;


   cbSyntax.Items.Add(tmpName);
 end;

 	cbSyntax.Sorted := true;
 	for j := 0 to cbSyntax.Items.Count - 1 do
 	begin
     tmpName := cbSyntax.Items.Strings[j];
 	   SyntaxItem := newItem(
              tmpName,
              0, false, true, Highlighter1Click, 0,
              format('SynItem%d',[i]));
   	SyntaxItem.Tag := i;
   	miSetSytax.Insert(i, SyntaxItem);
   	inc(i);
 	end;

  // Set the file filters
  // I am using the cbSyntax box because it is sorted.
  for i := 0 to cbSyntax.Items.Count - 1 do
  begin
    for j := 0 to dmSyn.ComponentCount - 1 do
 		begin
   		if not (dmSyn.Components[j] is TSynCustomHighlighter) then
     		continue;
   		tmpName := (dmSyn.Components[j] as TSynCustomHighlighter).GetLanguageName;
   		if (tmpName = 'Java') then
    	begin
      	if ((dmSyn.Components[j] as TSynCustomHighlighter).Name = 'SynCSharp') then
        	tmpName := 'C Sharp';
    	end;

   		if (tmpName = 'General Multi-Highlighter') then
   		begin
    		tmpName := (dmSyn.Components[j] as TSynMultiSyn).DefaultLanguageName;
   		end;


      if (tmpName = cbSyntax.Items[i]) then
      	if (tmpName <> 'HTMLComplex') and (tmpName <> 'PHPcomplex') then
        begin
      		tstr := trim((dmSyn.Components[j] as TSynCustomHighlighter).DefaultFilter);
          SetFileFilter(tstr);
        end;
    end;

  end;
 	SaveDialog.Filter := FileFilters;
  ModifyOnCreate;
end;

procedure TfrmTinnMain.SetFileFilter(iFilter : string);
begin
	if (iFilter <> '*.*') then
  begin
  	FilterList.Add(iFilter);
 		FileFilters := FileFilters + '|' + iFilter;
  end;
end;

procedure TfrmTinnMain.FindIniFilePath;
begin
  // Ini file can be located in any of the following places in this order
  // 1) Command Line
  // 2) Documents and Settings folder for current user
  // 3) Executable directory
  // 4) Windows directory

  // After finding it, save the path to IniFilePath to be used when writing out the ini file
  if FileExists(ExtractFilePath(ParamStr(0))+'Tinn.ini') then
    iniFilePath:=ExtractFilePath(ParamStr(0));

end;

procedure TfrmTinnMain.ReadIniFile;
var
  TopUp : integer;
  SearchList : TStringList;
  i : integer;
  intPos : integer;
  tmpStr : string;
  stream : TStream;
//  WinDir: array [0..MAX_PATH-1] of char;
  ShortcutsFileName : string;
begin

  FindIniFilePath;


  // Read the ini file for settings
  iniFile := TIniFile.create(iniFilePath + 'Tinn.ini');

  Self.WindowState := TWindowState(iniFile.ReadInteger('Form Position','WindowState',0));
  if (Self.WindowState = wsNormal) then
  begin
  	Self.Top                  := iniFile.ReadInteger('Form Position','Top',0);
  	Self.Left                 := iniFile.ReadInteger('Form Position','Left',0);
  	Self.Width                := iniFile.ReadInteger('Form Position','Width', 730);
  	Self.Height               := iniFile.ReadInteger('Form Position','Height', 537);
  end;
  FontName                    := iniFile.ReadString('Font Settings','Name','Courier New');
  FontSize                    := iniFile.ReadInteger('Font Settings','Size',10);
  FontColor                   := iniFile.ReadInteger('Font Settings','Color', 0);

  WorkingDir                  := trim(iniFile.ReadString('App Settings','LastPath', '')); //'c:\'));
  TopUp                       := iniFile.ReadInteger('App Settings','AlwaysOnTop', 0);
  if TopUp = 1 then
  	OnTopcmdExecute(Self);
  // File Bar
  tbFileBar.Visible           := iniFile.ReadBool('App Settings','ShowFileBar',True);
  pmShowFileBar1.Checked      := tbFileBar.Visible;
  FileBar1.Checked            := tbFileBar.Visible;
  tbFileBar.Left              := iniFile.ReadInteger('App Settings','FileBarPosition', tbFileBar.Left);
  tbFileBar.Top               := iniFile.ReadInteger('App Settings','FileBarPositionTop', tbFileBar.Top);

  // Search Bar
  tbSearchBar.Visible         := iniFile.ReadBool('App Settings','ShowSearchBar',True);
  pmShowSearchBar1.Checked    := tbSearchBar.Visible;
  SearchBar1.Checked          := tbSearchBar.Visible;
  tbSearchBar.Left            := iniFile.ReadInteger('App Settings','SearchBarPosition', tbSearchBar.Left);
  tbSearchBar.Top             := iniFile.ReadInteger('App Settings','SearchBarPositionTop', tbSearchBar.Top);

  // Settings Bar
  tbSettingsBar.Visible       := iniFile.ReadBool('App Settings','ShowSettingsBar',True);
  pmShowSettingsBar1.Checked  := tbSettingsBar.Visible;
  SettingsBar1.Checked        := tbSettingsBar.Visible;
  tbSettingsBar.Left          := iniFile.ReadInteger('App Settings','SettingsBarPosition', tbSettingsBar.Left);
  tbSettingsBar.Top           := iniFile.ReadInteger('App Settings','SettingsBarPositionTop', tbSettingsBar.Top);

  // Filter Bar
  tbRegExFilterBar.Visible    := iniFile.ReadBool('App Settings','ShowRegExBar',True);
  pmShowRegExBar.Checked      := tbRegExFilterBar.Visible;
  ShowGrepBar1.Checked       := tbRegExFilterBar.Visible;
  tbRegExFilterBar.Left       := iniFile.ReadInteger('App Settings','RegExBarPosition', tbRegExFilterBar.Left);
  tbRegExFilterBar.Top        := iniFile.ReadInteger('App Settings','RegExBarPositionTop', tbRegExFilterBar.Top);

  // Macro Bar
  tbMacroBar.Visible          := iniFile.ReadBool('App Settings','ShowMacroBar',True);
  pmMacroBar.Checked          := tbMacroBar.Visible;
  ToggleMacroBar1.Checked     := tbMacroBar.Visible;
  tbMacroBar.Left             := iniFile.ReadInteger('App Settings','MacroBarPosition', tbMacroBar.Left);
  tbMacroBar.Top              := iniFile.ReadInteger('App Settings','MacroBarPositionTop', tbMacroBar.Top);

  // Misc
  miStartwithnewfile.Checked  := iniFile.ReadBool('App Settings','StartWithNewFile', true);

  miStartFileMaxed.Checked    := iniFile.ReadBool('App Settings','OpenMaxed', true);
  boolOpenMaxed               := miStartFileMaxed.Checked;

  miShowLineNum.Checked       := iniFile.ReadBool('App Settings','ShowLineNumbers', false);

  boolRemoveExtentions        := iniFile.ReadBool('App Settings','RemoveExtentions', false);
  boolUndoAfterSave           := iniFile.ReadBool('App Settings','UndoAfterSave', false);
  boolMinimizeTinnAfterLastFile := iniFile.ReadBool('App Settings','MinimizeAfterLastFile', false);

  boolHighlightActiveLine     := iniFile.ReadBool('App Settings', 'HighlightActiveLine', false);
  colorHighlightActiveLive    := iniFile.ReadInteger('App Settings', 'HighlightActiveLineColor', Tcolor(clYellow));

  boolHighlightAllWords       := iniFile.ReadBool('App Settings', 'HighlightAllWords', true);
  colorHighlightAllWords      := iniFile.ReadInteger('App Settings', 'HighlightAllWordsColor', Tcolor(clSilver));

  actToggleWordWrap.Checked   := iniFile.ReadBool('App Settings', 'WordWrap', false);

  pgFiles.Style                       := TTabStyle(iniFile.ReadInteger('App Settings','TabStyle', 0));
  pgFiles.Align                       := TAlign(iniFile.ReadInteger('App Settings','TabPos', 1));
  actToggleTabVisible.Checked         := iniFile.ReadBool('App Settings','ViewTabs', true);
  SetTabOptions;

  gStartComment                       := iniFile.ReadString('App Settings', 'StartComment', '');
  gEndComment                         := iniFile.ReadString('App Settings', 'EndComment', '');

  // Editor Options

  FEditorOptions.Gutter.Color         := iniFile.ReadInteger('Editor Settings', 'GutterColor', FEditorOptions.Gutter.Color);
  FEditorOptions.Gutter.Font.Name     := iniFile.ReadString('Editor Settings', 'GutterFont', 'Courier New');
  FEditorOptions.Gutter.Font.Size     := iniFile.ReadInteger('Editor Settings', 'GutterFontSize', 8);
  FEditorOptions.Gutter.Font.Color    := iniFile.ReadInteger('Editor Settings', 'GutterFontColor', 0);
  FEditorOptions.Gutter.Width         := iniFile.ReadInteger('Editor Settings', 'GutterWidth', 20);
 	FEditorOptions.Gutter.DigitCount    := iniFile.ReadInteger('Editor Settings', 'GutterDigitCount', 2);
  FEditorOptions.Gutter.AutoSize      := iniFile.ReadBool('Editor Settings', 'GutterAutoSize', True);  //JCFaria
 	FEditorOptions.Gutter.LeadingZeros  := iniFile.ReadBool('Editor Settings', 'GutterLeadingZeros', false);
 	FEditorOptions.Gutter.ZeroStart     := iniFile.ReadBool('Editor Settings', 'GutterZeroStart', false);
 	FEditorOptions.Gutter.Visible       := iniFile.ReadBool('Editor Settings', 'GutterVisible', true);

  FEditorOptions.HideSelection        := iniFile.ReadBool('Editor Settings', 'HideSelection', false);
  FEditorOptions.ExtraLineSpacing     := iniFile.ReadInteger('Editor Settings', 'ExtraLineSpacing', 0);
  FEditorOptions.RightEdge            := iniFile.ReadInteger('Editor Settings', 'RightEdge', 80);
  FEditorOptions.RightEdgeColor       := iniFile.ReadInteger('Editor Settings', 'RightEdgeColor', FEditorOptions.RightEdgeColor);
  FEditorOptions.WantTabs             := iniFile.ReadBool('Editor Settings', 'WantTabs', true);
  FEditorOptions.InsertCaret          := TSynEditCaretType(iniFile.ReadInteger('Editor Settings', 'InsertCaret', 0));
  FEditorOptions.OverWriteCaret       := TSynEditCaretType(iniFile.ReadInteger('Editor Settings', 'OverWriteCaret', 3));
  FEditorOptions.SelectedColor.Background := iniFile.ReadInteger('Editor Settings', 'SelectedColorBackground', FEditorOptions.SelectedColor.Background);
  FEditorOptions.SelectedColor.Foreground := iniFile.ReadInteger('Editor Settings', 'SelectedColorForeground', FEditorOptions.SelectedColor.Foreground);
  FEditorOptions.TabWidth             := iniFile.ReadInteger('Editor Settings', 'TabWidth', 2);
  FEditorOptions.Options              := TSynEditorOptions(iniFile.ReadInteger('Editor Settings', 'Options', 25560082));

  // Search Settings
  SearchListMax                       := iniFile.ReadInteger('Search Settings', 'SearchListMax', 6);
  boolSearchFromCaret                 := iniFile.ReadBool('Search Settings', 'SearchFromCaret', false);
  boolSearchBackwards                 := iniFile.ReadBool('Search Settings', 'SearchBackwards', false);
  boolSearchCaseSensitive             := iniFile.ReadBool('Search Settings', 'SearchCaseSensitive', false);
  boolSearchSelectionOnly             := iniFile.ReadBool('Search Settings', 'SearchSelectionOnly', false);
  boolSearchTextAtCaret               := iniFile.ReadBool('Search Settings', 'SearchTextAtCaret', false);
  boolSearchWholeWords                := iniFile.ReadBool('Search Settings', 'SearchWholeWords', false);
  boolSearchRegex                     := iniFile.ReadBool('Search Settings', 'SearchRegex', false);
  boolRememberSearchList              := iniFile.ReadBool('Search Settings', 'RememberSearchList', false);
  gboolSearchOpenFiles                := iniFile.ReadBool('Search Settings', 'SearchOpenFiles', true );
  gboolSearchDirectory                := iniFile.ReadBool('Search Settings', 'SearchDirectory', false);
  gboolSearchInSub                    := iniFile.ReadBool('Search Settings', 'SearchInSub', false );



  if (boolRememberSearchList) then
  begin
    SearchList := TStringList.Create;
    iniFile.ReadSectionValues('SearchTextHistory', SearchList);
    if (SearchList.Count > 0) then
    begin
      for i := 0 to SearchList.Count - 1 do
      begin
        tmpStr := SearchList.Strings[i];
        intPos := pos('=', tmpStr);
        tmpStr := copy(tmpStr, intPos + 1, length(tmpStr));
        if (i = 0) then
          strSearchTextHistory := tmpStr
        else
          strSearchTextHistory := strSearchTextHistory + #10 + tmpStr;
      end;
    end
    else
      strSearchTextHistory := '';
  end;

  SearchList := TStringList.Create;
  strSearchDirHistory := '';
  iniFile.ReadSectionValues('SearchDirHistory', SearchList);
  if (SearchList.Count > 0) then
  begin
    for i := 0 to SearchList.Count - 1 do
    begin
      tmpStr := SearchList.Strings[i];
      intPos := pos('=', tmpStr);
      tmpStr := copy(tmpStr, intPos + 1, length(tmpStr));
      if (i = 0) then
        strSearchDirHistory := tmpStr
      else
        strSearchDirHistory := strSearchDirHistory + #10 + tmpStr;
    end;
  end
  else
    strSearchDirHistory := '';

  SearchList := TStringList.Create;
  iniFile.ReadSectionValues('SearchFileMaskHistory', SearchList);
  if (SearchList.Count > 0) then
  begin
    for i := 0 to SearchList.Count - 1 do
    begin
      tmpStr := SearchList.Strings[i];
      intPos := pos('=', tmpStr);
      tmpStr := copy(tmpStr, intPos + 1, length(tmpStr));
      if (i = 0) then
        strSearchFileMaskHistory := tmpStr
      else
        strSearchFileMaskHistory := strSearchFileMaskHistory + #10 + tmpStr;
    end;
  end
  else
    strSearchFileMaskHistory := '';

//  SetString(ShortcutsFileName, WinDir, GetWindowsDirectory(WinDir, MAX_PATH));
  ShortcutsFileName := iniFilePath + '\shortcuts.tinn';
  if FileExists(ShortcutsFileName) then
  begin
    stream := TFileStream.Create(ShortcutsFileName, fmOpenRead);
    FEditorOptions.Keystrokes.LoadFromStream(stream);
    stream.free;
  end;

  MRUmax := iniFile.ReadInteger('App Settings','MaxFiles', 6);
  // Read the list of MRU docs and add them to the menu and the drop down menu
  iniFile.ReadSectionValues('MRU',MRUList);
  BuildMRU(miRecentFile1);

  // Do the same for Projects
  iniFile.ReadSectionValues('ProjectMRU', ProjectMRUList);
  BuildProjectMRU(miProjectReopen1);

  CorrectFormPosition(Self);
end;

procedure TfrmTinnMain.SetDefaultEditorOptions;
begin

  //FEditorOptions.Options := SynEditorOptions;
  //FEditorOptions.Options := FEditorOptions.Options - [eoAltSetsColumnMode];
  FEditorOptions.Options    := FEditorOptions.Options + [eoTabIndent];
  FEditorOptions.Options    := FEditorOptions.Options - [eoDropFiles];
  FEditorOptions.WantTabs   := True;
  FEditorOptions.Font.Size  := FontSize;
  FEditorOptions.Font.Name  := FontName;
  FEditorOptions.Font.Color := FontColor;
  FEditorOptions.Gutter.ShowLineNumbers := miShowLineNum.Checked;
  if actShowSpecialChar.Checked then
  	FEditorOptions.Options  := FEditorOptions.Options + [eoShowSpecialChars]
  else
    FEditorOptions.Options  := FEditorOptions.Options - [eoShowSpecialChars];
end;


procedure TfrmTinnMain.SetTabOptions;
begin
	// Check the proper settings for the menu options based on the ini file
  if (integer(pgFiles.Align) = 1) then
  	tabPosUp1.Checked   := true
  else
  	tabPosDown1.Checked := true;

  case (integer(pgFiles.Style)) of
  	0 : tsStandard1.Checked     := true;
		1	:	tsButtons1.Checked      := true;
  	2	:	tsFlatButtons1.Checked  := true;
  else
  	tsStandard1.Checked         := true;
  end;

  pgFiles.Visible               := actToggleTabVisible.Checked;

end;

procedure TfrmTinnMain.BuildMRU(var ioMenuItem : TMenuItem);
var
 i : integer;
 MRUItem : TMenuItem;
begin
	//ShowMessage('Building MRU');
 pmMRU.Items.Clear;
 ioMenuItem.Clear;
 if MRUList.Count > 0 then
 begin
   for i := 0 to MRUList.Count -1  do
   begin
     if i < MRUmax then
     begin
       MRUItem := newItem(
              MRUList.Values[IntToStr(i)],
              0, false, true, RecentFileClick, 0,
              format('File%d', [i]));
       MRUItem.Tag := i;
       ioMenuItem.Add(MRUItem);
       MRUItem := newItem(
              MRUList.Values[IntToStr(i)],
              0, false, true, RecentFileClick, 0,
              format('File%d', [i]));
       pmMRU.Items.Add(MRUItem);
     end;
   end;
 end;
end;

procedure TfrmTinnMain.UpdateMRU(var ioMenuItem : TMenuItem; iFileName : string);
var
 i, j : integer;
 tmplst : TStringList;
 tmpStr : string;
begin
  if denyUpdateMRU then exit;
  tmplst := TStringList.create;
  //Put the opened file in at the top of the list
  tmpStr := StringReplace(iFileName,'&','&&', [rfReplaceAll]);
  if FileExists(iFileName) then
  begin
    tmplst.Insert(0,'0=' + tmpStr);
    j := 1;
  end
  else
    j := 0;
 //Store Data and remove from menu
 for i := 0 to MRUList.Count - 1 do
 begin
   //if (tmpStr <>  MRUList.Values[IntToStr(i)]) then
   if CompareText(tmpStr, MRUList.Values[IntToStr(i)]) <> 0 then
   begin
     tmplst.Add(IntToStr(j) + '=' + MRUList.Values[IntToStr(i)]);
     inc(j);
   end;
 end;
 MRUList.Text := tmplst.Text;
 BuildMRU(ioMenuItem);
 tmplst.free;
end;

procedure TfrmTinnMain.RecentFileClick(Sender: TObject);
var
 tmpstr : string;
begin
  tmpstr := StringReplace(TMenuItem(Sender).Caption, '&', '', []); //rfReplaceAll]);
  tmpstr := StringReplace(tmpstr, '&&', '&', [rfReplaceAll]);
  if FileExists(tmpstr) then
    OpenFileIntoTinn(tmpstr)
  else begin
    // Take it off the MRU list
    ShowMessage('File does not exist.' + #10#13 + 'Removing it from MRU' + #10#13 + tmpstr);
    UpdateMRU(miRecentFile1, tmpstr);
  end;

end;

function TfrmTinnMain.FindWindowByName(iName : string) : integer;
var
  i : integer;
  Found : boolean;
  tmpCaption : string;
begin
  Found := false;
  for i := Self.MDIChildCount-1 downto 0 do
  begin
    tmpCaption := frmEditor.ScrubCaption(Self.MDIChildren[i].Caption);
    if (UpperCase(tmpCaption) = UpperCase(iName)) then
    begin
      Found := true;
      break;
    end;
  end;
  if (Found) then
    result := i
  else
    result := -1;
end;

function TfrmTinnMain.FindTopWindow : integer;
var
 i : integer;
 Found : boolean;
begin
 Found := false;
 for i := Self.MDIChildCount-1 downto 0 do
 begin
   if (Self.MDIChildren[i].Active = true) then
   begin
     Found := true;
     break;
   end;
 end;
 if (Found) then
   result := i
 else
   result := -1;
end;

procedure TfrmTinnMain.OnTopcmdExecute(Sender: TObject);
begin
 if AlwaysOnTop1.Checked = False then
 begin
   SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0,SWP_NOSIZE or SWP_NOMOVE );
   AlwaysOnTop1.Checked     := true;
   AlwaysOnTop1.ImageIndex  := 19;
   tbOnTop.ImageIndex       := 19;
 end
 else
 begin
   SetWindowPos( Handle, HWND_NOTOPMOST, 0, 0, 0, 0,SWP_NOSIZE or SWP_NOMOVE );
   AlwaysOnTop1.Checked     := false;
   AlwaysOnTop1.ImageIndex  := 16;
   tbOnTop.ImageIndex       := 16;
 end;
 tbOnTop.Down := AlwaysOnTop1.Checked;
end;

procedure TfrmTinnMain.UpdateCursorPos(Sender : TSynEdit);
var
 CharPos: TBufferCoord;
 CharPos2 : TDisplayCoord;
 LineCount : Integer;
begin
 CharPos := Sender.CaretXY;
 CharPos2 := Sender.DisplayXY;
 LineCount := Sender.Lines.Count;
 if LineCount = 0 then LineCount := 1;
 StatusBar.Panels[0].Text := Format('Ln %d/%d: Col %d ', [CharPos.Line, LineCount , CharPos2.Column]);
end;

procedure TfrmTinnMain.SetSyntaxMenuItem(iSynName : string);
var
 i : integer;
 SynName : string;
begin
 for i := 0 to miSetSytax.Count - 1 do
 begin
   SynName := StringReplace(miSetSytax.Items[i].Caption,'&','', []); //[rfReplaceAll]);
   miSetSytax.Items[i].Checked := (SynName = iSynName);
   miSetSytax.Items[i].Default := miSetSytax.Items[i].Checked;
 end;  
end;

procedure TfrmTinnMain.SetSyntaxComboBox(iSynName : string);
var
 i : integer;
begin
 for i := 0 to cbSyntax.Items.Count - 1 do
 begin
   if cbSyntax.Items[i] = iSynName then
     cbSyntax.ItemIndex := i;
 end;
end;

procedure TfrmTinnMain.tbFindClick(Sender: TObject);
var
 i : integer;
begin
 i := FindTopWindow;
 (Self.MDIChildren[i] as tfrmEditor).FindExecute(Sender);
end;

procedure TfrmTinnMain.tbReplaceClick(Sender: TObject);
var
 i : integer;
begin
 i := FindTopWindow;
 (Self.MDIChildren[i] as tfrmEditor).ReplaceExecute(Sender);
end;

procedure TfrmTinnMain.tbGotoClick(Sender: TObject);
var
 i : integer;
begin
 i := FindTopWindow;
 (Self.MDIChildren[i] as tfrmEditor).GotoLineExecute(Sender);
end;

procedure TfrmTinnMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  boolClose : boolean;
begin
  boolClose := true;
  if (frmProjectSpace <> Nil) then
  begin
    if (frmProjectSpace.boolProjectChanged) then
    begin
      boolClose := SaveModifiedProjectQuery;
    end;
  end;
  if (boolClose) then
  begin
	  WriteIniFile;
    CanClose := true;
  end;
end;

function TfrmTinnMain.SaveModifiedProjectQuery : boolean;
var
  SaveResp: Integer;
begin
  result := false;
  SaveResp := MessageDlg(Format('Save changes to %s?', [ProjectName]),
    mtConfirmation, [mbYes, mbNo], 0); //mbYesNoCancel  , mbYesToAll, mbNoToAll
  case SaveResp of
    idYes:
      begin
        frmProjectSpace.SaveProject;
        result := true;
      end;
    idNo: result := true;
    //idCancel: result := false; //Abort;
  end;
end;

procedure TfrmTinnMain.WriteIniFile;
var
 i : integer;
 SearchList : TStringList;
// WinDir: array [0..MAX_PATH-1] of char;
 ShortcutsFileName : string;
 stream : TStream;
begin
  // Form postion
  iniFile.WriteInteger('Form Position','Top',Self.Top);
  iniFile.WriteInteger('Form Position','Left',Self.Left);
  iniFile.WriteInteger('Form Position','Width',Self.Width);
  iniFile.WriteInteger('Form Position','Height',Self.Height);
  iniFile.WriteInteger('Form Position','WindowState', integer(Self.WindowState));

  // Font info
  iniFile.WriteString('Font Settings','Name', FontName);
  iniFile.WriteInteger('Font Settings','Size', FontSize);
  iniFile.WriteInteger('Font Settings','Color', FontColor);

  iniFile.WriteString('App Settings','LastPath', WorkingDir);

  if AlwaysOnTop1.Checked  = true then
    iniFile.WriteInteger('App Settings','AlwaysOnTop', 1)
  else
    iniFile.WriteInteger('App Settings','AlwaysOnTop', 0);

  // Max files in MRU
  iniFile.WriteInteger('App Settings','MaxFiles', MRUmax);

  // Toolbars
  iniFile.WriteBool('App Settings','ShowFileBar',tbFileBar.Visible);
  iniFile.WriteInteger('App Settings','FileBarPosition',tbFileBar.Left);
  iniFile.WriteInteger('App Settings','FileBarPositionTop',tbFileBar.Top);
  iniFile.WriteBool('App Settings','ShowSearchBar',tbSearchBar.Visible);
  iniFile.WriteInteger('App Settings','SearchBarPosition',tbSearchBar.Left);
  iniFile.WriteInteger('App Settings','SearchBarPositionTop',tbSearchBar.Top);
  iniFile.WriteBool('App Settings','ShowSettingsBar',tbSettingsBar.Visible);
  iniFile.WriteInteger('App Settings','SettingsBarPosition',tbSettingsBar.Left);
  iniFile.WriteInteger('App Settings','SettingsBarPositionTop',tbSettingsBar.Top);
  iniFile.WriteBool('App Settings','ShowRegExBar',tbRegExFilterBar.Visible);
  iniFile.WriteInteger('App Settings','RegExBarPosition',tbRegExFilterBar.Left);
  iniFile.WriteInteger('App Settings','RegExBarPositionTop',tbRegExFilterBar.Top);
  iniFile.WriteBool('App Settings','ShowMacroBar',tbMacroBar.Visible);
  iniFile.WriteInteger('App Settings','MacroBarPosition',tbMacroBar.Left);
  iniFile.WriteInteger('App Settings','MacroBarPositionTop',tbMacroBar.Top);

  // Tabs
  iniFile.WriteInteger('App Settings','TabStyle', integer(pgFiles.Style));
  iniFile.WriteInteger('App Settings','TabPos', integer(pgFiles.Align));
  iniFile.WriteBool('App Settings','ViewTabs', actToggleTabVisible.Checked);

  // Misc
  iniFile.WriteBool('App Settings','StartWithNewFile', miStartwithnewfile.Checked);
  iniFile.WriteBool('App Settings','OpenMaxed', miStartFileMaxed.Checked);
  iniFile.WriteBool('App Settings','ShowLineNumbers', miShowLineNum.Checked);
  iniFile.WriteBool('App Settings','RemoveExtentions', boolRemoveExtentions);
  iniFile.WriteBool('App Settings','UndoAfterSave', boolUndoAfterSave);
  iniFile.WriteBool('App Settings','MinimizeAfterLastFile', boolMinimizeTinnAfterLastFile);
  iniFile.WriteBool('App Settings', 'HighlightActiveLine', boolHighlightActiveLine);
  iniFile.WriteInteger('App Settings', 'HighlightActiveLineColor', Tcolor(colorHighlightActiveLive));

  iniFile.WriteBool('App Settings', 'HighlightAllWords', boolHighlightAllWords);
  iniFile.WriteInteger('App Settings', 'HighlightAllWordsColor', Tcolor(colorHighlightAllWords));


  iniFile.WriteBool('App Settings', 'WordWrap', actToggleWordWrap.Checked);
  iniFile.WriteString('App Settings', 'StartComment', gStartComment);
  iniFile.WriteString('App Settings', 'EndComment', gEndComment);

  // Editor settings
  iniFile.WriteFloat('Editor Settings', 'GutterColor', FEditorOptions.Gutter.Color);
  iniFile.WriteString('Editor Settings', 'GutterFont', FEditorOptions.Gutter.Font.Name);
  iniFile.WriteInteger('Editor Settings', 'GutterFontSize', FEditorOptions.Gutter.Font.Size);
  iniFile.WriteInteger('Editor Settings', 'GutterFontColor', FEditorOptions.Gutter.Font.Color);
  iniFile.WriteInteger('Editor Settings', 'GutterWidth', FEditorOptions.Gutter.Width);
  iniFile.WriteInteger('Editor Settings', 'GutterDigitCount', FEditorOptions.Gutter.DigitCount);
  iniFile.WriteBool('Editor Settings', 'GutterAutoSize', FEditorOptions.Gutter.AutoSize);  //JCFaria 
  iniFile.WriteBool('Editor Settings', 'GutterLeadingZeros', FEditorOptions.Gutter.LeadingZeros);
  iniFile.WriteBool('Editor Settings', 'GutterZeroStart', FEditorOptions.Gutter.ZeroStart);
  iniFile.WriteBool('Editor Settings', 'GutterVisible', FEditorOptions.Gutter.Visible);

  iniFile.WriteBool('Editor Settings', 'HideSelection', FEditorOptions.HideSelection);
  iniFile.WriteInteger('Editor Settings', 'ExtraLineSpacing', FEditorOptions.ExtraLineSpacing);
  iniFile.WriteInteger('Editor Settings', 'RightEdge', FEditorOptions.RightEdge);
  iniFile.WriteInteger('Editor Settings', 'RightEdgeColor', FEditorOptions.RightEdgeColor);
  iniFile.WriteBool('Editor Settings', 'WantTabs', FEditorOptions.WantTabs);
  iniFile.WriteInteger('Editor Settings', 'InsertCaret', Integer(FEditorOptions.InsertCaret));
  iniFile.WriteInteger('Editor Settings', 'OverwriteCaret', Integer(FEditorOptions.OverwriteCaret));
  iniFile.WriteInteger('Editor Settings', 'SelectedColorBackground', FEditorOptions.SelectedColor.Background);
  iniFile.WriteInteger('Editor Settings', 'SelectedColorForeground', FEditorOptions.SelectedColor.Foreground);
  iniFile.WriteInteger('Editor Settings', 'TabWidth', FEditorOptions.TabWidth);
  iniFile.WriteInteger('Editor Settings', 'Options', Integer(FEditorOptions.Options));

  //iniFile.WriteInteger('Editor Settings', 'LineWidth', FLineWidth);

  // Search Settings
  iniFile.WriteBool('Search Settings', 'SearchFromCaret', boolSearchFromCaret);
  iniFile.WriteBool('Search Settings', 'SearchBackwards', boolSearchBackwards);
  iniFile.WriteBool('Search Settings', 'SearchCaseSensitive', boolSearchCaseSensitive);
  iniFile.WriteBool('Search Settings', 'SearchSelectionOnly', boolSearchSelectionOnly);
  iniFile.WriteBool('Search Settings', 'SearchTextAtCaret', boolSearchTextAtCaret);
  iniFile.WriteBool('Search Settings', 'SearchWholeWords', boolSearchWholeWords);
  iniFile.WriteBool('Search Settings', 'SearchRegex', boolSearchRegex);
  iniFile.WriteBool('Search Settings', 'RememberSearchList', boolRememberSearchList);
  iniFile.WriteInteger('Search Settings', 'SearchListMax', SearchListMax);
  iniFile.WriteBool('Search Settings', 'SearchOpenFiles', gboolSearchOpenFiles);
  iniFile.WriteBool('Search Settings', 'SearchDirectory', gboolSearchDirectory);
  iniFile.WriteBool('Search Settings', 'SearchInSub', gboolSearchInSub);

  iniFile.EraseSection('SearchTextHistory');
  if (boolRememberSearchList) then
  begin
    SearchList := TStringList.Create;
    SearchList.Text := strSearchTextHistory;
    i := 0;
    while (SearchList.Count >= 1) and  (i < SearchListMax) do
    begin
      if (trim(SearchList.Strings[0]) <> '') then
      begin
        IniFile.WriteString('SearchTextHistory',IntToStr(i), SearchList.Strings[0]);
        inc(i);
      end;
      SearchList.Delete(0);
    end;
    SearchList.Free;
  end;

  iniFile.EraseSection('SearchDirHistory');
  SearchList := TStringList.Create;
  SearchList.Text := strSearchDirHistory;
  i := 0;
  while (SearchList.Count >= 1) do
  begin
    if (trim(SearchList.Strings[0]) <> '') then
    begin
      IniFile.WriteString('SearchDirHistory',IntToStr(i), SearchList.Strings[0]);
      inc(i);
    end;
    SearchList.Delete(0);
  end;
  SearchList.Free;

  iniFile.EraseSection('SearchFileMaskHistory');
  SearchList := TStringList.Create;
  SearchList.Text := strSearchFileMaskHistory;
  i := 0;
  while (SearchList.Count >= 1) do
  begin
    if (trim(SearchList.Strings[0]) <> '') then
    begin
      IniFile.WriteString('SearchFileMaskHistory',IntToStr(i), SearchList.Strings[0]);
      inc(i);
    end;
    SearchList.Delete(0);
  end;
  SearchList.Free;

//  SetString(ShortcutsFileName, WinDir, GetWindowsDirectory(WinDir, MAX_PATH));
  ShortcutsFileName := iniFilePath + '\shortcuts.tinn';
  if FileExists(ShortcutsFileName) then
  	DeleteFile(ShortcutsFileName);
  stream := TFileStream.Create(ShortcutsFileName, fmCreate);
  FEditorOptions.Keystrokes.SaveToStream(stream);
  stream.free;

  iniFile.EraseSection('MRU');
  i := 0;
  while (MRUList.Count >= 1) and  (i < MRUmax) do
  begin
    IniFile.WriteString('MRU',IntToStr(i),MRUList.Values[IntToStr(i)]);
    inc(i);
    MRUList.Delete(0);
  end;

  iniFile.EraseSection('ProjectMRU');
  i := 0;
  while (ProjectMRUList.Count >= 1) and  (i < MRUmax) do
  begin
    IniFile.WriteString('ProjectMRU',IntToStr(i), ProjectMRUList.Values[IntToStr(i)]);
    inc(i);
    ProjectMRUList.Delete(0);
  end;
  if Assigned(frmExplorer) then
    frmExplorer.SavePosition;
  if Assigned(externalTools) then
    externalTools.StoreToFile(iniFile);
  iniFile.free;
end;

procedure TfrmTinnMain.pgFilesChange(Sender: TObject);
var
 tmpstr,vGlobalSearch : string;
 i : integer;
begin
	// Bring the proper window up top
	{tmpstr := pgFiles.ActivePage.Hint;
 	i := FindWindowByName(tmpstr);
 	if i > -1 then
 	begin
  	if Self.MDIChildren[i].WindowState = wsMinimized then
    	Self.MDIChildren[i].WindowState := wsNormal
   	else
     	Self.MDIChildren[i].BringToFront;
  end;
  pgFiles.Hint := tmpstr;
  SynMR.Editor := (Self.MDIChildren[FindTopWindow] as TfrmEditor).synEditor; }
  // Code tweaked from Marco

  if Assigned(frmExplorer) then
    frmExplorer.Editor := nil;
      
  if Assigned(pgFiles.ActivePage) then
  begin
    tmpstr := pgFiles.ActivePage.Hint;
    i := FindWindowByName(tmpstr);
    if i > -1 then
    begin
     if Self.MDIChildren[i].WindowState = wsMinimized then
       Self.MDIChildren[i].WindowState := wsNormal
      else
      begin
       // Check if the active form (position 0) is maximized
       if  Self.MDIChildren[0].WindowState = wsMaximized then
       begin
         // Size new window to fit mainform
         Self.MDIChildren[i].Width := Width;
         Self.MDIChildren[i].Height := Height;
       end;
      Self.MDIChildren[i].BringToFront;
      end
    end;
    pgFiles.Hint := tmpstr;
    SynMR.Editor := (Self.MDIChildren[FindTopWindow] as TfrmEditor).synEditor;

    if Assigned(SynMR.Editor) then
      vGlobalSearch:=(Self.MDIChildren[i] as TfrmEditor).gsSearchText;
    (Self.MDIChildren[FindTopWindow] as TfrmEditor).gsSearchText:=vGlobalSearch;
  end
  else
    SynMR.Editor := nil;
  if Assigned(frmExplorer) then
    frmExplorer.Editor := SynMR.Editor;
end;

function TfrmTinnMain.StripPath(iFileName : string) : string;
var
	tmpStr : string;
  slashpos : integer;
begin
  tmpStr := iFileName;
  repeat
  	slashpos := pos('\',tmpStr);
    tmpStr := copy(tmpStr, slashpos + 1, length(tmpStr));
  until (slashpos = 0);
	Result := tmpStr;

end;

function TfrmTinnMain.StripFileName(iFileName : string) : string;
var
	tmpStr : string;
  slashpos : integer;
  namePos : integer;
begin
  tmpStr := iFileName;
  repeat
  	slashpos := pos('\',tmpStr);
    tmpStr := copy(tmpStr, slashpos + 1, length(tmpStr));
  until (slashpos = 0);
  namePos := pos(tmpStr, iFilename);
  tmpStr := copy(iFileName, 1, namePos-1);
	Result := tmpStr;

end;

procedure TfrmTinnMain.PrintExecute(Sender: TObject);
begin
	if PrintDialog1.Execute then
 begin
   SynEditPrint1.SynEdit := (Self.MDIChildren[FindTopWindow] as tfrmEditor).synEditor;
   SynEditPrint1.DocTitle :=	(Self.MDIChildren[FindTopWindow] as tfrmEditor).FileName;
   SynEditPrint1.Title :=	(Self.MDIChildren[FindTopWindow] as tfrmEditor).FileName;
   SynEditPrint1.Font := (Self.MDIChildren[FindTopWindow] as tfrmEditor).synEditor.Font;
   //SynEditPrint1.Header.Add('$TITLE$$RIGHT$Printed $DATETIME$ $LINE$',SynEditPrint1.Font, taLeftJustify, 1 );
   SynEditPrint1.Print;
 end;
end;

procedure TfrmTinnMain.actPrintPreviewExecute(Sender: TObject);
begin
  SynEditPrint1.SynEdit := (Self.MDIChildren[FindTopWindow] as tfrmEditor).synEditor;
  SynEditPrint1.DocTitle :=	(Self.MDIChildren[FindTopWindow] as tfrmEditor).FileName;
  SynEditPrint1.Title :=	(Self.MDIChildren[FindTopWindow] as tfrmEditor).FileName;
  SynEditPrint1.Font := (Self.MDIChildren[FindTopWindow] as tfrmEditor).synEditor.Font;
	frmPrintPreview.synPP.SynEditPrint := SynEditPrint1;
  frmPrintPreview.synPP.UpdatePreview;
	frmPrintPreview.Show;
end;

procedure TfrmTinnMain.actTsStandardExecute(Sender: TObject);
begin
	pgFiles.Style := tsTabs;
  tsStandard1.Checked := true;
end;

procedure TfrmTinnMain.aDuplicateLineExecute(Sender: TObject);
var
 i : integer;
begin
	if (pgFiles.PageCount > 0) then
  begin
 		i := FindTopWindow;
 		(Self.MDIChildren[i] as tfrmEditor).DuplicateLineExecute(Sender);
  end;
end;

procedure TfrmTinnMain.actTsButtonsExecute(Sender: TObject);
begin
	pgFiles.Style := tsButtons;
  tsButtons1.Checked := true;
end;

procedure TfrmTinnMain.actTsFlatExecute(Sender: TObject);
begin
	pgFiles.Style := tsFlatButtons;
  tsFlatButtons1.Checked := true;
end;

procedure TfrmTinnMain.actTabPosTopExecute(Sender: TObject);
begin
	pgfiles.Align := alTop;
  tabPosUp1.Checked := true;
end;

procedure TfrmTinnMain.actTabPosBottomExecute(Sender: TObject);
begin
	pgfiles.Align := alBottom;
  tabPosDown1.Checked := true;
end;

procedure TfrmTinnMain.actToggleLineNumbersExecute(Sender: TObject);
var
	i : integer;
begin
	miShowLineNum.Checked := not(miShowLineNum.Checked);
  if Self.MDIChildCount > 0 then
  begin
    for  i := Self.MDIChildCount - 1 downto 0 do
 		begin
  		//(Self.MDIChildren[i] as tfrmEditor).synEditor.Gutter.ShowlineNumbers := miShowLineNum.Checked;
      (Self.MDIChildren[i] as tfrmEditor).ToggleLineNumbers;
 		end;
  end;

end;

procedure TfrmTinnMain.CheckForNewFileStart;
begin
	if (dmSyn.boolLoadedFileFromStartUp = false) then
  	timerStartNewFile.Enabled := true;
end;

procedure TfrmTinnMain.actToggleNewFileStartExecute(Sender: TObject);
begin
	miStartwithnewfile.Checked := not(miStartwithnewfile.Checked);
end;

procedure TfrmTinnMain.FormActivate(Sender: TObject);
begin
	CheckForNewFileStart;
end;

procedure TfrmTinnMain.timerStartNewFileTimer(Sender: TObject);
begin
	if (miStartwithnewfile.Checked) then
		FileNewItem1Click(self);
  timerStartNewFile.Enabled := False;
  dmSyn.boolLoadedFileFromStartUp := true;
end;

procedure TfrmTinnMain.actOpenMaxedExecute(Sender: TObject);
begin
	miStartFileMaxed.Checked := not(miStartFileMaxed.Checked);
end;

procedure TfrmTinnMain.actCloseAllExecute(Sender: TObject);
var
	i : integer;
begin
  if Self.MDIChildCount > 0 then
  begin
    for i := Self.MDIChildCount - 1 downto 0 do
 		begin
			Self.MDIChildren[i].Close;
 		end;
  end;
end;

procedure TfrmTinnMain.actSaveAllExecute(Sender: TObject);
var
	i : integer;
  tmpstr : string;
  ChildID : integer;
  tmpActivePage : integer;
begin
	if pgFiles.PageCount > 0 then
  begin
  	// Get the starting window ID
  	tmpActivePage := pgFiles.ActivePageIndex;

    // Loop through all windows and save files
    for i := 0 to pgFiles.PageCount - 1 do
    begin
    	pgFiles.ActivePageIndex := i;
      tmpstr := pgFiles.ActivePage.Hint;
 			ChildID := FindWindowByName(tmpstr);
      MDIChildren[ChildID].BringToFront;
      Application.ProcessMessages;
      ChildID := FindWindowByName(tmpstr);
      if ((Self.MDIChildren[ChildID] as tfrmEditor).synEditor.Modified) then
      	(Self.MDIChildren[ChildID] as tfrmEditor).FileSaveCmdExecute(Sender);
    end;

    // Bring back the starting window
    pgFiles.ActivePageIndex := tmpActivePage;
    tmpstr := pgFiles.ActivePage.Hint;
    ChildID := FindWindowByName(tmpstr);
    MDIChildren[ChildID].BringToFront;
  end;
  actSaveAll.Enabled := false;

end;

procedure TfrmTinnMain.tbsRegExFilterClick(Sender: TObject);
var
	StartFile : integer;
  NewFile : integer;
  i : integer;
  tmpStr : string;
  tmpText : TStringList;
  grepRegEx : TRegExpr;
begin
  // fix from jcfaria
  if (edRegEx.TexT = '') then
  begin
    MessageDlg('You need to define a RegEx filter before running it.', mtInformation, [mbOk], 0);
    exit;
  end;
	// Grep and filter
  grepRegEx := TRegExpr.Create;
  tmpText := TStringList.Create;
  try
    // For every line in the current on top window that matches, put it into another editor window
    StartFile := FindTopWindow;
    tmpText.Text := (Self.MDIChildren[StartFile] as tfrmEditor).synEditor.Lines.text;
    // Create new tab and window
    FileNewItem1Click(Sender);
    NewFile := FindTopWindow;
    grepRegEx.Expression := edRegEx.Text;
    for i := 0 to tmpText.Count - 1 do
    begin
      // Look at each line and if it matches, add it to the new child
      tmpStr := tmpText.Strings[i];
      if grepRegEx.Exec(tmpStr) then
        (Self.MDIChildren[NewFile] as tfrmEditor).synEditor.Lines.Add(tmpStr);
    end;
    if ((Self.MDIChildren[NewFile] as tfrmEditor).synEditor.Lines.Count = 0) then
      (Self.MDIChildren[NewFile] as tfrmEditor).synEditor.Lines.Add('No matches found.');
  finally
    grepRegEx.Free;
    tmpText.Free;
  end;
end;

procedure TfrmTinnMain.actSyntaxColorsExecute(Sender: TObject);
var
  dlg: TdlgSynColor;
begin
	dlg := TdlgSynColor.Create(self);
  if dlg.ShowModal = mrOK then
  begin

  end;
end;

procedure TfrmTinnMain.actStatusBarExecute(Sender: TObject);
begin
	StatusBar.Visible := Not(StatusBar.Visible);
  actStatusBar.Checked := StatusBar.Visible;
end;

procedure TfrmTinnMain.actSplitWindowVertExecute(Sender: TObject);
begin
	(Self.MDIChildren[FindTopWindow] as TfrmEditor).WindowSplit(false);
end;

procedure TfrmTinnMain.actSplitWindowHorizExecute(Sender: TObject);
begin
  (Self.MDIChildren[FindTopWindow] as TfrmEditor).WindowSplit;
end;

procedure TfrmTinnMain.actShowSpecialCharExecute(Sender: TObject);
var
	i : integer;
begin
	actShowSpecialChar.Checked := not(actShowSpecialChar.Checked);
  if Self.MDIChildCount > 0 then
  begin
    for  i := Self.MDIChildCount - 1 downto 0 do
 		begin
      (Self.MDIChildren[i] as TfrmEditor).ToggleSpecialChars(actShowSpecialChar.Checked);
 		end;
  end;

end;

procedure TfrmTinnMain.SetTabTitle(iStat : string);
begin
	if pgFiles.PageCount > 0 then
  begin
		if (miToggleReadOnly.Checked) then
  		pgFiles.ActivePage.Caption := '<' + StripPath(pgFiles.ActivePage.Hint) + iStat + '>'
		else
  		pgFiles.ActivePage.Caption := StripPath(pgFiles.ActivePage.Hint) + iStat;
  end;
end;

procedure TfrmTinnMain.actRecordExecute(Sender: TObject);
begin
  SynMR.Editor := (Self.MDIChildren[FindTopWindow] as TfrmEditor).synEditor;
	if (tbsRecord.ImageIndex = 30) then
  begin
		SynMR.RecordMacro(SynMR.Editor);
  	tbsRecord.ImageIndex := 32;
  	tbsRecord.Down := true;
    tbsRecord.Hint := 'Stop';
    Record1.ImageIndex := 32;
  end
  else
  begin
  	SynMR.Stop;
    tbsRecord.ImageIndex := 30;
  	tbsRecord.Down := false;
    tbsRecord.Hint := 'Record';
    Record1.ImageIndex := 30;
  end;
end;

procedure TfrmTinnMain.actPlayExecute(Sender: TObject);
var
	i : integer;
begin
	SynMR.PlaybackMacro(SynMR.Editor);
  i := FindTopWindow;
  if ((Self.MDIChildren[i] as TfrmEditor).synEditor2 <> Nil) then
  begin
  	if ((Self.MDIChildren[i] as TfrmEditor).ActiveEditor = 'synEditor') then
    begin
      (Self.MDIChildren[i] as TfrmEditor).synEditor2.Lines.Text := (Self.MDIChildren[i] as TfrmEditor).synEditor.Lines.Text;
    end
    else
    begin
      (Self.MDIChildren[i] as TfrmEditor).synEditor.Lines.Text := (Self.MDIChildren[i] as TfrmEditor).synEditor2.Lines.Text;
    end;
  end;
end;

procedure TfrmTinnMain.actToggleMacroBarExecute(Sender: TObject);
begin
	tbMacroBar.Visible := not(tbMacroBar.Visible);
  ToggleMacroBar1.Checked := tbMacroBar.Visible;
end;

procedure TfrmTinnMain.actShowEditorOptionsExecute(Sender: TObject);
var
	i : integer;
   qqqEditorOptions : TSynEditorOptionsContainer;
begin

{
  FEditorOptions.Gutter.ShowLineNumbers := miShowLineNum.Checked;
  if actShowSpecialChar.Checked then
  	FEditorOptions.Options := FEditorOptions.Options + [eoShowSpecialChars]
  else
    FEditorOptions.Options := FEditorOptions.Options - [eoShowSpecialChars];

  if (Self.MDIChildCount > 0) then
    FEditorOptions.Options := (Self.MDIChildren[FindTopWindow] as TfrmEditor).synEditor.Options;
}
  if SynEditOptionsDialog1.Execute(FEditorOptions) then
  begin
    FEditorOptions.Options := FEditorOptions.Options + [eoTabIndent];
  	for i := Self.MDIChildCount - 1 downto 0 do
    begin
      FEditorOptions.AssignTo((Self.MDIChildren[i] as TfrmEditor).synEditor);
      //(Self.MDIChildren[i] as TfrmEditor).synEditor.MaxScrollWidth := FLineWidth;

      if ((Self.MDIChildren[i] as TfrmEditor).synEditor2 <> Nil) then
      begin
        FEditorOptions.AssignTo((Self.MDIChildren[i] as TfrmEditor).synEditor2);
        //(Self.MDIChildren[i] as TfrmEditor).synEditor2.MaxScrollWidth := FLineWidth;
        (Self.MDIChildren[i] as TfrmEditor).synEditor2.RightEdge := FEditorOptions.RightEdge;
      (Self.MDIChildren[i] as TfrmEditor).synEditor2.RightEdgeColor := FEditorOptions.RightEdgeColor;
      end;
    end;
    FontName := FEditorOptions.Font.Name;
    FontSize := FEditorOptions.Font.Size;
    FontColor := FEditorOptions.Font.Color;
    miShowLineNum.Checked := FEditorOptions.Gutter.ShowLineNumbers;
    actShowSpecialChar.Checked := (eoShowSpecialChars in FEditorOptions.Options);
    if Assigned(frmExplorer) then begin
     frmExplorer.tvFunctions.Font.Size := FEditorOptions.Gutter.Font.Size;
     frmExplorer.tvDB.Font.Size := FEditorOptions.Gutter.Font.Size;
    end;
  end;

end;


procedure TfrmTinnMain.SaveDialogTypeChange(Sender: TObject);
var
	tmpFileName : string;
	SelectedIndex : integer;
  tStr : string;
  periodPos : integer;
  endPos : integer;
begin
	tmpFileName := SaveDialog.FileName;
  tStr := '';
  if (pos('.', tmpFileName) = 0 ) then
  begin
    SelectedIndex := SaveDialog.FilterIndex;

    if (SelectedIndex > 2) then
    begin
      tStr := FilterList.Strings[SelectedIndex - 3];
      periodPos := pos('*', tStr);
      endPos := pos(',', tStr);
      if (endPos = 0) then
        endPos := pos(')', tStr);
      tStr := Copy(tStr, periodPos + 1, (endPos - periodPos) - 1);
      {if (pos('.net', tStr) > 0) then
      begin
      	periodPos := pos('*', tStr);
      	endPos := pos(',', tStr);
      	if (endPos = 0) then
        	endPos := pos(')', tStr);
      	tStr := Copy(tStr, periodPos, (endPos - periodPos));
      end;}
    end
    else if (SelectedIndex = 2) then
    begin
      tStr := '.txt';
    end;

	end;
  SaveAsFileExt := tStr;
end;

procedure TfrmTinnMain.actToggleTabVisibleExecute(Sender: TObject);
begin
	pgFiles.Visible := not(pgFiles.Visible);
  actToggleTabVisible.Checked := pgFiles.Visible;
end;

procedure TfrmTinnMain.actShowAppOptionsExecute(Sender: TObject);
var
  dlg: TdlgAppOptions;
  i : integer;
begin
	dlg := TdlgAppOptions.Create(self);
  dlg.spMRU.Value                   := MRUMax;
  dlg.spSearchListMax.Value         := SearchListMax;
  dlg.cbRememberSearchList.Checked  := boolRememberSearchList;
  dlg.cbRemoveExtentions.Checked    := boolRemoveExtentions;
  dlg.cbUndoAfterSave.Checked       := boolUndoAfterSave;
  dlg.cbMinimizeTinn.Checked        := boolMinimizeTinnAfterLastFile;
  dlg.cbHighlighted.Checked         := boolHighlightActiveLine;
  dlg.edColor.Color                 := colorHighlightActiveLive;
  dlg.cbWordWrap.Checked            := actToggleWordWrap.Checked;
  dlg.edStartComment.Text           := gStartComment;
  dlg.edEndComment.Text             := gEndComment;

  dlg.cbHighlightedWH.Checked       := boolHighlightAllWords;
  dlg.edColorWH.Color               := colorHighlightAllWords;


  if dlg.ShowModal = mrOK then
  begin
    MRUMax                          := dlg.spMRU.Value;
    SearchListMax                   := dlg.spSearchListMax.Value;
    boolRememberSearchList          := dlg.cbRememberSearchList.Checked;
    boolRemoveExtentions            := dlg.cbRemoveExtentions.Checked;
    boolUndoAfterSave               := dlg.cbUndoAfterSave.Checked;
    boolMinimizeTinnAfterLastFile   := dlg.cbMinimizeTinn.Checked;
    boolHighlightActiveLine         := dlg.cbHighlighted.Checked;
    colorHighlightActiveLive        := dlg.edColor.Color;
    actToggleWordWrap.Checked       := dlg.cbWordWrap.Checked;
    gStartComment                   := dlg.edStartComment.Text;
    gEndComment                     := dlg.edEndComment.Text;

    boolHighlightAllWords           := dlg.cbHighlightedWH.Checked;
    colorHighlightAllWords          := dlg.edColorWH.Color;
    //FLineWidth := StrToIntDef(dlg.edLineWidth.Text, 1024);

    for i := Self.MDIChildCount - 1 downto 0 do
    begin
      if (boolHighlightActiveLine) then
        (Self.MDIChildren[i] as TfrmEditor).synEditor.ActiveLineColor := TColor(colorHighlightActiveLive)
      else
        (Self.MDIChildren[i] as TfrmEditor).synEditor.ActiveLineColor := TColor(clNone);
      (Self.MDIChildren[i] as TfrmEditor).synEditor.WordWrap := actToggleWordWrap.Checked;
      (Self.MDIChildren[i] as TfrmEditor).Repaint;
    end;
  end;
end;


procedure TfrmTinnMain.RemoveTab(iTabCaption: string);
var
  j, i : integer;
begin
  j := 0;
  while (j <= pgFiles.PageCount -1) do
  begin
    if (pgFiles.Pages[j].Hint = iTabCaption) then
      pgFiles.Pages[j].Free;
    inc(j);
  end;
  for i := Self.MDIChildCount - 1 downto 0 do
    begin
      (Self.MDIChildren[i] as TfrmEditor).Repaint;
    end;
  pgFilesChange(pgFiles);
end;

procedure TfrmTinnMain.actAsciiChartExecute(Sender: TObject);
var
  dlgAscii : TfmAsciiChart;
begin
  AsciiString := '';
  dlgAscii := TfmAsciiChart.Create(Self);
  dlgAscii.ShowModal;
  if (AsciiString <> '') then
  begin
    (Self.MDIChildren[FindTopWindow] as TfrmEditor).synEditor.SelText := AsciiString;
    (Self.MDIChildren[FindTopWindow] as TfrmEditor).EnableSave;
  end;
end;

procedure TfrmTinnMain.actOpenMRUExecute(Sender: TObject);
var
  i : integer;
  tmpList : TStringList;
begin
  // Open all files in MRU
  tmpList := TStringList.Create;
  for i := 0 to miRecentFile1.Count - 1 do
    tmpList.Add(miRecentFile1.Items[i].Caption);
  for i := 0 to tmpList.Count - 1 do
  begin
    if FileExists(tmpList.Strings[i]) then
      OpenFileIntoTinn(tmpList.Strings[i])
    else begin
      // Take it off the MRU list
      ShowMessage('File does not exist.' + #10#13 + 'Removing it from MRU list.' + #10#13 + tmpList.Strings[i]);
      UpdateMRU(miRecentFile1, tmpList.Strings[i]);
    end;
  end;
  tmpList.Free;
end;

procedure TfrmTinnMain.panSearchResultsGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  CanDock := DockClient is TfrmSearchResults;
  {if (not CanDock) then
    CanDock := DockClient is TfrmProject; }
end;

procedure TfrmTinnMain.panSearchResultsDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  panSearchResults.Constraints.MinHeight := 20;
  panSearchResults.Height := 110;
  StatusBar.Top := panSearchResults.Top + panSearchResults.Height;
  if Source.Control is TfrmSearchResults then
    frmResults.boolDocked := true;
  splitterBottom.Visible := true;
end;

procedure TfrmTinnMain.panSearchResultsUnDock(Sender: TObject;
  Client: TControl; NewTarget: TWinControl; var Allow: Boolean);
begin
  splitterBottom.Visible := False;
  panSearchResults.Constraints.MinHeight := 0;
  panSearchResults.Height := 1;
  if Client is TfrmSearchResults then
    frmResults.boolDocked := false;
end;

procedure TfrmTinnMain.splitterBottomMoved(Sender: TObject);
begin
  StatusBar.Top := panSearchResults.Top + panSearchResults.Height;
end;

{procedure TfrmTinnMain.actSearchInFilesExecute(Sender: TObject);
var
  dlg : TdlgSearchInFiles;
  strSearchText : string;
  ResultList : TStringList;
  MatchCount : integer;
  foundFileCount : integer;
  totFileCount : integer;
  strFiles, strMatches : string;
  strSearchDirectoryText : string;
  strSearchFileMask : string;
begin
  dlg := TdlgSearchInFiles.Create(Self);
  ResultList := TStringList.Create;
  dlg.SearchTextHistory := strSearchTextHistory;
  dlg.SearchRegularExpression := gboolUseRegEx;
  dlg.SearchWholeWords := gboolSearchWholeWords;
  dlg.SearchCaseSensitive := gboolCaseSensitivity;
  dlg.SearchOpenFiles := gboolSearchOpenFiles;
  dlg.SearchInSub := gboolSearchInSub;
  dlg.SearchDirectory := gboolSearchDirectory;
  dlg.SearchDirHistory := strSearchDirHistory;
  if (strSearchFileMaskHistory <> '') then
    dlg.SearchFileMaskHistory := strSearchFileMaskHistory;
  dlg.SearchDirectoryText := strSearchDirectoryText;

  MatchCount := 0;
  foundFileCount := 0;

  if (Self.MDIChildCount > 0) then
  begin
    with (Self.MDIChildren[FindTopWindow] as TfrmEditor) do
    begin
      if SynEditor.SelAvail and (SynEditor.BlockBegin.Line = SynEditor.BlockEnd.Line)
      then
        dlg.SearchText := SynEditor.SelText
      else
        dlg.SearchText := SynEditor.GetWordAtRowCol(SynEditor.CaretXY);
    end;
  end;

  if dlg.ShowModal = mrOK then
  begin
    if (frmResults = Nil) then
    begin
      frmResults := TfrmSearchResults.Create(Self);
    end;
    
    frmResults.Show;
    frmResults.ManualDock(panSearchResults);

    strSearchText := dlg.SearchText;
    gboolUseRegEx := dlg.SearchRegularExpression;
    gboolSearchWholeWords := dlg.SearchWholeWords;
    gboolCaseSensitivity := dlg.SearchCaseSensitive;
    gboolSearchOpenFiles := dlg.SearchOpenFiles;
    gboolSearchInSub := dlg.SearchInSub;
    gboolSearchDirectory := dlg.SearchDirectory;
    strSearchDirHistory := dlg.SearchDirHistory;
    strSearchFileMaskHistory := dlg.SearchFileMaskHistory;
    strSearchDirectoryText := dlg.SearchDirectoryText;
    strSearchFileMask := dlg.SearchFileMask;

    with dlg do
    begin
      gTimerCounter := 0;
      totFileCount := 0;

      SetupSearchParameters(strSearchText);
      if (gboolSearchOpenFiles) then
      begin
        // go through the open files
        ResultList.Add('Searching all open files');
        ResultList.Add('Search string : ' + strSearchText);
        Application.ProcessMessages;
        SearchInOpenFiles(ResultList, foundFileCount, MatchCount);
        totFileCount := Self.MDIChildCount;
      end;
      if (gboolSearchDirectory) then
      begin
        // go through the open files
        ResultList.Add('Searching in directory ' + strSearchDirectoryText);
        if (gboolSearchInSub) then
          ResultList.Add('Searching in sub directories');
        ResultList.Add('Search file mask : ' + strSearchFileMask);
        ResultList.Add('Search string : ' + strSearchText);
        Application.ProcessMessages;
        SearchInDirectories(ResultList, strSearchDirectoryText, strSearchFileMask, foundFileCount, MatchCount, totFileCount);
      end;
      strSearchTextHistory := dlg.SearchTextHistory;
    end;

    //ResultList.Add('');
    if (foundFileCount = 0) then
    ResultList.Add('Nothing found')
    else
    begin
      ResultList.Add('');
      if (foundFileCount = 1) then
        strFiles := ' in ' + IntToStr(foundFileCount) + ' file'
      else if (foundFileCount > 1) then
        strFiles := ' in ' + IntToStr(foundFileCount) + ' files';

      if (MatchCount = 1) then
        strMatches := 'Found ' + IntToStr(MatchCount) + ' match'
      else if (MatchCount > 1) then
        strMatches := 'Found ' + IntToStr(MatchCount) + ' matches'
      else if (MatchCount = 0) then
        strMatches := 'Nothing Found';

      ResultList.Add(strMatches + strFiles);
    end;

    if (totFileCount = 1) then
      ResultList.Add('Searched ' + IntToStr(totFileCount) + ' file')
    else if (totFileCount > 1) then
      ResultList.Add('Searched ' + IntToStr(totFileCount) + ' files');


    frmResults.synSearchResults.Lines.Text := ResultList.Text;
  end;

end; }


//Changes by Marco
procedure TfrmTinnMain.actSearchInFilesExecute(Sender: TObject);
var
  dlg : TdlgSearchInFiles;
  strSearchText : string;
  MatchCount : integer;
  foundFileCount : integer;
  totFileCount : integer;
  strFiles, strMatches : string;
  strSearchDirectoryText : string;
  strSearchFileMask : string;
  lSavedCursor: TCursor;
begin
  dlg := TdlgSearchInFiles.Create(Self);
  dlg.SearchTextHistory := strSearchTextHistory;
  dlg.SearchRegularExpression := gboolUseRegEx;
  dlg.SearchWholeWords := gboolSearchWholeWords;
  dlg.SearchCaseSensitive := gboolCaseSensitivity;
  dlg.SearchOpenFiles := gboolSearchOpenFiles;
  dlg.SearchInSub := gboolSearchInSub;
  dlg.SearchDirectory := gboolSearchDirectory;
  dlg.SearchDirHistory := strSearchDirHistory;
  if (strSearchFileMaskHistory <> '') then
    dlg.SearchFileMaskHistory := strSearchFileMaskHistory;
  dlg.SearchDirectoryText := strSearchDirectoryText;

  MatchCount := 0;
  foundFileCount := 0;

  if (Self.MDIChildCount > 0) then
  begin
    with (Self.MDIChildren[FindTopWindow] as TfrmEditor) do
    begin
      if SynEditor.SelAvail and (SynEditor.BlockBegin.Line = SynEditor.BlockEnd.Line)
      then
        dlg.SearchText := SynEditor.SelText
      else
        dlg.SearchText := SynEditor.GetWordAtRowCol(SynEditor.CaretXY);
    end;
  end;

  if dlg.ShowModal = mrOK then
  begin
    // set cursor to 'busy'
    if frmTinnMain.MDIChildCount > 0 then
    begin
       lSavedCursor := TfrmEditor(frmTinnMain.MDIChildren[0]).synEditor.cursor;
       TfrmEditor(frmTinnMain.MDIChildren[0]).synEditor.cursor := crhourglass;
    end
    else
    begin
      Screen.cursor := crHourGlass;
    end;

    try
      if (frmResults = Nil) then
      begin
        frmResults := TfrmSearchResults.Create(Self);
      end;

      frmResults.synSearchResults.Lines.Clear;
      frmResults.Show;
      frmResults.ManualDock(panSearchResults);

      strSearchText := dlg.SearchText;
      gboolUseRegEx := dlg.SearchRegularExpression;
      gboolSearchWholeWords := dlg.SearchWholeWords;
      gboolCaseSensitivity := dlg.SearchCaseSensitive;
      gboolSearchOpenFiles := dlg.SearchOpenFiles;
      gboolSearchInSub := dlg.SearchInSub;
      gboolSearchDirectory := dlg.SearchDirectory;
      strSearchDirHistory := dlg.SearchDirHistory;
      strSearchFileMaskHistory := dlg.SearchFileMaskHistory;
      strSearchDirectoryText := dlg.SearchDirectoryText;
      strSearchFileMask := dlg.SearchFileMask;

      with dlg do
      begin
        gTimerCounter := 0;
        totFileCount := 0;
        SetupSearchParameters(strSearchText);
        if (gboolSearchOpenFiles) then
        begin
          // go through the open files
          frmResults.synSearchResults.Lines.Add('Searching all open files');
          frmResults.synSearchResults.Lines.Add('Search string : ' + strSearchText);
          Application.ProcessMessages;
          SearchInOpenFiles(frmResults.synSearchResults.Lines, foundFileCount, MatchCount);

          totFileCount := Self.MDIChildCount;
        end;
        if (gboolSearchDirectory) then
        begin
          // go through the open files
          frmResults.synSearchResults.Lines.Add('Searching in directory ' + strSearchDirectoryText);
          if (gboolSearchInSub) then
            frmResults.synSearchResults.Lines.Add('Searching in sub directories');
          frmResults.synSearchResults.Lines.Add('Search file mask : ' + strSearchFileMask);
          frmResults.synSearchResults.Lines.Add('Search string : ' + strSearchText);
          Application.ProcessMessages;
          SearchInDirectories(frmResults.synSearchResults.Lines, strSearchDirectoryText, strSearchFileMask, foundFileCount, MatchCount, totFileCount);
        end;
        strSearchTextHistory := dlg.SearchTextHistory;
      end;

      if (foundFileCount = 0) then
      frmResults.synSearchResults.Lines.Add('Nothing found')
      else
      begin
        frmResults.synSearchResults.Lines.Add('');
        if (foundFileCount = 1) then
          strFiles := ' in ' + IntToStr(foundFileCount) + ' file'
        else if (foundFileCount > 1) then
          strFiles := ' in ' + IntToStr(foundFileCount) + ' files';

        if (MatchCount = 1) then
          strMatches := 'Found ' + IntToStr(MatchCount) + ' match'
        else if (MatchCount > 1) then
          strMatches := 'Found ' + IntToStr(MatchCount) + ' matches'
        else if (MatchCount = 0) then
          strMatches := 'Nothing Found';

        frmResults.synSearchResults.Lines.Add(strMatches + strFiles);
      end;

      if (totFileCount = 1) then
        frmResults.synSearchResults.Lines.Add('Searched ' + IntToStr(totFileCount) + ' file')
      else if (totFileCount > 1) then
        frmResults.synSearchResults.Lines.Add('Searched ' + IntToStr(totFileCount) + ' files');
    finally
      // Restore cursor
      if frmTinnMain.MDIChildCount > 0 then
         TfrmEditor(frmTinnMain.MDIChildren[0]).synEditor.cursor := lSavedCursor
      else Screen.cursor := crDefault;
    end;
  end;
end;

procedure TfrmTinnMain.SearchInOpenFiles(const ioResultList: TStrings; var ioFileCount, ioMatchCount : integer);
var
  i, j : integer;
  tmpLine : string;
  searchFileName : string;
  boolFileFind : boolean;
  //colPos : integer;
begin

  for  i := Self.MDIChildCount - 1 downto 0 do
  begin
    with (Self.MDIChildren[i] as TfrmEditor) do
    begin
      boolFileFind := false;
      searchFileName := frmEditor.ScrubCaption((Self.MDIChildren[i] as TfrmEditor).Caption);
      for j := 0 to synEditor.Lines.Count - 1 do
      begin
        tmpLine := trim(synEditor.Lines.Strings[j]);
          if SearchRegEx.Exec(tmpLine) then
          begin
            boolFileFind := true;
            inc(ioMatchCount);
            ioResultList.Add(searchFileName + ':(' + IntToStr(j+1) + '): ' + tmpLine);
            while SearchRegEx.ExecNext do
            begin
              ioResultList.Add(searchFileName + ':(' + IntToStr(j+1) + '): ' + tmpLine);
              inc(ioMatchCount);
            end; // while execNext
          end; // if regex match
      end; // end line loop
      if (boolFileFind) then
        inc(ioFileCount);
    end;
  end;
end;

procedure TfrmTinnMain.ClearMRU;
var
  i : integer;
begin
  MRUList.Clear;
  pmMRU.Items.Clear;
  i := FindTopWindow;
  while miRecentFile1.Count > 0 do
  begin
    miRecentFile1.Delete(0);
    if i > -1 then
      (Self.MDIChildren[i] as TfrmEditor).miRecentFiles.Delete(0);
  end;
end;

procedure TfrmTinnMain.Copyinipath1Click(Sender: TObject);
var
  StrUserName: PChar;
  Size: DWord;
  vPath : String;
begin
  Size:=250;
  GetMem(StrUserName, Size);
  GetUserName(StrUserName, Size);
  vPath:='c:\Users\'+StrPas(StrUserName)+'\AppData\Local\VirtualStore\Program Files (x86)\OraTinn\Tinn.ini';
  Clipboard.AsText := vPath;
  ShowMEssage(vPath+#13#10+'Copied to clippboard.');
end;

procedure TfrmTinnMain.MinimizeTinnAfterLastFile;
begin
  if (boolMinimizeTinnAfterLastFile) then
    Application.Minimize;  
end;

procedure TfrmTinnMain.SearchInDirectories(const ioResultList: TStrings;
  iDir, iMask : string; var ioFileCount, ioMatchCount, ioTotFileCount: integer);
var
  Path : string;
  FileList : TStringList;
  i, j : integer;
  posSlash : integer;
  iDirLen : integer;
  lastChar : string;
  tmpLine : string;
  boolFileFind : boolean;
  tmpSyn : TSynEdit;
  linePos : integer;
begin
  FileList := TStringList.Create;
  tmpSyn := TSynEdit.Create(Self);
  try
    // Make sure the file path has a '\' at the end
    iDirLen := Length(iDir);
    lastChar := copy(iDir, iDirLen, 1);
    posSlash := pos('\', lastChar);

    if (posSlash = 0) then
      Path := iDir + '\'
    else
      Path := iDir;

    // Get a file list
    TraverseDir(Path, FileList, iMask);
    
    for i := 0 to FileList.Count - 1 do
    begin
      boolFileFind := false;
      j := 0;
      tmpSyn.Lines.LoadFromFile(FileList.Strings[i]);
      for linePos := 0 to tmpSyn.Lines.Count - 1 do
      begin
        tmpLine := tmpSyn.Lines.Strings[linePos];
        if SearchRegEx.Exec(tmpLine) then
        begin
          tmpLine := trim(tmpLine);
          boolFileFind := true;
          inc(ioMatchCount);
          ioResultList.Add(FileList.Strings[i] + ':(' + IntToStr(j+1) + '): ' + tmpLine);
          while SearchRegEx.ExecNext do
          begin
            ioResultList.Add(FileList.Strings[i] + ':(' + IntToStr(j+1) + '): ' + tmpLine);
            inc(ioMatchCount);
          end; // while execNext
        end; // if regex match
        inc(j);
      end;
      if (boolFileFind) then
        inc(ioFileCount);
      end;

      ioTotFileCount := FileList.Count;
      FileList.Free;
      tmpSyn.Free;
  except
    on e : exception do
    begin
      ioResultList.Add(e.Message);
      FileList.Free;
      tmpSyn.Free;
    end;
  end;
end;

function TfrmTinnMain.StripRegExPower(iSearchText : string) : string;
begin
  iSearchText := StringReplace(iSearchText, '*', '\*', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '\', '\\', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '[', '\[', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '(', '\(', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '+', '\+', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '?', '\?', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '^', '\^', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '$', '\$', [rfReplaceAll]);
  iSearchText := StringReplace(iSearchText, '.', '\.', [rfReplaceAll]);

  result := iSearchText;
end;

procedure TfrmTinnMain.SetupSearchParameters(iSearchText : string);
begin
  if SearchRegEx = nil then
    SearchRegEx := TRegExpr.Create;

  if (Length(trim(iSearchText)) = 0) then
    iSearchText := ' ';

  if Not(gboolUseRegEx) then
  begin
    iSearchText := StripRegExPower(iSearchText);
  end;

  if (gboolSearchWholeWords) then
    iSearchText := iSearchText + '\W';

  if Not(gboolCaseSensitivity) then
    SearchRegEx.ModifierI := true;

  SearchRegEx.Expression := iSearchText;


end;

procedure TfrmTinnMain.TraverseDir(iPath: string;
  var ioFileList: TStringList; iMask : string);
var
  PathList : TStringList;
  Path : string;
  DirRec : TSearchRec;
  i : integer;
  handle: THandle;
	curFile: WIN32_FIND_DATA;
  DirFound : integer;
begin
  // Get the files for the current directory
  handle := FindFirstFile(PChar(iPath + iMask), curFile);
  if FileExists(iPath + curFile.cFilename) then
    ioFileList.Add(iPath + curFile.cFilename);
  while FindNextFile(Handle, curFile) do
  begin
    if FileExists(iPath + curFile.cFilename) then
      ioFileList.Add(iPath + curFile.cFilename);
  end;

  if gboolSearchInSub then
  begin
    // Okay to search sub directories
    PathList := TStringList.Create;
    try
      // Get the list of sub directories
      DirFound := FindFirst(iPath + '*.*', faDirectory, DirRec);
      while (DirFound = 0) do
      begin
        if (DirRec.Attr and faDirectory > 0) and (DirRec.Name[1] <> '.') then
        begin
          PathList.Add(DirRec.Name);
        end;
        DirFound := FindNext(DirRec);
      end;

      for i := 0 to PathList.Count - 1 do
      begin
        // Traverse the directories
        Path := iPath + PathList.Strings[i] + '\';
        TraverseDir(Path, ioFileList, iMask);
      end;
    finally
      PathList.Free;
    end;
  end;
end;

procedure TfrmTinnMain.SynMRStateChange(Sender: TObject);
begin
  with (Self.MDIChildren[FindTopWindow] as TfrmEditor) do
  begin
    if SynMR.State = msRecording then
    begin
      alEdit.OnExecute:= RecordActions;
      alFile.OnExecute:= RecordActions;
      alFormat.OnExecute:= RecordActions;
      alSearch.OnExecute:= RecordActions;
    end
    else if Assigned(alEdit.OnExecute) then
    begin
      alEdit.OnExecute:= nil;
      alFile.OnExecute:= nil;
      alFormat.OnExecute:= nil;
      alSearch.OnExecute:= nil;
    end;
  end;
end;

procedure TfrmTinnMain.RecordActions(Action: TBasicAction; var Handled: Boolean);
var
  AEvent: TActionMacroEvent;
begin
  try
  if not InExecute and (Action <> actRecord) and (Action <> actPlay) then
    with SynMR do
    begin
      AEvent:= TActionMacroEvent.Create;
      AEvent.ActionName:= Action.Name;
      with (Self.MDIChildren[FindTopWindow] as TfrmEditor) do
      begin
        AEvent.ActionLists.Add(alEdit);
        AEvent.ActionLists.Add(alFile);
        AEvent.ActionLists.Add(alFormat);
        AEvent.ActionLists.Add(alSearch);
      end;
      AddCustomEvent(TSynMacroEvent(AEvent));
      InExecute:= True;
      try
        Action.Execute;
        Handled:= True;
      finally
        InExecute:= False;
      end;
    end;
  except
    on e : exception do
      ShowMessage(e.message);
  end;
end;

procedure TfrmTinnMain.tbReloadClick(Sender: TObject);
begin
  (Self.MDIChildren[FindTopWindow] as TfrmEditor).actReload.Execute;
end;

procedure TfrmTinnMain.panProjectDockSiteDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  panProjectDockSite.Constraints.MinWidth := 20;
  panProjectDockSite.Width := 150;
  if Source.Control is TfrmProject then
    frmProjectSpace.boolDocked := true;
  leftSplitter.Visible := true;
end;

procedure TfrmTinnMain.actProjectNewExecute(Sender: TObject);
var
  sd : TSaveDialog;
begin
  // New Project
  // Check for existing project

  sd := TSaveDialog.Create(self);
  try
    sd.InitialDir := WorkingDir;
    sd.Filter := 'Tinn Project Space (*.tps)|*.tps';
    if (sd.Execute) then
 	  begin
      ProjectName := sd.FileName + '.tps';
      if (frmProjectSpace = nil) then
        frmProjectSpace := TfrmProject.Create(self);
      frmProjectSpace.Caption := ExtractFileName(ProjectName);
      frmProjectSpace.ManualDock(panProjectDockSite);
      frmProjectSpace.Show;
      frmProjectSpace.SaveProject;
    end;
  finally
      sd.Free;
  end;

  Self.Repaint;
end;

procedure TfrmTinnMain.panProjectDockSiteGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  CanDock := DockClient is TfrmProject;
end;

procedure TfrmTinnMain.panProjectDockSiteUnDock(Sender: TObject;
  Client: TControl; NewTarget: TWinControl; var Allow: Boolean);
begin
  panProjectDockSite.Constraints.MinWidth := 1;
  panProjectDockSite.Width := 0;
  if Client is TfrmProject then
    frmProjectSpace.boolDocked := false;
  leftSplitter.Visible := false;
end;

procedure TfrmTinnMain.actProjectAddCurrentFileExecute(Sender: TObject);
begin
  // Add the current file to the project
  if (frmProjectSpace <> Nil) then
    frmProjectSpace.AddFile((Self.MDIChildren[FindTopWindow] as TfrmEditor).FileName);
end;

procedure TfrmTinnMain.actProjectOpenExecute(Sender: TObject);
var
  od : TOpenDialog;
begin
  // Open an existing project
  od := TOpenDialog.Create(self);
  try
    od.InitialDir := WorkingDir;
    od.Filter := 'Tinn Project Space (*.tps)|*.tps';
    if (od.Execute) then
 	  begin
      {ProjectName := od.FileName;
  	  if (frmProjectSpace = nil) then
        frmProjectSpace := TfrmProject.Create(self);
      frmProjectSpace.Caption := ProjectName;
      frmProjectSpace.OpenProject;
      frmProjectSpace.ManualDock(panProjectDockSite);
      frmProjectSpace.Show;
      actProjectOpenAllFiles.Enabled := true;
      actProjectCloseAllFiles.Enabled := true;  }
      OpenProjectIntoTinn(od.FileName);
    end;
  finally
    od.Free;
  end;

  Self.Repaint;
end;

procedure TfrmTinnMain.actProjectSaveExecute(Sender: TObject);
begin
  if not(frmProjectSpace = Nil) then
  begin
    frmProjectSpace.SaveProject;
    UpdateProjectMRU(miProjectReopen1, ProjectName);
  end;
end;

procedure TfrmTinnMain.actProjectRemoveExecute(Sender: TObject);
begin
  // Remove current file
  if (frmProjectSpace <> Nil) then
    frmProjectSpace.RemoveFile((Self.MDIChildren[FindTopWindow] as TfrmEditor).FileName);
end;

procedure TfrmTinnMain.actProjectCloseExecute(Sender: TObject);
begin
  if not(frmProjectSpace = Nil) then
  begin
    frmProjectSpace.Close;
    actProjectOpenAllFiles.Enabled := false;
    actProjectCloseAllFiles.Enabled := false;
  end;
end;

procedure TfrmTinnMain.actProjectOpenAllFilesExecute(Sender: TObject);
begin
  frmProjectSpace.OpenAllFiles;
end;

procedure TfrmTinnMain.actProjectCloseAllFilesExecute(Sender: TObject);
begin
  frmProjectSpace.CloseAllFiles;
end;

procedure TfrmTinnMain.OpenProjectIntoTinn(iProjectName : string);
begin
  Self.ProjectName := iProjectName;
  if (frmProjectSpace = nil) then
    frmProjectSpace := TfrmProject.Create(self);
  frmProjectSpace.Caption := ProjectName;
  frmProjectSpace.OpenProject;
  frmProjectSpace.ManualDock(panProjectDockSite);
  frmProjectSpace.Show;
  actProjectOpenAllFiles.Enabled := true;
  actProjectCloseAllFiles.Enabled := true;
  UpdateProjectMRU(miProjectReopen1, iProjectName);
end;

procedure TfrmTinnMain.BuildProjectMRU(var ioMenuItem : TMenuItem);
var
 i : integer;
 MRUItem : TMenuItem;
begin
	//ShowMessage('Building MRU');
 ioMenuItem.Clear;
 if ProjectMRUList.Count > 0 then
 begin
   for i := 0 to ProjectMRUList.Count -1  do
   begin
     if i < MRUmax then
     begin
       MRUItem := newItem(
              ProjectMRUList.Values[IntToStr(i)],
              0, false, true, RecentProjectFileClick, 0,
              format('File%d', [i]));
       MRUItem.Tag := i;
       ioMenuItem.Add(MRUItem);
     end;
   end;
 end;
end;

procedure TfrmTinnMain.UpdateProjectMRU(var ioMenuItem : TMenuItem; iFileName : string);
var
 i, j : integer;
 tmplst : TStringList;
 tmpStr : string;
begin
  tmplst := TStringList.create;
  //Put the opened file in at the top of the list
  tmpStr := StringReplace(iFileName,'&','&&', [rfReplaceAll]);
  if FileExists(iFileName) then
  begin
    tmplst.Insert(0,'0=' + tmpStr);
    j := 1;
  end
  else
    j := 0;
 //Store Data and remove from menu
 for i := 0 to ProjectMRUList.Count - 1 do
 begin
   if (tmpStr <>  ProjectMRUList.Values[IntToStr(i)]) then
   begin
     tmplst.Add(IntToStr(j) + '=' + ProjectMRUList.Values[IntToStr(i)]);
     inc(j);
   end;
 end;
 ProjectMRUList.Text := tmplst.Text;
 BuildProjectMRU(ioMenuItem);
 tmplst.free;
end;

procedure TfrmTinnMain.RecentProjectFileClick(Sender: TObject);
var
 tmpstr : string;
begin
  tmpstr := StringReplace(TMenuItem(Sender).Caption, '&', '', []); //rfReplaceAll]);
  tmpstr := StringReplace(tmpstr, '&&', '&', [rfReplaceAll]);
  if FileExists(tmpstr) then
    OpenProjectIntoTinn(tmpstr)
  else begin
    // Take it off the MRU list
    ShowMessage('File does not exist.' + #10#13 + 'Removing it from MRU' + #10#13 + tmpstr);
    UpdateProjectMRU(miProjectReopen1, tmpstr);
  end;

end;


procedure TfrmTinnMain.pgFilesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  tmpstr : String;
  i : Integer;
begin
  if(Button=mbMiddle) then begin
   //close tab
    if Assigned(pgFiles.ActivePage) then
    begin
      tmpstr := pgFiles.ActivePage.Hint;
      i := FindWindowByName(tmpstr);
      if i > -1 then
        Self.MDIChildren[i].Close;
    end;
  end else
    pgFiles.BeginDrag(False);
end;

procedure TfrmTinnMain.pgFilesDragDrop(Sender, Source: TObject; X,
  Y: Integer);
const
  TCM_GETITEMRECT = $130A;
var
  i: Integer;
  r: TRect;
begin
  if not (Sender is TPageControl) then Exit;
  with pgFiles do
  begin
    for i := 0 to PageCount - 1 do
    begin
      Perform(TCM_GETITEMRECT, i, lParam(@r));
      if PtInRect(r, Point(X, Y)) then
      begin
        if i <> ActivePage.PageIndex then
          ActivePage.PageIndex := i;
        Exit;
      end;
    end;
  end; 

end;

procedure TfrmTinnMain.pgFilesDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if Sender is TPageControl then
    Accept := True;
end;

procedure TfrmTinnMain.actExecCmdExecute(Sender: TObject);
begin           
  //  People keep asking for an exec function
  // So I am trying to stub it out now.
end;

procedure TfrmTinnMain.actToggleWordWrapExecute(Sender: TObject);
var
  i : integer;
begin
  // Toogle Word wrap
  actToggleWordWrap.Checked := not(actToggleWordWrap.Checked);

  if Self.MDIChildCount > 0 then
  begin
    for  i := Self.MDIChildCount - 1 downto 0 do
 		begin
      (Self.MDIChildren[i] as tfrmEditor).ToggleWordWrap(actToggleWordWrap.Checked);
 		end;
  end;
end;

procedure TfrmTinnMain.WindowExplorerExecute(Sender: TObject);
begin
  if not Assigned(frmExplorer) then ModifyOnCreate;
  if not frmExplorer.Visible then
  begin
    frmExplorer.Show;
    frmExplorer.ManualDock(panProjectDockSite);
    if panProjectDockSite.Width<>vPrevWidth then begin
      if vPrevWidth=0 then begin
        vPrevWidth:=300;
        frmExplorer.Width:=vPrevWidth;
      end;
      panProjectDockSite.Width:=vPrevWidth;
    end;
  end
  else
  begin
    vPrevWidth := panProjectDockSite.Width;
    frmExplorer.Close;
  end;
end;


procedure TfrmTinnMain.ModifyOnCreate;
var
 vWidth : Integer;
begin
  Application.OnException := HandleException;
  if (frmExplorer = Nil) then
  begin
    frmExplorer := TFrmCodeCompletion.Create(Self,ControlBar1, tbConnect,
        StatusBar.Panels[3], panSearchResults, FileNewItem1Click,IniFile);
    frmExplorer.fspStatus:= StatusBar.Panels[0];
    if Assigned(IniFile) then
    begin
      vWidth:=IniFile.ReadInteger('CodeNavigator','Width',0);
      if vWidth>0 then
      begin
        WindowExplorerExecute(nil);
        panProjectDockSite.Width:=vWidth;
      end;
    end;
    frmExplorer.LoadFromFile(IniFile);
  end;
  FEditorOptions.Options := FEditorOptions.Options-[eoScrollPastEol];
  tbSettingsBar.Visible:=False;
  externalTools := TExternalToolsManager.Create(tbExternalTools,frmExplorer);
  externalTools.LoadFromFile(IniFile);
  externalTools.MenuReload;
  frmExplorer.tvFunctions.Font.Size := FEditorOptions.Gutter.Font.Size;
  frmExplorer.tvDB.Font.Size := FEditorOptions.Gutter.Font.Size;

  aMoveBlockDown.SecondaryShortCuts.AddObject('CTRL+ALT+ArrowDown', TObject(Menus.ShortCut(VK_DOWN,  [ssCTRL, ssSHIFT])));
  //(aMoveBlockDown, 'CTRL+SHIFT+ArrowDown', VK_DOWN, [ssCTRL, ssSHIFT]);

end;

procedure TfrmTinnMain.actConnectExecute(Sender: TObject);
var
  vForm : TFrmConnect;
  vConnected : Boolean;
begin
  vForm:=TFrmConnect.Create(Self);
  vConnected:=False;
  try
    vForm.iniFile:=IniFile;
    repeat
      if vForm.ShowModal=mrOK then
      begin
        if vForm.vUser<>'' then
        begin
           vConnected:=frmExplorer.Connect(vForm.ConnectString,vForm.vUser,
              vForm.vPass, vForm.vHost);
           if vConnected then
             vForm.Post
           else
             Application.MessageBox(PChar('Cannot connect to database'),PChar('Oracle error'),MB_ICONHAND+MB_OK);
        end;
      end;
    until (vForm.ModalResult<>mrOK) or vConnected;

  finally
    vForm.Free;
    Screen.cursor:=crDefault;
  end;
end;

procedure TfrmTinnMain.actCompileExecute(Sender: TObject);
begin
  if Assigned(frmExplorer) then begin
    if (Self.MDIChildCount > 0) then
      (Self.MDIChildren[FindTopWindow] as TfrmEditor).FileSaveCmd.Execute;
    frmExplorer.Compile;
  end;
end;

procedure TfrmTinnMain.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  DragAcceptFiles(Handle, False);
  if Assigned(frmExplorer) then
    frmExplorer.Editor := nil;
{  frmExplorer.Free;
  frmExplorer:=nil;
  externalTools.Free;
  externalTools:=nil;}  
end;

procedure TfrmTinnMain.actSQLPlusExecute(Sender: TObject);
begin
  if Assigned(frmExplorer) then
    frmExplorer.SQLPlus;
end;

procedure TfrmTinnMain.actDisconnectExecute(Sender: TObject);
begin
  if Assigned(frmExplorer) then
    frmExplorer.DisConnect;
end;


procedure TfrmTinnMain.HandleException(Sender: TObject; E: Exception);
begin
 try
  Screen.Cursor:=crDefault;
  if E is CException then
    Application.MessageBox(PChar(CException(E).ReadHistory[0] + #13#10 + #13#10 +
                        '________________________________________________' + #13#10+
                        CException(E).ReadHistory.GetText), PChar('Handled Application Error'), MB_ICONEXCLAMATION)
  else
    Application.MessageBox(PChar(E.message),PChar('Application Error'),MB_ICONEXCLAMATION);
  except
   raise;
  end;
end;


procedure TfrmTinnMain.Free1Click(Sender: TObject);
begin
  frmExplorer.Free;
  frmExplorer:=nil;
end;

procedure TfrmTinnMain.actExtToolExecute(Sender: TObject);
var
 vForm : TFormExternalTools;
 vI, vReturn : Integer;
begin
 vForm:=TFormExternalTools.Create(Self);
 try
   for vI:=0 to Length(externalTools.Items)-1 do
     vForm.Add(externalTools.Items[vI].Name, externalTools.Items[vI].Command);

   vReturn:=vForm.ShowModal;
   if vReturn=mrYes then begin
     if (vForm.edName.Text<>'') and (vForm.edCommand.Text<>'') then
       externalTools.Add(vForm.edName.Text, vForm.edCommand.Text);
   end else if vReturn=mrNo then begin
     if (vForm.edName.Text<>'') and (vForm.edCommand.Text<>'') then
       externalTools.Modify(vForm.fLastPos, vForm.edName.Text,
          vForm.edCommand.Text);
   end else if vReturn=mrAbort then begin
       externalTools.Remove(vForm.fLastPos);
   end;

   externalTools.MenuReload;
 finally
   vForm.Free;
 end;
end;

   
procedure TfrmTinnMain.Reload1Click(Sender: TObject);
begin
   ControlBar1.Refresh;
   ControlBar1.Repaint;;   
end;

procedure TfrmTinnMain.Stop1Click(Sender: TObject);
begin
  frmExplorer.TimCursorPos.Enabled:=False;
end;



procedure TfrmTinnMain.actMarkJumpExecute(Sender: TObject);
begin
  frmExplorer.CycleJumpNextMark(fLastMarkIdx);
end;

procedure TfrmTinnMain.tbsHghlightClick(Sender: TObject);
begin
  if tbsHghlight.Down then begin
    frmExplorer.HighlightList:=edHighlight.Text;
    edHighlight.Enabled:=False;
  end else begin
    frmExplorer.HighlightList:='';
    edHighlight.Enabled:=True;    
  end;
end;

procedure TfrmTinnMain.actSQLExecuteExecute(Sender: TObject);
begin
  frmExplorer.ExecuteQuery;
end;

procedure TfrmTinnMain.actSQLExecuteToHTMLExecute(Sender: TObject);
begin
    frmExplorer.ExecuteToHTML;
end;

function TfrmTinnMain.IsWindowOnTaskabr: Boolean;
var
  WinInfo: TWindowInfo;
begin
  GetWindowInfo(Application.Handle, WinInfo);
  result := (WinInfo.dwStyle and WS_VISIBLE)>0;

end;

procedure TfrmTinnMain.aJumpProcedureExecute(Sender: TObject);
var
  vForm : TFrmJumpProc;
begin
  try
    if not Assigned(frmExplorer) then exit;
    if not Assigned(frmExplorer.Editor) then exit;
    vForm := TFrmJumpProc.Create(Self);

    frmExplorer.GetFunctionList(vForm.fList);

    vForm.ShowModal;
    if vForm.LineNumber>0 then begin
      frmExplorer.Editor.TopLine:=vForm.LineNumber;
      frmExplorer.Editor.GotoLineAndCenter(vForm.LineNumber);
    end;
  finally
    vForm.Free;
  end;
end;

procedure TfrmTinnMain.aMoveBlockDownExecute(Sender: TObject);
var
 i : integer;
begin
	if (pgFiles.PageCount > 0) then
  begin
 		i := FindTopWindow;
 		(Self.MDIChildren[i] as tfrmEditor).MoveBlockExecute(Sender);
  end;
end;


procedure TfrmTinnMain.RefactorRename(Sender: TObject);
var
  vOldText, vText : String;
begin
  vOldText:=SynMR.Editor.GetWordAtRowCol(SynMR.Editor.CaretXY);
  if vOldText = '' then
    exit;
  vText := vOldText;
  if InputQuery('Refactoring rename', 'Enter new name:', vText) then
  begin
    frmExplorer.RefactorChangeName(vOldText, vText, SynMR.Editor.CaretXY.Line);
  end;
end;

Initialization
  WM_FINDINSTANCE := RegisterWindowMessage('Editor: find previous instance');
  if WM_FINDINSTANCE = 0 then raise Exception.Create('Initialization failed');

end.




