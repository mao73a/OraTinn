unit ufrmProject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, ComCtrls, SynEdit, ufrmEditor;

type
  TfrmProject = class(TForm)
    tvProjectFiles: TTreeView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure tvProjectFilesDblClick(Sender: TObject);
  private
    { Private declarations }
    function NodeExists(var ioPos : integer; iFile : string) : boolean;
    procedure StartTree;
  public
    { Public declarations }
    boolDocked : boolean;
    boolProjectChanged : boolean;

    procedure AddFile(iFile : string);
    procedure SaveProject;
    procedure OpenProject;
    procedure RemoveFile(iFile : string);
    procedure OpenAllFiles;
    procedure CloseAllFiles;
  end;

var
  frmProject: TfrmProject;

implementation

uses ufrmMain;

{$R *.DFM}

procedure TfrmProject.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i, intPos : integer;
  fileName : string;
begin
  frmTinnMain.leftSplitter.Visible := False;
  frmTinnMain.panProjectDockSite.Constraints.MinWidth := 0;
  frmTinnMain.panProjectDockSite.Width := 1;
  frmTinnMain.ProjectName := '';
  // Close all the files in that project
  for i := 1 to tvProjectFiles.Items.Count - 1 do
  begin
    fileName := string(tvProjectFiles.Items[i].Data);
    intPos := frmTinnMain.FindWindowByName(fileName);
    if (intPos > -1) then
      (frmTinnMain.MDIChildren[intPos] as TfrmEditor).Close;
  end;
end;

procedure TfrmProject.FormCreate(Sender: TObject);
begin
  StartTree;
end;

procedure TfrmProject.AddFile(iFile: string);
var
  childPos : integer;
  childNode : TTreeNode;
begin
  // Check to see if the file has already been added
  if (not NodeExists(childPos, iFile)) then
  begin
    childNode := tvProjectFiles.Items.AddChild(tvProjectFiles.Items.Item[0], ExtractFileName(iFile));
    childNode.Data := PChar(iFile);
    tvProjectFiles.Items.Item[0].Expand(true);
    boolProjectChanged := true;
    tvProjectFiles.AlphaSort;
  end;
end;

procedure TfrmProject.SaveProject;
var
  listProjectFiles : TStringList;
  i : integer;
begin
  // Save the file list to the project name
  listProjectFiles := TStringList.Create;
  for i := 1 to tvProjectFiles.Items.Count - 1 do
  begin
    listProjectFiles.Add(string(tvProjectFiles.Items[i].Data));
  end;

  listProjectFiles.SaveToFile(frmTinnMain.ProjectName);
  boolProjectChanged := false;
end;

procedure TfrmProject.OpenProject;
var
  listProjectFiles : TStringList;
  i : integer;
begin
  if (tvProjectFiles.Items.Count > 1) then
  begin
    tvProjectFiles.Items.Clear;
    StartTree;
  end;
  listProjectFiles := TStringList.Create;
  listProjectFiles.LoadFromFile(frmTinnMain.ProjectName);
  for i := 0 to listProjectFiles.Count - 1 do
  begin
    if (trim(listProjectFiles.Strings[i]) <> '') then
      AddFile(listProjectFiles.Strings[i]);
  end;
  // Reset the boolProjectChanged to false
  boolProjectChanged := false;
  tvProjectFiles.AlphaSort;
end;

procedure TfrmProject.tvProjectFilesDblClick(Sender: TObject);
begin
  if tvProjectFiles.Selected.Level > 0 then
    frmTinnMain.OpenFileIntoTinn(string(tvProjectFiles.Selected.Data));
end;

procedure TfrmProject.RemoveFile(iFile: string);
var
  childPos : integer;
begin
  // Check to see if the file hasn't already been deleted
  if (NodeExists(childPos, iFile)) then
  begin
    tvProjectFiles.Items.Item[childPos].Delete;
    boolProjectChanged := true;
    tvProjectFiles.AlphaSort;
  end;

end;

function TfrmProject.NodeExists(var ioPos: integer; iFile : string): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to tvProjectFiles.Items.Count - 1 do
  begin
    if (tvProjectFiles.Items[i].Data = Pchar(iFile)) then
    begin
      ioPos := i;
      result := true;
      break;
    end;
  end;
end;

procedure TfrmProject.StartTree;
var
  NewNode : TTreeNode;
begin
  tvProjectFiles.SortType := stText;
  NewNode := TTreeNode.Create(tvProjectFiles.Items);
  NewNode.Text := frmTinnMain.ProjectName;
  NewNode.Data := Pchar(frmTinnMain.ProjectName);
  tvProjectFiles.Items.AddChild(NewNode, ExtractFileName(frmTinnMain.ProjectName));

end;

procedure TfrmProject.OpenAllFiles;
var
  i : integer;
begin
  for i := 1 to tvProjectFiles.Items.Count - 1 do
  begin
    frmTinnMain.OpenFileIntoTinn(string(tvProjectFiles.Items[i].Data));
  end;
end;

procedure TfrmProject.CloseAllFiles;
var
  i : integer;
  fileName : string;
  intPos : integer;
begin
  // Close all the files in that project
  for i := 1 to tvProjectFiles.Items.Count - 1 do
  begin
    fileName := string(tvProjectFiles.Items[i].Data);
    intPos := frmTinnMain.FindWindowByName(fileName);
    if (intPos > -1) then
      (frmTinnMain.MDIChildren[intPos] as TfrmEditor).Close;
  end;
end;

end.
