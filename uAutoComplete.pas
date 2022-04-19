unit uAutoComplete;

interface
uses classes, SynEdit, StdCtrls,SynEditKeyCmds,SynEditAutoComplete;

type
 TOraTinnAutoComp = class(TObject)
   private
    { Private declarations }
    fAutoComplete : TSynAutoComplete;
    FEditor: TCustomSynEdit;
    procedure SetEditor(const Value: TCustomSynEdit);
   public
    property Editor : TCustomSynEdit read FEditor write SetEditor;
    constructor Create(AOwner : TComponent; AEditor : TCustomSynEdit; AFile:String);
    destructor Destroy;

  end;
implementation

constructor  TOraTinnAutoComp.Create(AOwner : TComponent; AEditor : TCustomSynEdit; AFile:String);
begin
  inherited Create;
  fAutoComplete := TSynAutoComplete.Create(AOwner);
  fAutoComplete.Editor := AEditor;
  fAutoComplete.AutoCompleteList.LoadFromFile(AFile);
end;


destructor TOraTinnAutoComp.Destroy;
begin
  fAutoComplete.Free;
end;

procedure TOraTinnAutoComp.SetEditor(const Value: TCustomSynEdit);
begin
  FEditor := Value;
  fAutoComplete.Editor := FEditor;
end;

end.
