unit udlgAppOptions;

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
  ComCtrls, StdCtrls, Buttons, Spin, OleServer;//, Word97;

type
  TdlgAppOptions = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    spMRU: TSpinEdit;
    Label2: TLabel;
    spSearchListMax: TSpinEdit;
    cbRememberSearchList: TCheckBox;
    cbRemoveExtentions: TCheckBox;
    cbUndoAfterSave: TCheckBox;
    btnMRUClear: TButton;
    cbMinimizeTinn: TCheckBox;
    Label3: TLabel;
    edLineWidth: TEdit;
    Label4: TLabel;
    cbHighlighted: TCheckBox;
    ColorDialog: TColorDialog;
    sbColor: TSpeedButton;
    edColor: TEdit;
    cbWordWrap: TCheckBox;
    Label5: TLabel;
    edStartComment: TEdit;
    Label6: TLabel;
    edEndComment: TEdit;
    cbHighlightedWH: TCheckBox;
    edColorWH: TEdit;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnMRUClearClick(Sender: TObject);
    procedure edLineWidthKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbColorClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgAppOptions: TdlgAppOptions;

implementation

uses
  ufrmMain;

{$R *.DFM}

procedure TdlgAppOptions.FormCreate(Sender: TObject);
begin
  spMRU.Value                   := frmTinnMain.MRUmax;
  spSearchListMax.Value         := frmTinnMain.SearchListMax;
  cbRememberSearchList.Checked  := frmTinnMain.boolRememberSearchList;
  cbRemoveExtentions.Checked    := frmTinnMain.boolRemoveExtentions;
  cbHighlighted.Checked         := frmTinnMain.boolHighlightActiveLine;
  edColor.Color                 := frmTinnMain.colorHighlightActiveLive;
  cbWordWrap.Checked            := frmTinnMain.actToggleWordWrap.Checked;
  edStartComment.Text           := frmTinnMain.gStartComment;
  edEndComment.Text             := frmTinnMain.gEndComment;
  edColorWH.Color               := frmTinnMain.colorHighlightAllWords;
  cbHighlightedWH.Checked       := frmTinnMain.boolHighlightAllWords;
end;

procedure TdlgAppOptions.btnMRUClearClick(Sender: TObject);
begin
  frmTinnMain.ClearMRU;
end;

procedure TdlgAppOptions.edLineWidthKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Only digits allowed

end;

procedure TdlgAppOptions.sbColorClick(Sender: TObject);
begin
  ColorDialog.Color := edColorWH.Color;
  if (ColorDialog.Execute) then
    edColorWH.Color := ColorDialog.Color;
end;

end.
