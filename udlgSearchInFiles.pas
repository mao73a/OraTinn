unit udlgSearchInFiles;

{
 The contents of this file are subject to the terms and conditions found under
 the GNU General Public License Version 2 or later (the "GPL").
 See http://www.opensource.org/licenses/gpl-license.html or
 http://www.fsf.org/copyleft/gpl.html for further information.

}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, BrowseForFolder;

type
  TdlgSearchInFiles = class(TForm)
    Label1: TLabel;
    cbSearchText: TComboBox;
    gbSearchOptions: TGroupBox;
    cbSearchCaseSensitive: TCheckBox;
    cbSearchWholeWords: TCheckBox;
    cbRegularExpression: TCheckBox;
    gbxWhere: TGroupBox;
    GroupBox1: TGroupBox;
    lblDirectory: TLabel;
    lblFileMask: TLabel;
    comboDirectories: TComboBox;
    comboFileMasks: TComboBox;
    cbSubdirectories: TCheckBox;
    sbtnDirectory: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cbOpenFiles: TCheckBox;
    cbDirectories: TCheckBox;
    BrowseForFolder: TBrowseForFolder;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbRegularExpressionClick(Sender: TObject);
    procedure sbtnDirectoryClick(Sender: TObject);
    procedure cbDirectoriesClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    // Getters
    function GetSearchCaseSensitive: boolean;
    function GetSearchText: string;
    function GetSearchTextHistory: string;
    function GetSearchWholeWords: boolean;
    function GetSearchRegularExpression: boolean;
    function GetSearchOpenFiles : boolean;
    function GetSearchDirectory : boolean;
    function GetSearchDirHistory: string;
    function GetSearchFileMaskHistory: string;
    function GetSearchInSub : boolean;
    function GetSearchDirectoryText: string;
    function GetSearchFileMask: string;

    // Setters
    procedure SetSearchCaseSensitive(Value: boolean);
    procedure SetSearchText(Value: string);
    procedure SetSearchTextHistory(Value: string);
    procedure SetSearchWholeWords(Value: boolean);
    procedure SetSearchRegularExpression(const Value: boolean);
    procedure SetSearchOpenFiles(const Value: boolean);
    procedure SetSearchDirectory(const Value: boolean);
    procedure SetSearchDirHistory(Value: string);
    procedure SetSearchFileMaskHistory(Value: string);
    procedure SetSearchFileMask(Value: string);
    procedure SetSearchInSub(const Value: boolean);
    procedure SetSearchDirectoryText(const Value: string);
    

  public
    { Public declarations }
    property SearchCaseSensitive: boolean       read GetSearchCaseSensitive       write SetSearchCaseSensitive;
    property SearchText: string                 read GetSearchText                write SetSearchText;
    property SearchTextHistory: string          read GetSearchTextHistory         write SetSearchTextHistory;
    property SearchWholeWords: boolean          read GetSearchWholeWords          write SetSearchWholeWords;
    property SearchRegularExpression: boolean   read GetSearchRegularExpression   write SetSearchRegularExpression;
    property SearchOpenFiles: boolean           read GetSearchOpenFiles           write SetSearchOpenFiles;
    property SearchDirectory: boolean           read GetSearchDirectory           write SetSearchDirectory;
    property SearchDirHistory: string           read GetSearchDirHistory          write SetSearchDirHistory;
    property SearchDirectoryText: string        read GetSearchDirectoryText       write SetSearchDirectoryText;
    property SearchFileMaskHistory: string      read GetSearchFileMaskHistory     write SetSearchFileMaskHistory;
    property SearchFileMask: string             read GetSearchFileMask            write SetSearchFileMask;
    property SearchInSub: boolean               read GetSearchInSub               write SetSearchInSub;
  end;

var
  dlgSearchInFiles: TdlgSearchInFiles;

implementation

{$R *.DFM}

// Getters
function TdlgSearchInFiles.GetSearchCaseSensitive: boolean;
begin
  Result := cbSearchCaseSensitive.Checked;
end;

function TdlgSearchInFiles.GetSearchRegularExpression: boolean;
begin
  Result := cbRegularExpression.Checked;
end;

function TdlgSearchInFiles.GetSearchText: string;
begin
  Result := cbSearchText.Text;
end;

function TdlgSearchInFiles.GetSearchTextHistory: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to cbSearchText.Items.Count - 1 do begin
    if i >= 10 then
      break;
    if i > 0 then
      Result := Result + #13#10;
    Result := Result + cbSearchText.Items[i];
  end;
end;

function TdlgSearchInFiles.GetSearchWholeWords: boolean;
begin
  Result := cbSearchWholeWords.Checked;
end;

function TdlgSearchInFiles.GetSearchOpenFiles : boolean;
begin
  Result := cbOpenFiles.Checked;
end;

function TdlgSearchInFiles.GetSearchDirectory : boolean;
begin
  Result := cbDirectories.Checked;
end;

function TdlgSearchInFiles.GetSearchDirHistory: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to comboDirectories.Items.Count - 1 do begin
    if i >= 10 then
      break;
    if i > 0 then
      Result := Result + #13#10;
    Result := Result + comboDirectories.Items[i];
  end;
end;

function TdlgSearchInFiles.GetSearchFileMaskHistory: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to comboFileMasks.Items.Count - 1 do begin
    if i >= 10 then
      break;
    if i > 0 then
      Result := Result + #13#10;
    Result := Result + comboFileMasks.Items[i];
  end;
end;

function TdlgSearchInFiles.GetSearchInSub : boolean;
begin
  Result := cbSubdirectories.Checked;
end;

function TdlgSearchInFiles.GetSearchDirectoryText: string;
begin
  Result := comboDirectories.Text;
end;

function TdlgSearchInFiles.GetSearchFileMask: string;
begin
  Result := comboFileMasks.Text;
end;

// Setters
procedure TdlgSearchInFiles.SetSearchCaseSensitive(Value: boolean);
begin
  cbSearchCaseSensitive.Checked := Value;
end;

procedure TdlgSearchInFiles.SetSearchText(Value: string);
begin
  cbSearchText.Text := Value;
end;

procedure TdlgSearchInFiles.SetSearchTextHistory(Value: string);
begin
  cbSearchText.Items.Text := Value;
end;

procedure TdlgSearchInFiles.SetSearchWholeWords(Value: boolean);
begin
  cbSearchWholeWords.Checked := Value;
end;

procedure TdlgSearchInFiles.SetSearchRegularExpression(
  const Value: boolean);
begin
  cbRegularExpression.Checked := Value;
end;

procedure TdlgSearchInFiles.SetSearchOpenFiles(const Value: boolean);
begin
  cbOpenFiles.Checked := Value;
end;

procedure TdlgSearchInFiles.SetSearchDirectory(const Value: boolean);
begin
  cbDirectories.Checked := Value;
end;

procedure TdlgSearchInFiles.SetSearchDirHistory(Value: string);
begin
  comboDirectories.Items.Text := Value;
end;

procedure TdlgSearchInFiles.SetSearchFileMask(Value: string);
begin
  comboFileMasks.Items.Text := Value;
end;

procedure TdlgSearchInFiles.SetSearchInSub(const Value: boolean);
begin
  cbSubdirectories.Checked := Value;
end;

procedure TdlgSearchInFiles.SetSearchDirectoryText(const Value: string);
begin
  comboDirectories.Text := Value;
end;

procedure TdlgSearchInFiles.SetSearchFileMaskHistory(Value: string);
begin
  comboFileMasks.Items.Text := Value;
end;

// Form procedure
procedure TdlgSearchInFiles.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  s: string;
  i: integer;
begin
  if ModalResult = mrOK then
  begin
    // Set the combo boxes so the entered text gets accounted for
    s := cbSearchText.Text;
    if s <> '' then begin
      i := cbSearchText.Items.IndexOf(s);
      if i > -1 then begin
        cbSearchText.Items.Delete(i);
        cbSearchText.Items.Insert(0, s);
        cbSearchText.Text := s;
      end else
        cbSearchText.Items.Insert(0, s);
    end;

    if (cbDirectories.Checked) then
    begin
      s := comboDirectories.Text;
      if s <> '' then
      begin
        i := comboDirectories.Items.IndexOf(s);
        if i > -1 then
        begin
          comboDirectories.Items.Delete(i);
          comboDirectories.Items.Insert(0, s);
          comboDirectories.Text := s;
        end else
          comboDirectories.Items.Insert(0, s);
      end;

      s := comboFileMasks.Text;
      if s <> '' then
      begin
        i := comboFileMasks.Items.IndexOf(s);
        if i > -1 then
        begin
          comboFileMasks.Items.Delete(i);
          comboFileMasks.Items.Insert(0, s);
          comboFileMasks.Text := s;
        end else
          comboFileMasks.Items.Insert(0, s);
      end;
    end;
  end;
end;

procedure TdlgSearchInFiles.cbRegularExpressionClick(Sender: TObject);
begin
  cbSearchWholeWords.Enabled := Not(cbRegularExpression.Checked);
  cbSearchWholeWords.Checked := false;
  cbSearchCaseSensitive.Enabled := cbSearchWholeWords.Enabled;
  cbSearchCaseSensitive.Checked := false;
end;

procedure TdlgSearchInFiles.sbtnDirectoryClick(Sender: TObject);
resourcestring
  SBrowCap = 'Search in Folder';
begin
  // Thanks to the syn Text Editor project!
  with BrowseForFolder do begin
    Title := SBrowCap;
    Directory := comboDirectories.Text;
    if Execute then
      comboDirectories.Text := Directory;
  end;

end;

procedure TdlgSearchInFiles.cbDirectoriesClick(Sender: TObject);
var
  boolVis : boolean;
begin
  boolVis := cbDirectories.Checked;
  comboDirectories.Enabled := boolVis;
  sbtnDirectory.Enabled := boolVis;
  comboFileMasks.Enabled := boolVis;
  cbSubdirectories.Enabled := boolVis;
  lblDirectory.Enabled := boolVis;
  lblFileMask.Enabled := boolVis;
end;

procedure TdlgSearchInFiles.FormActivate(Sender: TObject);
begin
  if cbSearchText.Items.Count > 0 then
    cbSearchText.ItemIndex := 0;

  if comboDirectories.Enabled then
    if comboDirectories.Items.Count > 0 then
      comboDirectories.ItemIndex := 0;

  if comboFileMasks.Enabled then
    if comboFileMasks.Items.Count > 0 then
      comboFileMasks.ItemIndex := 0;

end;



end.
