unit utypesE;

interface

uses Sysutils,dialogs, classes, forms, dbgrids,controls;

type
  CException = class(Exception)
  private
    FNum: Integer;
    history : TStrings;
    procedure AddToHistory(pDescription : String);
  public
    constructor Create(const pDescription: string; pNumber: Integer;
                       AOwner : TObject);overload;
    destructor Destroy;override;
    function ReadHistory : TStrings;
  published
    property Num: Integer read FNum write FNum;
  end;


implementation
{ CException }

constructor CException.Create(const pDescription: string; pNumber: Integer;
                       AOwner : TObject);
begin
  inherited Create(pDescription);
  FNum := pNumber;
  history:=TStringList.Create;
  if assigned(AOwner) then
  begin
    if (AOwner is TComponent) then
      AddToHistory(AOwner.ClassName+'('+TComponent(AOwner).Name+')-'+pDescription)
    else if (AOwner is TForm) then
      AddToHistory(AOwner.ClassName+'('+TForm(AOwner).Name+')-'+pDescription)
    else
      AddToHistory(AOwner.ClassName+'(?)-'+pDescription);
  end
  else
    AddToHistory(pDescription);
end;

destructor CException.Destroy;
begin
  inherited;
  history.Free;
end;

procedure CException.AddToHistory(pDescription : String);
begin
  if ExceptObject<>nil then
  begin
    if ExceptObject.Classname='CException' then
      history.AddStrings((ExceptObject as CException).ReadHistory)
    else //ExceptObject.Classname='Exception'
      history.Add((ExceptObject as Exception).message);
  end;
  history.Add(pDescription);
end;


function CException.ReadHistory : TStrings;
begin
   result := history;
end;

end.

