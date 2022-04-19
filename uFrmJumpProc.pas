unit uFrmJumpProc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Db, Grids, DBGrids, inifiles,
  ExtCtrls, utypese, ComCtrls;

type
  TFrmJumpProc = class(TForm)
    Panel1: TPanel;
    KeyList: TListView;
    Label1: TLabel;
    edFilter: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure sgConnSetFilter(ARows: TStrings; var Accept: Boolean);
    procedure KeyListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure KeyListColumnClick(Sender: TObject; Column: TListColumn);
    procedure KeyListCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure KeyListDblClick(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edFilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFilterKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    fActive : Boolean;
    fFilter : String;
    fIniFile : TIniFile;
    fSortedColumn : Integer;
    fSortDirection : Integer;
    fLineNumber : Integer;    
    procedure Filter(AFilter:String);
  public
    { Public declarations }
    LineNumber : Integer;
    fList : TStrings;
    procedure ReadIniFile;
  end;


implementation

{$R *.DFM}

procedure TFrmJumpProc.FormActivate(Sender: TObject);
var vWidth : Integer;
begin
{*}try
    if not fActive then
    begin
      ReadIniFile;
      fSortedColumn:=0;
      fSortDirection:=1;
      LineNumber:=-1;
      FActive:=True;
      KeyList.SortType:=stText;
      KeyList.Columns[0].Width:=400;
      KeyList.Columns[1].Width:=80;
      if KeyList.Items.Count>0 then
        KeyListSelectItem(Self,KeyList.Items[0], True);
    end;
{*}except
{*}  raise CException.Create('FormActivate',0,self);
{*}end;
end;

procedure TFrmJumpProc.ReadIniFile;
var
  i,j: Integer;
  vTmpStr, s : String;
  vTmpPos : Integer;
  Item : TListItem;
begin
{*}try
    try
      assert(Assigned(fList),'fList unassgined');
      KeyList.Items.BeginUpdate;
      KeyList.Items.Clear;
      for i:=0 to fList.Count-1 do
      begin
        vTmpStr := fList[i];
        vTmpPos := pos('=', vTmpStr);
        //vTmpStr := copy(vTmpStr, vTmpPos + 1, length(vTmpStr));
        Item:= KeyList.Items.Add;
        s := copy(vTmpStr,1, vTmpPos - 1);
        Item.Caption:=s;
        s := copy(vTmpStr, vTmpPos + 1, 10);
        Item.SubItems.Add(s);
      end;
  finally
    KeyList.Items.EndUpdate;
  end;
{*}except
{*}  raise CException.Create('ReadIniFile',0,self);
{*}end;
end;


procedure TFrmJumpProc.BitBtn2Click(Sender: TObject);
begin
{*}try
    Close;
{*}except
{*}  raise CException.Create('BitBtn2Click',0,self);
{*}end;
end;

procedure TFrmJumpProc.sgConnSetFilter(ARows: TStrings;
  var Accept: Boolean);
 var i : Integer;
begin
{*}try
    Accept:=False;
    if ARows.Count>1 then
      for i:=0 to ARows.Count-2 do
        if (fFilter='') or (pos(UpperCase(fFilter),ARows[i])<>0) then begin
          Accept:=True;
          break;
        end;
{*}except
{*}  raise CException.Create('sgConnSetFilter',0,self);
{*}end;
end;

procedure TFrmJumpProc.KeyListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
{*}try
      if not fActive then exit;
      fLineNumber := StrToInt(Item.SubItems[0]);
{*}except
{*}  raise CException.Create('KeyListSelectItem',0,self);
{*}end;
end;

procedure TFrmJumpProc.KeyListColumnClick(Sender: TObject;
  Column: TListColumn);
begin
{*}try
    if (fSortedColumn=Column.Index) then
      fSortDirection:=fSortDirection*(-1)
    else
      fSortedColumn:=Column.Index;   
    KeyList.AlphaSort;
{*}except
{*}  raise CException.Create('KeyListColumnClick',0,self);
{*}end;
end;


procedure TFrmJumpProc.KeyListCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
{*}try
    if (fSortedColumn>0) and ((fSortedColumn-1)<Item1.SubItems.Count) and
         ((fSortedColumn-1)<Item2.SubItems.Count) then
      Compare:=fSortDirection*StrComp(PChar(Item1.SubItems[fSortedColumn-1]),
                       PChar(Item2.SubItems[fSortedColumn-1]))
    else if fSortedColumn=0 then
      Compare:=fSortDirection*StrComp(PChar(Item1.Caption),
                       PChar(Item2.Caption))


{*}except
{*}  raise CException.Create('KeyListCompare',0,self);
{*}end;
end;



procedure TFrmJumpProc.Filter(AFilter:String);
var
 i : Integer;
begin
{*}try
    KeyList.Items.BeginUpdate;
    i:=0;
    while i<KeyList.Items.Count do begin
     if (pos(UpperCase(AFilter), UpperCase(KeyList.Items[i].Caption))=0) then
       KeyList.Items[i].Delete
     else
       Inc(i);
    end;
    KeyList.Items.EndUpdate;
{*}except
{*}  raise CException.Create('Filter',0,self);
{*}end;
end;

procedure TFrmJumpProc.KeyListDblClick(Sender: TObject);
begin
  LineNumber:=fLineNumber;
  Close;
end;

procedure TFrmJumpProc.edFilterChange(Sender: TObject);
begin
    fFilter:=edFilter.Text;
    if fFilter='' then begin
      ReadIniFile;
      KeyList.SortType:=stNone;
      KeyList.SortType:=stText;
    end
    else begin
      ReadIniFile;    
      Filter(fFilter);
      if KeyList.Items.Count>0 then
        KeyListSelectItem(Self,KeyList.Items[0], True);
    end;
//    ActiveControl:=KeyList;
end;

procedure TFrmJumpProc.FormCreate(Sender: TObject);
begin
  fList:=TStringList.Create;
end;

procedure TFrmJumpProc.FormDestroy(Sender: TObject);
begin
  fList.Free;
end;

procedure TFrmJumpProc.edFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If (Key = VK_DOWN) or (Key = VK_UP) then begin
    PostMessage(KeyList.Handle, WM_KEYDOWN, Key, 0);
  end;
  If (Key = VK_RETURN) then begin
    LineNumber:=fLineNumber;
    Close;
  end;
  If (Key = VK_ESCAPE) then begin
    Close;
  end;

end;

procedure TFrmJumpProc.edFilterKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If (Key = VK_DOWN)  or (Key = VK_UP) then begin
    PostMessage(KeyList.Handle, WM_KEYUP, Key, 0);
  end;
end;

end.


