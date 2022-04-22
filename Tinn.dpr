program Tinn;

{
 The contents of this file are subject to the terms and conditions found under
 the GNU General Public License Version 2 or later (the "GPL").
 See http://www.opensource.org/licenses/gpl-license.html or
 http://www.fsf.org/copyleft/gpl.html for further information.
 
}
{%ToDo 'Tinn.todo'}
{%File 'changelog.txt'}

uses
  FastMM4,
  Forms,
  Windows,
  SysUtils,
  Messages,
  classes,
  ufrmMain in 'ufrmMain.pas' {frmTinnMain},
  uAbout in 'uAbout.pas' {AboutBox},
  uGotoBox in 'uGotoBox.pas' {GotoBox},
  uDMSyn in 'uDMSyn.pas' {dmSyn: TDataModule},
  ufrmEditor in 'ufrmEditor.pas' {frmEditor},
  dlgSearchText in 'dlgSearchText.pas' {TextSearchDialog},
  dlgReplaceText in 'dlgReplaceText.pas' {TextReplaceDialog},
  ufrmPrintPreview in 'ufrmPrintPreview.pas' {frmPrintPreview},
  ufrmSynColor in 'ufrmSynColor.pas' {dlgSynColor},
  udlgAppOptions in 'udlgAppOptions.pas' {dlgAppOptions},
  AsciiChart in 'AsciiChart.pas' {fmAsciiChart},
  ufrmSearchResults in 'ufrmSearchResults.pas' {frmSearchResults},
  udlgSearchInFiles in 'udlgSearchInFiles.pas' {dlgSearchInFiles},
  BrowseForFolder in 'BrowseForFolder.pas',
  uActionMacro in 'uActionMacro.pas',
  ufrmProject in 'ufrmProject.pas' {frmProject},
  ufrmCodeCompletion in 'ufrmCodeCompletion.pas' {FrmCodeCompletion},
  uFrmConnect in 'uFrmConnect.pas' {FrmConnect},
  uFrmCompileErrors in 'uFrmCompileErrors.pas' {FrmCompileErrors},
  uPLSQLLExer in 'uPLSQLLExer.pas',
  uFormExternalTools in 'uFormExternalTools.pas' {FormExternalTools},
  utypesE in 'utypese.pas',
  uQueryGrid in 'uQueryGrid.pas' {FrmQueryGrid},
  uFrmJumpProc in 'uFrmJumpProc.pas' {JumpProc},
  VDMUnit;

{$R *.RES}

Var
  Previous: HWnd;
  {This code, to allow file association and open doubleclicked file in the running
  instance of app was written by Andrius Adamonis
  and I tweaked it to work for me}

Function EnumWindowsCallback(Handle: HWnd; Param: LParam): Boolean; Stdcall;
  Function IsMyClass: Boolean;
  Var
    ClassName: Array[0..30] Of Char;
  Begin
    GetClassName(Handle, ClassName, 30);

    Result := (StrIComp(ClassName, 'TfrmTinnMain') = 0) And
     (SendMessage(Handle, WM_FINDINSTANCE, 0, 0) = MyUniqueConst);
  End;
var
  vCurrVirtual : BOOL;
  vMyClass : boolean;
  vOwnerHWND : HWND;
Begin
  vMyClass:=IsMyClass;
  if vMyClass then
  begin
    vOwnerHWND:=GetWindow(Handle, GW_OWNER );
    vCurrVirtual:=IsOnCurrentDesktop(vOwnerHWND);//sprawdza czy okno na aktualnym wirtualnym dekstopie https://stackoverflow.com/questions/41803962/using-ivirtualdesktopmanager-in-delphi
  end;
  Result := Not (vMyClass and vCurrVirtual); { needs True to continue }
  If Not Result Then Previous := Handle;
End;



procedure FillFileList(FileList : TStringList);
var
  i : integer;
  intPos : integer;
  handle: THandle;
  intPos1, intPos2 : integer;
  curFile: WIN32_FIND_DATA;
  Path : string;
begin
	for i := 1 to ParamCount do // Loop through all the parameters and build a file list
    begin
      intPos := pos('*', ParamStr(i));
      intPos1 := pos('/', ParamStr(i));
      intPos2 := pos('@', ParamStr(i));
      if (intPos1>0) and (intPos2>0) then begin

        FileList.Add(ParamStr(i));
      end else if intPos > 0 then  // Do multi file globbing
      begin
        Path := ExtractFilePath(ExpandFileName(ParamStr(i)));
        handle := FindFirstFile(PChar(ParamStr(i)), curFile);
        if FileExists(Path + curFile.cFilename) then
            FileList.Add('"' + Path + curFile.cFilename + '"');
                while FindNextFile(Handle, curFile) do
        begin
            if FileExists(Path + curFile.cFilename) then
                FileList.Add('"' + Path + curFile.cFilename + '"');
        end;
        end // End globbing
      else
      begin	// Do single file open
    		if FileExists(ParamStr(i)) then  // Check for file
        begin
        	if (i < ParamCount) then // Check for line number
        		intPos := pos('ln=',ParamStr(i+1))
          else
          	intPos := -1;

          if (intPos > 0) then
          begin
          	FileList.Add('"' + ExpandFileName(ParamStr(i)) + '"' + ',' + Copy(ParamStr(i+1), intPos + 3, length(ParamStr(i+1))));
          end
          else
          	FileList.Add('"' + ExpandFileName(ParamStr(i)) + '"');
        end
        else // Create a new file
        begin
          if ParamStr(i)<>'-n' then begin
            // Check for the line request
            intPos := pos('ln=',ParamStr(i));
            if (intPos = 0) then
            begin
              Path := ExtractFilePath(ExpandFileName(ParamStr(i)));
              // if the path isn't already in the file name, add it
              if pos(Path, ParamStr(i)) = 0 then
                FileList.Add('"' + Path + ParamStr(i) + '"')
              else
                FileList.Add('"' + ParamStr(i) + '"');
            end;
          end;
        end;
      end; // End single file open

    end; // End param loop

end;

Var
  Atom: TAtom;
  FileList : TStringList;
  i : integer;
  LineNumberJump : integer;
  tmpInfo : TStringList;
  vSwitch : String;
begin
  if ParamCount>0 then
     vSwitch:=ParamStr(1);
	FileList := TStringList.create;
  Previous := 0;
  EnumWindows(@EnumWindowsCallback, 0);
  If (Previous <> 0)  then
  begin
    if (vSwitch<>'-n') or (ID_NO=Application.MessageBox('Would you like to open a new instance of Tinn?',
      'Tinn - Running Instance Found',MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2)) then
    Begin
      SetForegroundWindow(Previous);
      PostMessage(Previous, WM_RESTOREAPP, 0, 0);

      If ParamCount > 0 Then
      Begin
        {Path := ExtractFilePath(ExpandFileName(ParamStr(1)));
        Atom := GlobalAddAtom(PChar(Path + ParamStr(1)));
        SendMessage(Previous, WM_OPENEDITOR, Atom, 0);

        GlobalDeleteAtom(Atom);}
        FillFileList(FileList);
        if (FileList.Count > 0) then
        begin
          for i := 0 to FileList.Count - 1 do
          begin
              Atom := GlobalAddAtom(PChar(FileList.Strings[i]));
              SendMessage(Previous, WM_OPENEDITOR, Atom, 0);
              GlobalDeleteAtom(Atom);
          end;
        end;

      End;

      Exit;
    End;
  end;
  Application.Initialize;
  Application.Title := 'Tinn';
  Application.CreateForm(TdmSyn, dmSyn);
  if (ParamCount > 0) then
  begin
  	FillFileList(FileList);
  end;


  if FileList.Count > 0 then
  	dmSyn.boolLoadedFileFromStartUp := true;


  Application.CreateForm(TfrmTinnMain, frmTinnMain);
  Application.CreateForm(TfrmPrintPreview, frmPrintPreview);
  if (dmSyn.boolLoadedFileFromStartUp) then
  begin
  	for i := 0 to FileList.Count - 1 do
    begin
      tmpInfo := TStringList.create;
      tmpInfo.CommaText := FileList.Strings[i];
      if (tmpInfo.Count = 2) then
      begin
        LineNumberJump := StrToIntDef(tmpInfo.Strings[1], 0);
      	frmTinnMain.OpenFileIntoTinn(tmpInfo.Strings[0], LineNumberJump);
      end
      else
      	frmTinnMain.OpenFileIntoTinn(tmpInfo.Strings[0]);
    end;
  end;
  FileList.free;
  Application.Run;
end.
