unit ufrmRefactorVariableRename;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormVariableRefactoringChoice = class(TForm)
    RadioGroup1: TRadioGroup;
    btOK: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetGroupOptions : TStrings;
    function GetResult : Integer;
    procedure SetOption(pIdx : Integer);
  end;



implementation

{$R *.dfm}

{ TFormVariableRefactoringChoice }


function TFormVariableRefactoringChoice.GetResult: Integer;
begin
   result:=RadioGroup1.ItemIndex;
end;

procedure TFormVariableRefactoringChoice.SetOption(pIdx: Integer);
begin
 RadioGroup1.ItemIndex:=pIdx;
end;

function TFormVariableRefactoringChoice.GetGroupOptions: TStrings;
begin
  result :=RadioGroup1.Items;
end;

end.
