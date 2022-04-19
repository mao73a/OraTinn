unit uAbout;

{
 The contents of this file are subject to the terms and conditions found under
 the GNU General Public License Version 2 or later (the "GPL").
 See http://www.opensource.org/licenses/gpl-license.html or
 http://www.fsf.org/copyleft/gpl.html for further information.

 Copyright Russell May
 http://www.solarvoid.com

}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ShellAPI;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    OKButton: TButton;
    Label3: TLabel;
    PhysMem: TLabel;
    FreeRes: TLabel;
    Label4: TLabel;
    Label1: TLabel;
    lblURL2: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lbURLClick(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblURL2Click(Sender: TObject);
    procedure lblURL2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblURL2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblURL2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetBuildInfo : string;
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.FormCreate(Sender: TObject);
var
  MS: TMemoryStatus;
begin
  GlobalMemoryStatus(MS);
  PhysMem.Caption := FormatFloat('#,###" KB"', MS.dwTotalPhys / 1024);
  FreeRes.Caption := Format('%d %%', [MS.dwMemoryLoad]);
  Version.Caption := Version.Caption + ' ' + GetBuildInfo;
end;

procedure TAboutBox.lbURLClick(Sender: TObject);
begin
 //open browser
 ShellExecute( 0, 'open', Pchar( 'http://tinn.sourceforge.net' ), nil, nil, sw_shownormal);
end;

procedure TAboutBox.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 lblURL2.Font.Style := [];
end;

function TAboutBox.GetBuildInfo : string;
var
 VerInfoSize:  DWORD;
 VerInfo:      Pointer;
 VerValueSize: DWORD;
 VerValue:     PVSFixedFileInfo;
 Dummy:        DWORD;
 V1:           Word;
 V2:           Word;
 V3:           Word;
 V4:           Word;
begin
 VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
 GetMem(VerInfo, VerInfoSize);
 GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
 VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
 with VerValue^ do
 begin
   V1 := dwFileVersionMS shr 16;
   V2 := dwFileVersionMS and $FFFF;
   V3 := dwFileVersionLS shr 16;
   V4 := dwFileVersionLS and $FFFF;
 end;
 FreeMem(VerInfo, VerInfoSize);
 result := InttoStr(V1) + '.' + InttoStr(V2) + '.' + InttoStr(V3) + '.' + InttoStr(V4);
end;

procedure TAboutBox.lblURL2Click(Sender: TObject);
begin
	//open browser
 ShellExecute( 0, 'open', Pchar( 'http://tinn.solarvoid.com' ), nil, nil, sw_shownormal);
end;

procedure TAboutBox.lblURL2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	lblURL2.Font.Color := clRed;
end;

procedure TAboutBox.lblURL2MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
	lblURL2.Font.Style:= [fsUnderline];
end;

procedure TAboutBox.lblURL2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	lblURL2.Font.Color := clBlue;
end;

end.

