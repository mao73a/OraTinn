{
  syn
  Copyright (C) 2002, Ascher Stefan. All rights reserved.
  stievie@utanet.at, http://syn.sourceforge.net/

  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in compliance
  with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
  the specific language governing rights and limitations under the License.

  The Original Code is BrowseForFolder.pas, released Mon, 23 Dec 2002 12:24:10 UTC.

  The Initial Developer of the Original Code is Ascher Stefan.
  Portions created by Ascher Stefan are Copyright (C) 2002 Ascher Stefan.
  All Rights Reserved.

  Contributor(s): .

  Alternatively, the contents of this file may be used under the terms of the
  GNU General Public License Version 2 or later (the "GPL"), in which case
  the provisions of the GPL are applicable instead of those above.
  If you wish to allow use of your version of this file only under the terms
  of the GPL and not to allow others to use your version of this file
  under the MPL, indicate your decision by deleting the provisions above and
  replace them with the notice and other provisions required by the GPL.
  If you do not delete the provisions above, a recipient may use your version
  of this file under either the MPL or the GPL.

  You may retrieve the latest version of this file at the  home page,
  located at http://syn.sourceforge.net/

 $Id: BrowseForFolder.pas,v 1.1 2003/08/22 19:44:55 rmay Exp $
}

unit BrowseForFolder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ShlObj,
  ActiveX;

type
  TBrowseOptions = set of (boStatusText, boNewFolder, boCenter);
  TBrowseType = (btComputer, btPrinter, btNoBellowDomain, btSysAncestors, btSysDirs);
  TSHFolder = (foDesktop, foDesktopExpanded, foPrograms, foControlPanel,
    foPrinters, foPersonal, foFavorites, foStartup, foRecent, foSendto,
    foRecycleBin, foStartMenu, foDesktopFolder, foMyComputer, foNetwork,
    foNetworkNeighborhood, foFonts, foTemplates);

  TBrowseForFolder = class(TComponent)
  private
    { Private declarations }
    fDirectory: string;
    fTitle: string;
    fOptions: TBrowseOptions;
    fSelFolder: string;
    fHandle: HWND;
    fRootFolder : TSHFolder;
    fBrowseType: TBrowseType;
    fNewFolder: string;
    procedure CenterWindow;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function Execute: boolean;
  published
    { Published declarations }
    property Directory: string read fDirectory write fDirectory;
    property Title: string read fTitle write fTitle;
    property Options: TBrowseOptions read fOptions write fOptions;
    property RootFolder: TSHFolder read fRootFolder write fRootFolder default foDesktopExpanded;
    property BrowseType: TBrowseType read fBrowseType write fBrowseType default btSysDirs;
  end;

procedure Register;

implementation

const
  ID_NEWFOLDER = 255;
  SH_FOLDERS_ARRAY: array[TSHFolder] of Integer = (
    CSIDL_DESKTOP, -1, CSIDL_PROGRAMS, CSIDL_CONTROLS, CSIDL_PRINTERS, CSIDL_PERSONAL,
    CSIDL_FAVORITES, CSIDL_STARTUP, CSIDL_RECENT, CSIDL_SENDTO, CSIDL_BITBUCKET,
    CSIDL_STARTMENU, CSIDL_DESKTOPDIRECTORY, CSIDL_DRIVES, CSIDL_NETWORK,
    CSIDL_NETHOOD, CSIDL_FONTS, CSIDL_TEMPLATES
  );
  SH_BROWSETYPE: array[TBrowseType] of integer = (
    BIF_BROWSEFORCOMPUTER, BIF_BROWSEFORPRINTER, BIF_DONTGOBELOWDOMAIN,
    BIF_RETURNFSANCESTORS, BIF_RETURNONLYFSDIRS
  );

procedure Register;
begin
  RegisterComponents('syn Text Editor', [TBrowseForFolder]);
end;

function DirExists(const ADir: string): boolean;
var
  h: THandle;
  wfd: TWin32FindData;
begin
  h := FindFirstFile(PChar(ADir), wfd);
  if h <> INVALID_HANDLE_VALUE then begin
    Windows.FindClose(h);
    Result := ((wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0);
  end else
    Result := false;
end;

function MakePath(APath: string): boolean;
begin
  Result := True;
  if APath = '' then
    Exit;
  APath := ExcludeTrailingBackslash(APath);
  if (Length(APath) < 3) or DirExists(APath)
    or (ExtractFilePath(APath) = APath) then Exit;
  Result := MakePath(ExtractFilePath(APath)) and CreateDir(APath);
end;

function WndProc(HWindow: HWND; Msg: UINT; wParam : WPARAM; lParam : LPARAM): LRESULT; stdcall;
resourcestring
  NewFolderCap = 'New Folder';
  NewFolderPrompt = 'Enter the name of the new folder';
var
  NewFolder : string;
  inst: TBrowseForFolder;
begin
  Result := 0;
  inst := TBrowseForFolder(GetWindowLong(HWindow, GWL_USERDATA));
  if (Msg = WM_COMMAND) and (Lo(wParam) = ID_NEWFOLDER) then begin
    NewFolder := InputBox(NewFolderCap, NewFolderPrompt, '');
    if NewFolder <> '' then begin
      inst.fNewFolder := NewFolder;
      PostMessage(HWindow, WM_KEYDOWN, VK_TAB, 0);
      PostMessage(HWindow, WM_KEYUP, VK_TAB, 0);
      PostMessage(HWindow, WM_KEYDOWN, VK_RETURN, 0);
      PostMessage(HWindow, WM_KEYUP, VK_RETURN, 0);
    end;
  end else
    Result := DefDlgProc(HWindow, Msg, wParam, lParam);
end;

procedure AddControls(HWindow : HWND);
resourcestring
  SNewFolder = 'New Folder...';
var
  cntrls: HWND;
  styles, h: integer;
  rc: TRect;
begin
  styles := WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE or WS_TABSTOP
    or BS_PUSHBUTTON;
  GetClientRect(HWindow, rc);
  h := rc.Bottom - rc.Top;
  cntrls := CreateWindow('Button', PChar(SNewFolder), styles, 12, h - 30, 80, 23,
    HWindow, ID_NEWFOLDER, HInstance, nil);
  with TBitmap.Create do try
    PostMessage(cntrls, WM_SETFONT, Canvas.Font.Handle, MAKELPARAM(1, 0));
  finally
    Free;
  end;
  SetWindowLong(HWindow, GWL_WNDPROC, Cardinal(@WndProc));
end;

function BrowseProc(wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer; stdcall;
var
  Dir: array[0..MAX_PATH] of Char;
begin
  case uMsg of
    BFFM_INITIALIZED:
      begin
        TBrowseForFolder(lpData).fHandle := wnd;
        if boNewFolder in TBrowseForFolder(lpData).Options then
          AddControls(wnd);
        if boCenter in TBrowseForFolder(lpData).Options then
          TBrowseForFolder(lpData).CenterWindow;
        if boStatusText in TBrowseForFolder(lpData).Options then
          SendMessage(wnd, BFFM_SETSTATUSTEXT, 0, integer(PChar(TBrowseForFolder(lpData).Directory)));
        if TBrowseForFolder(lpData).Directory <> '' then
          SendMessage(wnd, BFFM_SETSELECTION, 1, integer(PChar(TBrowseForFolder(lpData).Directory)));
        SetWindowLong(wnd, GWL_USERDATA, lpData);
      end;
    BFFM_SELCHANGED:
      begin
        if (SHGetPathFromIDList(PItemIDList(lParam), Dir)) then begin
          TBrowseForFolder(lpData).fSelFolder := PChar(@Dir[0]);
          SendMessage(wnd, BFFM_SETSTATUSTEXT, 0, integer(PChar(TBrowseForFolder(lpData).fSelFolder)));
        end;
      end;
  end;
  Result := 0;
end;

constructor TBrowseForFolder.Create(AOwner: TComponent);
begin
  inherited;
  fRootFolder := foDesktopExpanded;
  fBrowseType := btSysDirs;
end;

function TBrowseForFolder.Execute: boolean;
resourcestring
  FailedCreateFolder = 'Unable to create folder %s';
var
  displayname: array[0..MAX_PATH] of Char;
  bi: TBrowseInfo;
  pidl: PItemIdList;
  AFolder: string;
begin
  CoInitialize(nil);
  try
    FillChar(bi, SizeOf(bi), 0);
    if (Owner <> nil) and (Owner is TWinControl) then
      bi.hWndOwner := (Owner as TWinControl).Handle
    else
      bi.hwndOwner := Application.Handle;
    bi.ulFlags := SH_BROWSETYPE[fBrowseType];
    SHGetSpecialFolderLocation(Application.Handle,
      SH_FOLDERS_ARRAY[FRootFolder], bi.pidlRoot);
    bi.pszDisplayName := PChar(@displayname[0]);
    bi.lpszTitle := PChar(Title);
    if boStatusText in fOptions then
      bi.ulFlags := bi.ulFlags or BIF_STATUSTEXT;
    bi.lParam := integer(Self);
    bi.lpfn := @BrowseProc;
    bi.iImage := 0;
    repeat
      fNewFolder:= '';
      pidl := SHBrowseForFolder(bi);
      Result := pidl <> nil;
      if Result then begin
        try
          Result := SHGetPathFromIDList(pidl, PChar(@displayname[0]));
          AFolder := displayname;
        finally
          CoTaskMemFree(pidl);
        end;
        if fNewFolder = '' then
          fDirectory := AFolder
        else begin
          AFolder := IncludeTrailingBackslash(fSelFolder) + fNewFolder;
          MakePath(AFolder);
          if not DirExists(AFolder) then
            raise Exception.CreateFmt(FailedCreateFolder, [AFolder]);
          fDirectory := AFolder;
          bi.lParam := integer(Self);
        end;
      end;
    until fNewFolder = '';
  finally
    CoUnInitialize;
  end;
end;

procedure TBrowseForFolder.CenterWindow;

  function FindParent: TForm;
  var
    p: TControl;
  begin
    if Owner = nil then begin
      Result := nil;
      Exit;
    end;
    p := (Owner as TControl);
    while not (p is TForm) do begin
      if p = nil then begin
        Result := nil;
        Exit;
      end;
      p := p.Parent;
    end;
    Result := (p as TForm);
  end;
var
  Left, Top, Width, Height: integer;
  r: TRect;
  p: TForm;
begin
  GetWindowRect(fHandle, r);
  Width := r.Right - r.Left;
  Height := r.Bottom - r.Top;
  p := FindParent;
  if (p <> nil) then begin
    Left := p.Left + ((p.Width - Width) div 2);
    Top := p.Top + ((p.Height - Height) div 2);
  end else begin
    Left := Screen.Monitors[0].Left + ((Screen.Monitors[0].Width - Width) div 2);
    Top := Screen.Monitors[0].Top + ((Screen.Monitors[0].Height - Height) div 2);
  end;
  MoveWindow(fHandle, Left, Top, Width, Height, false)
end;

end.


