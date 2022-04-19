unit ufrmPrintPreview;

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
  SynEditPrintPreview;

type
  TfrmPrintPreview = class(TForm)
    synPP: TSynEditPrintPreview;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrintPreview: TfrmPrintPreview;

implementation

{$R *.DFM}

end.
