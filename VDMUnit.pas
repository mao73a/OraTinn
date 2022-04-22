unit VDMUnit;
//https://stackoverflow.com/questions/41803962/using-ivirtualdesktopmanager-in-delphi

interface

uses
  Windows;

function IsOnCurrentDesktop(wnd: HWND): Boolean;
function GetWindowDesktopId(Wnd: HWND): TGUID;
procedure MoveWindowToDesktop(Wnd: HWND; const DesktopID: TGUID);

implementation

uses
  ActiveX, Comobj;

const
 IID_VDM: TGUID = '{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}';
 CLSID_VDM: TGUID ='{AA509086-5CA9-4C25-8F95-589D3C07B48A}';

type
  IVirtualDesktopManager = interface(IUnknown)
    ['{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}']
    function IsWindowOnCurrentVirtualDesktop(Wnd: HWND; out IsTrue: BOOL): HResult; stdcall;
    function GetWindowDesktopId(Wnd: HWND; out DesktopID: TGUID): HResult; stdcall;
    function MoveWindowToDesktop(Wnd: HWND; const DesktopID: TGUID): HResult; stdcall;
  end;

function GetVDM: IVirtualDesktopManager;
begin
  Result := nil;
  OleCheck(CoCreateInstance(CLSID_VDM, nil, CLSCTX_INPROC_SERVER, IVirtualDesktopManager, Result));
end;

function IsOnCurrentDesktop(wnd: HWND): Boolean;
var
  value: BOOL;
begin
  OleCheck(GetVDM.IsWindowOnCurrentVirtualDesktop(Wnd, value));
  Result := value;
end;

function GetWindowDesktopId(Wnd: HWND): TGUID;
begin
  OleCheck(GetVDM.GetWindowDesktopId(Wnd, Result));
end;

procedure MoveWindowToDesktop(Wnd: HWND; const DesktopID: TGUID);
begin
  OleCheck(GetVDM.MoveWindowToDesktop(Wnd, DesktopID));
end;

end.
