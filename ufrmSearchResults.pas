unit ufrmSearchResults;

{
 The contents of this file are subject to the terms and conditions found under
 the GNU General Public License Version 2 or later (the "GPL").
 See http://www.opensource.org/licenses/gpl-license.html or
 http://www.fsf.org/copyleft/gpl.html for further information.

 Copyright Russell May
 http://www.solarvoid.com

}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, SynEdit, ComCtrls;

type
  TfrmSearchResults = class(TForm)
    synSearchResults: TSynEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure synSearchResultsSpecialLineColors(Sender: TObject;
      Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure synSearchResultsDblClick(Sender: TObject);
  private
    { Private declarations }
    fHighlighterLine : integer;
  public
    { Public declarations }
    boolDocked : boolean;
  end;

var
  frmSearchResults: TfrmSearchResults;

implementation

uses ufrmMain, ufrmEditor, synEditKeyCmds;

{$R *.DFM}

procedure TfrmSearchResults.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmTinnMain.splitterBottom.Visible := False;
  frmTinnMain.panSearchResults.Constraints.MinHeight := 0;
  frmTinnMain.panSearchResults.Height := 1;
end;

procedure TfrmSearchResults.synSearchResultsSpecialLineColors(
  Sender: TObject; Line: Integer; var Special: Boolean; var FG,
  BG: TColor);
begin
  if Line = synSearchResults.CaretY then
  begin
    FG := clHighlightText;
    BG := clHighlight;
  end;

end;

procedure TfrmSearchResults.synSearchResultsDblClick(Sender: TObject);
var
  tmpFileName : string;
  colonPos : integer;
  endPos : integer;
  tmpLineNumber : string;
begin
  tmpFileName := synSearchResults.Lines.Strings[synSearchResults.CaretY - 1];
  colonPos := pos(':(', tmpFileName);
  if (colonPos > 0) then
  begin
    endPos := pos('):', tmpFileName);
    tmpLineNumber := Copy(tmpFileName, colonPos + 2, ((endPos - colonPos) - 2));
    tmpFileName := Copy(tmpFileName, 1, colonPos - 1);
    frmTinnMain.OpenFileIntoTinn(tmpFileName, StrToIntDef(tmpLineNumber,0));
  end;

  with TfrmEditor(frmTinnMain.MDIChildren[0]).synEditor do
      ExecuteCommand(ecSelLineEnd, 'A', @lines); 
end;

end.
