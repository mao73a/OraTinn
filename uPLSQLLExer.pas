unit uPLSQLLexer;

interface
uses sysutils, classes;


type
  TStructure = record
   name : String;
   rule : Array[1..3] of Integer
  end;

 TLangStructure = record
   tokens : Array[1..12] of String;
   structures : Array[1..9] of TStructure
 end;

 TStructureElement=record
   token : Integer;
   nrLinii : Integer;
   tekst : String
  end;

 TBlock = record
   startPos, endPos : Integer;
   startStr, endStr : String;
   structureId : Integer;
  end;

 TBlocks = Array[0..2048] of TBlock;

 TStrunctureElements = Array of TStructureElement;

type TPLSLexer = class(TPersistent)
  private
    fstos : Array[0..1023] of TStructureElement;
    fEndTokenList : String;
    fFunctionIndexBuilt : Boolean;
    fFunctionIndex : Array[0..1023] of Integer;
    fFunctionIndexCount : Integer;
    procedure BuildIndex;
  protected
    procedure Assign(Source: TPersistent);override;
    procedure AssignTo(Dest : TPersistent);override;
  public
    fBlockCount : Integer;
    fStackSize : Integer;
    fBlocks : TBlocks;
  
    function CheckToken(p_token : String; var p_tokenId : Integer) : Boolean;
    procedure PutToken(p_tokenId,p_nrLinii : Integer; p_tekst:String);
    procedure NewStructure;
    function isEmpty : Boolean;
    function FindCurrentBlock(ALine : Integer; var pBegin, pEnd : Integer) : Boolean;
    function FindCurrentFunction(ALine : Integer; var pBegin, pEnd : Integer) : Integer;
    function isTOken(pString : String):Boolean;
    procedure Clear;
    procedure CloseDoubleEndToken(var p_token : String; var ptokenId : Integer;
        p_Line : Integer);
    destructor Destroy;override;
    constructor Create;

end;

const gLangStructures : TLangStructure =
  (tokens:('PROCEDURE','FUNCTION','BEGIN','IF','LOOP','END','FOR','END IF','END LOOP','WHILE','CASE','DECLARE');
   structures:((name:'function';rule:(2,3,6)),
              (name:'procedure';rule:(1,3,6)),
              (name:'declare-begin-end';rule:(12,3,6)),
              (name:'if';       rule:(4,0,8)),
              (name:'begin-end';rule:(3,0,6)),
              (name:'for-loop'; rule:(7,5,9)),
              (name:'while-loop';rule:(10,5,9)),
              (name:'loop';     rule:(5,0,9)),
              (name:'when-case';  rule:(11,0,6))
             )
   );
implementation

procedure TPLSLexer.CloseDoubleEndToken(var p_token : String; var ptokenId : Integer;
    p_Line : Integer);
begin
  if fStackSize>0 then begin
    if gLangStructures.tokens[fStos[fStackSize-1].token ]='END' then begin
      if ((p_token ='IF') or (p_token ='LOOP')) and //end if, end loop
         (fStos[fStackSize-1].nrLinii=p_Line) then begin
         p_token:='END '+p_token;
         //replace last token  (eg IF) with double token (END IF)
         Dec(fStackSize);
         CheckToken(p_token, ptokenId);
         //SetLength(fstos,Length(fstos)-1);
      end
    end;
  end;
end;

function TPLSLexer.CheckToken(p_token : String; var p_tokenId : Integer) : Boolean;
var
  v_i, v_badany, v_tokenId, vLastId : Integer;
  vToken : String;
begin
  v_i:=1;
  vToken:=p_token;
  result:=False;
  for v_badany:=1 to Length(gLangStructures.Tokens) do begin
    if gLangStructures.Tokens[v_badany]=vToken then
    begin
      p_tokenId:=v_badany; result:=True; break;
    end;
  end;
end;

procedure TPLSLexer.PutToken(p_tokenId,p_nrLinii : Integer; p_tekst:String );
begin
// SetLength(fstos,Length(fstos)+1);
 if fStackSize<1023 then begin
   Inc(fStackSize);
   fstos[fStackSize-1].token:=p_tokenId;
   fstos[fStackSize-1].nrLinii:=p_nrLinii;
   fstos[fStackSize-1].tekst:=p_tekst;
 end;
end;

procedure TPLSLexer.NewStructure;
var
 v_nrStruktury : Integer;
 v_i : Integer;
 v_token : Integer;
 v_pozycjaStosu, vNewPos : Integer;
 v_rozmiarStruktury : Integer;
 vFound : Boolean;
begin
  //szukamy nowej struktuy na stosie
  for v_nrStruktury:=1 to Length(gLangStructures.Structures) do
  begin
    vFound:=True;
    v_pozycjaStosu:=fStackSize-1;
    v_rozmiarStruktury:=0;
    for v_i:=Length(gLangStructures.Structures[v_nrStruktury].rule) downto 1 do
    begin
      if v_pozycjaStosu=-1 then
      begin
        vFound:=False; break;
      end;
      v_token:=gLangStructures.Structures[v_nrStruktury].rule[v_i];
      if v_token=0 then continue;
      if v_token<>fstos[v_pozycjaStosu].token then
      begin
        vFound:=False; break;
      end;
      v_pozycjaStosu:=v_pozycjaStosu-1;
      v_rozmiarStruktury:=v_rozmiarStruktury+1;
    end;{for reguly}
    if vFound then
    begin
      //opisujemy strukture
      vNewPos:=fBlockCount;
      Inc(fBlockCount);
      if fBlockCount>2048-1 then
        raise Exception.Create('Stack size exceeded');

      fBlocks[vNewPos].startPos:=fStos[fStackSize-v_rozmiarStruktury].nrLinii;
      fBlocks[vNewPos].startStr:=fStos[fStackSize-v_rozmiarStruktury].tekst;
      fBlocks[vNewPos].endPos:=fStos[fStackSize-1].nrLinii;
      fBlocks[vNewPos].endStr:=fStos[fStackSize-1].tekst;
      fBlocks[vNewPos].structureId:=v_nrStruktury;

      fStackSize:=fStackSize-v_rozmiarStruktury;
      //SetLength(fStos,Length(fStos)-v_rozmiarStruktury);
      break;
    end;{if}
   end;{for struktury}
   fFunctionIndexBuilt:=False;
end;

procedure TPLSLexer.Clear;
begin
  fFunctionIndexBuilt:=False;
  fFunctionIndexCount:=0;
  fStackSize:=0;
  fBlockCount:=0;
end;

function TPLSLexer.isEmpty: Boolean;
begin
  if fStackSize=0 then result:=True
  else result:=False;
end;

destructor TPLSLexer.Destroy;
begin
  Clear;
  inherited;
end;

constructor TPLSLexer.Create;
var
 i : Integer;
 numOfRules : Integer;
begin
  inherited;
  fBlockCount:=0;
  fStackSize:=0;
  fFunctionIndexCount:=0;
  //remember list of ending tokens for further optimization
  for i:=1 to Length(gLangStructures.Structures) do begin
    numOfRules:=Length(gLangStructures.Structures[i].rule);
    if pos(';'+gLangStructures.tokens[gLangStructures.Structures[i].rule[
          numOfRules]]+';',';'+fEndTokenList)=0 then
      fEndTokenList:=fEndTokenList+
        gLangStructures.tokens[
           gLangStructures.Structures[i].rule[numOfRules]]+';';
  end;
end;

procedure TPLSLexer.Assign(Source: TPersistent);
var
 i : Integer;
begin
  fBlockCount:=TPLSLexer(Source).fBlockCount;
  for i:=0 to TPLSLexer(Source).fBlockCount-1 do begin
    fBlocks[i] := TPLSLexer(Source).fBlocks[i];
  end;
  fFunctionIndexBuilt:=False;
end;

procedure TPLSLexer.AssignTo(Dest: TPersistent);
var
 i : Integer;
begin
  TPLSLexer(Dest).fBlockCount:=fBlockCount;
  for i:=0 to fBlockCount-1 do begin
    TPLSLexer(Dest).fBlocks[i] := fBlocks[i];
  end;
  fFunctionIndexBuilt:=False;
end;


function TPLSLexer.FindCurrentBlock(ALine: Integer; var pBegin,
  pEnd: Integer): Boolean;
var
 i, vNew, currFunction, matchedBlockId, vTmp : Integer;
begin
  {if not fFunctionIndexBuilt then BuildIndex;
  currFunction:=-1;
  //find current function
  for i:=0 to fFunctionIndexCount-1 do begin
    if (ALine>=fBlocks[fFunctionIndex[i]].startPos) and
       (ALine<=fBlocks[fFunctionIndex[i]].endPos) then begin
      currFunction:=i;
      break;
    end;
  end;}
  currFunction:=FindCurrentFunction(ALine, vTmp, vTmp);
  if currFunction=-1 then result:=False
  else begin
    i:=fFunctionIndex[currFunction];
    while (i>=0) and (ALine<=fBlocks[i].endPos) do begin
      if (ALine>=fBlocks[i].startPos) and (ALine<=fBlocks[i].endPos) then
        matchedBlockId:=i;
      dec(i);
    end;
    pBegin:=fBlocks[matchedBlockId].startPos;
    pEnd:=fBlocks[matchedBlockId].EndPos;
    result:=True;
  end;
end;

procedure TPLSLexer.BuildIndex;
var i,vNew : Integer;
begin
  if not fFunctionIndexBuilt then begin//build functions index
    fFunctionIndexCount:=0;
    for i:=0 to fBlockCount-1 do begin
      if fBlocks[i].structureId in [1,2] then begin
        vNew:=fFunctionIndexCount;
        if fFunctionIndexCount<1023 then
          Inc(fFunctionIndexCount)
        else
          raise Exception.Create('Function index exceeded');
        //SetLength(fFunctionIndex,vNew+1);
        fFunctionIndex[vNew]:=i;
      end;
    end;
    fFunctionIndexBuilt:=True;
  end;
end;

function TPLSLexer.isTOken(pString: String): Boolean;
var i : Integer;
begin
  result:=False;
  if (pos('BEGIN',pString)<>0) or
     (pos('END',pString)<>0) or
     (pos('IF',pString)<>0) or
     (pos('LOOP',pString)<>0) or
     (pos('ELSE',pString)<>0) or
     (pos('ELSIF',pString)<>0) or
     (pos('PROCEDURE',pString)<>0) or
     (pos('FUNCTION',pString)<>0) or
     (pos('EXCEPTION',pString)<>0) or
     (pos('DECLARE',pString)<>0) or
     (pos('CASE',pString)<>0)  then
    result:=True;
end;

function TPLSLexer.FindCurrentFunction(ALine: Integer;
   var pBegin, pEnd: Integer): Integer;
var
 i:Integer;
begin
  if not fFunctionIndexBuilt then BuildIndex;
  result:=-1;
  //find current function
  for i:=0 to fFunctionIndexCount-1 do begin
    if (ALine>=fBlocks[fFunctionIndex[i]].startPos) and
       (ALine<=fBlocks[fFunctionIndex[i]].endPos) then begin
      pBegin:=fBlocks[fFunctionIndex[i]].startPos;
      pEnd:=fBlocks[fFunctionIndex[i]].endPos;
      result:=i;
      break;
    end;
  end;
end;

end.


