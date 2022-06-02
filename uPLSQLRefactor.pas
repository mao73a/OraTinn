unit uPLSQLRefactor;

interface

uses
  sysutils, classes, SynEditTypes, regularExpressions;

type
  TStructure = record
    name: string;
    rule: array[1..3] of Integer
  end;

  TLangStructure = record
    tokens: array[1..13] of string;
    structures: array[1..10] of TStructure
  end;

  TStructureElement = record
    token: Integer;
    tokenPos: TBufferCoord;
    tekst: string;
    nrTokena : Integer
  end;

  TBlock = record
    startPos, endPos: TBufferCoord;
    startTokenNr, endTokenNr : Integer;
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
    function StackString(pStartIdx : Integer) : String;
    function StartingTokenRulePattern(pToken : Integer) : String;
    procedure RemoveFromStack(pStackIdx : Integer);
  protected
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    fBlockCount: Integer;
    fStackSize: Integer;
    fBlocks: TBlocks;
    fFoundResultBlocks: TFoundResultBlocks;
    function CheckToken(p_token: string; var p_tokenId: Integer): Boolean;
    procedure PutToken(p_tokenId : Integer; p_TokenPos: TBufferCoord; p_tekst: string; p_nrTokena : Integer);
    procedure NewStructure;
    function isEmpty: Boolean;
    function FindCurrentBlock(ALine: Integer; var pBegin, pEnd: Integer): Boolean;
    function FindMatichngBlocks(ALine: Integer): Integer;

    procedure Clear;
    procedure CloseDoubleEndToken(var p_token: string; var ptokenId: Integer; p_TokenPos: TBufferCoord);
    destructor Destroy; override;
    constructor Create;
    procedure OutputBlocks(var pOut: string);
    procedure OutputResultBlocks(var pOut: string);
    function RemoveUnrecognizedStructures : String;
  end;

const
  gLangStructures: TLangStructure = (
    tokens: ('PROCEDURE', 'FUNCTION', 'BEGIN', 'IF', 'LOOP', 'END', 'FOR', 'END IF', 'END LOOP', 'WHILE', 'CASE',
      'DECLARE','PACKAGE');
    structures: (
    (
    name: 'package-end';
    rule: (13, 0, 6)
   ), (
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
  )
  )
  );

implementation

procedure TPLSRefactor.CloseDoubleEndToken(var p_token: string; var ptokenId: Integer; p_TokenPos: TBufferCoord);
begin
  if fStackSize > 0 then
  begin
    if gLangStructures.tokens[fStos[fStackSize - 1].token] = 'END' then
    begin
      if ((p_token = 'IF') or (p_token = 'LOOP')) and //end if, end loop
        (fStos[fStackSize - 1].tokenPos.Line = p_TokenPos.Line) then
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

procedure TPLSRefactor.PutToken(p_tokenId : Integer; p_TokenPos: TBufferCoord; p_tekst: string; p_nrTokena : Integer);
begin
// SetLength(fstos,Length(fstos)+1);
  if fStackSize < 1023 then
  begin
    Inc(fStackSize);
    fstos[fStackSize - 1].token := p_tokenId;
    fstos[fStackSize - 1].tokenPos := p_TokenPos;
    fstos[fStackSize - 1].tekst := p_tekst;
    fstos[fStackSize - 1].nrTokena := p_nrTokena;

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

      fBlocks[vNewPos].startPos := fStos[fStackSize - v_rozmiarStruktury].tokenPos;
      fBlocks[vNewPos].startStr := fStos[fStackSize - v_rozmiarStruktury].tekst;
      fBlocks[vNewPos].startTokenNr := fStos[fStackSize - v_rozmiarStruktury].nrTokena;
      fBlocks[vNewPos].endPos := fStos[fStackSize - 1].tokenPos;
      fBlocks[vNewPos].endStr := fStos[fStackSize - 1].tekst;
      fBlocks[vNewPos].endTokenNr := fStos[fStackSize - 1].nrTokena;
      fBlocks[vNewPos].structureId := v_nrStruktury;

      fStackSize := fStackSize - v_rozmiarStruktury;
      //SetLength(fStos,Length(fStos)-v_rozmiarStruktury);
      break;
    end; {if}
  end; {for struktury}
  fFunctionIndexBuilt := False;
end;

{
function TPLSRefactor.CanStructureBeMatched(pStackPos, pStructureNr : Integer
procedure TPLSRefactor.RemoveUnrecognizedStructures;
var
 vLoopNumber, vStosIdx, v_nrStruktury, vToken, v_i : Integer;
begin
  vLoopNumber:=1;
  while fStackSize>0 do
  begin
    for vStosIdx := 0 to fStackSize-1 do
    begin
      vToken := fStos[vStosIdx].token;
      for v_nrStruktury := 1 to Length(gLangStructures.Structures) do
      begin
       for v_i := 1 to Length(gLangStructures.Structures[v_nrStruktury].rule) do
       begin
         if gLangStructures.Structures[v_nrStruktury].rule[v_i]=vToken then
         begin

         end;

       end;

      end;
    end;


    Inc(vLoopNumber);
    if vLoopNumber >100 then exit;
  end;
end;
}

function TPLSRefactor.StackString(pStartIdx : Integer) : String;
var
 vI : Integer;
begin
  if (pStartIdx<0) or (pStartidx>fStackSize-1) then
  begin
    raise Exception.Create('blad w StackString; pStartIdx='+IntToStr(pStartIdx));
  end;

  result:='';
  for vI := pStartIdx to fStackSize-1 do
  begin
    result:=result+','+IntToStr(fStos[vI].token)+',';
  end;
end;


function TPLSRefactor.StartingTokenRulePattern(pToken : Integer) : String;
var
  vStrctIdx,  vI : Integer;
begin
   result:='';
   for vStrctIdx := 1 to Length(gLangStructures.Structures) do
   begin
     if gLangStructures.Structures[vStrctIdx].rule[1]=pToken then
     begin
       for vI := 1 to Length(gLangStructures.Structures[vStrctIdx].rule) do
       begin
         if gLangStructures.Structures[vStrctIdx].rule[vI]<>0 then
           result:=result+'.*,'+IntToStr(gLangStructures.Structures[vStrctIdx].rule[vI])+',.*';
       end;
     end;
   end;
end;

procedure TPLSRefactor.RemoveFromStack(pStackIdx : Integer);
var
  vI : Integer;
begin
  if (pStackIdx>fStackSize-1) or (pStackIdx<0) then
    exit;
  for vI := pStackIdx+1 to fStackSize-1 do
  begin
    fStos[vI-1]:=fStos[vI];
  end;
  Dec(fStackSize);

end;

function TPLSRefactor.RemoveUnrecognizedStructures : String;
var
  vStackString, vStrctPattern : String;
  vI, vToken, vTokenIdx : Integer;
  vOrgStackSize : Integer;
begin
   vOrgStackSize:=fStackSize;
   for vI := 0 to vOrgStackSize-1 do
   begin
     vTokenIdx:=vOrgStackSize-vI-1;
     vToken:=fStos[vTokenIdx].token;
     vStackString:=StackString(vTokenIdx);
     vStrctPattern := StartingTokenRulePattern(vToken);
     if vStrctPattern<>'' then
     begin
       if not TRegEx.IsMatch(vStackString, vStrctPattern) then
       begin
          RemoveFromStack(vTokenIdx);
       end;
     end;
   end;
   for vI := 1 to fStackSize do
    try
      NewStructure;
    except
    end;
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
    while (i >= 0) and (ALine <= fBlocks[i].endPos.Line) do
    begin
      if (ALine >= fBlocks[i].startPos.Line) and (ALine <= fBlocks[i].endPos.Line) then
        matchedBlockId := i;
      dec(i);
    end;
    pBegin := fBlocks[matchedBlockId].startPos.Line;
    pEnd := fBlocks[matchedBlockId].EndPos.Line;
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
      if fBlocks[i].structureId in [1, 2, 3, 4] then
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
    if (ALine >= fBlocks[fFunctionIndex[i]].startPos.Line) and (ALine <= fBlocks[fFunctionIndex[i]].endPos.Line) then
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
    pOut := pOut + IntToStr(i) + ': ' + IntToStr(fBlocks[i].structureId) + ' start:' + IntToStr(fBlocks[i].startPos.Line) +
      ' end:' + IntToStr(fBlocks[i].endPos.Line) + #13#10;
  end;
end;

procedure TPLSRefactor.OutputResultBlocks(var pOut: string);
var
  i: Integer;
begin
  for i := 0 to Length(fFoundResultBlocks) - 1 do
  begin
    pOut := pOut + IntToStr(i) + ': ' + IntToStr(fFoundResultBlocks[i].structureId) + ' start:' + IntToStr(fFoundResultBlocks
      [i].startPos.Line) + ' end:' + IntToStr(fFoundResultBlocks[i].endPos.Line) + #13#10;
  end;
end;

end.

