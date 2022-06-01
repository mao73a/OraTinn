unit uPLSQLRefactor;

interface

uses
  sysutils, classes;

type
  TStructure = record
    name: string;
    rule: array[1..3] of Integer
  end;

  TLangStructure = record
    tokens: array[1..12] of string;
    structures: array[1..9] of TStructure
  end;

  TStructureElement = record
    token: Integer;
    nrLinii: Integer;
    tekst: string
  end;

  TBlock = record
    startPos, endPos: Integer;
    startStr, endStr: string;
    structureId: Integer;
  end;

  TBlocks = array[0..2048] of TBlock;

  TFoundResultBlocks = array of TBlock;

  TStrunctureElements = array of TStructureElement;

type
  TPLSRefactor = class(TPersistent)
  private
    fstos: array[0..1023] of TStructureElement;
    fEndTokenList: string;
    fFunctionIndexBuilt: Boolean;
    fFunctionIndex: array[0..1023] of Integer;
    fFunctionIndexCount: Integer;
    procedure BuildIndex;
  protected
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    fBlockCount: Integer;
    fStackSize: Integer;
    fBlocks: TBlocks;
    fFoundResultBlocks: TFoundResultBlocks;
    function CheckToken(p_token: string; var p_tokenId: Integer): Boolean;
    procedure PutToken(p_tokenId, p_nrLinii: Integer; p_tekst: string);
    procedure NewStructure;
    function isEmpty: Boolean;
    function FindCurrentBlock(ALine: Integer; var pBegin, pEnd: Integer): Boolean;
    function FindMatichngBlocks(ALine: Integer): Integer;
    function isTOken(pString: string): Boolean;
    procedure Clear;
    procedure CloseDoubleEndToken(var p_token: string; var ptokenId: Integer; p_Line: Integer);
    destructor Destroy; override;
    constructor Create;
    procedure OutputBlocks(var pOut: string);
    procedure OutputResultBlocks(var pOut: string);
  end;

const
  gLangStructures: TLangStructure = (
    tokens: ('PROCEDURE', 'FUNCTION', 'BEGIN', 'IF', 'LOOP', 'END', 'FOR', 'END IF', 'END LOOP', 'WHILE', 'CASE',
      'DECLARE');
    structures: ((
    name: 'function';
    rule: (2, 3, 6)
  ), (
    name: 'procedure';
    rule: (1, 3, 6)
  ), (
    name: 'declare-begin-end';
    rule: (12, 3, 6)
  ), (
    name: 'if';
    rule: (4, 0, 8)
  ), (
    name: 'begin-end';
    rule: (3, 0, 6)
  ), (
    name: 'for-loop';
    rule: (7, 5, 9)
  ), (
    name: 'while-loop';
    rule: (10, 5, 9)
  ), (
    name: 'loop';
    rule: (5, 0, 9)
  ), (
    name: 'when-case';
    rule: (11, 0, 6)
  ))
  );

implementation

procedure TPLSRefactor.CloseDoubleEndToken(var p_token: string; var ptokenId: Integer; p_Line: Integer);
begin
  if fStackSize > 0 then
  begin
    if gLangStructures.tokens[fStos[fStackSize - 1].token] = 'END' then
    begin
      if ((p_token = 'IF') or (p_token = 'LOOP')) and //end if, end loop
        (fStos[fStackSize - 1].nrLinii = p_Line) then
      begin
        p_token := 'END ' + p_token;
         //replace last token  (eg IF) with double token (END IF)
        Dec(fStackSize);
        CheckToken(p_token, ptokenId);
         //SetLength(fstos,Length(fstos)-1);
      end
    end;
  end;
end;

function TPLSRefactor.CheckToken(p_token: string; var p_tokenId: Integer): Boolean;
var
  v_i, v_badany, v_tokenId, vLastId: Integer;
  vToken: string;
begin
  v_i := 1;
  vToken := p_token;
  result := False;
  for v_badany := 1 to Length(gLangStructures.Tokens) do
  begin
    if gLangStructures.Tokens[v_badany] = vToken then
    begin
      p_tokenId := v_badany;
      result := True;
      break;
    end;
  end;
end;

procedure TPLSRefactor.PutToken(p_tokenId, p_nrLinii: Integer; p_tekst: string);
begin
// SetLength(fstos,Length(fstos)+1);
  if fStackSize < 1023 then
  begin
    Inc(fStackSize);
    fstos[fStackSize - 1].token := p_tokenId;
    fstos[fStackSize - 1].nrLinii := p_nrLinii;
    fstos[fStackSize - 1].tekst := p_tekst;
  end;
end;

procedure TPLSRefactor.NewStructure;
var
  v_nrStruktury: Integer;
  v_i: Integer;
  v_token: Integer;
  v_pozycjaStosu, vNewPos: Integer;
  v_rozmiarStruktury: Integer;
  vFound: Boolean;
begin
  //szukamy nowej struktuy na stosie
  for v_nrStruktury := 1 to Length(gLangStructures.Structures) do
  begin
    vFound := True;
    v_pozycjaStosu := fStackSize - 1;
    v_rozmiarStruktury := 0;
    for v_i := Length(gLangStructures.Structures[v_nrStruktury].rule) downto 1 do
    begin
      if v_pozycjaStosu = -1 then
      begin
        vFound := False;
        break;
      end;
      v_token := gLangStructures.Structures[v_nrStruktury].rule[v_i];
      if v_token = 0 then
        continue;
      if v_token <> fstos[v_pozycjaStosu].token then
      begin
        vFound := False;
        break;
      end;
      v_pozycjaStosu := v_pozycjaStosu - 1;
      v_rozmiarStruktury := v_rozmiarStruktury + 1;
    end; {for reguly}
    if vFound then
    begin
      //opisujemy strukture
      vNewPos := fBlockCount;
      Inc(fBlockCount);
      if fBlockCount > 2048 - 1 then
        raise Exception.Create('Stack size exceeded');

      fBlocks[vNewPos].startPos := fStos[fStackSize - v_rozmiarStruktury].nrLinii;
      fBlocks[vNewPos].startStr := fStos[fStackSize - v_rozmiarStruktury].tekst;
      fBlocks[vNewPos].endPos := fStos[fStackSize - 1].nrLinii;
      fBlocks[vNewPos].endStr := fStos[fStackSize - 1].tekst;
      fBlocks[vNewPos].structureId := v_nrStruktury;

      fStackSize := fStackSize - v_rozmiarStruktury;
      //SetLength(fStos,Length(fStos)-v_rozmiarStruktury);
      break;
    end; {if}
  end; {for struktury}
  fFunctionIndexBuilt := False;
end;

procedure TPLSRefactor.Clear;
begin
  fFunctionIndexBuilt := False;
  fFunctionIndexCount := 0;
  fStackSize := 0;
  fBlockCount := 0;
end;

function TPLSRefactor.isEmpty: Boolean;
begin
  if fStackSize = 0 then
    result := True
  else
    result := False;
end;

destructor TPLSRefactor.Destroy;
begin
  SetLength(fFoundResultBlocks, 0);
  Clear;
  inherited;
end;

constructor TPLSRefactor.Create;
var
  i: Integer;
  numOfRules: Integer;
begin
  inherited;
  fBlockCount := 0;
  fStackSize := 0;
  fFunctionIndexCount := 0;
  //remember list of ending tokens for further optimization
  for i := 1 to Length(gLangStructures.Structures) do
  begin
    numOfRules := Length(gLangStructures.Structures[i].rule);
    if pos(';' + gLangStructures.tokens[gLangStructures.Structures[i].rule[numOfRules]] + ';', ';' + fEndTokenList) = 0
      then
      fEndTokenList := fEndTokenList + gLangStructures.tokens[gLangStructures.Structures[i].rule[numOfRules]] + ';';
  end;
end;

procedure TPLSRefactor.Assign(Source: TPersistent);
var
  i: Integer;
begin
  fBlockCount := TPLSRefactor(Source).fBlockCount;
  for i := 0 to TPLSRefactor(Source).fBlockCount - 1 do
  begin
    fBlocks[i] := TPLSRefactor(Source).fBlocks[i];
  end;
  fFunctionIndexBuilt := False;
end;

procedure TPLSRefactor.AssignTo(Dest: TPersistent);
var
  i: Integer;
begin
  TPLSRefactor(Dest).fBlockCount := fBlockCount;
  for i := 0 to fBlockCount - 1 do
  begin
    TPLSRefactor(Dest).fBlocks[i] := fBlocks[i];
  end;
  fFunctionIndexBuilt := False;
end;

function TPLSRefactor.FindCurrentBlock(ALine: Integer; var pBegin, pEnd: Integer): Boolean;
var
  i, vNew, currFunction, matchedBlockId, vTmp: Integer;
begin
//  currFunction:=FindCurrentFunction(ALine, vTmp, vTmp);
  if currFunction = -1 then
    result := False
  else
  begin
    i := fFunctionIndex[currFunction];
    while (i >= 0) and (ALine <= fBlocks[i].endPos) do
    begin
      if (ALine >= fBlocks[i].startPos) and (ALine <= fBlocks[i].endPos) then
        matchedBlockId := i;
      dec(i);
    end;
    pBegin := fBlocks[matchedBlockId].startPos;
    pEnd := fBlocks[matchedBlockId].EndPos;
    result := True;
  end;
end;

procedure TPLSRefactor.BuildIndex;
var
  i, vNew: Integer;
begin
  if not fFunctionIndexBuilt then
  begin//build functions index
    fFunctionIndexCount := 0;
    for i := 0 to fBlockCount - 1 do
    begin
      if fBlocks[i].structureId in [1, 2, 3] then
      begin
        vNew := fFunctionIndexCount;
        if fFunctionIndexCount < 1023 then
          Inc(fFunctionIndexCount)
        else
          raise Exception.Create('Function index exceeded');
        //SetLength(fFunctionIndex,vNew+1);
        fFunctionIndex[vNew] := i;
      end;
    end;
    fFunctionIndexBuilt := True;
  end;
end;

function TPLSRefactor.isTOken(pString: string): Boolean;
var
  i: Integer;
begin
  result := False;
  if (pos('BEGIN', pString) <> 0) or (pos('END', pString) <> 0) or (pos('IF', pString) <> 0) or (pos('LOOP', pString) <>
    0) or (pos('ELSE', pString) <> 0) or (pos('ELSIF', pString) <> 0) or (pos('PROCEDURE', pString) <> 0) or (pos('FUNCTION',
    pString) <> 0) or (pos('EXCEPTION', pString) <> 0) or (pos('DECLARE', pString) <> 0) or (pos('CASE', pString) <> 0)
    then
    result := True;
end;

function TPLSRefactor.FindMatichngBlocks(ALine: Integer): Integer;
var
  i, j: Integer;
begin
  if not fFunctionIndexBuilt then
    BuildIndex;
  result := -1;
  //find current function
  SetLength(fFoundResultBlocks, 0);
  for i := 0 to fFunctionIndexCount - 1 do
  begin
    if (ALine >= fBlocks[fFunctionIndex[i]].startPos) and (ALine <= fBlocks[fFunctionIndex[i]].endPos) then
    begin
      j := Length(fFoundResultBlocks);
      SetLength(fFoundResultBlocks, j + 1);
      fFoundResultBlocks[j] := fBlocks[fFunctionIndex[i]];
    end;
  end;
  result := j;
end;

procedure TPLSRefactor.OutputBlocks(var pOut: string);
var
  i: Integer;
begin
  for i := 0 to fBlockCount - 1 do
  begin
    pOut := pOut + IntToStr(i) + ': ' + IntToStr(fBlocks[i].structureId) + ' start:' + IntToStr(fBlocks[i].startPos) +
      ' end:' + IntToStr(fBlocks[i].endPos) + #13#10;
  end;
end;

procedure TPLSRefactor.OutputResultBlocks(var pOut: string);
var
  i: Integer;
begin
  for i := 0 to Length(fFoundResultBlocks) - 1 do
  begin
    pOut := pOut + IntToStr(i) + ': ' + IntToStr(fFoundResultBlocks[i].structureId) + ' start:' + IntToStr(fFoundResultBlocks
      [i].startPos) + ' end:' + IntToStr(fFoundResultBlocks[i].endPos) + #13#10;
  end;
end;

end.

