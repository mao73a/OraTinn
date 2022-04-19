unit ufrmSynColor;

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
  StdCtrls, ExtCtrls, Buttons, ComCtrls, SynEdit, ColorGrd,
  SynEditHighlighter, SynHighlighterMulti, SynHighlighterPas;

type
  TdlgSynColor = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    GroupBox2: TGroupBox;
    lbHighlighters: TListBox;
    GroupBox3: TGroupBox;
    lbElements: TListBox;
    Label2: TLabel;
    cgColors: TColorGrid;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    cbTextBold: TCheckBox;
    cbTextItalics: TCheckBox;
    cbTextUnderline: TCheckBox;
    GroupBox4: TGroupBox;
    synSample: TSynEdit;
    BitBtn3: TBitBtn;
    ColorDialog: TColorDialog;
    edColor: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure lbHighlightersClick(Sender: TObject);
    procedure lbElementsClick(Sender: TObject);
    procedure ElementChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    //PascalString : string;
    sampleMulti : TSynMultiSyn;
    sampleCustom : TSynCustomHighlighter;
    procedure SetElementStyle;
    procedure SaveColors;
  public
    { Public declarations }
  end;

var
  dlgSynColor: TdlgSynColor;


implementation

uses uDMSyn, ufrmMain;

{$R *.DFM}

const ASP_STRING = '<%' + #13#10 +
      ''' Syntax highlighting' + #13#10 +
      'function printNumber()' + #13#10 +
      'number = 1234' + #13#10 +
      'response.write "The number is " & number' + #13#10 +
      'for i = 0 to number' + #13#10 +
      '  x = x + 1' + #13#10 +
      'next' + #13#10 +
      'end function' + #13#10 +
      '%>';

procedure TdlgSynColor.FormCreate(Sender: TObject);
var
	j, i : integer;
  tmpName : string;
begin
	sampleMulti := TSynMultiSyn.Create(self);
  sampleCustom := TSynCustomHighlighter.Create(self);
	// Load the highligher names into the list box
  for j := 0 to dmSyn.ComponentCount - 1 do
	begin
		if not (dmSyn.Components[j] is TSynCustomHighlighter) then
    	continue;
   	tmpName := (dmSyn.Components[j] as TSynCustomHighlighter).GetLanguageName;
   	if (tmpName <> 'General Multi-Highlighter') then
   	begin
    	if (tmpName = 'Java') then
      begin
      	if ((dmSyn.Components[j] as TSynCustomHighlighter).Name = 'SynCSharp') then
        	tmpName := 'C Sharp';
      end;
    	lbHighlighters.Items.Add(tmpName);
   	end
    else
    begin
    	tmpName := (dmSyn.Components[j] as TSynMultiSyn).DefaultLanguageName;
      lbHighlighters.Items.Add(tmpName);
    end;

  end;
  lbHighlighters.Sorted := true;
  lbHighlighters.ItemIndex := 0;

  //if (frmTinnMain.MDIChildCount > 0) then
  //begin
  	tmpName := frmTinnMain.cbSyntax.Items[frmTinnMain.cbSyntax.ItemIndex]; // (frmTinnMain.MDIChildren[frmTinnMain.FindTopWindow] as tfrmEditor).synEditor.Highlighter.GetLanguageName;
  	for i := 0 to (lbHighlighters.Items.Count - 1) do
  	begin
  		if tmpName = lbHighlighters.Items.Strings[i] then
    		lbHighlighters.ItemIndex := i;
  	end;
  //end;

  lbHighlightersClick(self);
end;

procedure TdlgSynColor.lbHighlightersClick(Sender: TObject);
var
	i, j, k : integer;
  HighlighterName : string;
  tmpName : string;
  intHighlighterID : integer;
begin
	dmSyn.LoadSyntaxColors;
	lbElements.Clear;
  intHighlighterID := -1;
	for i:= 0 to (lbHighlighters.Items.Count - 1) do
  begin
  	if lbHighlighters.Selected[i] then
    begin
    	HighlighterName := lbHighlighters.Items.Strings[i];
    end;	// end active item
  end;	// end list box loop
  for j := 0 to dmSyn.ComponentCount - 1 do
  begin
    if not (dmSyn.Components[j] is TSynCustomHighlighter) then
      continue;
    tmpName := (dmSyn.Components[j] as TSynCustomHighlighter).GetLanguageName;
    if (tmpName = 'Java') then
    begin
      if ((dmSyn.Components[j] as TSynCustomHighlighter).Name = 'SynCSharp') then
        tmpName := 'C Sharp';
    end;
    if (tmpName = 'General Multi-Highlighter') then
    	tmpName := (dmSyn.Components[j] as TSynMultiSyn).DefaultLanguageName;
    if (tmpName = HighlighterName) then
    begin
      intHighlighterID := j;
      for k := 0 to (dmSyn.Components[j] as TSynCustomHighlighter).AttrCount - 1 do
      begin
        if ((dmSyn.Components[j] as TSynCustomHighlighter).Attribute[k].Name <> '') then
          lbElements.Items.Add((dmSyn.Components[j] as TSynCustomHighlighter).Attribute[k].Name);
      end;

    end;
  end;	// end dmSyn loop
  if intHighlighterID > -1 then
  begin

  	if ((dmSyn.Components[intHighlighterID] as TSynCustomHighlighter).GetLanguageName = 'General Multi-Highlighter') then
    begin
      if (HighlighterName = 'ASP') then
        synSample.Lines.Text := ASP_STRING;
      if (HighlighterName = 'ASP.net') then
        synSample.Lines.Text := dmSyn.SynVBScript.SampleSource;
      if (HighlighterName = 'HTMLComplex') then
        synSample.Lines.Text := dmSyn.SynHTML.SampleSource;
      if (synSample.Lines.Count = 0) then
        synSample.Lines.Text := dmSyn.SynPas.SampleSource;
      //ShowMessage(HighlighterName);
      sampleMulti := (dmSyn.Components[intHighlighterID] as TSynMultiSyn);
  		synSample.Highlighter := sampleMulti;

    end
  	else
    begin
      synSample.Highlighter := nil;
    	{if (HighlighterName = 'Cascading style sheets') then
      begin
      	PascalString := synSample.Lines.Text;
      	synSample.Lines.Text := CSS_STRING;
      end
      else
      begin
      	if (length(PascalString) > 0) then
      		synSample.Lines.Text := PascalString;
      end; }
      synSample.Lines.Text := (dmSyn.Components[intHighlighterID] as TSynCustomHighlighter).SampleSource;
      if (synSample.Lines.Count = 0) then
        synSample.Lines.Text := dmSyn.SynPas.SampleSource;
      sampleCustom := (dmSyn.Components[intHighlighterID] as TSynCustomHighlighter);
      synSample.Highlighter := sampleCustom;

    end;
    lbElements.ItemIndex := 0;
  	SetElementStyle;
    //dmSyn.LoadSyntaxColors;
  end;
  //lbElements.Sorted := true;
  SaveColors;
end;


procedure TdlgSynColor.SetElementStyle;
var
  tmpColor: TColor;
begin
  with synSample.Highlighter do
  begin
    tmpColor := Attribute[lbElements.ItemIndex].Foreground;

    if tmpColor = clNone then
      cgColors.ForegroundIndex := 0
    else
      cgColors.ForegroundIndex := cgColors.ColorToIndex(tmpColor);

    tmpColor := Attribute[lbElements.ItemIndex].Background;
    if cgColors.ColorToIndex(tmpColor)=-1 then
    begin
       edColor.Color:=tmpColor;
       cgColors.BackgroundIndex := 15;
    end
    else
    begin
      if tmpColor = clNone then
        cgColors.BackgroundIndex := 15
      else
        cgColors.BackgroundIndex := cgColors.ColorToIndex(tmpColor);
    end;

    cbTextBold.Checked := (fsBold in Attribute[lbElements.ItemIndex].Style);

    cbTextItalics.Checked := (fsItalic in Attribute[lbElements.ItemIndex].Style);

    cbTextUnderline.Checked := (fsUnderline in Attribute[lbElements.ItemIndex].Style);

  end;

end;

procedure TdlgSynColor.lbElementsClick(Sender: TObject);
begin
	SetElementStyle;
end;


procedure TdlgSynColor.ElementChange(Sender: TObject);
var
  Attr: TSynHighlighterAttributes;
  AttrStyle: TFontstyles;
begin
  if (lbHighlighters.ItemIndex >= 0) then
  begin
    Attr := TSynHighlighterAttributes.Create(lbElements.Items[lbElements.ItemIndex]);
    try
      AttrStyle := [];
      Attr.ForegRound := cgColors.ForegroundColor;
      Attr.BackGround := cgColors.BackGroundColor;
      if cbTextBold.Checked then
        Include(AttrStyle, FsBold);
      if cbTextItalics.Checked then
        Include(AttrStyle, FsItalic);
      if cbTextUnderLine.Checked then
        Include(AttrStyle, FsUnderLine);
      Attr.Style := AttrStyle;
      synSample.Highlighter.Attribute[lbElements.ItemIndex].Assign(Attr);
    finally
      Attr.Free;
    end;
  end;

end;

procedure TdlgSynColor.BitBtn1Click(Sender: TObject);
begin
	SaveColors;
end;

procedure TdlgSynColor.SaveColors;
var
	LanguageName : string;
begin
	LanguageName := synSample.Highlighter.GetLanguageName;
  if (LanguageName = 'C/C++') then
    LanguageName := 'C++';
	synSample.Highlighter.SaveToFile(LanguageName + '.ini');
end;

procedure TdlgSynColor.BitBtn3Click(Sender: TObject);
begin
	dmSyn.LoadSyntaxColors;
end;

procedure TdlgSynColor.Panel2Click(Sender: TObject);
begin
   ColorDialog.Color := edColor.Color;
  if (ColorDialog.Execute) then
    edColor.Color := ColorDialog.Color;
end;

procedure TdlgSynColor.Button1Click(Sender: TObject);
var i : Integer;
begin
  for i:=0 to lbElements.Items.Count-1 do
   with synSample.Highlighter do
   begin
     Attribute[i].Background:=edColor.Color;
   end;
end;

end.
