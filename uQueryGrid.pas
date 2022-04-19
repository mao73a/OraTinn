unit uQueryGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Grids,  Menus, ActnList;

type
  TFrmQueryGrid = class(TForm)
    ActionList1: TActionList;
    PopupMenu1: TPopupMenu;
    acBestFit: TAction;
    BestFit1: TMenuItem;
    Action1: TAction;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acBestFitExecute(Sender: TObject);
  private
    { Private declarations }
    fColumnsCount, fRowCount, fColIdx : Integer;
    fSortedColumn, fSortDirection : Integer;
    fListItem: TListItem;
    fLastHintNode : TTreeNode;
    FMode: String;
    fSL : TStrings;
    FStatus: String;
    procedure SetMode(const Value: String);
    procedure ExecuteToHTML;
    procedure SetStatus(const Value: String);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;
    procedure Clear;
    procedure AddHeaderCol(pText : String);
    procedure NewRow;
    procedure AddRowCol(pText : String);
    procedure ShowGrid;
    Procedure HideGrid;
    property Mode : String read FMode write SetMode;
    property Status : String read FStatus write SetStatus;
  end;


implementation

uses ufrmMain, ShellAPI;

{$R *.DFM}

{ TForm1 }

procedure TFrmQueryGrid.AddHeaderCol(pText: String);
begin
  if FMode='HTML' then begin
    if fColumnsCount=0 then fSL.Add('<TR>');
    fSL.Add('<TD>'+pText+'</TD>');
  end else begin
    if fColumnsCount>0 then
      sgGrid.ColCount:=sgGrid.ColCount+1;
    sgGrid.Cells[fColumnsCount, fRowCount]:=pText;
  end;
  Inc(fColumnsCount);
end;

procedure TFrmQueryGrid.NewRow;
begin
  fColIdx:=0;
  if FMode='HTML' then begin
    fSL.Add('</TR>');
    fSL.Add('<TR>');
  end else begin
    if fRowCount>0 then
      sgGrid.RowCount:=sgGrid.RowCount+1;
  end;

  Inc(fRowCount);
end;

procedure TFrmQueryGrid.AddRowCol(pText: String);
var
 vCol :   TListColumn;
begin
  if FMode='HTML' then begin
    fSL.Add(' <TD>'+pText+'</TD>');
  end else begin
    sgGrid.Cells[fColIdx, fRowCount]:=pText;
  end;

  Inc(fColIdx);
end;

procedure TFrmQueryGrid.Clear;
var
  i : Integer;
begin
  if Assigned(fSL) then
    fSL.Clear;

  fColumnsCount:=0;
  fRowCount:=0;
  fSortedColumn:=0;
  fSortDirection:=-1;
  fColIdx:=0;
  //
  for i:=0 to sgGrid.RowCount-1 do begin
    sgGrid.Rows[i].Clear;
  end;

  sgGrid.RowCount:=2;
  sgGrid.ColCount:=1;
  sgGrid.Options:=sgGrid.Options-[goRowSelect];
  sgGrid.CancelEditor;

end;

procedure TFrmQueryGrid.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmTinnMain.splitterBottom.Visible := False;
  frmTinnMain.panSearchResults.Constraints.MinHeight := 0;
  frmTinnMain.panSearchResults.Height := 1;

  sgGrid.RowCount:=2;
  sgGrid.ColCount:=1;
end;

procedure TFrmQueryGrid.acBestFitExecute(Sender: TObject);
begin
  sgGrid.AutoSizeColumns;
end;

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
   vProg:=Copy(FileName,1, pos(' ', FileName)-1);
   if vProg<>'' then
     vParams:=Copy(FileName,pos(' ', FileName)+1, 999)
   else
     vProg:=FileName;
   ShellExecute(0,nil,PChar(vProg),PChar(vParams),nil,SW_NORMAL);

end;

procedure TFrmQueryGrid.ExecuteToHTML;
var
  vTemppath : array[0..255] of char;
  vTempFileBuf: array [0..MAX_PATH-1] of char;
begin

    GetTempPath(255,vTemppath);
     if GetTempFileName(vTemppath, '~', 0, vTempFileBuf) = 0 then
       raise Exception.Create(SysErrorMessage(GetLastError));
    fSL.Insert(0,'<HTML>');
    fSL.Insert(1,'<TABLE "WIDTH=''90%'' BORDER=''1'' FRAME=BOX RULES=ALL">');
    fSL.Add('</TR></TABLE>');
    fSL.Add('<P>');
    fSL.Add(FStatus);
    fSL.Add('</HTML>');
    fSL.SaveToFile(String(vTempFileBuf)+'.html');    
    WinExec('firefox.exe "'+String(vTempFileBuf)+'.html"' , 1);
end;


procedure TFrmQueryGrid.ShowGrid;
begin
  if fMode='HTML' then begin
    ExecuteToHTML;
  end else begin
    sgGrid.AutoSizeColumns;
    sgGrid.Visible:=True;
  end;
end;

procedure TFrmQueryGrid.HideGrid;
begin
  sgGrid.Visible:=False;
  Clear;
end;

procedure TFrmQueryGrid.SetMode(const Value: String);
begin
  FMode := Value;
end;

constructor TFrmQueryGrid.Create(AOwner: TComponent);
begin
  inherited;
  fSL:=TStringList.Create;
end;

destructor TFrmQueryGrid.Destroy;
begin
   fSL.Free;
   fSl:=nil;
end;

procedure TFrmQueryGrid.SetStatus(const Value: String);
begin
  FStatus := Value;
end;

end.
