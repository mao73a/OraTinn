unit uDMSyn;

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
  SynHighlighterJava, SynHighlighterGeneral, SynEditHighlighter,
  SynHighlighterCpp, SynHighlighterPas, SynHighlighterIni,
  SynHighlighterPerl, SynHighlighterCss, SynHighlighterSQL,
  SynHighlighterJScript, SynHighlighterHTML, SynHighlighterVBScript,
  SynHighlighterPHP, SynHighlighterMulti, SynHighlighterXML,
  SynHighlighterAsm, SynHighlighterCS, SynHighlighterPython;

type
  TdmSyn = class(TDataModule)
    SynPas: TSynPasSyn;
    SynHTML: TSynHTMLSyn;
    SynJScript: TSynJScriptSyn;
    SynSQL: TSynSQLSyn;
    SynPerl: TSynPerlSyn;
    SynCpp: TSynCppSyn;
    SynJava: TSynJavaSyn;
    SynIni: TSynIniSyn;
    SynGeneralSyn1: TSynGeneralSyn;
    SynPHPsimple: TSynPHPSyn;
    SynVBScript: TSynVBScriptSyn;
    SynASP: TSynMultiSyn;
    SynASPNET: TSynMultiSyn;
    SynHTMLComplex: TSynMultiSyn;
    SynCss: TSynCssSyn;
    SynXML: TSynXMLSyn;
    SynAsmSyn: TSynAsmSyn;
    SynCS: TSynCSSyn;
    SynPHPcomplex: TSynMultiSyn;
    SynPythonSyn1: TSynPythonSyn;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    boolLoadedFileFromStartUp : boolean;
    procedure LoadSyntaxColors;
  end;

var
  dmSyn: TdmSyn;

implementation

{$R *.DFM}

procedure TdmSyn.DataModuleCreate(Sender: TObject);
begin
	LoadSyntaxColors;
end;

procedure TdmSyn.LoadSyntaxColors;
var
	i : integer;
 	LanguageName : string;
begin
	// Load any colors
	for i := 0 to ComponentCount - 1 do
	begin
  	if not (Components[i] is TSynCustomHighlighter) then
    	continue;
   	LanguageName := (Components[i] as TSynCustomHighlighter).GetLanguageName;
    //if FileExists(LanguageName + '.ini') then
  		(Components[i] as TSynCustomHighlighter).LoadFromFile(LanguageName + '.ini');
   	if (LanguageName = 'General Multi-Highlighter') then
  	begin
    	LanguageName := (Components[i] as TSynMultiSyn).DefaultLanguageName;
      //if FileExists(LanguageName + '.ini') then
  			(Components[i] as TSynMultiSyn).LoadFromFile(LanguageName + '.ini');
  	end;

 	end;
end;

end.
