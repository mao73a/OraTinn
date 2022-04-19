unit uFrmConnect;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Db, Grids, DBGrids, inifiles,
  ExtCtrls, utypese, ComCtrls;

type
  TFrmConnect = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btOK: TBitBtn;
    BitBtn2: TBitBtn;
    edUser: TEdit;
    edPass: TEdit;
    edHost: TEdit;
    panelFilter: TPanel;
    Panel1: TPanel;
    KeyList: TListView;
    procedure btOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure sgConnDblClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure sgConnSetFilter(ARows: TStrings; var Accept: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure sgConnKeyPress(Sender: TObject; var Key: Char);
    procedure KeyListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure KeyListColumnClick(Sender: TObject; Column: TListColumn);
    procedure KeyListCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure KeyListDblClick(Sender: TObject);
  private
    { Private declarations }
    fActive : Boolean;
    fFilter : String;
    fIniFile : TIniFile;
    fSortedColumn : Integer;
    fSortDirection : Integer;
    procedure Filter(AFilter:String);
  public
    { Public declarations }
    vUser, vPass, vHost : String;
    ConnectString: String;
    IniFile : TIniFile;
    procedure Post;
    procedure ReadIniFile(pIniFile : TIniFile);
    procedure WriteIniFile(pIniFile : TIniFile);
  end;


implementation

{$R *.DFM}

procedure TFrmConnect.Post;
var
 i : Integer;
 vFound : Boolean;
 Item : TListItem;
begin
{*}try
    vUser:=UpperCase(EdUser.Text); vPass:=EdPass.Text; vHost:=UpperCase(EdHost.Text);
    if fFilter<>'' then
      ReadIniFile(fIniFile); //cancel filtering
    vFound:=False;
    if vUser<>'' then
    begin
     for i:=1 to KeyList.Items.Count-1 do
       if (KeyList.Items[i].Caption=vUser) and
         (KeyList.Items[i].SubItems[0]=vHost) then
       begin
         KeyList.Items[i].SubItems[1]:=DateTimeToStr(Now);
         KeyList.Items[i].SubItems[2]:=vPass;
         vFound:=True;
         WriteIniFile(iniFile);
         break;
       end;
     if not vFound then
     begin
       Item:= KeyList.Items.Add;
       Item.Caption:=vUser;
       Item.SubItems.Add(vHost);
       Item.SubItems.Add(DateTimeToStr(Now));
       Item.SubItems.Add(vPass);
       WriteIniFile(iniFile);
     end;
  end;
  
{*}except
{*}  raise CException.Create('Post',0,self);
{*}end;
end;

procedure TFrmConnect.FormActivate(Sender: TObject);
var vWidth : Integer;
begin
{*}try
    if not fActive then
    begin
      fSortedColumn:=2;
      fSortDirection:=-1;
      ReadIniFile(IniFile);
      FActive:=True;
      KeyList.SortType:=stText;
      if KeyList.Items.Count>0 then
        KeyListSelectItem(Self,KeyList.Items[0], True);
    end;

{*}except
{*}  raise CException.Create('FormActivate',0,self);
{*}end;
end;

procedure TFrmConnect.ReadIniFile(pIniFile : TIniFile);
var
  i,j: Integer;
  vConnectList : TStringList;
  vUniqueList : TStringList;
  vTmpStr, s, v2bUniqe : String;
  vTmpPos : Integer;
  Item : TListItem;
begin
{*}try
    KeyList.Items.BeginUpdate;
    fIniFile:=pIniFile;
    vConnectList := TStringList.Create;
    vUniqueList := TStringList.Create;
    vUniqueList.Sorted:=True; vUniqueList.Duplicates:=dupError;
    pIniFile.ReadSectionValues('ConnectHistory', vConnectList);
    try
    KeyList.Items.Clear;
      for i:=0 to vConnectList.Count-1 do
      begin
        vTmpStr := vConnectList.Strings[i];
        vTmpPos := pos('=', vTmpStr);
        vTmpStr := copy(vTmpStr, vTmpPos + 1, length(vTmpStr));
        v2bUniqe:='';
        Item:= KeyList.Items.Add;
        for j:=0 to KeyList.Columns.Count-1 do
        begin
          vTmpPos := pos(';', vTmpStr);
          s := copy(vTmpStr,1, vTmpPos - 1);
          vTmpStr := copy(vTmpStr, vTmpPos +1, length(vTmpStr));
          //sgConn.Cells[j,k+1]:=s;
          if j=0 then Item.Caption:=s
          else begin
            Item.SubItems.Add(s);
          end;
          if j<=1 then v2bUniqe:=v2bUniqe+UpperCase(s);
        end;
        try
          vUniqueList.Add(v2bUniqe); //check for uniqueness
        except
          on EStringListError do
           KeyList.Items.Delete(KeyList.Items.Count-1);
        end;
      end;
      vConnectList.Free;
      vUniqueList.Free;

  finally
    KeyList.Items.EndUpdate;
  end;

{
  try
    KeyList.Items.Clear;
    for I:= 0 to FSynEdit.Keystrokes.Count-1 do
    begin
      Item:= KeyList.Items.Add;
      FillInKeystrokeInfo(FSynEdit.Keystrokes.Items[I], Item);
      Item.Data:= FSynEdit.Keystrokes.Items[I];
    end;
    if (KeyList.Items.Count > 0) then KeyList.Items[0].Selected:= True;
  finally
    KeyList.Items.EndUpdate;
  end;
 }
{*}except
{*}  raise CException.Create('ReadIniFile',0,self);
{*}end;
end;

procedure TFrmConnect.WriteIniFile(pIniFile: TIniFile);
var
 i,j : Integer;
 begin
{*}try
    if not Assigned(pIniFile) then exit;
    pIniFile.EraseSection('ConnectHistory');
    for i:=0 to KeyList.Items.Count-1 do
       pIniFile.WriteString('ConnectHistory',IntToStr(i),
        KeyList.Items[i].Caption+';'+KeyList.Items[i].SubItems[0]+';'+
          KeyList.Items[i].SubItems[1]+';'+KeyList.Items[i].SubItems[2]+';');
{*}except
{*}  raise CException.Create('WriteIniFile',0,self);
{*}end;
end;

procedure TFrmConnect.btOKClick(Sender: TObject);
begin
{*}try
    vUser:=EdUser.Text; vPass:=EdPass.Text; vHost:=EdHost.Text;
    ConnectString:=vUser+'@'+vHost;
{*}except
{*}  raise CException.Create('btOKClick',0,self);
{*}end;
end;

procedure TFrmConnect.sgConnDblClick(Sender: TObject);
begin
{*}try
    btOKClick(nil);
    ModalResult:=mrOK;
{*}except
{*}  raise CException.Create('sgConnDblClick',0,self);
{*}end;
end;

procedure TFrmConnect.BitBtn2Click(Sender: TObject);
begin
{*}try
    Close;
{*}except
{*}  raise CException.Create('BitBtn2Click',0,self);
{*}end;
end;

procedure TFrmConnect.sgConnSetFilter(ARows: TStrings;
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

procedure TFrmConnect.Button1Click(Sender: TObject);
begin
{*}try
   btOKClick(Self);
   Post;
{*}except
{*}  raise CException.Create('Button1Click',0,self);
{*}end;
end;

procedure TFrmConnect.sgConnKeyPress(Sender: TObject; var Key: Char);
begin
{*}try
    if Key=#8 then begin  //Backspace
       fFilter:='';
    end else begin
       fFilter:=fFilter+Key;
    end;
    if fFilter='' then begin
      panelFilter.Visible:=False;
      ReadIniFile(fIniFile);
      KeyList.SortType:=stNone;      
      KeyList.SortType:=stText;
    end
    else begin
      panelFilter.Visible:=True;
      panelFilter.Caption:='Filter: '+fFilter;
      Filter(fFilter);
      if KeyList.Items.Count>0 then
        KeyListSelectItem(Self,KeyList.Items[0], True);
    end;
    ActiveControl:=KeyList;
{*}except
{*}  raise CException.Create('sgConnKeyPress',0,self);
{*}end;
end;

procedure TFrmConnect.KeyListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
{*}try
      if not fActive then exit;
      EdUser.Text := Item.Caption;
      EdHost.Text := Item.SubItems[0];
      EdPass.Text := Item.SubItems[2];
{*}except
{*}  raise CException.Create('KeyListSelectItem',0,self);
{*}end;
end;

procedure TFrmConnect.KeyListColumnClick(Sender: TObject;
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


procedure TFrmConnect.KeyListCompare(Sender: TObject; Item1,
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



procedure TFrmConnect.Filter(AFilter:String);
var
 i : Integer;
begin
{*}try
    try
      KeyList.Items.BeginUpdate;
      i:=0;
      while i<KeyList.Items.Count do begin
       if (pos(UpperCase(AFilter), UpperCase(KeyList.Items[i].Caption))=0) and
          (pos(UpperCase(AFilter), UpperCase(KeyList.Items[i].SubItems[0]))=0) and
          (pos(UpperCase(AFilter), UpperCase(KeyList.Items[i].SubItems[1]))=0) and
          (pos(UpperCase(AFilter), UpperCase(KeyList.Items[i].SubItems[2]))=0) then
         KeyList.Items[i].Delete
       else
         Inc(i);
      end;
    finally
       KeyList.Items.EndUpdate;
    end;
{*}except
{*}  raise CException.Create('Filter',0,self);
{*}end;
end;

procedure TFrmConnect.KeyListDblClick(Sender: TObject);
begin
  btOKClick(nil);
  ModalResult:=mrOK;
end;

end.


