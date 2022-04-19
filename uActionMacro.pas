unit uActionMacro;

{
  The contents of this file are subject to the terms and conditions found under
  the GNU General Public License Version 2 or later (the "GPL").
  See http://www.opensource.org/licenses/gpl-license.html or
  http://www.fsf.org/copyleft/gpl.html for further information.


  The TActionMacroEvent class was taken from the uSynAPI.pas file in the syn
  project (see http://syn.sourceforge.net/). The only changes made is to
  create a separate unit for the class and the addition of constructor and
  destructor methods as well as the ActionLists property.

  How it works:

    The TSynMacroRecorder works by recording events and keeping them in an
    array. It records all text editting functionailty, but does not record
    external events like searching/replacing, and so on.

    However, since each event in the array is actually a separate object,
    you can add custom events to the recorder by inheriting from the base
    TSynMacroEvent class and implementing new event recording functionality.

    This class (TActionMacroEvent) is one such class and is designed for the
    recording of action list events and their subsequent playback. It works by
    hooking onto the action list's OnExecute function and creating a new
    TActionMacroEvent object and adding it to the recorder's event list.

    By storing the Action List's name and providing to the TActionMacroEvent
    class the list of all possible actions, the object is able to locate the
    recorded action and re-execute it on playback.

  How to use this class:

    1) Include a TSynMacroRecorder in your project and add a method to the
       OnStateChange event. Add the following StateChange function to your form.

       This code assumes your form class is TfrmMain, the name of the
       TSynMacroRecorder instance is SynMR, and you have 4 action lists
       (alEdit, alFile, alFormat and alSearch).

          procedure TfrmMain.SynMRStateChange(Sender: TObject);
          begin
            if SynMR.State = msRecording then
            begin
              alEdit.OnExecute:= RecordActions;
              alFile.OnExecute:= RecordActions;
              alFormat.OnExecute:= RecordActions;
              alSearch.OnExecute:= RecordActions;
            end
            else if Assigned(alEdit.OnExecute) then
            begin
              alEdit.OnExecute:= nil;
              alFile.OnExecute:= nil;
              alFormat.OnExecute:= nil;
              alSearch.OnExecute:= nil;
            end;
          end;

    2) Add the InExecute variable and RecordActions procedure to your form:

        var
          InExecute: Boolean;

        procedure TfrmMain.RecordActions(Action: TBasicAction; var Handled: Boolean);
        var
          AEvent: TActionMacroEvent;
        begin
          if not InExecute and (Action <> actRecord) and (Action <> actPlay) then
            with SynMR do
            begin
              AEvent:= TActionMacroEvent.Create;
              AEvent.ActionName:= Action.Name;
              AEvent.ActionLists.Add(alEdit);
              AEvent.ActionLists.Add(alFile);
              AEvent.ActionLists.Add(alFormat);
              AEvent.ActionLists.Add(alSearch);
              AddCustomEvent(TSynMacroEvent(AEvent));
              InExecute:= True;
              try
                Action.Execute;
                Handled:= True;
              finally
                InExecute:= False;
              end;
            end;
        end;

    3) Done!


    Written by lesx99 and donated to the Tinn project. Thanks!
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SynEdit, Menus, StdActns, ActnList, StdCtrls, ExtCtrls,
  SynEditKeyCmds, SynMacroRecorder;

const
  ecAction: TSynEditorCommand = ecUserFirst;

type
  TActionMacroEvent = class(TSynMacroEvent)

  private
    fActionName: string;
    fActionLists: TList;
  protected
    function GetAsString : string; override;
    procedure InitEventParameters(aStr : string); override;
  public
    constructor Create(); override;
    destructor Destroy; override;
    procedure Initialize(aCmd: TSynEditorCommand; aChar: Char; aData: Pointer);
      override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure Playback(aEditor: TCustomSynEdit); override;
  public
    property ActionName: string read fActionName write fActionName;
    property ActionLists: TList read fActionLists write fActionLists;
  end;

implementation

{ TActionMacroEvent }

constructor TActionMacroEvent.Create;
begin
  inherited Create;
  fActionLists := TList.Create;
end;

destructor TActionMacroEvent.Destroy;
begin
  FreeAndNil(fActionLists);
end;

function TActionMacroEvent.GetAsString: string;
begin
  Result := 'ecAction ' + FActionName;
  if RepeatCount > 1 then
    Result := Result + ' ' + IntToStr(RepeatCount);
end;

procedure TActionMacroEvent.InitEventParameters(aStr: string);
var
  Head, Tail: PChar;
begin
  Head:= PChar(AStr);
  while Head^ in [#6, ' '] do Inc(Head);
  Tail:= Head;
  while Tail^ in ['A'..'Z', 'a'..'z', '0'..'9', '_'] do Inc(Tail);
  fActionName:= Copy(Head, 1, Tail-Head);
  RepeatCount := StrToIntDef(Trim(Tail), 1);
end;

procedure TActionMacroEvent.Initialize(aCmd: TSynEditorCommand;
  aChar: Char; aData: Pointer);
begin
  fActionName := String(aData);
end;

procedure TActionMacroEvent.LoadFromStream(aStream: TStream);
var
  l : Integer;
  Buff : PChar;
begin
  aStream.Read(l, SizeOf(l));
  GetMem(Buff, l);
  try
  {$IFNDEF WINDOWS}
    FillMemory(Buff, l, 0);
  {$ENDIF}
    aStream.Read(Buff^, l);
    fActionName := Buff;
  finally
    FreeMem(Buff);
  end;
  aStream.Read( fRepeatCount, SizeOf(fRepeatCount) );
end;

procedure TActionMacroEvent.Playback(aEditor: TCustomSynEdit);

  function GetLoadedAction(const AActionName: string): TContainedAction;
  (* returns already created action with name AActionName *)
  var
    i, j: integer;
  begin
    Assert(Assigned(fActionLists));
    for i:= 0 to fActionLists.Count-1 do
    begin
      with TCustomActionList(fActionLists[i]) do
      begin
        for j:= 0 to ActionCount-1 do
        begin
          if SameText(Actions[j].Name, AActionName) then
          begin
            Result:= Actions[j];
            Exit;
          end;
        end;
      end;
    end;
    Result:= nil;
  end;

var
  Action: TContainedAction;
  i: Integer;
begin
  Action:= GetLoadedAction(FActionName);
  if Assigned(Action) then
    for i:= 1 to RepeatCount do Action.Execute;
end;

procedure TActionMacroEvent.SaveToStream(aStream: TStream);
var
  l : Integer;
  Buff : PChar;
begin
  aStream.Write(ecAction, SizeOf(ecAction));
  l := Length(FActionName) + 1;
  aStream.Write(l, sizeof(l));
  GetMem(Buff, l);
  try
  {$IFNDEF WINDOWS}
    FillMemory(Buff, l, 0);
  {$ENDIF}
    StrPCopy(Buff, fActionName);
    aStream.Write(Buff^, l);
  finally
    FreeMem(Buff);
  end;
  aStream.Write( RepeatCount, SizeOf(RepeatCount) );
end;

end.
