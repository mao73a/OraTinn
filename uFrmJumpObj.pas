unit uFrmJumpObj;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Db, Grids, DBGrids, inifiles,
  ExtCtrls, utypese, ComCtrls, Menus;

type

  TFrmJumpObj = class(TForm)
    Panel1: TPanel;
    KeyList: TListView;
    Label1: TLabel;
    edFilter: TEdit;
    pmDb: TPopupMenu;
    LoadSpc1: TMenuItem;
    LoadBody1: TMenuItem;
    SpeedButton1: TSpeedButton;
    procedure sgConnSetFilter(ARows: TStrings; var Accept: Boolean);
    procedure KeyListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure KeyListColumnClick(Sender: TObject; Column: TListColumn);
    procedure KeyListCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure edFilterChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edFilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFilterKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LoadSpc1Click(Sender: TObject);
    procedure LoadBody1Click(Sender: TObject);
    procedure KeyListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure KeyListDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    fActive : Boolean;
    fIniFile : TIniFile;
    fSortedColumn : Integer;
    fSortDirection : Integer;
    fLineNumber : Integer;
    fTreeView : TTreeView;
    FOnLoadSPCClick: TNotifyEvent;
    FOnLoadBDYClick: TNotifyEvent;
    FOnDobleClick: TNotifyEvent;
    FFilter: String;
    procedure DoFilter(AFilter:String);
    procedure SetOnLoadSPCClick(const Value: TNotifyEvent);
    procedure SetOnLoadBDYClick(const Value: TNotifyEvent);
    procedure SetOnDobleClick(const Value: TNotifyEvent);
    procedure SetFilter(const Value: String);
  public
    { Public declarations }
    LineNumber : Integer;
    fList : TStrings;
    procedure ReadIniFile;
    procedure Prepare;
    constructor Create(AOwner: TComponent; pTreeView: TTreeView);
    property OnLoadSPCClick : TNotifyEvent read FOnLoadSPCClick write SetOnLoadSPCClick;
    property OnLoadBDYClick : TNotifyEvent read FOnLoadBDYClick write SetOnLoadBDYClick;
    property OnDobleClick : TNotifyEvent read FOnDobleClick write SetOnDobleClick;
    procedure SetFocusOnFilter;
    function FilterMatch(AFilter, AText:String) : Boolean;
    property Filter : String read FFilter write SetFilter;
  end;


implementation

{$R *.DFM}



procedure TFrmJumpObj.ReadIniFile;
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
        s := copy(vTmpStr,1, vTmpPos - 1);
        if FilterMatch(edFilter.Text, s) then
        begin
          Item:= KeyList.Items.Add;
          Item.Caption:=vTmpStr;
          Item.Caption:=s;
          s := copy(vTmpStr, vTmpPos + 1, 10);
          Item.SubItems.Add(s);
        end;
      end;
  finally
    KeyList.Columns[0].AutoSize:=False;
    KeyList.Columns[1].AutoSize:=False;
    KeyList.Columns[0].Width:=fTreeView.Width-30;
    KeyList.Columns[1].Width:=0;
    KeyList.Items.EndUpdate;
  end;
{*}except
{*}  raise CException.Create('ReadIniFile',0,self);
{*}end;
end;


procedure TFrmJumpObj.SetFilter(const Value: String);
begin
  FFilter := Value;
end;

procedure TFrmJumpObj.SetFocusOnFilter;
var
 vPoint : TPoint;
 vOldPoint : TPoint;
begin
  try
    vOldPoint :=  Mouse.CursorPos;
    vPoint := edFilter.ClientToScreen(Point(10,10));
    SetCursorPos(vPoint.X,vPoint.Y);
    mouse_event(MOUSEEVENTF_LEFTDOWN,0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP,0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP,0, 0, 0, 0);
    keybd_event(VK_END, 0, 0, 0);
  finally
    SetCursorPos(vOldPoint.X,vOldPoint.Y);
  end;

end;

procedure TFrmJumpObj.SetOnDobleClick(const Value: TNotifyEvent);
begin
  FOnDobleClick := Value;
end;

procedure TFrmJumpObj.SetOnLoadBDYClick(const Value: TNotifyEvent);
begin
  FOnLoadBDYClick := Value;
end;

procedure TFrmJumpObj.SetOnLoadSPCClick(const Value: TNotifyEvent);
begin
  FOnLoadSPCClick := Value;
end;

procedure TFrmJumpObj.sgConnSetFilter(ARows: TStrings;
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

procedure TFrmJumpObj.SpeedButton1Click(Sender: TObject);
begin
  edFilter.Text:='';
  Close;
end;

procedure TFrmJumpObj.KeyListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
{*}try
      if not fActive then exit;
      fLineNumber := StrToInt(Item.SubItems[0]);
{*}except
{*}  raise CException.Create('KeyListSelectItem',0,self);
{*}end;
end;

procedure TFrmJumpObj.LoadBody1Click(Sender: TObject);
begin
  LineNumber:=fLineNumber;
  KeyList.Tag:=fLineNumber;
  if Assigned(FOnLoadBDYClick) then
    FOnLoadBDYClick(KeyList);
end;

procedure TFrmJumpObj.LoadSpc1Click(Sender: TObject);
begin
  LineNumber:=fLineNumber;
  KeyList.Tag:=fLineNumber;
  if Assigned(FOnLoadSPCClick) then
    FOnLoadSPCClick(KeyList);
end;

procedure TFrmJumpObj.Prepare;
var vWidth : Integer;
begin
{*}try
    ReadIniFile;
    fSortedColumn:=0;
    fSortDirection:=1;
    LineNumber:=-1;
    FActive:=True;
    KeyList.SortType:=stText;
    if KeyList.Items.Count>0 then
      KeyListSelectItem(Self,KeyList.Items[0], True);
    if edFilter.Text<>'' then
      DoFilter(edFilter.Text);

{*}except
{*}  raise CException.Create('FormActivate',0,self);
{*}end;
end;
procedure TFrmJumpObj.KeyListColumnClick(Sender: TObject;
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


procedure TFrmJumpObj.KeyListCompare(Sender: TObject; Item1,
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



procedure TFrmJumpObj.KeyListDblClick(Sender: TObject);
begin
 KeyList.Tag:=fLineNumber;
 if Assigned(FOnDobleClick) then
    FOnDobleClick(KeyList);
end;

procedure TFrmJumpObj.KeyListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If (Key = VK_ESCAPE) then begin
    Close;
  end else If (Key = VK_RETURN) then begin
    KeyListDblClick(Sender);
  end;

end;

function TFrmJumpObj.FilterMatch(AFilter, AText:String) : Boolean;
begin
  if AFilter='' then
    result:=true
  else
    result := pos(UpperCase(AFilter), UpperCase(AText))<>0;
end;

procedure TFrmJumpObj.DoFilter(AFilter:String);
var
 i : Integer;
begin
{*}try
    KeyList.Items.BeginUpdate;
    i:=0;
    while i<KeyList.Items.Count do begin
     if FilterMatch(AFilter, KeyList.Items[i].Caption) then
       Inc(i)
     else
       KeyList.Items[i].Delete;
    end;
    KeyList.Items.EndUpdate;
{*}except
{*}  raise CException.Create('Filter',0,self);
{*}end;
end;

constructor TFrmJumpObj.Create(AOwner: TComponent; pTreeView: TTreeView);
begin
  inherited Create(Aowner);
  fTreeView:=pTreeView;
end;

procedure TFrmJumpObj.edFilterChange(Sender: TObject);
begin
    fFilter:=edFilter.Text;
    if fFilter='' then begin
      ReadIniFile;
      KeyList.SortType:=stNone;
      KeyList.SortType:=stText;
    end
    else begin
      ReadIniFile;
      DoFilter(fFilter);
      if KeyList.Items.Count>0 then
        KeyListSelectItem(Self,KeyList.Items[0], True);
    end;
//    ActiveControl:=KeyList;
end;

procedure TFrmJumpObj.FormCreate(Sender: TObject);
begin
  fList:=TStringList.Create;
end;

procedure TFrmJumpObj.FormDestroy(Sender: TObject);
begin
  fList.Free;
end;

procedure TFrmJumpObj.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If (Key = VK_ESCAPE) then begin
    Close;
  end;
end;


procedure TFrmJumpObj.FormShow(Sender: TObject);
begin
  SetFocusOnFilter;
end;

procedure TFrmJumpObj.edFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If (Key = VK_DOWN) or (Key = VK_UP) or (Key = VK_RETURN) then begin
    PostMessage(KeyList.Handle, WM_KEYDOWN, Key, 0);
  end;
  If (Key = VK_ESCAPE) then begin
    Close;
  end;
end;

procedure TFrmJumpObj.edFilterKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If (Key = VK_DOWN)  or (Key = VK_UP) or (Key = VK_RETURN) then begin
    PostMessage(KeyList.Handle, WM_KEYUP, Key, 0);
  end;
end;

end.


