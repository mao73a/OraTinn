unit uFrmCompileErrors;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TFrmCompileErrors = class(TForm)
    mMemo: TMemo;
    btNext: TSpeedButton;
    btPrev: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mMemoDblClick(Sender: TObject);
    procedure btPrevClick(Sender: TObject);
    procedure btNextClick(Sender: TObject);
  private
    FErrors: TStringList;
    fLineNo : Integer;
    procedure SetErrors(const Value: TStringList);
    { Private declarations }
  public
    { Public declarations }
    property Errors : TStringList read FErrors write SetErrors;
    procedure SelectError;
    procedure CheckButtons;
  end;

implementation

uses ufrmMain, ufrmEditor, SynEditKeyCmds;

{$R *.DFM}

{ TFrmCompileErrors }

procedure TFrmCompileErrors.SetErrors(const Value: TStringList);
begin
  FErrors := Value;
  fLineNo:=0;
  if Assigned(FErrors) then
    if  FErrors.Count>0 then
    begin
      mMemo.Lines.Clear;
      mMemo.Lines.Add(FErrors[0]);
      CheckButtons;
      SelectError;
    end;
end;

procedure TFrmCompileErrors.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmTinnMain.splitterBottom.Visible := False;
  frmTinnMain.panSearchResults.Constraints.MinHeight := 0;
  frmTinnMain.panSearchResults.Height := 1;
end;

procedure TFrmCompileErrors.mMemoDblClick(Sender: TObject);
begin
   SelectError
end;

procedure TFrmCompileErrors.SelectError;
begin
  with TfrmEditor(frmTinnMain.MDIChildren[0]).synEditor do
  begin
    GotoLineAndCenter(PPoint(FErrors.Objects[fLineNo])^.Y);
    ExecuteCommand(ecSelGotoXY, 'A', PPoint(FErrors.Objects[fLineNo]));
  end;
end;

procedure TFrmCompileErrors.btPrevClick(Sender: TObject);
begin
  if fLineNo>0 then
  begin
    Dec(fLineNo);
    mMemo.Lines.Clear;
    mMemo.Lines.Add(FErrors[fLineNo]);
    CheckButtons;
    SelectError;
  end;
end;

procedure TFrmCompileErrors.btNextClick(Sender: TObject);
begin
  if fLineNo<FErrors.Count-1  then
  begin
    Inc(fLineNo);
    mMemo.Lines.Clear;
    mMemo.Lines.Add(FErrors[fLineNo]);
    CheckButtons;
    SelectError;
  end;
end;

procedure TFrmCompileErrors.CheckButtons;
begin
  if fLineNo=0 then
    btPrev.Enabled:=False
  else
    btPrev.Enabled:=True;

  if fLineNo=FErrors.Count-1 then
    btNext.Enabled:=False
  else
    btNext.Enabled:=True;

end;

end.
