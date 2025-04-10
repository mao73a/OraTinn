unit ufrmCodeCompletion;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, SynEditHighlighter, SynHighlighterSQL, SynEdit, ComCtrls,
  ExtCtrls, SynCompletionProposal, ImgList, ToolWin, Db, Menus,
  uFrmCompileErrors, inifiles, uAutoComplete, uPLSQLLExer, SynEditTypes, uQueryGrid,
  ActnList, Oracle, OracleData,
  RegularExpressions, uFrmJumpObj;

const DefaultDelay : Integer=10;
      QUERY_BREAK_AFTER = 1000;

type TFuncData = record
   funct_begin, funct_end : Integer;
end;

type  TFuncArr = Array[0..1023] of TFuncData; //static array for speed optimalisation

type TBlockPaint = record
   StartBC, EndBC: TBufferCoord;
   repaint, valid : Boolean;
end;

type TExternalToolREC = record
   Name, Command : String
end;

type
 THighilightWord=record
    BufferCoord : TBufferCoord;
    Word : String;
    ColorIdx : Integer
 end;

type
 TArray = array of string;

 THighilightWordArr=Array of THighilightWord;
 PTHighilightWordArr =  ^THighilightWordArr;


type

  TMyOracleSession = class(TOracleSession)
    private
      connectString : String;
      fileTabList : TStringList;
      fActiveFileTab : TTabSheet;
      FConnectionTab: TTabSheet;
      procedure SetConnectionTab(const Value: TTabSheet);
      function GetConnectionTab :TTabSheet;
    public
      constructor Create(AOwner: TComponent; pConnectString : String);overload;
      destructor  Destroy;override;
      property  ConnectionTab : TTabSheet read GetConnectionTab write SetConnectionTab;
      procedure RegisterFileTab(pFileName : String; pFileTab: TTabSheet);
      procedure SetActivePageTab(pActivePageTab : TTabSheet);
      function UnregisterFileTab(pFileName : String; pFileTab: TTabSheet) : Boolean;
      procedure ShowActiveFileTabs;
      procedure ShowAllFileTabs;
  end;

  TFrmCodeCompletion = class(TForm)
    SynCompletionProposalAll: TSynCompletionProposal;
    pmConnectMenu: TPopupMenu;
    tsFile: TPageControl;
    TabSheet1: TTabSheet;
    tvFunctions: TTreeView;
    tsDB: TTabSheet;
    pmDb: TPopupMenu;
    LoadSpc1: TMenuItem;
    LoadBody1: TMenuItem;
    tvDb: TTreeView;
    ilDbError: TImageList;
    Refresh1: TMenuItem;
    ilModify: TImageList;
    pmExplorerMenu: TPopupMenu;
    Sort1: TMenuItem;
    TimCursorPos: TTimer;
    FunctionListRefresh: TMenuItem;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    TabSheet3: TTabSheet;
    Memo2: TMemo;
    alOgolne: TActionList;
    aWarnings: TAction;
    ComplierWarnings1: TMenuItem;
    ComplierWarnings2: TMenuItem;
    OracleQuery1: TOracleQuery;
    OracleSession1: TOracleSession;
    dsCompile: TOracleDataSet;
    dsDetail: TOracleDataSet;
    TimerLoadOnClick: TTimer;
    aSearch: TAction;
    Search2: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure tvFunctionsChange(Sender: TObject; Node: TTreeNode);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tvFunctionsClick(Sender: TObject);
    procedure LoadSpc1Click(Sender: TObject);
    procedure LoadBody1Click(Sender: TObject);
    procedure tvDbChange(Sender: TObject; Node: TTreeNode);
    procedure Refresh1Click(Sender: TObject);
    procedure tvFunctionsCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure Sort1Click(Sender: TObject);
    procedure TimCursorPosTimer(Sender: TObject);
    procedure FunctionListRefreshClick(Sender: TObject);
    procedure SynCompletionProposalAllExecute(Kind: SynCompletionType;
      Sender: TObject; var CurrentInput: String; var x, y: Integer;
      var CanExecute: Boolean);
    procedure FindCurrentBlock;
    procedure tvDbDblClick(Sender: TObject);
    procedure aWarningsExecute(Sender: TObject);
    procedure LoadFromFile(pIniFile: TIniFile);
    procedure TimerLoadOnClickTimer(Sender: TObject);
    procedure RefactorChangeName(pOldName, pNewName : String; ALine : Integer);
    procedure aSearchExecute(Sender: TObject);
    procedure tvDbKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function BlockSelection(ALine : Integer; var pBlockLevel : Integer) : Boolean;
  private
    { Private declarations }
    fWorkerThread : TThread;
    fOrigEdOnChange : TNotifyEvent;
    FEditor: TCustomSynEdit;
    fControlBar : TControlBar;
    fConnections : TStringList;
    fDbObjects : TStringList;
    fDbPackages : TStringList;
    fEdFunctions : TStringList;
    fAutoCompleteList : TStringList;    
    fCompileResults : TStringList;
    fConnectButton : TToolButton;
    fActiveConnection : String;
    fspConnection : TStatusPanel;
    fpCompileResults : TPanel;
    fCompileErrors :  TFrmCompileErrors;
    fFrmQueryGrid :  TFrmQueryGrid;
    fNewFileEvent : TNotifyEvent;
    IniFile : TIniFile;
    vLastObject : String;
    fPreviouslyClickedNode : TTreeNode;
    fObjectName : String;
    fAutoComplete : TOraTinnAutoComp;
    fCaretPos : TBufferCoord;
    fObjectsLoaded : Boolean;
    FHighlightList: String;
    fTimerExecution : Boolean;
    TimerLoadOnClick_pPackage : String;
    TimerLoadOnClick_pFunction : String;
    fPackageNameMatchList : TStrings;
    fFrmJumpObj : TFrmJumpObj;
    FShowAllFiles: Boolean;
    procedure SetEditor(const Value: TCustomSynEdit);
    procedure SetModificationMark;
    procedure ShowFunction(pFunction : String; pCount : Integer);
    procedure LoadObjectsList;
    procedure SetHighlightList(const Value: String);
    function GetQueryText : String;
    function PackageNameMatch(pSQLObjectName,pLogonUsername : String) : Boolean;
    function FastCharIndexToRow(  Index,pPrevLine : Integer; var pPrevChars: integer): Integer;
    procedure SetShowAllFiles(const Value: Boolean);
    procedure JumpObjOnLoadBDYClick(Sender: TObject);
    procedure JumpObjOnLoadSPCClick(Sender: TObject);
    procedure PrepareSearchBox;
    procedure JumpObjOnDobleClick(Sender: TObject);
//    fEditor : TCustomSynEdit;
  public
    { Public declarations }
    fspStatus : TStatusPanel;
    fPLSLexer : TPLSLexer;
    BlockPaint : TBlockPaint;
    fHighilightWordArr : THighilightWordArr;
    fHighlightWord : String;
    procedure Load(pName, pType : String);
    function GetConnectionFolderName : String;
    procedure Compile;
    procedure ExecuteQuery;
    procedure MyConnectionChange(Sender: TObject);
    function AssignWindowToCurrentConnection(pFileName: String; pFileTab: TTabSheet) : Boolean;
    function AssignWindowToConnection(pConnection : String; pFileName: String; pFileTab: TTabSheet) : Boolean;
    procedure SetActiveConnectionPageTab(pActivePageTab : TTabSheet);
    procedure MySynEditChange(Sender: TObject);
    constructor Create(AOwner : TComponent; ACb: TControlBar; aConnectButton : TToolButton;
                        aStatusPanel : TStatusPanel; aCompileResults : TPanel;
                        aNewFileEvent : TNotifyEvent; aIniFile : TIniFile);
    function Connect(pConnString, pUser, pPAss, pHost: String; pConnectionPageControl : TPageControl) : Boolean;
    procedure Disconnect;
    procedure SavePosition;
    function isFunction(pName : String) : Boolean;
    function isPackage(pName : String) : Boolean;
    procedure GotoFunction(pPackage, pFunction : String);
    procedure SQLPlus;
    function LoadExplorerFromStream(S: TStream ) : Boolean;
    Procedure SaveExplorerToStream(S: TStream );
    procedure CycleJumpNextMark(var pMarkIdx : Integer);
    procedure ExecuteToHTML;
    procedure GetFunctionList(pFunctionList: TStrings);
    procedure SetActiveConnection(pConnectString : String);
    procedure ShowActiveFileTabs;
    procedure RegisterFileForActiveConnection(pFileName : String; pFileTab : TTabSheet);
    procedure UnregisterFileFromActiveConnection(pFileName: String; pFileTab: TTabSheet);
    procedure RegisterUnregisteredTabs(pConnection : TMyOracleSession);
    procedure SetJumpObjFocus;
    procedure GotoPos(pos: TBufferCoord);
  published
    property Editor : TCustomSynEdit read FEditor write SetEditor;
    property HighlightList : String read FHighlightList write SetHighlightList;
    property ShowAllFiles : Boolean read FShowAllFiles write SetShowAllFiles;
 end;


type
  TScanKeywordThread = class(TThread)
  private
    fHighlighter: TSynCustomHighlighter;
    flastCount : Integer;
    fKeywords: TStringList;
    fFunctionList : TStringList;
    fCompeleteTokens: TStringList;
    fTmpStrings : TStringList;
    fCompletionAdd : TStringList;
    fLastPercent: integer;
    fScanEventHandle: THandle;
    fSource: string;
    fSourceChanged: boolean;
    fOutput : TTreeView;
    fTmpStringList  : TStringList;
    fAutoCompletionList : TStringList;
    fCompleteM :  TMemo;
    fSynCompletionAll: TSynCompletionProposal;
    fPosition : Integer;
    fReload : Boolean;
    fSourceActual : Boolean;
    fPLSLexer, fOuterPLSLexer : TPLSLexer;
    fHighilightWordArr : THighilightWordArr;
    fResultArr : PTHighilightWordArr;
    fHighlightModified : Boolean;
    fHighlightListModified : Boolean;

    procedure GetSource;
    procedure SetResults;
    procedure SetNavigatorPos;
    procedure ShowProgress;
    procedure MarkChanges;
    function LinesString(pList : TStrings) : String;
    procedure SetPositions;
    function FastCharIndexToRow(Index,pPrevLine : Integer; var pPrevChars: integer): Integer;
    procedure SetBlockStructures;
    procedure SetHighlightResults;
    function Explode(cDelimiter,  sValue : string; iCount : integer) : TArray;
  protected
    procedure Execute; override;

  public

    fEditor : TCustomSynEdit;
    fDelay : Integer;
    SQLObjectName : String;
    fDebugSL : TStrings;
    fHighlightWord : String;
    fHighlightList : String;
    fToHighlightArr : TArray;

    procedure  NoDelay;
    destructor Destroy; override;
    constructor Create(AOutput : TTreeView; AEditor : TCustomSynEdit;
        ACompleteM : TMemo; ACompletionAll : TSynCompletionProposal;
        ACompletionAdd : TStringList; AFunctionList : TStringList; APLSLexer : TPLSLexer;
        AResultArr : PTHighilightWordArr; AAutoCompletion : TStringList);
    procedure SetModified;
    procedure SetActual;
    procedure Reload;
    procedure Shutdown;
    procedure SetHighlightWord(pWord : String);
    procedure SetHighlightList(pList : String);

  end;

  type TExternalToolsManager = class(TObject)
    private
      fToolButton : TToolButton;
      fCodeCompletionForm : TFrmCodeCompletion;
    public
      Items : Array of TExternalToolREC;
      procedure MyOnExternalTool(Sender: TObject);
      procedure Add(pName, pCommand : String);
      procedure Remove(pIndex : Integer);
      procedure Modify(pIndex: Integer;  Name, Command : String);
      procedure LoadFromFile(pIniFile: TIniFile);
      procedure StoreToFile(pIniFile: TIniFile);
      procedure MenuReload;
      constructor Create(aToolButton : TToolButton; aCodeCompletionForm : TFrmCodeCompletion);
      destructor  Destroy;override;

  end;

implementation
uses ufrmMain, ufrmEditor, uTypesE, ShellAPI, uPLSQLRefactor, ClipBrd, SynEditKeyCmds, ufrmRefactorVariableRename;

{$R *.DFM}

function WinExec(FileName: string; Visibility: integer): cardinal;
var
   zAppName          : array[0..512] of char;
   zCurDir           : array[0..255] of char;
   WorkDir           : string;
   StartupInfo       : TStartupInfo;
   ProcessInfo       : TProcessInformation;
var
 vProg, vParams : String;
begin
  try
   vProg:=Copy(FileName,1, pos(' ', FileName)-1);
   if vProg<>'' then
     vParams:=Copy(FileName,pos(' ', FileName)+1, 999)
   else
     vProg:=FileName;
   ShellExecute(0,nil,PChar(vProg),PChar(vParams),nil,SW_NORMAL);
  except
    raise CException.Create('WinExec',0,application);
  end;
end;

constructor TScanKeywordThread.Create(AOutput : TTreeView; AEditor : TCustomSynEdit;
        ACompleteM : TMemo; ACompletionAll : TSynCompletionProposal;
        ACompletionAdd : TStringList; AFunctionList : TStringList; APLSLexer : TPLSLexer;
        AResultArr : PTHighilightWordArr;AAutoCompletion : TStringList);
begin
{*}try
    inherited Create(TRUE);
    //inherited Create;;
    fDelay:=DefaultDelay;
    fOutput := AOutput;
    fHighlighter := TSynSQLSyn.Create(nil);
    fPLSLexer:=TPLSLexer.Create;
    TSynSQLSyn(fHighlighter).SQLDialect := SQLOracle;
    fKeywords := TStringList.Create;
    fCompeleteTokens := TStringList.Create;
     fCompeleteTokens.Sorted:=True;
     fCompeleteTokens.Duplicates:=dupIgnore;
    fTmpStringList := TStringList.Create;
     fTmpStringList.Sorted:=True;
     fTmpStringList.Duplicates:=dupIgnore;
    fTmpStrings := TStringList.Create;
    fCompletionAdd := ACompletionAdd;
    fSynCompletionAll:=ACompletionAll;
    fFunctionList :=AFunctionList;
    fScanEventHandle := CreateEvent(nil, FALSE, FALSE, nil);
    fEditor := AEditor;
    fCompleteM:=ACompleteM;
    fOuterPLSLexer:=APLSLexer;
    fResultArr:=AResultArr;
    fAutoCompletionList:=AAutoCompletion;
    if (fScanEventHandle = 0) or (fScanEventHandle = INVALID_HANDLE_VALUE) then
       raise EOutOfResources.Create('Couldn''t create WIN32 event object');
    Resume; 
{*}except
{*}  raise CException.Create('Create',0,self);
{*}end;
end;

destructor TScanKeywordThread.Destroy;
var i : Integer;
begin
{*}try
    fHighlighter.Free;
    fKeywords.Free;
    fCompeleteTokens.Free;
    fTmpStrings.Free;
    fTmpStringList.Free;
    fPLSLexer.Free;
    SetLength(fHighilightWordArr,0);
    if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
      CloseHandle(fScanEventHandle);
    inherited Destroy;
{*}except
{*}  raise CException.Create('Destroy',0,self);
{*}end;
end;

function TScanKeywordThread.LinesString(pList : TStrings) : String;
var
  i : Integer;
begin
{*}try
    for i:=0 to pList.Count-1 do
      result:=result+';'+IntToStr(Integer(pList.Objects[i]));
{*}except
{*}  raise CException.Create('LinesString',0,self);
{*}end;
end;


function TScanKeywordThread.FastCharIndexToRow(
  Index,pPrevLine : Integer; var pPrevChars: integer): Integer;
{ Index is 0-based; Result.x and Result.y are 1-based }
var
 x, y: integer;
begin
  try
    x := 0;
    y := pPrevLine-1;
    while y < fEditor.Lines.Count do
    begin
      x := Length(fEditor.Lines[y]);
      if pPrevChars + x + 2 > Index then
      begin
        x := Index - pPrevChars;
        break;
      end;
      Inc(pPrevChars, x + 2);
      x := 0;
      Inc(y);
    end;
    // Result.Char := x + 1;
    Result := y + 1;
  except
    raise CException.Create('FastCharIndexToRow',0,self);
  end;
end;

function TScanKeywordThread.Explode(cDelimiter, sValue: string;
  iCount: integer): TArray;
var
  s : string; i,p : integer;
begin
        s := sValue; i := 0;
        while length(s) > 0 do
        begin
                inc(i);
                SetLength(result, i);
                p := pos(cDelimiter,s);

                if ( p > 0 ) and ( ( i < iCount ) OR ( iCount = 0) ) then
                begin
                        result[i - 1] := copy(s,0,p-1);
                        s := copy(s,p + length(cDelimiter),length(s));
                end else
                begin result[i - 1] := s;
                        s :=  '';
                end;
        end;
end;

procedure TScanKeywordThread.Execute;
var
  i,j, vLine, vLineTmp, vLineF, vLineTmpF: integer;
  s, sPositions, vPrevToken, vHw : string;
  vTokenId : Integer;

begin
{*}try
     while not Terminated do begin
      WaitForSingleObject(fScanEventHandle, INFINITE);
      repeat
        if Terminated then
          break;
        // make sure the event is reset when we are still in the repeat loop
        ResetEvent(fScanEventHandle);
        // get the modified source and set fSourceChanged to 0
        Synchronize(GetSource);
        GetSource;
        if Terminated then
          break;
        //remember positions of functions to check changes after scan
        sPositions := LinesString(fKeywords);
        // clear keyword list
        fKeywords.Clear;
        fCompeleteTokens.Clear;

        // scan the source text for the keywords, cancel if the source in the
        // editor has been changed again
        fHighlighter.ResetRange;
        fHighlighter.SetLine(fSource, 1);
        SQLObjectName:='';
        fPosition:=-1;
        vLine:=1; vLineTmp:=0; vLineF:=1; vLineTmpF:=0;
        fPLSLexer.Clear;
        while not fSourceChanged and not fHighlighter.GetEol and not Terminated do begin
          if (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkKey)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkIdentifier)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkFunction)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDefaultPackage)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDatatype)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkString)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDelimitedIdentifier)) then
          begin
            s := fHighlighter.GetToken;
            fCompeleteTokens.Add(s);
            if (SQLObjectName='') and
               ((fHighlighter.GetTokenKind =
                          Ord(SynHighlighterSQL.tkIdentifier))
                OR
                (fHighlighter.GetTokenKind =
                          Ord(SynHighlighterSQL.tkDelimitedIdentifier)))
                then
              SQLObjectName:=StringReplace(s,'"','',[rfReplaceAll]);
          end;
          if (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) then
          begin
            s := fHighlighter.GetToken;
            s:=UpperCase(s);

            if fPLSLexer.CheckToken(s, vTokenId) then begin
              vLine:=FastCharIndexToRow(fHighlighter.GetTokenPos, vLine, vLineTmp);
              if vPrevToken='END' then
                fPLSLexer.CloseDoubleEndToken(s,vTokenId, vLine);
              fPLSLexer.PutToken(vTokenId, vLine,s);
              try
                fPLSLexer.NewStructure;
              except
              end;
            end;

            if (s = 'FUNCTION') or (s='PROCEDURE') then
            begin
              fHighlighter.Next;
              s := fHighlighter.GetToken;
              while not fSourceChanged and not fHighlighter.GetEol and
                    ((s='') or (pos(' ',s)<>0)) do
              begin
                fHighlighter.Next;
                s := fHighlighter.GetToken;
              end;

              vLineF:=FastCharIndexToRow(fHighlighter.GetTokenPos, vLineF, vLineTmpF);
              with fKeywords do begin
                AddObject(s, pointer(Integer(vLineF)));
              end;
            end;
          end;
          vPrevToken:=s;
          fHighlighter.Next;
        end;
        Sleep(10);
      until not fSourceChanged;

      if Terminated then
        break;

      // source was changed while scanning
      if fSourceChanged then begin
        continue;
      end;

      if (((fHighlightWord<>'') or (fHighlightList<>'')) or fHighlightListModified) then begin
        fHighlighter.ResetRange;
        fHighlighter.SetLine(fSource, 1);
        SetLength(fHighilightWordArr,0);
        SetLength(fHighilightWordArr,256);

        i:=0;
        try
          while not fSourceChanged and not fHighlighter.GetEol and not Terminated do begin
            if 1=1 then
             { //(fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkKey)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkIdentifier)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkFunction)) or
               //(fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDefaultPackage)) or
               //(fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDatatype)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkString)) then}
            begin
              for j:=0 to Length(fToHighlightArr)-1 do begin
                vHw:=UpperCase(fToHighlightArr[j]);
                if vHw=UpperCase(fHighlighter.GetToken) then begin
                  if i+1>Length(fHighilightWordArr) then SetLength(fHighilightWordArr, i+256);
                  fHighilightWordArr[i].BufferCoord:=
                        fEditor.CharIndexToRowCol(fHighlighter.GetTokenPos);
                  vLine:=fHighlighter.GetTokenPos;
                  fHighilightWordArr[i].Word:=fHighlighter.GetToken;
                  fHighilightWordArr[i].ColorIdx:=j;
                  Inc(i);
                end;
              end;
            end;
            fHighlighter.Next;
          end;
        except
          SetLength(fHighilightWordArr,0);
        end;
        SetLength(fHighilightWordArr,i);
      end;

      // source was changed while scanning
      if fSourceChanged then begin
        continue;
      end;

//      Synchronize(MarkChanges);
      if fSourceActual then begin
         fTmpStrings.AddStrings(fKeywords);
         fSourceActual:=False;
      end;

      if (((fHighlightWord<>'') or (fHighlightList<>'')) or
            fHighlightListModified or fHighlightModified) then begin
        Synchronize(SetHighlightResults);
      end;
      fHighlightModified:=False;
      fHighlightListModified :=False;
      if (fReload or (not fSourceChanged and fHighlighter.GetEol) and
        (fTmpStrings.Text<>fKeywords.Text)) then
      begin
        Synchronize(SetResults);
        fTmpStrings.Clear;
        fTmpStrings.AddStrings(fKeywords);
        fReload := False;
        flastCount:=fEditor.Lines.Count;
      end
      else if (fHighlighter.GetEol and (sPositions <> LinesString(fKeywords))) then begin
        if flastCount <> fEditor.Lines.Count then begin
          Synchronize(SetPositions);
          flastCount:=fEditor.Lines.Count;
        end;
        Synchronize(SetBlockStructures);        
      end else if fHighlighter.GetEol then
          Synchronize(SetBlockStructures);

     fSynCompletionAll.ItemList:=fCompeleteTokens;
     fSynCompletionAll.InsertList:=fCompeleteTokens;
     fAutoCompletionList:=fCompeleteTokens;
   end;
{*}except
{*}  raise CException.Create('Execute',0,self);
{*}end;
end;

procedure TScanKeywordThread.GetSource;
begin
{*}try
    if fEditor <> nil then
      fSource := fEditor.Text
    else
      fSource := '';
    fSourceChanged := FALSE;
{*}except
{*}  raise CException.Create('GetSource',0,self);
{*}end;
end;

procedure TScanKeywordThread.NoDelay;
begin
{*}try
    fDelay:=0;
{*}except
{*}  raise CException.Create('NoDelay',0,self);
{*}end;
end;

procedure TScanKeywordThread.Reload;
begin
{*}try
   fReload:=True;
{*}except
{*}  raise CException.Create('Reload',0,self);
{*}end;
end;

procedure TScanKeywordThread.SetModified;
begin
{*}try
    fSourceChanged := TRUE;
    fHighlightListModified:=True;
    if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
      SetEvent(fScanEventHandle);
{*}except
{*}  raise CException.Create('SetModified',0,self);
{*}end;
end;

procedure TScanKeywordThread.SetHighlightWord(pWord: String);
begin
  try
    fHighlightModified:=True;
    fHighlightWord:=pWord;
    if Length(fToHighlightArr)=0 then
      SetLength(fToHighlightArr,1);
    fToHighlightArr[0]:=pWord;

  //    fSourceChanged := TRUE;
    if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
      SetEvent(fScanEventHandle);
  except
    raise CException.Create('SetHighlightWord',0,self);
  end;
end;

procedure TScanKeywordThread.SetHighlightList(pList: String);
begin
  try
    fHighlightListModified:=True;
    fHighlightList:=pList;
    if fHighlightWord<>'' then
      fToHighlightArr:=explode(' ',fHighlightWord+' '+pList,0)
    else begin
      fToHighlightArr:=explode(' ','hword'+' '+pList,0);
      fToHighlightArr[0]:='';
    end;


  //    fSourceChanged := TRUE;
    if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
      SetEvent(fScanEventHandle);
  except
    raise CException.Create('SetHighlightWord',0,self);
  end;
end;


procedure TScanKeywordThread.SetActual;
begin
{*}try
    fSourceActual := True;
    fTmpStrings.AddStrings(fKeywords);
{*}except
{*}  raise CException.Create('SetActual',0,self);
{*}end;
end;


procedure TScanKeywordThread.MarkChanges;
var
 i: Integer;
 caretPos : TBufferCoord;
begin
{*}try
exit;
    caretPos := fEditor.CaretXY;
    for i:=fOutput.Items.Count-1 downto 0 do begin
      if caretPos.Line>=fOutput.Items[i].SelectedIndex then begin
        fOutput.Items[i].StateIndex:=caretPos.Line;
        exit;
      end;
    end;
{*}except
{*}  raise CException.Create('MarkChanges',0,self);
{*}end;
end;


procedure TScanKeywordThread.SetBlockStructures;
var i : Integer;
begin
  try
  {    if Assigned(fDebugSL) then begin
        fDebugSL.Clear;
        for i:=0 to fPLSLexer.fBlockCount-1 do begin
          fDebugSL.Add(IntToStr(i)+'. '+IntToStr(fPLSLexer.fBlocks[i].startPos)+':'+fPLSLexer.fBlocks[i].startStr+
            ' -> '+ IntToStr(fPLSLexer.fBlocks[i].endPos)+':'+fPLSLexer.fBlocks[i].endStr+
            '  ['+IntToStr(fPLSLexer.fBlocks[i].structureId)+']');
        end;
      end;        }
      fOuterPLSLexer.Assign( fPLSLexer );
  except
    raise CException.Create('SetBlockStructures',0,self);
  end;
end;

procedure TScanKeywordThread.SetPositions;
var i : Integer;
begin
{*}try
exit;
    for i:=0 to fOutput.Items.Count-1 do begin
      if fKeywords.Count>i then
        if fKeywords[i]=fKeywords[i] then
          fOutput.Items[i].SelectedIndex:=Integer(fKeywords.Objects[i]);
    end;
{*}except
{*}  raise CException.Create('SetPositions',0,self);
{*}end;
end;

procedure TScanKeywordThread.SetResults;
var
 i: Integer;
 n : TTreeNode;
 s : String;
begin
{*}try
    if fEditor <> nil then
    begin
      if Assigned(fOutput) then
      begin
        fOutput.Enabled:=False;
        fOutput.Visible:=False;
        fTmpStringList.Clear;
        for i:=fOutput.Items.Count-1 downto 0 do begin
            fTmpStringList.Add(fOutput.Items[i].Text);
            fTmpStringList.AddObject(fOutput.Items[i].Text, Pointer(0+Integer(fOutput.Items[i].StateIndex)));
        end;

        fOutput.Items.Clear;
        n:=nil;
        {if SQLObjectName<>'' then
        begin
          n:=fOutput.Items.Add(n,SQLObjectName);
          for i:=0 to fKeywords.Count-1 do
            fOutput.Items.AddChild(n,fKeywords[i]);
          n.Expand(False);
        end
        else}

  {      if fOutput.SortType=stText then
          fKeywords.Sort;  }
        for i:=0 to fKeywords.Count-1 do
        begin
          n:=fOutput.Items.Add(n,fKeywords[i]);
          n.SelectedIndex:=Integer(fKeywords.Objects[i]);
          n.StateIndex:=0;
          if fTmpStringList.Count>i then
            if fTmpStringList[i]=fKeywords[i] then
              n.StateIndex:=Integer(fTmpStringList.Objects[i]);
        end;
        if fOutput.SortType=stText then
          fOutput.AlphaSort;

      end;
      if Assigned(fFunctionList) then
        fFunctionList.Assign(fKeywords);
      if Assigned(fCompleteM) then
        fCompleteM.Lines:=fCompeleteTokens;

//      fSynCompletionAll.ItemList:=fCompeleteTokens;
//      fSynCompletionAll.InsertList:=fCompeleteTokens;
//      fSynCompletionAll.ItemList.AddStrings(fCompletionAdd);
//      fSynCompletionAll.InsertList.AddStrings(fCompletionAdd);
      fOutput.Enabled:=True;
      fOutput.Visible:=True;      
      fOuterPLSLexer.Assign( fPLSLexer );
    end
{*}except
      fOutput.Enabled:=True;
      fOutput.Visible:=True;
{*}  raise CException.Create('SetResults',0,self);
{*}end;
end;

procedure TScanKeywordThread.SetHighlightResults;
var
  i : Integer;
begin
  try
    SetLength(fResultArr^,Length(fHighilightWordArr));
    for i:=0 to Length(fHighilightWordArr)-1 do begin
      fResultArr^[i]:=fHighilightWordArr[i];
    end;
    if fEditor <> nil then fEditor.Repaint;  
  except
    raise CException.Create('SetHighlightResults',0,self);
  end;
end;


procedure TScanKeywordThread.SetNavigatorPos;
begin
{*}try
    if not fOutput.Focused and (fPosition>=0) then
    begin
      fOutput.Items[fPosition].Selected:=True;
      fOutput.Items[fPosition].StateIndex:=1;
    end
{*}except
{*}  raise CException.Create('SetNavigatorPos',0,self);
{*}end;
end;


procedure TScanKeywordThread.ShowProgress;
begin
{*}try
{*}except
{*}  raise CException.Create('ShowProgress',0,self);
{*}end;
end;

procedure TScanKeywordThread.Shutdown;
begin
{*}try
    Terminate;
    if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
      SetEvent(fScanEventHandle);
{*}except
{*}  raise CException.Create('Shutdown',0,self);
{*}end;
end;


{ TFrmCodeCompletion }
constructor TFrmCodeCompletion.Create(AOwner : TComponent; ACb: TControlBar; aConnectButton : TToolButton;
                        aStatusPanel : TStatusPanel; aCompileResults : TPanel;
                        aNewFileEvent : TNotifyEvent; aIniFile: TIniFile);
begin
{*}try
    inherited Create(AOwner);
    fActiveConnection:='';
    fTimerExecution:=False;
    fControlBar := ACb;
    fConnections := TStringList.Create;
    fCompileResults := TStringList.Create;
    fDbObjects := TStringList.Create;
    fDbPackages := TStringList.Create;
    fEdFunctions:= TStringList.Create;
    fAutoCompleteList := TStringList.Create;
    fPLSLexer := TPLSLexer.Create;
    fPackageNameMatchList:=TStringList.Create;
    fConnectButton:=AConnectButton;
    fspConnection:=aStatusPanel;
    fConnectButton.DropdownMenu:= pmConnectMenu;
    fNewFileEvent:=aNewFileEvent;
    fpCompileResults:=aCompileResults;
    SynCompletionProposalAll.TriggerChars:='abcdefghijklmnoprstuvwxz';
    SynCompletionProposalAll.TriggerChars:=SynCompletionProposalAll.TriggerChars+
          UpperCase('abcdefghijklmnoprstuvwxz');
    SynCompletionProposalAll.TriggerChars:=SynCompletionProposalAll.TriggerChars+'_$';
    IniFile:=aIniFile;
    if Assigned(IniFile) then
      if IniFile.ReadString('CodeNavigator','Sorted', 'F')='T' then
      begin
        Sort1.Checked:=True;
        tvFunctions.SortType:=stText;
      end;
    fAutoComplete:=TOraTinnAutoComp.Create(Self,nil,ExtractFilePath(ParamStr(0))+'autocomplete.ini');
    SynCompletionProposalAll.ShortCut:=16397; //Ctrl+Enter (not aviable from drop down list)

    fFrmJumpObj := TFrmJumpObj.Create(Self, tvDb);

{*}except
{*}  raise CException.Create('Create',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.FormDestroy(Sender: TObject);
var
 vIdx : Integer;
 vTrace : String;
begin
{*}try
    inherited;
    vTrace:='1';
    TimCursorPos.Enabled:=False;
    SynCompletionProposalAll.Editor:=nil;
    vTrace:='2';
    dsCompile.Session:=nil;
    fAutoComplete.Editor:=nil;
    fAutoComplete.Free;
    fPackageNameMatchList.Free;
    fPackageNameMatchList:=nil;
    vTrace:='3';
    if fWorkerThread <> nil then  begin
      TScanKeywordThread(fWorkerThread).Shutdown;
      TScanKeywordThread(fWorkerThread).WaitFor;      
      TScanKeywordThread(fWorkerThread).Free;
    end;
    vTrace:='4';

    while pmConnectMenu.Items.Count>0 do
      if Assigned(pmConnectMenu.Items[0]) then
        pmConnectMenu.Items[0].Free;
      //pmConnectMenu.Items.Delete(0);
    vTrace:='5';
    for vIdx := 0 to fCompileResults.Count-1 do
      if Assigned(fCompileResults.Objects[vIdx]) then
        Dispose(PPoint(fCompileResults.Objects[vIdx]));
    vTrace:='6';
    for vIdx := 0 to fConnections.Count-1 do
      if Assigned(fConnections.Objects[vIdx]) then
      begin
        try
          vTrace:='7';
          try
            TMyOracleSession(fConnections.Objects[vIdx]).Connected:=False;
          except
          end;
        finally
          vTrace:='8';
          TMyOracleSession(fConnections.Objects[vIdx]).Free;
        end;
      end;
    vTrace:='9';
    fConnections.Free;
    fCompileResults.Free;
    fFrmQueryGrid.Free;
    fCompileErrors.Free;
    fDbObjects.Free;
    fDbPackages.Free;
    fEdFunctions.Free;
    fAutoCompleteList.Free;
    fPLSLexer.Free;
    vTrace:='10';    
    if Assigned(fEditor) then
    begin
      fEditor.OnChange:=fOrigEdOnChange;
      fEditor.OnChange:=nil;;
      fEditor:=nil;
    end;
    fFrmJumpObj.Free;
    fFrmJumpObj:=nil;

{*}except
{*}  raise CException.Create('FormDestroy-'+vTrace,0,self);
{*}end;
end;

procedure TFrmCodeCompletion.MySynEditChange(Sender: TObject);
begin
{*}try
    BlockPaint.Valid:=False;
    fPLSLexer.Clear;
    fEditor.Repaint;
    if Assigned(fEditor) then
      fEditor.InvalidateGutter;
    if Assigned(fOrigEdOnChange) then
      fOrigEdOnChange(Sender);
    if (fWorkerThread <> nil) and (SynCompletionProposalAll.Form.Visible=False) then
      TScanKeywordThread(fWorkerThread).SetModified;
    if fWorkerThread <> nil then begin
      fHighlightWord:='';
      SetLength(fHighilightWordArr,0);
    end;
   // TimerAll.Enabled:=True;
   SetModificationMark;
   fEditor.Repaint;
{*}except
{*}  raise CException.Create('MySynEditChange',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.ShowFunction(pFunction: String; pCount : Integer);
var
 b:TBufferCoord;
 s : String;
 aHighlighter : TSynSQLSyn;
 vCount : Integer;
 vFound : Boolean;
begin
{*}try
    fEditor.TopLine:=b.line;
    aHighlighter := TSynSQLSyn.Create(nil);
    aHighlighter.SQLDialect := SQLOracle;
    aHighlighter.ResetRange;
    aHighlighter.SetLine(fEditor.Text, 1);
    vCount:=1;
    vFound:=True;
    while not aHighlighter.GetEol do
    begin
      if (aHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) then
      begin
        s := UpperCase(aHighlighter.GetToken);
        if (s = 'FUNCTION') or (s='PROCEDURE') then
        begin
          aHighlighter.Next;
          //rewind to FUNCTION keyword
          s := aHighlighter.GetToken;
          while not aHighlighter.GetEol and
                ((s='') or (pos(' ',s)<>0)) do
          begin
            aHighlighter.Next;
            s := aHighlighter.GetToken;
          end;
          if (aHighlighter.GetToken=pFunction) then
          begin
            if (pCount=vCount) or (pCount=-1) then begin
              b:=fEditor.CharIndexToRowCol(aHighlighter.GetTokenPos);

              //rewind to semicolon or IS (skip function declaratino in package body)
              if (pCount=-1) then
              begin
                  vFound:=False;
                  s := aHighlighter.GetToken;
                  while not aHighlighter.GetEol do
                  begin
                    aHighlighter.Next;
                    s := UpperCase(aHighlighter.GetToken);
                    if (s = 'IS') or (s = 'AS') then
                    begin
                      vFound:=True;
                      break;
                    end
                    else if s=';' then
                    begin
                      break;
                    end;
                  end;
              end;

              if vFound then
              begin
                fEditor.TopLine:=b.line;
                exit;
              end;
            end;
            Inc(vCount);            
          end;
        end;
      end;
      aHighlighter.Next;
    end;
    aHighlighter.Free;
{*}except
{*}  raise CException.Create('ShowFunction',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.GetFunctionList(pFunctionList: TStrings);
var
 functionNamePos:TBufferCoord;
 functionName, s : String;
 aHighlighter : TSynSQLSyn;
 vCount : Integer;
 loadDeclarations : Boolean;
begin
{*}try
    if not Assigned(pFunctionList) then exit;
//    fEditor.TopLine:=b.line;
    aHighlighter := TSynSQLSyn.Create(nil);
    aHighlighter.SQLDialect := SQLOracle;
    aHighlighter.ResetRange;
    aHighlighter.SetLine(fEditor.Text, 1);
    vCount:=1;
    loadDeclarations:=True;
    try
      pFunctionList.BeginUpdate;
      while not aHighlighter.GetEol do
      begin
        if (aHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) then
        begin
          s := UpperCase(aHighlighter.GetToken);
          if s='BODY' then
            loadDeclarations:=False;
          if (s = 'FUNCTION') or (s='PROCEDURE') then
          begin
            aHighlighter.Next;
            s := aHighlighter.GetToken;
            while not aHighlighter.GetEol and
                  ((s='') or (pos(' ',s)<>0)) do
            begin
              aHighlighter.Next;
              s := aHighlighter.GetToken;
            end;
            functionNamePos:=fEditor.CharIndexToRowCol(aHighlighter.GetTokenPos);
            functionName:=aHighlighter.GetToken;


            while not aHighlighter.GetEol and
                  ((s<>';') and (s<>'IS')) do
            begin
              aHighlighter.Next;
              s := UpperCase(aHighlighter.GetToken);
            end;
            if (s='IS') or (loadDeclarations and (s=';')) then
              pFunctionList.Add(functionName+'='+IntToStr(functionNamePos.line));

          end;
        end;
        aHighlighter.Next;
      end;
    finally
      pFunctionList.EndUpdate;
    end;
    aHighlighter.Free;
{*}except
{*}  raise CException.Create('GetFunctionList',0,self);
{*}end;
end;


procedure TFrmCodeCompletion.tvFunctionsChange(Sender: TObject;
  Node: TTreeNode);
var
  vNode: TTreeNode;
  vCount : Integer;
begin
{*}try
    if not tvFunctions.Focused then exit;
    {if Node.SelectedIndex>0 then begin
      if (fPreviouslyClickedNode=Node) or (Node.StateIndex=0) then
        fEditor.TopLine:=Node.SelectedIndex
      else
        fEditor.GotoLineAndCenter(Node.StateIndex)
    end
    else}
    vNode:= tvFunctions.Items[0];
    vCount:=0;
    While (vNode <> nil) and (vNode<>Node) Do Begin
      if vNode.Text=Node.Text then Inc(vCount);
      vNode:= vNode.GetNext;
    End; { While }
    ShowFunction(Node.Text, vCount+1);
{*}except
{*}  raise CException.Create('tvFunctionsChange',0,self);
{*}end;
end;



procedure TFrmCodeCompletion.tvFunctionsClick(Sender: TObject);
begin
{*}try
    if Assigned(tvFunctions.Selected) then
    begin
      tvFunctionsChange(tvFunctions,tvFunctions.Selected);
      if fPreviouslyClickedNode=tvFunctions.Selected then
        fPreviouslyClickedNode:=nil
      else
        fPreviouslyClickedNode:=tvFunctions.Selected;
    end;
{*}except
{*}  raise CException.Create('tvFunctionsClick',0,self);
{*}end;
end;


Procedure TFrmCodeCompletion.SaveExplorerToStream(S: TStream );
  Var
    writer: TWriter;
    node: TTreeNode;
    tv: TTreeview;
  Begin
{*}try
      tv:=tvFunctions;
      Assert( Assigned( tv ));
      Assert( Assigned( S ));

      writer:= TWriter.Create( S, 4096 );
      try
        node:= tv.Items[0];
        writer.WriteListBegin;
        writer.WriteString(fObjectName);
        While node <> nil Do Begin
          writer.WriteInteger( node.level );
          writer.WriteString( node.Text );
          writer.WriteInteger( node.Selectedindex );
          writer.WriteString( IntToStr(node.Stateindex));
          //writer.WriteInteger( Integer(node.data ));
          node:= node.GetNext;
        End; { While }
        writer.WriteListEnd;
        writer.FlushBuffer;
      finally
        writer.Free;
      end;
{*}except
{*}  raise CException.Create('SaveExplorerToStream',0,self);
{*}end;
 End; { SaveTreeviewToStream }

function TFrmCodeCompletion.LoadExplorerFromStream(S: TStream ) : Boolean;
  Var
    reader: TReader;
    node: TTreenode;
    level: Integer;
    tv: TTreeview;
  Begin
{*}try
      tv:=tvFunctions;
      Assert( Assigned( tv ));
      Assert( Assigned( S ));
      if S.size= 0 then begin
        result:=False;
        exit;
      end;
      result:=True;
      tv.Items.BeginUpdate;
      try
        tv.Items.Clear;
        reader:= TReader.Create( S, 4096 );
        try
          node:= nil;
          reader.ReadListBegin;
          if not Reader.EndOfList then
            fObjectName:=Reader.ReadString;
          While not Reader.EndOfList Do Begin
            level := reader.ReadInteger;
            If node = nil Then
              // create root node, ignore its level
              node:= tv.Items.Add( nil, '' )
            Else Begin
              If level = node.level Then
                node := tv.Items.Add( node, '' )
              Else If level > node.level Then
                node := tv.Items.AddChild( node, '' )
              Else Begin
                While Assigned(node) and (level < node.level) Do
                  node := node.Parent;
                node := tv.Items.Add( node, '' );
              End; { Else }
            End; { Else }
            node.Text := Reader.ReadString;
            node.SelectedIndex := Reader.ReadInteger;
            //node.StateIndex := Reader.ReadInteger;
            node.StateIndex := StrToInt(Reader.ReadString);
            //node.Data := Pointer( Reader.ReadInteger );
          End; { While }
          reader.ReadListEnd;
        finally
          reader.Free;
        end;
      finally
        tv.items.Endupdate;
      end;
{*}except
{*}  raise CException.Create('LoadExplorerFromStream',0,self);
{*}end;
  End; { LoadTreeviewFromStream}


procedure TFrmCodeCompletion.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
{*}try
    frmTinnMain.leftSplitter.Visible := False;
    frmTinnMain.panProjectDockSite.Constraints.MinWidth := 0;
    frmTinnMain.panProjectDockSite.Width := 1;
{*}except
{*}  raise CException.Create('FormClose',0,self);
{*}end;
end;


procedure TFrmCodeCompletion.SetEditor(const Value: TCustomSynEdit);
var
 loaded : Boolean;
begin
{*}try

    if fEditor=Value then exit;

    if fWorkerThread <> nil then
    begin
      TScanKeywordThread(fWorkerThread).Shutdown;
      TScanKeywordThread(fWorkerThread).WaitFor;
      TScanKeywordThread(fWorkerThread).Free;
      fWorkerThread:=nil;
    end;


    //restoring original Event to previous editor
    if Assigned(fOrigEdOnChange) and Assigned(fEditor) then
      fEditor.OnChange:=fOrigEdOnChange;
    SetLength(fHighilightWordArr,0);
    //Storing code explorer state to editor window memorystream
{    if Assigned(FEditor) then
      if TCustomSynEdit(FEditor).Owner is TfrmEditor then
        if Assigned(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState) then
          if tvFunctions.Items.Count>0 then  begin
            //tvFunctions.SaveToStream(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState);
            TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState.Clear;
            fObjectName:=TScanKeywordThread(fWorkerThread).SQLObjectName; //Save this name to MemoryStream
            SaveExplorerToStream(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState);
          end;}
    fEdFunctions.Clear;
    fAutoCompleteList.Clear;
    SynCompletionProposalAll.ItemList.Clear;
    FEditor := Value;
    fAutoComplete.Editor:=fEditor;

    SynCompletionProposalAll.Editor:=nil;

    //seting our Event to current editor
    if Assigned(fEditor) then
    begin
      fOrigEdOnChange:=fEditor.OnChange;
      fEditor.OnChange:=MySynEditChange;
    end;
  


    //Restoring code explorer state to editor window memorystream
    loaded:=False;
   { if Assigned(FEditor) then
      if TCustomSynEdit(FEditor).Owner is TfrmEditor then
        if Assigned(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState) then begin
          TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState.Position:=0;
          //tvFunctions.LoadFromStream(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState);
          loaded:=LoadExplorerFromStream(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState);
        end;}

    if not loaded then begin
      tvFunctions.Enabled:=False;
      tvFunctions.Visible:=False;
      tvFunctions.Items.Clear;
      tvFunctions.Enabled:=True;
      tvFunctions.Visible:=True;      
    end;

    if Assigned(fEditor) then
    begin
      SynCompletionProposalAll.Editor:=fEditor;
      fWorkerThread := TScanKeywordThread.Create(tvFunctions, fEditor, nil,
        SynCompletionProposalAll, fdbPackages, fEdFunctions, fPLSLexer,
        @fHighilightWordArr, fAutoCompleteList);

      if Assigned(fWorkerThread) then
      begin
       //TScanKeywordThread(fWorkerThread).SQLObjectName:=fObjectName; //LoadedFrom MemoryStream
       if (not loaded) then
        TScanKeywordThread(fWorkerThread).SetModified
       else
        TScanKeywordThread(fWorkerThread).SetActual;
      end;
    end;
    SetHighlightList(fHighlightList);    
    fHighlightWord:='';
    BlockPaint.Valid:=False;
    BlockPaint.RePaint:=False;
    fCaretPos.Line:=0;
{*}except
{*}  raise CException.Create('SetEditor',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.Disconnect;
var
 vPos : Integer;
 ase : TMyOracleSession;
 vMi : TMenuItem;
begin
{*}try
    if not Assigned(dsCompile.Session) then exit;
    vPos:=fConnections.IndexOf(fActiveConnection);
    if pmConnectMenu.Items.Count>vPos then
    begin
      ase:=TMyOracleSession(fConnections.Objects[vPos]);
      try
        ase.Connected:=False;
        ase.ConnectionTab.PageControl.Visible := ase.ConnectionTab.PageControl.PageCount>1;
        ase.ConnectionTab.Free;
      except
         //wyciszam bledy zwiazane z wylaczeniem bazy w czasie polaczenia
      end;
       ase.Free;
      fConnections.Delete(vPos);
      pmConnectMenu.Items[vPos].Free;
      dsCompile.Session:=nil;
      fActiveConnection:='';

      vMi:=nil;
      if pmConnectMenu.Items.Count>0 then
        if Assigned(pmConnectMenu.Items[pmConnectMenu.Items.Count-1]) then
          vMi:=pmConnectMenu.Items[pmConnectMenu.Items.Count-1];

      MyConnectionChange(vMi);

    end;
{*}except
{*}  raise CException.Create('Disconnect',0,self);
{*}end;
end;


function TFrmCodeCompletion.Connect(pConnString, pUser, pPAss, pHost: String; pConnectionPageControl : TPageControl) : Boolean;
var
 vConn : TMyOracleSession;
 vMI : TMenuItem;
 vPos : Integer;
 vConnectionTab : TTabSheet;
begin
  try
    vPos:=fConnections.IndexOf(UpperCase(pConnString));
    if vPos>-1 then begin
      if fActiveConnection<>fConnections[vPos] then begin
         fActiveConnection:=fConnections[vPos];
         MyConnectionChange(nil);
      end;
      result:=True;
      exit;
    end;
    vConn:=TMyOracleSession.Create(Self, UpperCase(pConnString));
    vConn.LogonUsername:=UpperCase(pUser);
    vConn.LogonPassword:=pPass;
    vConn.LogonDatabase:=UpperCase(pHost);
    vConn.Connected:=True;
    fConnections.AddObject(UpperCase(pConnString), vConn);
    vMI := TMenuItem.Create(Self);
    vMI.Caption:=UpperCase(pConnString);
    vMI.OnClick:=MyConnectionChange;
    pmConnectMenu.Items.Add(vMI);

    if Assigned(pConnectionPageControl) then
    begin
      vConnectionTab := TTabSheet.Create(frmTinnMain);
      with vConnectionTab do
      begin
        PageControl := pConnectionPageControl;
        Caption := pConnString;
        Hint := Caption;
        ShowHint := True;
        vConn.ConnectionTab:=vConnectionTab;
        SetActiveConnectionPageTab(frmTinnMain.pgFiles.ActivePage);
      end;
    end;
    if fConnections.Count=1 then begin
      fActiveConnection:=fConnections[0];
      RegisterUnregisteredTabs(vConn);
      SetActiveConnectionPageTab(frmTinnMain.pgFiles.ActivePage);
    end;
    MyConnectionChange(vMI);
    result:=True;
  except
    if Assigned(vConn) then
     try
      vConn.Connected:=False;
     except
     end;
    vConn.Free;
    result:=False;
//    raise; - chce aby po nieudanym polaczeniu formatka Connection pojawila sie ponownie
  end;
end;

procedure TFrmCodeCompletion.RegisterUnregisteredTabs(pConnection : TMyOracleSession);
var
  vIdx : Integer;
begin
  for vIdx := 0 to frmTinnMain.pgFiles.PageCount-1 do
    pConnection.RegisterFileTab(frmTinnMain.pgFiles.Pages[vIdx].Caption, frmTinnMain.pgFiles.Pages[vIdx]);
end;


procedure TFrmCodeCompletion.SetActiveConnection(pConnectString : String);
var
 vPos: Integer;
 vMOS : TMyOracleSession;
begin
{*}try
    vPos:=fConnections.IndexOf(pConnectString);
    if vPos<>-1 then
    begin
      fObjectsLoaded:=False;
      fActiveConnection:=pConnectString;
      fspConnection.Text:=pConnectString;
      dsCompile.Close;
      dsDetail.Close;
      vMOS:=TMyOracleSession(fConnections.Objects[vPos]);
      dsCompile.Session:=vMOS;
      vMOS.ConnectionTab.PageControl.ActivePage := vMOS.ConnectionTab;
      vMOS.ConnectionTab.PageControl.Visible := vMOS.ConnectionTab.PageControl.PageCount>1;
      if not ShowAllFiles then
        vMOS.ShowActiveFileTabs
      else
        vMOS.ShowAllFileTabs;

      Application.ProcessMessages;

      tsDB.TabVisible:=True;
      tsDB.Caption:=pConnectString;
      LoadObjectsList;
      fObjectsLoaded:=True;
    end
    else begin
      fActiveConnection:='';
      tsFile.ActivePageIndex:=0;
      fDbObjects.Clear;
      tsDB.TabVisible:=False;
      tsDB.Caption:='';
      fspConnection.Text:='';
    end;
    PrepareSearchBox;
{*}except
{*}  raise CException.Create('SetActiveConnection',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.ShowActiveFileTabs;
var
 vPos: Integer;
 vMOS : TMyOracleSession;
begin
  vPos:=fConnections.IndexOf(fActiveConnection);
  if vPos<>-1 then
  begin
    vMOS:=TMyOracleSession(fConnections.Objects[vPos]);
    if not ShowAllFiles then
      vMOS.ShowActiveFileTabs;
  end;

end;

procedure TFrmCodeCompletion.SetActiveConnectionPageTab(pActivePageTab : TTabSheet);
var
 vCurrentIdx : Integer;
begin
 try
   if fActiveConnection<>'' then
   begin
     vCurrentIdx:=fConnections.IndexOf(fActiveConnection);
     if vCurrentIdx>=0 then
       TMyOracleSession(fConnections.Objects[vCurrentIdx]).SetActivePageTab(pActivePageTab);
   end;
{*}except
{*}  raise CException.Create('SetActiveConnectionPageIndex',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.JumpObjOnDobleClick(Sender: TObject);
var
 vItemIdx : Integer;
begin
  vItemIdx := (Sender as TListView).Tag;
  tvDB.Select(tvDB.Items[vItemIdx]);
  tvDbDblClick(Sender);
end;


procedure TFrmCodeCompletion.PrepareSearchBox;
var
 vNode : TTreeNode;
 aNodeEnum: TTreeNodesEnumerator;
begin
  fFrmJumpObj.OnLoadSPCClick := JumpObjOnLoadSPCClick;
  fFrmJumpObj.OnLoadBDYClick := JumpObjOnLoadBDYClick;
  fFrmJumpObj.OnDobleClick   := JumpObjOnDobleClick;
  fFrmJumpObj.Flist.Clear;
  aNodeEnum := tvDB.Items.GetEnumerator;
  try
    while aNodeEnum.MoveNext do
    begin
      vNode := aNodeEnum.Current;
      if vNode.Level>0 then
        fFrmJumpObj.Flist.Add(vNode.Text+'='+IntToStr(vNode.AbsoluteIndex));
    end;
  finally
    aNodeEnum.Free;
  end;
  fFrmJumpObj.Parent:=tvDB.Parent;
  fFrmJumpObj.Align:=alClient;
  fFrmJumpObj.Prepare;

end;

procedure TFrmCodeCompletion.aSearchExecute(Sender: TObject);
begin
  PrepareSearchBox;
  fFrmJumpObj.Show;
  SetJumpObjFocus;
end;

procedure TFrmCodeCompletion.SetJumpObjFocus;
begin
// PostMessage(handle,WM_SETFOCUS,0,0);
// PostMessage(fFrmJumpObj.handle,WM_SETFOCUS,0,0);
// PostMessage(fFrmJumpObj.edFilter.handle,WM_SETFOCUS,0,0);
//ActiveControl:=fFrmJumpObj;

//    ActiveControl:=fFrmJumpObj;
//    ActiveControl:=tsFile;
  fFrmJumpObj.SetFocusOnFilter;
end;


function TFrmCodeCompletion.AssignWindowToConnection(pConnection : String; pFileName: String; pFileTab: TTabSheet) : Boolean;
var
 vCurrentIdx, vIdx: Integer;
 vMOS : TMyOracleSession;
 vFOund : Boolean;
begin
   vFound:=False;
   if pConnection<>'' then
   begin
     vCurrentIdx:=fConnections.IndexOf(pConnection);
     if vCurrentIdx>=0 then
     begin
       for vIdx := 0 to fConnections.Count-1 do
       begin
         if vIdx<>vCurrentIdx then
         begin
           vMOS:=TMyOracleSession(fConnections.Objects[vIdx]);
           vFound := vMOS.UnregisterFileTab(pFileName, pFileTab);
           if vFound then
             break;
         end;
       end;
     end;
     if vFound then
       (fConnections.Objects[vCurrentIdx] as TMyOracleSession).RegisterFileTab(pFileName, pFileTab);
   end;
   result := vFound;
end;

function TFrmCodeCompletion.AssignWindowToCurrentConnection( pFileName: String; pFileTab: TTabSheet) : Boolean;
begin
  AssignWindowToConnection(fActiveConnection, pFileName, pFileTab);
end;


procedure TFrmCodeCompletion.MyConnectionChange(Sender: TObject);
var
 vConnectStr : String;
begin
{*}try
    if Sender<>nil then
      vConnectStr := StringReplace((Sender as TMenuItem).Caption, '&', '', [])
    else
      vConnectStr:=fActiveConnection;

    SetActiveConnection( vConnectStr);


{*}except
{*}  raise CException.Create('MyConnectionChange',0,self);
{*}end;
end;


function TFrmCodeCompletion.PackageNameMatch(pSQLObjectName,pLogonUsername : String) : Boolean;
var
  vPos1, vPos2, vPos3, vIdx : Integer;
  vObjNamePattern, vSchemaAcceptPattern, vSchemaRejectPattern : String;
  vToParse : String;
  regexpr : TRegEx;
  match   : TMatch;
  group   : TGroup;
  i       : integer;
begin
  Result:=True;
  for vIdx:=0 to fPackageNameMatchList.count-1 do
  begin
    vToParse := fPackageNameMatchList.Strings[vIdx]+';';
    vPos1 := pos('=', vToParse);
    vToParse:=copy(vToParse,vPos1+1,99999);
    vPos1 := pos(';', vToParse);
    vObjNamePattern := copy(vToParse,1,vPos1-1);
    vToParse:=copy(vToParse,vPos1+1,99999);

    vPos1 := pos(';', vToParse);
    vSchemaAcceptPattern := copy(vToParse,1,vPos1-1);
    vToParse:=copy(vToParse,vPos1+1,99999);

    vPos1 := pos(';', vToParse);
    vSchemaRejectPattern := copy(vToParse,1,vPos1-1);

    if TRegEx.IsMatch(pSQLObjectName, vObjNamePattern,[roIgnoreCase]) then
    begin
      if TRegEx.IsMatch(pLogonUsername, vSchemaAcceptPattern,[roIgnoreCase]) then
      begin
        if (vSchemaRejectPattern<>'') and (TRegEx.IsMatch(pLogonUsername, vSchemaRejectPattern,[roIgnoreCase])) then
        begin
          Result:=False;
        end;
      end
      else
      begin
        Result:=False;
      end;
    end;
    if Result=False then
      exit;
  end;
end;

procedure TFrmCodeCompletion.Compile;
var
 vIdx : Integer;
 p : PPoint;
 vTmp : Integer;
 vObjectType : String;
 vObjectName : String;
begin
{*}try
    if not Assigned(dsCompile.Session) then
      raise Exception.Create('Not connected to Oracle');

    if Assigned(fspStatus) then begin
      fspStatus.Text:='Compiling...';
      Refresh;
      Application.ProcessMessages;
    end;
    if aWarnings.Checked then begin
      dsCompile.Active:=False;
      dsCompile.SQL.Clear;
      dsCompile.SQL.Add('begin DBMS_WARNING.set_warning_setting_string(''ENABLE:ALL'' ,''SESSION''); END;');
      dsCompile.Active:=True;
    end;


    dsCompile.Active:=False;
    dsCompile.SQL.Clear;
    dsCompile.SQL.Text:=fEditor.Text;
    vTmp:=dsCompile.SQL.Count-10;
    if vTmp<0 then vTmp:=0;
    for vIdx:=dsCompile.SQL.Count-1 downto vTmp do
      if dsCompile.SQL[vIdx]='/' then
      begin
        dsCompile.SQL[vIdx]:='';
        break;
      end;

    for vIdx:=0 to 10 do begin
      if pos('PACKAGE',UpperCase(dsCompile.SQL[vIdx]))<>0 then begin
        vObjectType:='PACKAGE';
        if not PackageNameMatch(TScanKeywordThread(fWorkerThread).SQLObjectName,UpperCase(dsCompile.Session.LogonUsername))  then
        begin
          if IDNO=Application.MessageBox(PChar('Package name doesn''t match schema pattern. Continue anyway?'),'Query',MB_ICONQUESTION+MB_YESNO+MB_DEFBUTTON2) then
            exit;
        end;


        if pos('BODY',UpperCase(dsCompile.SQL[vIdx]))<>0 then
        begin
           vObjectType:='PACKAGE_BODY';
           break;
        end;
      end
      else if   pos('TRIGGER',UpperCase(dsCompile.SQL[vIdx]))<>0 then begin
        vObjectType:='TRIGGER';
        vObjectName:=StringReplace(UpperCase(dsCompile.SQL[vIdx]),'TRIGGER','',[rfReplaceAll]);
        //usuwanie spacji wiodacej
        while Copy(vObjectName,0,1)=' ' do vObjectName:=copy(vObjectName,2,9999);
        //odciecie ownera przed kropka
        if  pos('.', vObjectName)<>0 then
          vObjectName := copy(vObjectName,pos('.', vObjectName)+1,9999);
        //odszukanie znacznika konca (spacja lub nowa linia)
        if pos(' ',vObjectName)<>0 then
          vObjectName:=Copy(vObjectName,0, pos(' ', vObjectName));
       //usuniecie cudzyslowow
        vObjectName:=StringReplace(vObjectName,'"','',[rfReplaceAll]);
        dsCompile.SQL.Insert(0, 'CREATE OR REPLACE');
        TScanKeywordThread(fWorkerThread).SQLObjectName:=StringReplace(vObjectName,'"','',[rfReplaceAll]);
        break;
      end
      else if   pos('VIEW',UpperCase(dsCompile.SQL[vIdx]))<>0 then begin
        vObjectType:='VIEW';
        vObjectName:=StringReplace(UpperCase(dsCompile.SQL[vIdx]),'CREATE OR REPLACE VIEW ','',[rfReplaceAll]);
        TScanKeywordThread(fWorkerThread).SQLObjectName:=StringReplace(vObjectName,'"','',[rfReplaceAll]);
        break;
      end;
    end;

    dsCompile.Close;
    dsCompile.Open;
    dsCompile.Close;
    dsCompile.Active:=False;
    dsCompile.SQL.Clear;


    if Assigned(fWorkerThread) and (TScanKeywordThread(fWorkerThread).SQLObjectName<>'') then
    begin
      dsCompile.SQL.Add('select text, line, position from user_errors where name='+
                  UpperCase(QuotedStr(TScanKeywordThread(fWorkerThread).SQLObjectName))+
                  ' and type='+QuotedStr(StringReplace(vObjectType,'_',' ',[])));
      dsCompile.Open;
      if dsCompile.RecordCount>0 then
      begin
        for vIdx := 0 to fCompileResults.Count-1 do
          if Assigned(fCompileResults.Objects[vIdx]) then
            Dispose(PPoint(fCompileResults.Objects[vIdx]));
        fCompileResults.Clear;
        dsCompile.First;
        while not dsCompile.eof do
        begin
          New(p);
          p.X:=dsCompile.FieldByName('position').AsInteger;
          p.Y:=dsCompile.FieldByName('LINE').AsInteger;
          fCompileResults.AddObject(dsCompile.FieldByName('TEXT').AsString+' (line '+dsCompile.FieldByName('position').AsString+')',
            TObject(p));
          dsCompile.next;
        end;
        if not Assigned(fCompileErrors) then
          fCompileErrors:=TFrmCompileErrors.Create(Self);

        fCompileErrors.Errors:=fCompileResults;

        if Assigned(fFrmQueryGrid) then  fFrmQueryGrid.HideGrid;

        fCompileErrors.Show;
        if Assigned(fpCompileResults) then begin
          fCompileErrors.ManualDock(fpCompileResults);
        end;
      end
      else
      begin
        if Assigned(fCompileErrors) then fCompileErrors.Close;
        if Assigned(fspStatus) then
          fspStatus.Text:='Compiled!';
          Refresh;
          Application.ProcessMessages;
      end;
    end;
    if Assigned(dsCompile) then
      dsCompile.Close;
//    MyConnectionChange(nil);
    LoadObjectsList;
{*}except
{*}  raise CException.Create('Compile',0,self);
{*}end;
end;


function TFrmCodeCompletion.GetConnectionFolderName : String;
var
 vPos: Integer;
 vMOS : TMyOracleSession;
begin
  result := '';
  vPos:=fConnections.IndexOf(fActiveConnection);
  if vPos<>-1 then
  begin
    vMOS:=TMyOracleSession(fConnections.Objects[vPos]);
    result := vMOS.LogonUsername+'_'+vMos.LogonDatabase;
  end;
end;


procedure TFrmCodeCompletion.Load(pName, pType : String);
var
  sl : TStringList;
  vExt : String;
  vTemppath : array[0..255] of char;
  vFirst, vSlash : Boolean;
  vPath : String;
begin
{*}try
    Screen.Cursor:=crHourglass;
    try
      dsCompile.SQL.Clear;
      if pType='VIEW' then begin
        dsCompile.SQL.Add(
          //'select TEXT from USER_VIEWS where VIEW_NAME='+QuotedStr(UpperCase(pName))
          'select  dbms_lob.substr(dbms_xmlgen.getxml(''select text from user_views where view_name = '''+QuotedStr(UpperCase(pName))+'''''), 4000) TEXT  from dual'
          );
      end else begin
        dsCompile.SQL.Add(
          'select replace(TEXT,chr(9),''   '') text from USER_SOURCE where NAME='+QuotedStr(UpperCase(pName))+
            ' and TYPE='+QuotedStr(StringReplace(pType,'_',' ',[]))+' order by LINE');
      end;
      dsCompile.Close;
      dsCompile.Open;
      Screen.Cursor:=crHourglass;
      vFirst:=True;
      vSlash:=False;
      sl:=TStringList.Create;
      dsDetail.Session:=dsCompile.Session;
      while not dsCompile.eof do
      begin
        if vFirst and (pos('package',lowerCase(dsCompile.FieldByName('TEXT').AsString))<>0) then
        begin
          sl.Add('CREATE OR REPLACE '+dsCompile.FieldByName('TEXT').AsString);
          vFirst:=False;
        end
        else if pType='VIEW' then begin
           sl.SetText(PChar( StringReplace(StringReplace(dsCompile.FieldByName('TEXT').AsString, '<TEXT>','',[rfReplaceAll]), '</TEXT>','',[rfReplaceAll]) ));
           sl.Delete(0);
           sl.Delete(0);
           sl.Delete(0);
           sl.Delete(sl.count-1);
           sl.Delete(sl.count-1);
           sl.Insert(0, 'CREATE OR REPLACE VIEW '+UpperCase(pName) );

           sl.Insert(1, ') AS' );
           dsDetail.SQL.Clear;
           dsDetail.SQL.Add('select column_name From user_tab_columns where table_name='+QuotedStr(UpperCase(pName))+ ' order by column_id desc' );
           dsDetail.Close;
           dsDetail.Open;
           while not dsDetail.Eof do begin
             if dsDetail.Bof then
               sl.Insert(1, dsDetail.FieldByName('COLUMN_NAME').AsString )
             else
               sl.Insert(1, dsDetail.FieldByName('COLUMN_NAME').AsString+',' );
             dsDetail.Next;
           end;
           sl.Insert(1, '(' );           
           dsDetail.Close;
        end
        else
          sl.Add(dsCompile.FieldByName('TEXT').AsString);
        if dsCompile.FieldByName('TEXT').AsString='/' then
          vSlash:=True;
        dsCompile.next;
      end;
      dsCompile.Close;
      if (sl.Count<>0) and not vSlash then
        sl.Add('/');
  
      if pType='PACKAGE' then
        vExt:='.SPC'
      else
        vExt:='.BDY';
      GetTempPath(255,vTemppath);
      ForceDirectories(vTemppath+'OraTinn\'+GetConnectionFolderName);
      vPath:=vTemppath+'OraTinn\'+GetConnectionFolderName+'\'+UpperCase(pName)+vExt;
      sl.SaveToFile(vPath);
      frmTinnMain.denyUpdateMRU:=True;
      frmTinnMain.OpenFileIntoTinn(vPath);
      DeleteFile(vPath);
    finally
     sl.Free;
     frmTinnMain.denyUpdateMRU:=False;
    end;
  
    Screen.Cursor:=crDefault;
{*}except
{*}  raise CException.Create('Load',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.LoadSpc1Click(Sender: TObject);
begin
{*}try
    if Assigned(tvDB.Selected) then begin
      if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Packages') then
        Load(tvDB.Selected.Text,'PACKAGE')
      else if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Triggers') then
        Load(tvDB.Selected.Text,'TRIGGER')
      else if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Views') then
        Load(tvDB.Selected.Text,'VIEW');
    end;
{*}except
{*}  raise CException.Create('LoadSpc1Click',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.LoadBody1Click(Sender: TObject);
begin
{*}try
    if Assigned(tvDB.Selected) then begin
      if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Packages') then
        Load(tvDB.Selected.Text,'PACKAGE_BODY')
      else if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Triggers') then
        Load(tvDB.Selected.Text,'TRIGGER')
      else if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Views') then
        Load(tvDB.Selected.Text,'VIEW');
    end;
{*}except
{*}  raise CException.Create('LoadBody1Click',0,self);
{*}end;
end;


procedure TFrmCodeCompletion.SavePosition;
begin
{*}try
    if Assigned(IniFile) then
    begin
      IniFile.EraseSection('CodeNavigator');
      if Visible then
        IniFile.WriteInteger('CodeNavigator','Width', Width)
      else
        IniFile.WriteInteger('CodeNavigator','Width', 0);
  
      if tvDb.Selected<>nil then
        IniFile.WriteString('CodeNavigator','LastDBObject', tvDb.Selected.Text);
      if Sort1.Checked then
        IniFile.WriteString('CodeNavigator','Sorted', 'T')
      else
        IniFile.WriteString('CodeNavigator','Sorted', 'F');
    end;
{*}except
{*}  raise CException.Create('SavePosition',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.tvDbChange(Sender: TObject; Node: TTreeNode);
begin
{*}try
    if Assigned(Node) then
      vLastObject:=Node.Text;
{*}except
{*}  raise CException.Create('tvDbChange',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.Refresh1Click(Sender: TObject);
begin
{*}try
    MyConnectionChange(nil);
{*}except
{*}  raise CException.Create('Refresh1Click',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.RegisterFileForActiveConnection(pFileName: String; pFileTab: TTabSheet);
var
 vIdx: Integer;
 vMOS : TMyOracleSession;
begin
   if fActiveConnection<>'' then
   begin
     vIdx:=fConnections.IndexOf(fActiveConnection);
     if vIdx>=0 then
     begin
       vMOS:=TMyOracleSession(fConnections.Objects[vIdx]);
       vMOS.RegisterFileTab(pFileName, pFileTab);
     end;
   end;
end;

procedure TFrmCodeCompletion.UnregisterFileFromActiveConnection(pFileName: String; pFileTab: TTabSheet);
var
 vIdx: Integer;
 vMOS : TMyOracleSession;
begin
   if fActiveConnection<>'' then
   begin
     vIdx:=fConnections.IndexOf(fActiveConnection);
     if vIdx>=0 then
     begin
       vMOS:=TMyOracleSession(fConnections.Objects[vIdx]);
       vMOS.UnregisterFileTab(pFileName, pFileTab);
     end;
   end;
end;

procedure TFrmCodeCompletion.tvFunctionsCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  vStartLine ,vEndLine : Integer;
begin
{*}try
    DefaultDraw:=True;
    {if Node.StateIndex>0 then begin
      tvFunctions.Canvas.Font.Style:=tvFunctions.Canvas.Font.Style+[fsBold]
    end else}
    tvFunctions.Canvas.Font.Color:=clBlack;
{*}except
{*}  raise CException.Create('tvFunctionsCustomDrawItem',0,self);
{*}end;
end;

function TFrmCodeCompletion.isFunction(pName: String): Boolean;
begin
{*}try
   result:=False;
   if fEdFunctions.IndexOf(pName)<>-1 then
     result:=True;
{*}except
{*}  raise CException.Create('isFunction',0,self);
{*}end;
end;

function TFrmCodeCompletion.isPackage(pName: String): Boolean;
begin
{*}try
   result:=False;
   if fDbPackages.IndexOf(pName)<>-1 then
     result:=True;
  
{*}except
{*}  raise CException.Create('isPackage',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.JumpObjOnLoadBDYClick(Sender: TObject);
var
 vItemIdx : Integer;
begin
  vItemIdx := (Sender as TListView).Tag;
  tvDB.Select(tvDB.Items[vItemIdx]);
  LoadBody1Click(Self);
end;

procedure TFrmCodeCompletion.JumpObjOnLoadSPCClick(Sender: TObject);
var
 vItemIdx : Integer;
begin
  vItemIdx := (Sender as TListView).Tag;
  tvDB.Select(tvDB.Items[vItemIdx]);
  LoadSpc1Click(Self);
end;

procedure TFrmCodeCompletion.GotoFunction(pPackage, pFunction: String);
begin
{*}try
   if pPackage='' then
     ShowFunction(pFunction, -1)
   else
   begin
//     ActiveControl:=tsFile;
     TimerLoadOnClick_pPackage:=pPackage;
     TimerLoadOnClick_pFunction:=pFunction;
     TimerLoadOnClick.Enabled:=True;
   end;
{*}except
{*}  raise CException.Create('GotoFunction',0,self);
{*}end;
end;


procedure TFrmCodeCompletion.TimerLoadOnClickTimer(Sender: TObject);
begin
   TimerLoadOnClick.Enabled:=False;
   Load(TimerLoadOnClick_pPackage, 'PACKAGE_BODY');
   ShowFunction(TimerLoadOnClick_pFunction, -1);
end;



procedure TFrmCodeCompletion.Sort1Click(Sender: TObject);
begin
{*}try
   if not Sort1.Checked then
     tvFunctions.SortType:=stText
   else
   begin
     tvFunctions.SortType:=stNone;
     TScanKeywordThread(fWorkerThread).SetModified;
     TScanKeywordThread(fWorkerThread).Reload;
   end;
   Sort1.Checked:=not Sort1.Checked;
{*}except
{*}  raise CException.Create('Sort1Click',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.SQLPlus;
var
  vTemppath : array[0..255] of char;
  vStr : TStrings;
  vAs :  TOracleSession;
begin
  try
    GetTempPath(255,vTemppath);
    vStr := TStringList.Create;
    vStr.Assign(fEditor.Lines);
    vStr.Insert(0,'set serveroutput on size 999999');
    vStr.Insert(0,'set ARRAYSIZE 1');
    vStr.Insert(0,'set RECSEPCHAR |');
    if vStr.IndexOf('/')=-1 then
        vStr.Add('/');
    vStr.SaveToFile(vTemppath+'buffer.sql');
    if Assigned(dsCompile.Session) then
    begin
      vAs:=dsCompile.Session;
      WinExec('sqlplus '+vAs.LogonUsername+'/'+vAs.LogonPassword+
       '@'+vAs.LogonDatabase+ ' @'+vTemppath+'buffer.sql', 1)
    end else
      WinExec('sqlplus /nolog '+ ' @'+vTemppath+'buffer.sql', 1);
  finally
    if Assigned(vStr) then vStr.Free;
  end;
end;

procedure TFrmCodeCompletion.TimCursorPosTimer(Sender: TObject);
var
 caretPos : TBufferCoord;
 i : Integer;
 vWord : String;
 vStartLine, vEndLine : Integer;

begin
{*}try
    // get caret position
    if not Assigned(fEditor) or not fEditor.Focused or fTimerExecution then exit;
    try
      fTimerExecution:=True;
      caretPos:=fEditor.CaretXY;

      if frmTinnMain.boolHighlightAllWords and (fWorkerThread <> nil) then begin
        vWord:=UpperCase(fEditor.GetWordAtRowCol(caretPos));
        if vWord<>fHighlightWord then begin
          fHighlightWord:=vWord;
         // Sleep(200);
          TScanKeywordThread(fWorkerThread).SetHighlightWord(vWord);
        end;
      end;

      if caretPos.Line=fcaretPos.Line then exit;
      if fPLSLexer.isToken(UpperCase(fEditor.GetWordAtRowCol(caretPos))) then
        FindCurrentBlock
      else
        BlockPaint.Valid:=False;

      fEditor.Repaint;
      fCaretPos:=caretPos;

      if fPLSLexer.FindCurrentFunction(fEditor.CaretXY.Line, vStartLine ,vEndLine)>=0 then
        for i:=tvFunctions.Items.Count-1 downto 0 do
          if vStartLine=tvFunctions.Items[i].SelectedIndex then begin
            tvFunctions.Items[i].Selected:=True;
            break;
          end;
    finally
      fTimerExecution:=False;
    end;
{*}except
{*}  raise CException.Create('TimCursorPosTimer',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.FunctionListRefreshClick(Sender: TObject);
begin
  try
    TScanKeywordThread(fWorkerThread).Reload;
    TScanKeywordThread(fWorkerThread).SetModified;
  except
    raise CException.Create('FunctionListRefreshClick',0,self);
  end;
end;


procedure TFrmCodeCompletion.SetModificationMark;
var
  p: TBufferCoord;
  Mark: TSynEditMark;
begin
  try
    with fEditor do begin
      p := CaretXY;
      Marks.ClearLine(p.Line);
      Mark := TSynEditMark.Create(fEditor);
      with Mark do begin
        Line := p.Line;
        Char := p.Char;
        ImageIndex := 0;
        Visible := False;
        InternalImage := False;
      end;
      Marks.Place(Mark);

     // if Assigned(tvFunctions.Selected) then tvFunctions.Selected.StateIndex:=1;
    end;
  except
    raise CException.Create('SetModificationMark',0,self);
  end;
end;

procedure TFrmCodeCompletion.SetShowAllFiles(const Value: Boolean);
begin
  FShowAllFiles := Value;
end;

procedure TFrmCodeCompletion.CycleJumpNextMark(var pMarkIdx: Integer);
var
 vIdx : Integer;
 vLast : TSynEditMark;
 vPrevLine : Integer;
begin
  if fEditor.Marks.Count=0 then exit;
  vLast:=fEditor.Marks.Last;
  if Assigned(vLast) then begin
    vIdx:=0;
    vPrevLine:=fEditor.Marks.Items[pMarkIdx].Line;

    while(vIdx<10000) do begin
      if (pMarkIdx<vIdx) and (abs(vPrevLine-fEditor.Marks.Items[vIdx].Line)>25) then begin
          pMarkIdx:=vIdx;
          fEditor.GotoLineAndCenter(fEditor.Marks.Items[vIdx].Line);
          exit;
      end;
      vPrevLine:=fEditor.Marks.Items[vIdx].Line;
      if fEditor.Marks.Items[vIdx]=vLast then
        break;
      Inc(vIdx);
    end;
    //cycle: goto first mark
    pMarkIdx:=0;
    if fEditor.Marks.First<>nil then
      fEditor.GotoLineAndCenter(fEditor.Marks.First.Line);
  end;
end;

function FirstCharPos(ALine : String) : Integer;
 var vvTmp, vvSize : Integer;
begin
 try
     vvSize := Length(ALine);
     vvTmp:=0;
     //find first non white character
     while (vvTmp < vvSize-1) and not (ALine[vvTmp] in TSynValidStringChars) do
          Inc(vvTmp);
     if vvTmp = vvSize then
       result:=-1
     else
      result:=vvTmp;
 except
   raise CException.Create('FirstCharPos',0,application);
 end;
end;

procedure TFrmCodeCompletion.FindCurrentBlock;
var
 vFound : Boolean;
 vPrevBlock : TBlockPaint;
begin
  try
    vPrevBlock.StartBC.Char := BlockPaint.StartBC.Char;
    vPrevBlock.StartBC.Line := BlockPaint.StartBC.Line;
    vPrevBlock.EndBC.Char := BlockPaint.EndBC.Char;
    vPrevBlock.EndBC.Line := BlockPaint.EndBC.Line;
    vPrevBlock.Valid := BlockPaint.Valid;
  
    vFound:=fPLSLexer.FindCurrentBlock(fEditor.CaretXY.Line,
        BlockPaint.StartBC.Line ,BlockPaint.EndBC.Line);
    if vFound then begin
      vFound:=False;
      BlockPaint.StartBC.Char:=FirstCharPos(Editor.Lines[BlockPaint.StartBC.Line-1]);
      if BlockPaint.StartBC.Char>0 then begin
         BlockPaint.EndBC.Char:=FirstCharPos(Editor.Lines[BlockPaint.EndBC.Line-1]);
         if BlockPaint.EndBC.Char>0 then
           vFound:=True;
      end;
    end;
    BlockPaint.Valid := vFound;
     if not ((vPrevBlock.Valid=False) and (BlockPaint.Valid=False)) then
       if not ((vPrevBlock.StartBC.Char = BlockPaint.StartBC.Char) and
          (vPrevBlock.StartBC.Line = BlockPaint.StartBC.Line) and
          (vPrevBlock.EndBC.Char = BlockPaint.EndBC.Char) and
          (vPrevBlock.EndBC.Line = BlockPaint.EndBC.Line) and
          (vPrevBlock.Valid = BlockPaint.Valid)) then begin
         BlockPaint.RePaint := True;
         fEditor.Repaint;
       end;
  except
    raise CException.Create('FindCurrentBlock',0,self);
  end;
 end;




procedure TFrmCodeCompletion.SetHighlightList(const Value: String);
begin
  FHighlightList := Value;
  if (fWorkerThread <> nil) then begin
    TScanKeywordThread(fWorkerThread).SetHighlightList(FHighlightList);
  end;
end;


function DateTimeDiff(Start, Stop : TDateTime) : String;
var TimeStamp : TTimeStamp;
begin
  TimeStamp := DateTimeToTimeStamp(Stop - Start);
  Dec(TimeStamp.Date, TTimeStamp(DateTimeToTimeStamp(0)).Date);
  Result := IntToStr(TimeStamp.Date*24*60*60+(TimeStamp.Time))+' ms';
end;


function TFrmCodeCompletion.GetQueryText : String;
var
  vp1, vp2 : Integer;
  caretPos : TBufferCoord;
 vIdx : Integer;  
begin
    if fEditor.SelText<>'' then
      result:=fEditor.SelText
    else begin
        //dsCompile.SQL.Text:=fEditor.Text;
      vp1:=0; vp2:=fEditor.Lines.Count-1;
      caretPos := fEditor.CaretXY;
      for vIdx:=caretPos.Line-1 downto 0 do begin
        if fEditor.Lines[vIdx]='/' then begin vp1:=vidx+1; break; end;
      end;
      for vIdx:=caretPos.Line-1 to fEditor.Lines.Count do begin
        if fEditor.Lines[vIdx]='/' then begin vp2:=vidx-1; break; end;
      end;
      for vIdx:=vp1 to vp2 do
        if (fEditor.Lines[vIdx]='') then Inc(vp1)
        else break;

      for vIdx:=vp1 to vp2 do begin
        if vIdx=vp1 then
          result:=fEditor.Lines[vIdx]
        else
          result:=result+#13#10+(fEditor.Lines[vIdx]);
      end;
    end;
end;

procedure TFrmCodeCompletion.ExecuteToHTML;
var
  vTemppath : array[0..255] of char;
  vTempFileBuf: array [0..MAX_PATH-1] of char;
  vTempFileName: String;
  vStr : TStrings;
  vAs :  TOracleSession;
  vSQL : String;
begin
  try
    GetTempPath(255,vTemppath);
    vStr := TStringList.Create;

    vStr.Add('set serveroutput on size 999999');
    vStr.Add('set pagesize 0');
    vStr.Add('set RECSEPCHAR |');
    vStr.Add('set ARRAYSIZE 1');
    vStr.Add('SET MARKUP HTML ON SPOOL ON PREFORMAT OFF ENTMAP ON -');


    vStr.Add(
'HEAD "<TITLE>'+'OraTinn-SQL'+'</TITLE> '+
'<STYLE type=''text/css''> '+
'<!-- BODY {background: WHITE} --> '+
'</STYLE>" '+
'BODY "TEXT=BLACK" '+
'TABLE "WIDTH=''90%'' BORDER=''1'' FRAME=BOX RULES=ALL"'
);

     if GetTempFileName(vTemppath, '~', 0, vTempFileBuf) = 0 then
       raise Exception.Create(SysErrorMessage(GetLastError));
    vTempFileName:=String(vTempFileBuf)+'.html';
    vStr.Add('spool '+vTempFileName);
    vStr.Add(GetQueryText);    
    if vStr.IndexOf('/')=-1 then
        vStr.Add('/');
    vStr.Add('spool off');        
    vStr.Add('host "C:\Program Files\Mozilla Firefox\firefox.exe" '+vTempFileName);

    vStr.Add('exit');
    vStr.Add(' ');            
    vStr.SaveToFile(vTemppath+'buffer.sql');
    if Assigned(dsCompile.Session) then
    begin
      vAs:=dsCompile.Session;
      WinExec('sqlplusw '+vAs.LogonUsername+'/'+vAs.LogonPassword+
       '@'+vAs.LogonDatabase+ ' @'+vTemppath+'buffer.sql', 1)
    end else
      WinExec('sqlplusw /nolog '+ ' @'+vTemppath+'buffer.sql', 1);

    WinExec('"C:\Program Files\Mozilla Firefox\firefox.exe" '+vTempFileName , 1);
  finally
    if Assigned(vStr) then vStr.Free;
  end;
end;

procedure TFrmCodeCompletion.ExecuteQuery;
var
 vIdx : Integer;
// p : PPoint;
 vTmp : Integer;
 vObjectType : String;
 vObjectName, s, vAdd : String;
 vStart : TDateTime;
 vStop : TDateTime;
 vRowCount, vRowCountBreak: Integer;
 vUser, vPass, vHost, vStr : String;
 vSQLType : String;

 vAtom : TOracleSession;

begin
{*}try
    dsCompile.Active:=False;
    dsCompile.SQL.Clear;

    dsCompile.SQL.Text := GetQueryText;

    if (dsCompile.SQL.Count>0) then begin
      vStr:=UpperCase(dsCompile.SQL[0]);
      if pos('CONN',vStr)<>0 then   vSQLType:='CONN'
      else if pos('DESC',vStr)<>0 then   vSQLType:='DESC'
      else if pos('UPDATE',vStr)<>0 then   vSQLType:='UPDATE'
      else if pos('DELETE',vStr)<>0 then   vSQLType:='UPDATE'
      else  vSQLType:='SELECT';                  
    end;

    if (vSQLType='CONN') then begin
        vIdx:=pos(' ',vStr);
        vStr:=copy(vStr,vIdx+1,100);
        vIdx:=pos('/',vStr);
        vUser:=copy(vStr,0, vIdx-1);
        vStr:=copy(vStr,vIdx+1,100);
        vIdx:=pos('@',vStr);
        vPass:=copy(vStr,0, vIdx-1);
        vHost:=copy(vStr,vIdx+1,100);
        Connect(vUser+'@'+vHost,vUser, vPass, vHost,nil);
        exit;
    end
    else if (vSQLType='DESC') then begin
        vIdx:=pos(' ',vStr);
        vStr:=copy(vStr,vIdx+1,1000);
        vIdx:=pos('.',vStr);
        if vIdx>0 then begin
          vUser:=copy(vStr,0, vIdx-1);
          vStr:=copy(vStr,vIdx+1,1000);
        end else begin
          vIdx:=fConnections.IndexOf(fActiveConnection);
          if vIdx>=0 then begin
            vAtom:=TOracleSession(fConnections.Objects[vIdx]);
            vUser:=vAtom.LogonUsername;
          end;
        end;
        dsCompile.SQL.Text:='select column_id, column_name,'','' sep, data_type, data_length,nullable,last_analyzed from all_tab_cols where table_name='''+
            vStr+''' and owner='''+vUser+''' order by column_id';

        dsCompile.Close;
        dsCompile.Open;
        if dsCompile.RecordCount=0 then begin
          dsCompile.SQL.Text:='select object_name, object_type, status, owner from all_objects '+
             ' where object_name='''+vStr+''' and owner='''+vUser+''''+
          ' UNION ALL select ''-> Table ''||TABLE_OWNER||''.''||TABLE_NAME, null,null,null From all_synonyms '+
          'where synonym_name='''+vStr+''' and owner='''+vUser+'''';

        end;
    end;

    try
//      dsCompile.RowsInBlock:=10000;
      if not Assigned(fFrmQueryGrid) then begin
        fFrmQueryGrid:=TFrmQueryGrid.Create(Self);
        fpCompileResults.height:=1;
      end;
      if (vSQLType='SELECT') or (vSQLType='DESC')  then
        fFrmQueryGrid.Mode:='HTML';
      

 //     fFrmQueryGrid.Parent:=fFrmQueryGrid;
      if fFrmQueryGrid.Mode<>'HTML' then begin
        if Assigned(fpCompileResults) and (fpCompileResults.height<=1) then
          fFrmQueryGrid.ManualDock(fpCompileResults);
      end;    

      dsCompile.Close;
      vStart:=Now;
      dsCompile.Open;

      vStop:=Now;
      if vSQLType='UPDATE' then begin
        dsCompile.SQL.Text:='select ''Statement processed'' Status from dual';
        dsCompile.Close;
        dsCompile.Open;
      end;

      //if  dsCompile.RecordCount=dsCompile.RowsInBlock then  vAdd:='+';
      if Assigned(fspStatus) then begin
        fspStatus.Text:=IntToStr(dsCompile.RecordCount)+vAdd+' rows'+' | '+DateTimeDiff(vStart,vStop);
        fFrmQueryGrid.Status:=fspStatus.Text;
      end;

      Refresh;  Repaint;
      
      for vIdx := 0 to dsCompile.FieldCount - 1 do begin
        s := dsCompile.Fields[vIdx].FieldName;
        fFrmQueryGrid.AddHeaderCol(s);
      end;

      dsCompile.First;
      vRowCount:=0;
      vRowCountBreak:=QUERY_BREAK_AFTER;
      while not dsCompile.eof do
      begin
        Inc(vRowCount); Dec(vRowCountBreak);
        fFrmQueryGrid.NewRow;
        for vIdx := 0 to dsCompile.FieldCount - 1 do begin
          fFrmQueryGrid.AddRowCol(dsCompile.Fields[vIdx].AsString);
        end;
        if vRowCountBreak<=0 then begin
          if IDYES=Application.MessageBox(PChar('More than '+IntToStr(vRowCount)+' rows fetched. Continue query?'),'Query',MB_ICONQUESTION+MB_YESNO) then
            vRowCountBreak:=QUERY_BREAK_AFTER
          else
            break;
        end;
        dsCompile.next;
      end;

 {     if Assigned(fspStatus) then
        fspStatus.Text:=IntToStr(vRowCount)+' rows'+' | '+DateTimeDiff(vStart,vStop);}

    finally
      fFrmQueryGrid.ShowGrid;
      dsCompile.SQL.Clear;
      dsCompile.Close;
      dsCompile.Active:=False;
//      dsCompile.RowsInBlock:=1000;
    end;

    if Assigned(dsCompile) then
      dsCompile.Close;
    //MyConnectionChange(nil);
{*}except
{*}  raise CException.Create('ExecuteQuery',0,self);
{*}end;
end;

{ TExternalToolsManager }

procedure TExternalToolsManager.Add(pName, pCommand : String);
var i : Integer;
begin
  try
    i:=Length(Items);
    SetLength(Items,i+1);
    Items[i].Name:=pName;
    Items[i].Command:=pCommand;
  except
    raise CException.Create('Add',0,self);
  end;
end;

constructor TExternalToolsManager.Create(aToolButton : TToolButton;aCodeCompletionForm : TFrmCodeCompletion);
begin
  try
    fToolButton:=aToolButton;
    fToolButton.DropdownMenu:= TPopupMenu.Create(aToolButton.Owner);
    fCodeCompletionForm := aCodeCompletionForm;
  except
    raise CException.Create('Create',0,self);
  end;
end;

destructor TExternalToolsManager.Destroy;
begin
  try
    SetLength(Items,0);
    if Assigned(fToolButton.DropdownMenu) then begin
      while fToolButton.DropdownMenu.Items.Count>0 do
          if Assigned(fToolButton.DropdownMenu.Items[0]) then
            fToolButton.DropdownMenu.Items[0].Free;
      fToolButton.DropdownMenu.Free;
    end;  
    inherited;
  except
    raise CException.Create('Destroy',0,self);
  end;
end;

procedure TExternalToolsManager.LoadFromFile(pIniFile: TIniFile);
var
  i,j : Integer;
  vToolsList : TStringList;
  vTmpStr, s : String;
  vTmpPos : Integer;
begin
  try
    vToolsList:=TStringList.Create;
    pIniFile.ReadSectionValues('ExternalTools', vToolsList);
    SetLength(Items, vToolsList.Count);
    for i:=0 to vToolsList.Count-1 do
    begin
      vTmpStr := vToolsList.Strings[i];
      vTmpPos := pos('=', vTmpStr);
      vTmpStr := copy(vTmpStr, vTmpPos + 1, length(vTmpStr));
      begin
        vTmpPos := pos('#####', vTmpStr);
        s := copy(vTmpStr,1, vTmpPos - 1);
        Items[i].Name:=s;
  
        vTmpStr := copy(vTmpStr, vTmpPos + 5, length(vTmpStr));
        vTmpPos := pos('#####', vTmpStr);
        Items[i].Command := copy(vTmpStr,1, vTmpPos - 1);
      end;
    end;
    vToolsList.Free;


  except
    raise CException.Create('LoadFromFile',0,self);
  end;
end;

procedure TExternalToolsManager.StoreToFile(pIniFile: TIniFile);
var
 i,j : Integer;
 s : String;
begin
  try
    if not Assigned(pIniFile) then exit;
    pIniFile.EraseSection('ExternalTools');
    for i:=0 to Length(Items)-1 do
    begin
      s:=Items[i].Name+'#####'+Items[i].Command+'#####';
      pIniFile.WriteString('ExternalTools',IntToStr(i), s);
    end;
  except
    raise CException.Create('StoreToFile',0,self);
  end;
end;


procedure TExternalToolsManager.Modify(pIndex: Integer;
  Name, Command : String);
begin
  if pIndex>=0 then begin
    Items[pIndex].Name:=Name;
    Items[pIndex].Command:=Command;
  end;
end;

procedure TExternalToolsManager.Remove(pIndex: Integer);
var
 vI : Integer;
begin
  if pIndex>=0 then begin
    if pIndex<Length(Items) then
      for vI:=pIndex to Length(Items)-2 do begin
        Items[vI].Name:=Items[vI+1].Name;
        Items[vI].Command:=Items[vi+1].Command;
      end;
    if Length(Items)>0 then
      SetLength(Items,Length(Items)-1);
  end;
end;

procedure TExternalToolsManager.MenuReload;
var
  vMI : TMenuItem;
  i : Integer;
begin
  try
    while fToolButton.DropdownMenu.Items.Count>0 do
        if Assigned(fToolButton.DropdownMenu.Items[0]) then
          fToolButton.DropdownMenu.Items[0].Free;
  
    for i:=0 to Length(Items)-1 do
    begin
      vMI := TMenuItem.Create(fToolButton);
      vMI.Caption:=Items[i].Name;
      vMI.OnClick:=MyOnExternalTool;
      fToolButton.DropdownMenu.Items.Add(vMI);
    end;
  except
    raise CException.Create('MenuReload',0,self);
  end;
end;

procedure TExternalToolsManager.MyOnExternalTool(Sender: TObject);
var
  i : Integer;
  s, vWord : String;
  caretPos : TBufferCoord;
begin
  try
    for i:=0 to Length(Items)-1 do
      if Items[i].Name=StringReplace(TMenuItem(Sender).Caption,'&','',[]) then begin
        s := Items[i].Command;

        if Assigned(fCodeCompletionForm.fEditor) and fCodeCompletionForm.fEditor.Focused then begin
          caretPos:=fCodeCompletionForm.fEditor.CaretXY;
          vWord:=UpperCase(fCodeCompletionForm.fEditor.GetWordAtRowCol(caretPos));
          s:=StringReplace(s,'<line>',IntToStr(fCodeCompletionForm.fEditor.CaretXY.Line),[rfReplaceAll, rfIgnoreCase]);
          s:=StringReplace(s,'<word>',vWord,[rfReplaceAll, rfIgnoreCase]);
        end;

        if (pos('<user>',s)<>0) or (pos('<password>',s)<>0) or (pos('<host>',s)<>0) then begin
          if (fCodeCompletionForm.dsCompile.Session=nil) or
             (not fCodeCompletionForm.dsCompile.Session.Connected) then
            raise Exception.Create('Not connected to Oracle');
          if TOracleSession(fCodeCompletionForm.dsCompile.Session).LogonUsername<>'' then
            s:=StringReplace(s,'<user>',TOracleSession(fCodeCompletionForm.dsCompile.Session).
                LogonUsername,[rfReplaceAll, rfIgnoreCase]);
          if TOracleSession(fCodeCompletionForm.dsCompile.Session).LogonPassword<>'' then
            s:=StringReplace(s,'<password>',TOracleSession(fCodeCompletionForm.dsCompile.Session).
              LogonPassword,[rfReplaceAll, rfIgnoreCase]);
          if TOracleSession(fCodeCompletionForm.dsCompile.Session).LogonPassword<>'' then
            s:=StringReplace(s,'<host>',TOracleSession(fCodeCompletionForm.dsCompile.Session).
              LogonDatabase,[rfReplaceAll, rfIgnoreCase]);
        end;      
        s:=StringReplace(s,'<file>','file',[]);
        WinExec(s, 1);
        break;      
      end;
  except
    raise CException.Create('MyOnExternalTool',0,self);
  end;
end;


procedure TFrmCodeCompletion.SynCompletionProposalAllExecute(
  Kind: SynCompletionType; Sender: TObject; var CurrentInput: String;
  var x, y: Integer; var CanExecute: Boolean);
var
  ile : Integer;
  vCurInpPos : Integer;
  n,m : TTreeNode;
begin
  try
     vCurInpPos:=SynCompletionProposalAll.InsertList.IndexOf(CurrentInput);
     if vCurInpPos<>-1 then begin
       SynCompletionProposalAll.InsertList.Delete(vCurInpPos);
       SynCompletionProposalAll.ItemList.Delete(vCurInpPos);
     end;

     SynCompletionProposalAll.Form.CurrentString:=CurrentInput;

     vCurInpPos:=SynCompletionProposalAll.Form.AssignedList.IndexOf(CurrentInput);
     if (vCurInpPos<>-1) and (SynCompletionProposalAll.Form.AssignedList.Count=0) then
       CanExecute:=False;

     if SynCompletionProposalAll.Form.AssignedList.Count=1 then begin
       CanExecute:=False;
       if Assigned(SynCompletionProposalAll.Form.OnValidate) then
        SynCompletionProposalAll.Form.OnValidate(SynCompletionProposalAll.Form, [], #0);
     end;
  except
    raise CException.Create('SynCompletionProposalAllExecute',0,self);
  end;
end;

procedure TFrmCodeCompletion.LoadObjectsList;
var
 n,m : TTreeNode;
begin
  begin
    if vLastObject = '' then
      vLastObject:=IniFile.ReadString('CodeNavigator','LastDBObject', '');
    //db Tables
    fDbObjects.Clear;
    dsCompile.SQL.Clear;
    dsCompile.SQL.Add('select table_name from user_tables');
    dsCompile.Close;
    dsCompile.Open;
    fDbObjects.Clear;
    while not dsCompile.eof do
    begin
      fDbObjects.Add(dsCompile.FieldByName('TABLE_NAME').AsString);
      dsCompile.next;
    end;
    if Assigned(FEditor) and (FEditor.Highlighter is TSynSQLSyn) then
      (FEditor.Highlighter as TSynSQLSyn).TableNames.Assign(fDbObjects);
  
    tvDB.Items.Clear;
    n:=nil;
    n:=tvDB.Items.Add(n,'Triggers');
    dsCompile.SQL.Clear;
    dsCompile.SQL.Add('select lower(u1.object_name) object_name , u1.status body, ''VALID'' spc');
    dsCompile.SQL.Add('From user_objects u1');
    dsCompile.SQL.Add('where u1.object_type like ''TRIGGER''');
    dsCompile.SQL.Add('order by object_name');
    dsCompile.Close;
    dsCompile.Open;
    while not dsCompile.eof do
    begin
      m:=tvDB.Items.AddChild(n,dsCompile.FieldByName('OBJECT_NAME').AsString);
      if (dsCompile.FieldByName('BODY').AsString='VALID') then
        m.StateIndex:=1
      else if (dsCompile.FieldByName('BODY').AsString='INVALID') then begin
        m.StateIndex:=2;
        m.Parent.StateIndex:=2;
      end else
        m.StateIndex:=0;
      if vLastObject=dsCompile.FieldByName('OBJECT_NAME').AsString then
        m.Selected:=True;
      dsCompile.next;
    end;

    n:=nil;
    n:=tvDB.Items.Add(n,'Views');
    dsCompile.SQL.Clear;
    dsCompile.SQL.Add('select lower(u1.object_name) object_name , u1.status body, ''VALID'' spc');
    dsCompile.SQL.Add('From user_objects u1');
    dsCompile.SQL.Add('where u1.object_type like ''VIEW''');
    dsCompile.SQL.Add('order by object_name');
    dsCompile.Close;
    dsCompile.Open;
    while not dsCompile.eof do
    begin
      m:=tvDB.Items.AddChild(n,dsCompile.FieldByName('OBJECT_NAME').AsString);
      if (dsCompile.FieldByName('BODY').AsString='VALID') then
        m.StateIndex:=1
      else if (dsCompile.FieldByName('BODY').AsString='INVALID')  then  begin
        m.StateIndex:=2;
        m.Parent.StateIndex:=2;
      end else
        m.StateIndex:=0;
      if vLastObject=dsCompile.FieldByName('OBJECT_NAME').AsString then
        m.Selected:=True;
      dsCompile.next;
    end;

    //db Packages
    n:=nil;
    n:=tvDB.Items.Add(n,'Packages');
    fDbPackages.Clear;
    dsCompile.SQL.Clear;
    dsCompile.SQL.Add('select lower(u1.object_name) object_name , u1.status body, u2.status spc '+
                      'From user_objects u1, user_objects u2 '+
                      'where u1.object_type like ''PACKAGE BODY'' and '+
                            'u2.object_type like ''PACKAGE'' and '+
                            'u1.object_name=u2.object_name '+
                      ' order by object_name');

{
      'select max(lower(object_name)) object_name, min(status) status From user_objects '+
      'where object_type like ''PACKAGE%'' '+
      'group by object_name');
}
    dsCompile.Close;
    dsCompile.Open;
    fDbObjects.Clear;
    while not dsCompile.eof do
    begin
      fDbPackages.Add(dsCompile.FieldByName('OBJECT_NAME').AsString);
      m:=tvDB.Items.AddChild(n,dsCompile.FieldByName('OBJECT_NAME').AsString);
      if (dsCompile.FieldByName('BODY').AsString='VALID') and
         (dsCompile.FieldByName('SPC').AsString='VALID') then
        m.StateIndex:=1
      else if (dsCompile.FieldByName('BODY').AsString='INVALID') and
            (dsCompile.FieldByName('SPC').AsString='VALID') then  begin
        m.StateIndex:=2;
        m.Parent.StateIndex:=2;
      end else if (dsCompile.FieldByName('BODY').AsString='VALID') and
            (dsCompile.FieldByName('SPC').AsString='INVALID') then begin
        m.StateIndex:=3;
        m.Parent.StateIndex:=2;
      end else if (dsCompile.FieldByName('BODY').AsString='INVALID') and
            (dsCompile.FieldByName('SPC').AsString='INVALID') then begin
        m.StateIndex:=4;
        m.Parent.StateIndex:=2;
      end else
        m.StateIndex:=0;
      if vLastObject=dsCompile.FieldByName('OBJECT_NAME').AsString then
        m.Selected:=True;
      dsCompile.next;
    end;


    //db Packages w/o specyfication
    dsCompile.SQL.Clear;
    dsCompile.SQL.Add('select lower(object_name) object_name from user_objects '+
                        'where object_type = ''PACKAGE BODY'' ' +
                        'minus '+
                        'select lower(object_name) object_name  from user_objects '+
                        'where object_type = ''PACKAGE'' '+
                        'order by object_name');

    dsCompile.Close;
    dsCompile.Open;
    while not dsCompile.eof do
    begin
      m:=tvDB.Items.AddChild(n,dsCompile.FieldByName('OBJECT_NAME').AsString);
      m.StateIndex:=5;
      dsCompile.next;
    end;


    n.Expand(False);

    
    if Assigned(fWorkerThread) then
      TScanKeywordThread(fWorkerThread).Reload;
    dsCompile.Close;

  end;
end;


procedure TFrmCodeCompletion.tvDbDblClick(Sender: TObject);
begin
    if Assigned(tvDB.Selected) then begin
      if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Packages') then
        Load(tvDB.Selected.Text,'PACKAGE_BODY')
      else if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Triggers') then
        Load(tvDB.Selected.Text,'TRIGGER')
      else if Assigned(tvDB.Selected.Parent) and (tvDB.Selected.Parent.Text='Views') then
        Load(tvDB.Selected.Text,'VIEW');
    end;
end;


procedure TFrmCodeCompletion.tvDbKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If (Key <> VK_F3) and (Key <> VK_F4)  then begin
    PostMessage(fFrmJumpObj.edFilter.Handle, WM_KEYDOWN, Key, 0);
//    PostMessage(fFrmJumpObj.edFilter.Handle, WM_KEYUP, Key, 0);
    aSearch.Execute;

 //   fFrmJumpObj.Filter:=
  end;
end;

procedure TFrmCodeCompletion.aWarningsExecute(Sender: TObject);
begin
  aWarnings.Checked:=not aWarnings.Checked;
end;


procedure TFrmCodeCompletion.LoadFromFile(pIniFile: TIniFile);
begin
  if Assigned(fPackageNameMatchList) then
  begin
    pIniFile.ReadSectionValues('PackageNameMatch', fPackageNameMatchList);
  end;
end;


function TFrmCodeCompletion.FastCharIndexToRow(
  Index,pPrevLine : Integer; var pPrevChars: integer): Integer;
{ Index is 0-based; Result.x and Result.y are 1-based }
var
 x, y: integer;
begin
  try
    x := 0;
    y := pPrevLine-1;
    while y < fEditor.Lines.Count do
    begin
      x := Length(fEditor.Lines[y]);
      if pPrevChars + x + 2 > Index then
      begin
        x := Index - pPrevChars;
        break;
      end;
      Inc(pPrevChars, x + 2);
      x := 0;
      Inc(y);
    end;
    // Result.Char := x + 1;
    Result := y + 1;
  except
    raise CException.Create('FastCharIndexToRow2',0,self);
  end;
end;

procedure TFrmCodeCompletion.RefactorChangeName(pOldName, pNewName : String; ALine : Integer);
var
  fPLSRefactor : TPLSRefactor;
  fHighlighter: TSynCustomHighlighter;

  vTokenId, vFoundBlockIdx : Integer;
  vPrevToken, vPrev2Token, s,s1,s2, vNewBlockText, vGetToken : String;
  vOldNameFound : Boolean;
  i , vChoosenBlock: Integer;
  p : PPoint;
  caretPos, vCoord : TBufferCoord;
  vForm : TFormVariableRefactoringChoice;
begin
  fPLSRefactor:=nil;  fHighlighter:=nil;  vPrevToken:='';
  fPLSRefactor:=TPLSRefactor.Create;
  fHighlighter := TSynSQLSyn.Create(nil);

  try

    TSynSQLSyn(fHighlighter).SQLDialect := SQLOracle;
    fHighlighter.ResetRange;
    fHighlighter.SetLine(fEditor.Text, 1);

    while not fHighlighter.GetEol do
    begin
      while (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkSpace)) and (not fHighlighter.GetEol) do
        fHighlighter.Next;
      if  fHighlighter.GetEol then
        break;

      s := fHighlighter.GetToken;
      s:=UpperCase(s);
//      if (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) then
      begin
        if (s='UPDATE') and (vPrevToken='FOR') then
          fPLSRefactor.RemoveLastTokenFromStack;

        if (s='FOR') and (vPrev2Token='OPEN') then //pomin
        else if vPrevToken='$' then //dyrektywy
        else if fPLSRefactor.CheckToken(s, vTokenId) then begin
          vCoord:=fEditor.CharIndexToRowCol(fHighlighter.GetTokenPos);
          if vPrevToken='END' then
            fPLSRefactor.CloseDoubleEndToken(s,vTokenId, vCoord);
            fPLSRefactor.PutToken(vTokenId, vCoord,s, fHighlighter.GetTokenPos);

          try
            fPLSRefactor.NewStructure;
          except
          end;
        end;
      end;
      vPrev2Token:=vPrevToken;
      vPrevToken:=s;

      fHighlighter.Next;
    end;

    s:=fPLSRefactor.RemoveUnrecognizedStructures;
    fPLSRefactor.FindMatchingDeclarationBlocks(ALine);

{    fPLSRefactor.OutputBlocks(s);
    fPLSRefactor.OutputResultBlocks(s1);
    fPLSRefactor.OutputStack(s2);
    Clipboard.AsText := 'Stack size ='+IntToStr(fPLSRefactor.fStackSize)+#13#10+
      s1+#13#10+'-------------------------------'+#13#10+s+
      #13#10+s2;
    ShowMessage(IntToStr(Length(fPLSRefactor.fFoundResultBlocks)));
 }

    if Length(fPLSRefactor.fFoundResultBlocks)=1 then
       vChoosenBlock:=0
    else if Length(fPLSRefactor.fFoundResultBlocks)=0 then
    begin
      ShowMessage('Can''t do that');
      exit;
    end
    else
    begin
      try
        vForm := TFormVariableRefactoringChoice.Create(Self);
        fPLSRefactor.OutputResultBlocksStrings(vForm.getGroupOptions);
        vForm.SetOption(0);
        if vForm.ShowModal=mrCancel then
          exit;

        vChoosenBlock:=vForm.GetResult;
      finally
        vForm.Free;
      end;
    end;

    //parsuj kod i szukaj pasujacej deklarancji
    begin
      vNewBlockText:='';
      fHighlighter.ResetRange;
      fHighlighter.SetLine(fEditor.Text, 1);

      //przesun siê do pocz¹tku bloku
      while not fHighlighter.GetEol and (fHighlighter.GetTokenPos < fPLSRefactor.fFoundResultBlocks[vChoosenBlock].startTokenNr) do
      begin
        fHighlighter.Next;
      end;

      //podmien zmienn¹ w bloku
      while not fHighlighter.GetEol and (fHighlighter.GetTokenPos < fPLSRefactor.fFoundResultBlocks[vChoosenBlock].endTokenNr) do
      begin
          vGetToken:=fHighlighter.GetToken;

          if {(fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkIdentifier)) and}
             (UpperCase(vGetToken) = UpperCase(pOldName)) then
            vGetToken := pNewName;

          vNewBlockText:=vNewBlockText+vGetToken;
          fHighlighter.Next;
      end;

      //podmien w oryginalnym tekscie
      begin
         fEditor.BeginUpdate;
         caretPos := fEditor.CaretXY;
         Clipboard.AsText := vNewBlockText;
         New(p);
         try
           p.X:=fPLSRefactor.fFoundResultBlocks[vChoosenBlock].startPos.Char;
           p.Y:=fPLSRefactor.fFoundResultBlocks[vChoosenBlock].startPos.Line;
           fEditor.ExecuteCommand(ecGotoXY, 'A', p);

           p.X:=fPLSRefactor.fFoundResultBlocks[vChoosenBlock].endPos.Char;
           p.Y:=fPLSRefactor.fFoundResultBlocks[vChoosenBlock].endPos.Line;
           fEditor.ExecuteCommand(ecSelGotoXY, 'A', p);

           fEditor.ExecuteCommand(ecPaste, 'A', p);

           p.X:=caretPos.Char;
           p.Y:=caretPos.Line;
           fEditor.ExecuteCommand(ecGotoXY, 'A', p);

         finally
           fEditor.EndUpdate;
           dispose(p);
         end;
      end;
    end;
  finally
    if Assigned(fPLSRefactor) then
      fPLSRefactor.Free;
    if Assigned(fHighlighter) then
      fHighlighter.Free;
  end;

end;


{ TMyOracleSession }

constructor TMyOracleSession.Create(AOwner: TComponent; pConnectString: String);
begin
  inherited Create(AOwner);
  connectString:=pConnectString;
  fileTabList := TStringList.Create;
end;

destructor TMyOracleSession.Destroy;
begin
  inherited;
  fileTabList.Free;
  fileTabList:=nil;
  connectString:='';
end;

function TMyOracleSession.GetConnectionTab: TTabSheet;
begin
  result := FConnectionTab;
end;

procedure TMyOracleSession.RegisterFileTab(pFileName: String; pFileTab: TTabSheet);
begin
{*}try
  if not Assigned(pFileTab) then
    exit;
  fileTabList.AddObject(pFileName, pFileTab);
{*}except
{*}  raise CException.Create('UnregisterFileTab',0,self);
{*}end;
end;

procedure TMyOracleSession.SetActivePageTab(pActivePageTab: TTabSheet);
begin
  fActiveFileTab:=pActivePageTab;
end;

procedure TMyOracleSession.SetConnectionTab(const Value: TTabSheet);
begin
  FConnectionTab := Value;
end;

procedure TMyOracleSession.ShowActiveFileTabs;
var
  vIdx: Integer;
begin
{*}try
  for vIdx := 0 to frmTinnMain.pgFiles.PageCount-1 do
    frmTinnMain.pgFiles.Pages[vIdx].TabVisible:=False;

  for vIdx := 0 to fileTabList.Count-1 do
  begin
    (fileTabList.Objects[vIdx] as TTabSheet).TabVisible:=True;
    if fileTabList.Objects[vIdx] = fActiveFileTab then
      (fileTabList.Objects[vIdx] as TTabSheet).PageControl.ActivePage:=fActiveFileTab;
  end;

  frmTinnMain.WindowHideAll(fileTabList.Count=0);
  Application.ProcessMessages;
  frmTinnMain.pgFilesChange(nil);
{*}except
{*}  raise CException.Create('ShowActiveFileTabs',0,self);
{*}end;
end;

procedure TMyOracleSession.ShowAllFileTabs;
var
  vIdx: Integer;
begin
  for vIdx := 0 to frmTinnMain.pgFiles.PageCount-1 do
    frmTinnMain.pgFiles.Pages[vIdx].TabVisible:=True;

  frmTinnMain.WindowHideAll(False);
  Application.ProcessMessages;
  frmTinnMain.pgFilesChange(nil);
end;

function TMyOracleSession.UnregisterFileTab(pFileName: String; pFileTab: TTabSheet) : Boolean;
var
 vIdx : Integer;
begin
{*}try
  vIdx := fileTabList.IndexOfObject(pFileTab);
  if vIdx>-1 then
    fileTabList.Delete(vIdx);
  result := vIdx>-1;
{*}except
{*}  raise CException.Create('UnregisterFileTab',0,self);
{*}end;
end;



function TFrmCodeCompletion.BlockSelection(ALine : Integer; var pBlockLevel : Integer) : Boolean;
var
  fPLSRefactor : TPLSRefactor;
  fHighlighter: TSynCustomHighlighter;

  vTokenId, vFoundBlockIdx : Integer;
  vPrevToken, vPrev2Token, s,s1,s2, vNewBlockText, vGetToken : String;
  vOldNameFound : Boolean;
  i , vChoosenBlock, startPos, endPos: Integer;
  p : PPoint;
  caretPos, vCoord : TBufferCoord;
  vForm : TFormVariableRefactoringChoice;
begin
  fPLSRefactor:=nil;  fHighlighter:=nil;  vPrevToken:='';
  fPLSRefactor:=TPLSRefactor.Create;
  fHighlighter := TSynSQLSyn.Create(nil);

  try

    TSynSQLSyn(fHighlighter).SQLDialect := SQLOracle;
    fHighlighter.ResetRange;
    fHighlighter.SetLine(fEditor.Text, 1);

    while not fHighlighter.GetEol do
    begin
      while (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkSpace)) and (not fHighlighter.GetEol) do
        fHighlighter.Next;
      if  fHighlighter.GetEol then
        break;

      s := fHighlighter.GetToken;
      s:=UpperCase(s);
//      if (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) then
      begin
        if (s='UPDATE') and (vPrevToken='FOR') then
          fPLSRefactor.RemoveLastTokenFromStack;

        if (s='FOR') and (vPrev2Token='OPEN') then //pomin
        else if vPrevToken='$' then //dyrektywy
        else if fPLSRefactor.CheckToken(s, vTokenId) then begin
          vCoord:=fEditor.CharIndexToRowCol(fHighlighter.GetTokenPos);
          if vPrevToken='END' then
            fPLSRefactor.CloseDoubleEndToken(s,vTokenId, vCoord);
            fPLSRefactor.PutToken(vTokenId, vCoord,s, fHighlighter.GetTokenPos);

          try
            fPLSRefactor.NewStructure;
          except
          end;
        end;
      end;
      vPrev2Token:=vPrevToken;
      vPrevToken:=s;

      fHighlighter.Next;
    end;

    s:=fPLSRefactor.RemoveUnrecognizedStructures;
    fPLSRefactor.FindMatchingBlocks(ALine);

{    fPLSRefactor.OutputBlocks(s);
    fPLSRefactor.OutputResultBlocks(s1);
    fPLSRefactor.OutputStack(s2);
    Clipboard.AsText := 'Stack size ='+IntToStr(fPLSRefactor.fStackSize)+#13#10+
      s1+#13#10+'-------------------------------'+#13#10+s+
      #13#10+s2;
    ShowMessage(IntToStr(Length(fPLSRefactor.fFoundResultBlocks)));
 }

    if Length(fPLSRefactor.fFoundResultBlocks)=0 then
    begin
      result := False;
      exit;
    end;

    if pBlockLevel >= Length(fPLSRefactor.fFoundResultBlocks) then
       pBlockLevel:=0;

    //zaznacz blok
    begin
       fEditor.BeginUpdate;
       caretPos := fEditor.CaretXY;
       New(p);
       try
         p.X:=999;
         p.Y:=fPLSRefactor.fFoundResultBlocks[pBlockLevel].endPos.Line;
         fEditor.ExecuteCommand(ecGotoXY, 'A', p);

         p.X:=1;
         p.Y:=fPLSRefactor.fFoundResultBlocks[pBlockLevel].startPos.Line;
         fEditor.ExecuteCommand(ecSelGotoXY, 'A', p);

//         fEditor.ExecuteCommand(ecPaste, 'A', p);

//         p.X:=caretPos.Char;
//         p.Y:=caretPos.Line;
//         fEditor.ExecuteCommand(ecGotoXY, 'A', p);

       finally
         fEditor.EndUpdate;
         dispose(p);
       end;
    end;

    result := pBlockLevel < Length(fPLSRefactor.fFoundResultBlocks)-1;
  except
    raise CException.Create('BlockSelection',0,self);
  end;
end;

procedure TFrmCodeCompletion.GotoPos(pos: TBufferCoord);
var
  p : PPoint;
begin
   New(p);
   try
     fEditor.BeginUpdate;
      p.X:=pos.char;
      p.Y:=pos.line;
      fEditor.ExecuteCommand(ecGotoXY, 'A', p);

   finally
     fEditor.EndUpdate;
     dispose(p);
   end;
end;

end.









