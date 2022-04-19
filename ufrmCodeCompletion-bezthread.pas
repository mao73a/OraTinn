unit ufrmCodeCompletion;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, SynEditHighlighter, SynHighlighterSQL, SynEdit, ComCtrls,
  ExtCtrls, SynCompletionProposal, ImgList, ToolWin, Db, SqlDataSet, Menus,
  uFrmCompileErrors, inifiles, uAutoComplete, uPLSQLLExer, SynEditTypes;

const DefaultDelay : Integer=10;
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
 end;

 THighilightWordArr=Array of THighilightWord;
 PTHighilightWordArr =  ^THighilightWordArr;

type
  TFrmCodeCompletion = class(TForm)
    SynCompletionProposalAll: TSynCompletionProposal;
    pmConnectMenu: TPopupMenu;
    dsCompile: TAtomDataSet;
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
  private
    { Private declarations }
//Thread    fWorkerThread : TThread;
    fWorkerThread : TObject;
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
    fNewFileEvent : TNotifyEvent;
    IniFile : TIniFile;
    vLastObject : String;
    fPreviouslyClickedNode : TTreeNode;
    fObjectName : String;
    fAutoComplete : TOraTinnAutoComp;
    fCaretPos : TBufferCoord;
    fObjectsLoaded : Boolean;
    procedure SetEditor(const Value: TCustomSynEdit);
    procedure Load(pName, pType : String);
    procedure SetModificationMark;
    procedure ShowFunction(pFunction : String);
    procedure LoadObjectsList;
//    fEditor : TCustomSynEdit;
  public
    { Public declarations }
    fspStatus : TStatusPanel;
    fPLSLexer : TPLSLexer;
    BlockPaint : TBlockPaint;
    fHighilightWordArr : THighilightWordArr;
    fHighlightWord : String;
    procedure Compile;
    procedure MyConnectionChange(Sender: TObject);
    procedure MySynEditChange(Sender: TObject);
    constructor Create(AOwner : TComponent; ACb: TControlBar; aConnectButton : TToolButton;
                        aStatusPanel : TStatusPanel; aCompileResults : TPanel;
                        aNewFileEvent : TNotifyEvent; aIniFile : TIniFile);
    function Connect(pConnString, pUser, pPAss, PHost: String) : Boolean;
    procedure Disconnect;
    procedure SavePosition;
    function isFunction(pName : String) : Boolean;
    function isPackage(pName : String) : Boolean;
    procedure GotoFunction(pPackage, pFunction : String);
    procedure SQLPlus;
    function LoadExplorerFromStream(S: TStream ) : Boolean;
    Procedure SaveExplorerToStream(S: TStream );

  published
    property Editor : TCustomSynEdit read FEditor write SetEditor;
 end;


type
  TScanKeywordThread = class(TObject)
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

  public

    fEditor : TCustomSynEdit;
    fDelay : Integer;
    SQLObjectName : String;
    fDebugSL : TStrings;
    fHighlightWord : String;
    procedure Execute;
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
uses ufrmMain, ufrmEditor, uTypesE, ShellAPI;

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
    //inherited Create(TRUE);
    inherited Create;;
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
    //Resume; Thread
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


procedure TScanKeywordThread.Execute;
var
  i,vLine, vLineTmp, vLineF, vLineTmpF: integer;
  s, sPositions, vPrevToken, vHw : string;
  vTokenId : Integer;

begin
{*}try
//Thread   while not Terminated do begin
//Thread      WaitForSingleObject(fScanEventHandle, INFINITE);
//Thread      repeat
//Thread        if Terminated then
//Thread          break;
        // make sure the event is reset when we are still in the repeat loop
//Thread        ResetEvent(fScanEventHandle);
        // get the modified source and set fSourceChanged to 0
//Thread        Synchronize(GetSource);
        GetSource;
//Thread        if Terminated then
//Thread          break;
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
        while not fSourceChanged and not fHighlighter.GetEol
//Thread         and not Terminated do begin
       do begin
          if (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkKey)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkIdentifier)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkFunction)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDefaultPackage)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDatatype)) or
             (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkString)) then
          begin
            s := fHighlighter.GetToken;
            fCompeleteTokens.Add(s);
            if (SQLObjectName='') and (fHighlighter.GetTokenKind =
                          Ord(SynHighlighterSQL.tkIdentifier)) then
              SQLObjectName:=s;
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
              fPLSLexer.NewStructure;
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
        Sleep(100);
//Thread      until not fSourceChanged;

//Thread      if Terminated then
//Thread        break;

      // source was changed while scanning
//Thread      if fSourceChanged then begin
//Thread        continue;
//Thread      end;

      if fHighlightModified and (fHighlightWord<>'') then begin
        fHighlighter.ResetRange;
        fHighlighter.SetLine(fSource, 1);
        SetLength(fHighilightWordArr,0);
        SetLength(fHighilightWordArr,256);
        vHw:=UpperCase(fHighlightWord);
        i:=0;
        try
          while not fSourceChanged and not fHighlighter.GetEol
//Thread          and not Terminated
          do begin
            if //(fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkKey)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkIdentifier)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkFunction)) or
               //(fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDefaultPackage)) or
               //(fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDatatype)) or
               (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkString)) then
            begin
              if vHw=UpperCase(fHighlighter.GetToken) then begin
                if i+1>Length(fHighilightWordArr) then SetLength(fHighilightWordArr, i+256);
                fHighilightWordArr[i].BufferCoord:=
                      fEditor.CharIndexToRowCol(fHighlighter.GetTokenPos);
                vLine:=fHighlighter.GetTokenPos;
                fHighilightWordArr[i].Word:=fHighlighter.GetToken;
                Inc(i);
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
//Thread      if fSourceChanged then begin
//Thread        continue;
//Thread      end;

//      Synchronize(MarkChanges);
      if fSourceActual then begin
         fTmpStrings.AddStrings(fKeywords);
         fSourceActual:=False;
      end;

      if fHighlightModified then begin
//Thread        Synchronize(SetHighlightResults);
        SetHighlightResults
      end;
      fHighlightModified:=False;
      if (fReload or (not fSourceChanged and fHighlighter.GetEol) and
        (fTmpStrings.Text<>fKeywords.Text)) then
      begin
//Thread        Synchronize(SetResults);
        SetResults;
        fTmpStrings.Clear;
        fTmpStrings.AddStrings(fKeywords);
        fReload := False;
        flastCount:=fEditor.Lines.Count;
      end
      else if (fHighlighter.GetEol and (sPositions <> LinesString(fKeywords))) then begin
        if flastCount <> fEditor.Lines.Count then begin
//Thread          Synchronize(SetPositions);
          SetPositions;
          flastCount:=fEditor.Lines.Count;
        end;
//Thread        Synchronize(SetBlockStructures);
        SetBlockStructures;
      end else if fHighlighter.GetEol then
//Thread          Synchronize(SetBlockStructures);
      SetBlockStructures;

     fSynCompletionAll.ItemList:=fCompeleteTokens;
     fSynCompletionAll.InsertList:=fCompeleteTokens;
     //fAutoCompletionList:=fCompeleteTokens;
//    end;
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
      fOuterPLSLexer.Assign( fPLSLexer );
    end
{*}except
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
//Thread    Terminate;
//Thread    if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
//Thread      SetEvent(fScanEventHandle);
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
    fControlBar := ACb;
    fConnections := TStringList.Create;
    fCompileResults := TStringList.Create;
    fDbObjects := TStringList.Create;
    fDbPackages := TStringList.Create;
    fEdFunctions:= TStringList.Create;
    fAutoCompleteList := TStringList.Create;
    fPLSLexer := TPLSLexer.Create;
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
    SynCompletionProposalAll.ShortCut:=16397 //Ctrl+Enter (not aviable from drop down list)


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
    vTrace:='3';
    if fWorkerThread <> nil then  begin
      TScanKeywordThread(fWorkerThread).Shutdown;
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
          TAtomSession(fConnections.Objects[vIdx]).Connected:=False;
        finally
          vTrace:='8';
          TAtomSession(fConnections.Objects[vIdx]).Free;
        end;
      end;
    vTrace:='9';
    fConnections.Free;
    fCompileResults.Free;
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

procedure TFrmCodeCompletion.ShowFunction(pFunction: String);
var
 b:TBufferCoord;
 s : String;
 aHighlighter : TSynSQLSyn;
begin
{*}try
     fEditor.TopLine:=b.line;
    aHighlighter := TSynSQLSyn.Create(nil);
    aHighlighter.SQLDialect := SQLOracle;
    aHighlighter.ResetRange;
    aHighlighter.SetLine(fEditor.Text, 1);
    while not aHighlighter.GetEol do
    begin
      if (aHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) then
      begin
        s := UpperCase(aHighlighter.GetToken);
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
          if aHighlighter.GetToken=pFunction then
          begin
            b:=fEditor.CharIndexToRowCol(aHighlighter.GetTokenPos);
            fEditor.TopLine:=b.line;
            exit;
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


procedure TFrmCodeCompletion.tvFunctionsChange(Sender: TObject;
  Node: TTreeNode);
begin
{*}try
    if not tvFunctions.Focused then exit;
    if Node.SelectedIndex>0 then begin
      if (fPreviouslyClickedNode=Node) or (Node.StateIndex=0) then
        fEditor.TopLine:=Node.SelectedIndex
      else
        fEditor.GotoLineAndCenter(Node.StateIndex)
    end
    else
      ShowFunction(Node.Text);
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
//    if fEditor=Value then exit;
    //restoring original Event to previous editor
    if Assigned(fOrigEdOnChange) and Assigned(fEditor) then
      fEditor.OnChange:=fOrigEdOnChange;
    SetLength(fHighilightWordArr,0);
    //Storing code explorer state to editor window memorystream
    if Assigned(FEditor) then
      if TCustomSynEdit(FEditor).Owner is TfrmEditor then
        if Assigned(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState) then
          if tvFunctions.Items.Count>0 then  begin
            //tvFunctions.SaveToStream(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState);
            TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState.Clear;
            fObjectName:=TScanKeywordThread(fWorkerThread).SQLObjectName; //Save this name to MemoryStream
            SaveExplorerToStream(TfrmEditor(TCustomSynEdit(FEditor).Owner).explorerState);
          end;
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
  
    if fWorkerThread <> nil then
    begin
//Thread      TScanKeywordThread(fWorkerThread).Shutdown;
//Thread      TScanKeywordThread(fWorkerThread).WaitFor;
      TScanKeywordThread(fWorkerThread).Free;
      fWorkerThread:=nil;
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

    if not loaded then tvFunctions.Items.Clear;

    if Assigned(fEditor) then
    begin
      SynCompletionProposalAll.Editor:=fEditor;
      fWorkerThread := TScanKeywordThread.Create(tvFunctions, fEditor, nil,
        SynCompletionProposalAll, fdbPackages, fEdFunctions, fPLSLexer,
        @fHighilightWordArr, fAutoCompleteList);

      if Assigned(fWorkerThread) then
      begin
       //TScanKeywordThread(fWorkerThread).SQLObjectName:=fObjectName; //LoadedFrom MemoryStream
       if (not loaded) then begin
        TScanKeywordThread(fWorkerThread).SetModified;
        //Thread
        TScanKeywordThread(fWorkerThread).Execute;
       end else
        TScanKeywordThread(fWorkerThread).SetActual;
      end;
    end;
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
 ase : TAtomSession;
 vMi : TMenuItem;
begin
{*}try
    if not Assigned(dsCompile.Session) then exit;
    vPos:=fConnections.IndexOf(fActiveConnection);
    if pmConnectMenu.Items.Count>vPos then
    begin
      ase:=TAtomSession(fConnections.Objects[vPos]);
      try
        ase.Connected:=False;
      finally
        ase.Free;
      end;
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


function TFrmCodeCompletion.Connect(pConnString, pUser, pPAss, pHost: String) : Boolean;
var
 vConn : TAtomSession;
 vMI : TMenuItem;
begin
  try
    vConn:=TAtomSession.Create(Self);
    vConn.LogParams.UserName:=pUser;
    vConn.LogParams.Password:=pPass;
    vConn.LogParams.Connect:=pHost;
    vConn.Connected:=True;
    fConnections.AddObject(pConnString, vConn);
    vMI := TMenuItem.Create(Self);
    vMI.Caption:=pConnString;
    vMI.OnClick:=MyConnectionChange;
    pmConnectMenu.Items.Add(vMI);
    MyConnectionChange(vMI);
    result:=True;
  except
    if Assigned(vConn) then
      vConn.Connected:=False;
    vConn.Free;
    result:=False;
    raise;
  end;
end;

procedure TFrmCodeCompletion.MyConnectionChange(Sender: TObject);
var
 vConnectStr : String;
 vPos: Integer;
begin
{*}try
    if Sender<>nil then
      vConnectStr := StringReplace(TMenuItem(Sender).Caption, '&', '', [])
    else
      vConnectStr:=fActiveConnection;
    vPos:=fConnections.IndexOf(vConnectStr);
    if vPos<>-1 then
    begin
      fObjectsLoaded:=False;
      fActiveConnection:=vConnectStr;
      fspConnection.Text:=vConnectStr;
      dsCompile.Close;
      dsCompile.Session:=TAtomSession(fConnections.Objects[vPos]);
      tsDB.TabVisible:=True;
      tsDB.Caption:=vConnectStr;
      LoadObjectsList;
      fObjectsLoaded:=True;
    end
    else begin
      tsFile.ActivePageIndex:=0;
      fDbObjects.Clear;
      tsDB.TabVisible:=False;
      tsDB.Caption:='';
      fspConnection.Text:='';
    end;
{*}except
{*}  raise CException.Create('MyConnectionChange',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.Compile;
var
 vIdx : Integer;
 p : PPoint;
 vTmp : Integer;
 vObjectType : String;
begin
{*}try
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
  
    for vIdx:=0 to 10 do
      if pos('PACKAGE',UpperCase(dsCompile.SQL[vIdx]))<>0 then begin
        vObjectType:='PACKAGE';
        if pos('BODY',UpperCase(dsCompile.SQL[vIdx]))<>0 then
        begin
           vObjectType:='PACKAGE BODY';
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
                  ' and type='+QuotedStr(vObjectType));
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
          fCompileResults.AddObject(dsCompile.FieldByName('TEXT').AsString,
            TObject(p));
          dsCompile.next;
        end;
        if not Assigned(fCompileErrors) then
          fCompileErrors:=TFrmCompileErrors.Create(Self);
  
        fCompileErrors.Errors:=fCompileResults;
  
        fCompileErrors.Show;
        if Assigned(fpCompileResults) then
          fCompileErrors.ManualDock(fpCompileResults);
      end
      else
      begin
        if Assigned(fCompileErrors) then fCompileErrors.Close;
        if Assigned(fspStatus) then
          fspStatus.Text:='Compiled!';
      end;
    end;
    if Assigned(dsCompile) then
      dsCompile.Close;
    MyConnectionChange(nil);
{*}except
{*}  raise CException.Create('Compile',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.Load(pName, pType : String);
var
  sl : TStringList;
  vExt : String;
  vTemppath : array[0..255] of char;
  vFirst, vSlash : Boolean;
begin
{*}try
    Screen.Cursor:=crHourglass;
    try
      dsCompile.SQL.Clear;
      dsCompile.SQL.Add(
        'select replace(TEXT,chr(9),''   '') text from USER_SOURCE where NAME='+QuotedStr(UpperCase(pName))+
          ' and TYPE='+QuotedStr(pType)+' order by LINE');
      dsCompile.Close;
      dsCompile.Open;
      Screen.Cursor:=crHourglass;
      vFirst:=True;
      vSlash:=False;
      sl:=TStringList.Create;
      while not dsCompile.eof do
      begin
        if vFirst and (pos('package',lowerCase(dsCompile.FieldByName('TEXT').AsString))<>0) then
        begin
          sl.Add('CREATE OR REPLACE '+dsCompile.FieldByName('TEXT').AsString);
          vFirst:=False;
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
      sl.SaveToFile(vTemppath+UpperCase(pName)+vExt);
      frmTinnMain.denyUpdateMRU:=True;
      frmTinnMain.OpenFileIntoTinn(vTemppath+UpperCase(pName)+vExt);
      DeleteFile(vTemppath+UpperCase(pName)+vExt);
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
    if Assigned(tvDB.Selected) then
      Load(tvDB.Selected.Text,'PACKAGE');
{*}except
{*}  raise CException.Create('LoadSpc1Click',0,self);
{*}end;
end;

procedure TFrmCodeCompletion.LoadBody1Click(Sender: TObject);
begin
{*}try
    if Assigned(tvDB.Selected) then
      Load(tvDB.Selected.Text,'PACKAGE BODY');
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

procedure TFrmCodeCompletion.GotoFunction(pPackage, pFunction: String);
begin
{*}try
   if pPackage='' then
     ShowFunction(pFunction)
   else
   begin
     ActiveControl:=tsFile;
     Load(pPackage, 'PACKAGE BODY');
     ShowFunction(pFunction);
   end;
{*}except
{*}  raise CException.Create('GotoFunction',0,self);
{*}end;
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
    //Thread
     TScanKeywordThread(fWorkerThread).Execute;
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
  vAs :  TAtomSession;
begin
  try
    if Assigned(dsCompile.Session) then
    begin
      vAs:=dsCompile.Session;
      GetTempPath(255,vTemppath);
      vStr := TStringList.Create;
      vStr.Assign(fEditor.Lines);
      vStr.Insert(0,'set serveroutput on size 999999');
      if vStr.IndexOf('/')=-1 then
          vStr.Add('/');
      vStr.SaveToFile(vTemppath+'buffer.sql');
     WinExec('plus33 '+vAs.LogParams.Username+'/'+vAs.LogParams.Password+
        '@'+vAs.LogParams.Connect+ ' @'+vTemppath+'buffer.sql', 1);

     end;
  finally
    vStr.Free;
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
    if not Assigned(fEditor) or not fEditor.Focused then exit;
    caretPos:=fEditor.CaretXY;

    if frmTinnMain.boolHighlightAllWords and (fWorkerThread <> nil) then begin
      vWord:=UpperCase(fEditor.GetWordAtRowCol(caretPos));
      if vWord<>fHighlightWord then begin
        fHighlightWord:=vWord;
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
          exit;
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
    //Thread
    TScanKeywordThread(fWorkerThread).Execute;
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

procedure TFrmCodeCompletion.FindCurrentBlock;
var
 vFound : Boolean;
 vPrevBlock : TBlockPaint;

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
  s : String;
begin
  try
    for i:=0 to Length(Items)-1 do
      if Items[i].Name=StringReplace(TMenuItem(Sender).Caption,'&','',[]) then begin
        s := Items[i].Command;
        if (pos('<user>',s)<>0) or (pos('<password>',s)<>0) or (pos('<host>',s)<>0) then begin
          if (fCodeCompletionForm.dsCompile.Session=nil) or
             (not fCodeCompletionForm.dsCompile.Session.Connected) then
            raise Exception.Create('Not connected to Oracle');
          if TAtomSession(fCodeCompletionForm.dsCompile.Session).LogParams.Username<>'' then
            s:=StringReplace(s,'<user>',TAtomSession(fCodeCompletionForm.dsCompile.Session).
                LogParams.Username,[rfReplaceAll, rfIgnoreCase]);
          if TAtomSession(fCodeCompletionForm.dsCompile.Session).LogParams.Password<>'' then
            s:=StringReplace(s,'<password>',TAtomSession(fCodeCompletionForm.dsCompile.Session).
              LogParams.Password,[rfReplaceAll, rfIgnoreCase]);
          if TAtomSession(fCodeCompletionForm.dsCompile.Session).LogParams.Password<>'' then
            s:=StringReplace(s,'<host>',TAtomSession(fCodeCompletionForm.dsCompile.Session).
              LogParams.Connect,[rfReplaceAll, rfIgnoreCase]);
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
  
    //db Packages
    tvDB.Items.Clear;
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
            (dsCompile.FieldByName('SPC').AsString='VALID') then
        m.StateIndex:=2
      else if (dsCompile.FieldByName('BODY').AsString='VALID') and
            (dsCompile.FieldByName('SPC').AsString='INVALID') then
        m.StateIndex:=3
      else if (dsCompile.FieldByName('BODY').AsString='INVALID') and
            (dsCompile.FieldByName('SPC').AsString='INVALID') then
        m.StateIndex:=4
      else
        m.StateIndex:=0;
      if vLastObject=dsCompile.FieldByName('OBJECT_NAME').AsString then
        m.Selected:=True;
      dsCompile.next;
    end;
    n.Expand(False);
    if Assigned(fWorkerThread) then
      TScanKeywordThread(fWorkerThread).Reload;
    dsCompile.Close;

  end;
end;

end.









