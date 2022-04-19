unit uScanWordThread;

interface

uses Windows, SynEditHighlighter, SynHighlighterSQL, SynEdit, SynEditTypes,Messages,
  SysUtils,classes;

type
 THighilightWord=record
    BufferCoord : TBufferCoord;
    Word : String;
 end;

 THighilightWordArr=Array of THighilightWord;
 PTHighilightWordArr =  ^THighilightWordArr;

 TScanHighlightWordThread = class(TThread)
  private
    fHighilightWordArr, fResultArr : THighilightWordArr;
    fEditor: TCustomSynEdit;
    fHighlighter: TSynCustomHighlighter;
    fScanEventHandle: THandle;
    fSource : String;
    procedure GetSource;    
  protected
    procedure Execute; override;
  public
    fHighlightWord : String;
    fSourceChanged : Boolean;
    procedure Shutdown;
    procedure SetModified;

    procedure SetResults;
    constructor Create(AEditor : TCustomSynEdit;AResultArr : THighilightWordArr);
    destructor Destroy;override;
 end;

implementation

{ TScanKeywordThread }

constructor TScanHighlightWordThread.Create(AEditor: TCustomSynEdit;AResultArr : THighilightWordArr);
begin
{  fEditor:=AEditor;
  fHighilightWordArr:=AResultArr;
  fHighlighter := TSynSQLSyn.Create(nil);
  TSynSQLSyn(fHighlighter).SQLDialect := SQLOracle;
  fScanEventHandle := CreateEvent(nil, FALSE, FALSE, nil);
  if (fScanEventHandle = 0) or (fScanEventHandle = INVALID_HANDLE_VALUE) then
     raise EOutOfResources.Create('Couldn''t create WIN32 event object');
  Resume;      }
end;

destructor TScanHighlightWordThread.Destroy;
begin
  fHighlighter.Free;
  SetLength(fResultArr,0);
  if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
     CloseHandle(fScanEventHandle);
  inherited Destroy;
end;

procedure TScanHighlightWordThread.Execute;
var
 i : Integer;
 vHw : String;
begin
   //while not Terminated do begin
    //WaitForSingleObject(fScanEventHandle, INFINITE);
    // make sure the event is reset when we are still in the repeat loop
    Synchronize(GetSource);
ResetEvent(fScanEventHandle);
    fHighlighter.ResetRange;
    fHighlighter.SetLine(fSource, 1);
    SetLength(fResultArr,0);
    SetLength(fResultArr,256);
    i:=0;
    vHw:=UpperCase(fHighlightWord);
    while not fSourceChanged and not fHighlighter.GetEol and not Terminated do begin
      if (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkKey)) or
         (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkIdentifier)) or
         (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkFunction)) or
         (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkPLSQL)) or
         (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDefaultPackage)) or
         (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkDatatype)) or
         (fHighlighter.GetTokenKind = Ord(SynHighlighterSQL.tkString)) then
      begin
        if vHw=UpperCase(fHighlighter.GetToken) then begin
          if Length(fResultArr)<i then SetLength(fResultArr, i+256);
          fResultArr[i].BufferCoord:=
                fEditor.CharIndexToRowCol(fHighlighter.GetTokenPos);
          Inc(i);
        end;
      end;
    end;
    SetLength(fResultArr,i);
    Synchronize(SetResults);
end;

procedure TScanHighlightWordThread.GetSource;
begin
  if fEditor <> nil then
    fSource := fEditor.Text
  else
    fSource := '';
end;

procedure TScanHighlightWordThread.SetModified;
begin
 if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
    SetEvent(fScanEventHandle);
 //Execute;
end;

procedure TScanHighlightWordThread.SetResults;
var
  i : Integer;
begin
  SetLength(fHighilightWordArr,Length(fResultArr));
  for i:=0 to Length(fResultArr)-1 do begin
    fHighilightWordArr[i]:=fResultArr[i];
  end;
end;

procedure TScanHighlightWordThread.Shutdown;
begin
  Terminate;
  if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
    SetEvent(fScanEventHandle);
end;

end.
