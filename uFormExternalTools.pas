unit uFormExternalTools;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  { interposer class adding an OnCloseUp event }
  TComboBox = class(StdCtrls.TComboBox)
  private
    FOnCloseUp : TNotifyEvent;
  protected
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure DoCloseUp;
  published
    property OnCloseUp : TNotifyEvent
      read FOnCloseUp write FOnCloseUp;
  end;

  TFormExternalTools = class(TForm)
    edCommand: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    edName: TComboBox;
    Button2: TButton;
    Button3: TButton;
    Label7: TLabel;
    btCancel: TButton;
    procedure FormActivate(Sender: TObject);
    procedure edNameCloseUp(Sender: TObject);
  private
    { Private declarations }
    fActions : TStrings;
  public
    { Public declarations }
    fLastPos : Integer;    
    procedure Add(Name, Action : String);
    constructor Create(AOwner : TComponent);override;
    destructor Destroy;override;
  end;


implementation

{$R *.DFM}

{ TFormExternalTools }

procedure TFormExternalTools.Add(Name, Action: String);
begin
  edName.Items.Add(Name);
  fActions.Add(Action);
end;

constructor TFormExternalTools.Create(AOwner: TComponent);
begin
  inherited;
  fActions:=TStringList.Create;
  edName.OnCloseUp := edNameCloseUp;
end;

destructor TFormExternalTools.Destroy;
begin
  fActions.free;
  inherited;
end;

procedure TFormExternalTools.FormActivate(Sender: TObject);
begin
  edName.ItemIndex:=0;
  fLastPos:=edName.ItemIndex;
  edNameCloseUp(nil);
end;


procedure TFormExternalTools.edNameCloseUp(Sender: TObject);
begin
  if fActions.Count>0 then  edCommand.Text:=fActions[edName.ItemIndex];
  fLastPos:=edName.ItemIndex;  
end;

{ TComboBox }

procedure TComboBox.CNCommand(var Message: TWMCommand);
begin
  case Message.NotifyCode of
    CBN_CLOSEUP : DoCloseUp;
    else
      inherited;
  end;
end;

procedure TComboBox.DoCloseUp;
begin
  if Assigned(FOnCloseUp) then
    FOnCloseUp(self);
end;


end.
