unit uFrameCodeCompletion;

interface


uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TFrameCodeCompletion = class(TFrame)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TScanKeywordThread = class(TThread)
  private
    fHighlighter: TSynCustomHighlighter;
    fKeywords: TStringList;
    fLastPercent: integer;
    fScanEventHandle: THandle;
    fSource: string;
    fSourceChanged: boolean;
    procedure GetSource;
    procedure SetResults;
    procedure ShowProgress;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetModified;
    procedure Shutdown;
  end;
constructor TScanKeywordThread.Create;
begin
  inherited Create(TRUE);
  fHighlighter := TSynPasSyn.Create(nil);
  fKeywords := TStringList.Create;
  fScanEventHandle := CreateEvent(nil, FALSE, FALSE, nil);
  if (fScanEventHandle = 0) or (fScanEventHandle = INVALID_HANDLE_VALUE) then
    raise EOutOfResources.Create('Couldn''t create WIN32 event object');
  Resume;
end;

destructor TScanKeywordThread.Destroy;
begin
  fHighlighter.Free;
  fKeywords.Free;
  if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
    CloseHandle(fScanEventHandle);
  inherited Destroy;
end;

procedure TScanKeywordThread.Execute;
var
  i: integer;
  s: string;
  Percent: integer;
begin
  while not Terminated do begin
    WaitForSingleObject(fScanEventHandle, INFINITE);
    repeat
      if Terminated then
        break;
      // make sure the event is reset when we are still in the repeat loop
      ResetEvent(fScanEventHandle);
      // get the modified source and set fSourceChanged to 0
      Synchronize(GetSource);
      if Terminated then
        break;
      // clear keyword list
      fKeywords.Clear;
      fLastPercent := 0;
      // scan the source text for the keywords, cancel if the source in the
      // editor has been changed again
      fHighlighter.ResetRange;
      fHighlighter.SetLine(fSource, 1);
      while not fSourceChanged and not fHighlighter.GetEol do begin
        if fHighlighter.GetTokenKind = Ord(SynHighlighterPas.tkKey) then begin
          s := fHighlighter.GetToken;
          with fKeywords do begin
            i := IndexOf(s);
            if i = -1 then
              AddObject(s, pointer(1))
            else
              Objects[i] := pointer(integer(Objects[i]) + 1);
          end;
        end;
        // show progress (and burn some cycles ;-)
        Percent := MulDiv(100, fHighlighter.GetTokenPos, Length(fSource));
        if fLastPercent <> Percent then begin
          fLastPercent := Percent;
          Sleep(10);
          Synchronize(ShowProgress);
        end;
        fHighlighter.Next;
      end;
    until not fSourceChanged;

    if Terminated then
      break;
    // source was changed while scanning
    if fSourceChanged then begin
      Sleep(100);
      continue;
    end;

    fLastPercent := 100;
    Synchronize(ShowProgress);

    fKeywords.Sort;
    for i := 0 to fKeywords.Count - 1 do begin
      fKeywords[i] := fKeywords[i] + ': ' +
        IntToStr(integer(fKeywords.Objects[i]));
    end;
    Synchronize(SetResults);
    // and go to sleep again
  end;
end;

procedure TScanKeywordThread.GetSource;
begin
  if ScanThreadForm <> nil then
    fSource := ScanThreadForm.SynEdit1.Text
  else
    fSource := '';
  fSourceChanged := FALSE;
end;

procedure TScanKeywordThread.SetModified;
begin
  fSourceChanged := TRUE;
  if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
    SetEvent(fScanEventHandle);
end;

procedure TScanKeywordThread.SetResults;
begin
  if ScanThreadForm <> nil then
    ScanThreadForm.SynEdit2.Lines.Assign(fKeywords);
end;

procedure TScanKeywordThread.ShowProgress;
begin
  if ScanThreadForm <> nil then
    ScanThreadForm.StatusBar1.SimpleText := Format('%d %% done', [fLastPercent]);
end;

procedure TScanKeywordThread.Shutdown;
begin
  Terminate;
  if (fScanEventHandle <> 0) and (fScanEventHandle <> INVALID_HANDLE_VALUE) then
    SetEvent(fScanEventHandle);
end;

implementation

{$R *.DFM}

end.
