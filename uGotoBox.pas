unit uGotoBox;

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
  StdCtrls, Buttons, Spin;

type
  TGotoBox = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    spLine: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure spLineKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GotoBox: TGotoBox;

implementation

{$R *.DFM}

procedure TGotoBox.BitBtn1Click(Sender: TObject);
begin
 ModalResult := mrOk;
end;

procedure TGotoBox.spLineKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
   BitBtn1Click(Sender);
  if Key = 27 then // Escape
    ModalResult := mrCancel;
end;

end.
