Unit AsciiChart;

// I got a hold of it and changed it to work with Tinn.

// Thanks guys!

{  A form that displays a character chart for use with delphi.
   Nominally intended for inclusion with GExperts an excellent collection
   of Delphi experts by Gerald Nunn - gnunn@interlog.com}
{ Disclaimer : This code is freeware.
               It may be used by anyone in any way that they desire.
               If this code or any derivative of it causes the outbreak
               of World War 3 or any lesser event then you assume
               all responsibility for such actions.
      Regards,
               Taz Higgins - taz@taz.compulink.co.uk © 1997}

{Added in the following features and fixes/updates in 1.04
1)  Save and Restore the text in the text box to the registry
2)  Draw in all the 0-31 characters as the ASCII code
3)  Added in a pair of toggle button that displays the character value as
 either Integer or Hex.
4)  Tidied up the formcreate routine a little, moved the windowplacement
 stuff to the end so that drawing hapens at the correct time, and removed
 many unnecessary begin/end blocks.
5)  Removes the 3 font sizing buttons and replaced them with an editbox/updown
 so that it's much smoother, and you can have whatever font size you want, not
 being restricted to the pregenerated sizes.  Limits 6 to 20.
6)  I check that I am changing fontsize to remove an unnecessary redraw if
 clicking on the same size menu choice as already selected.
7)  Use setbounds rather than left then width in formresize and in
 showfontpalette to improve drawing of the edit box a little.
8)  Updated the formpaint routine to improve the drawing speed and reduce
 screen flicker by removing the frame3d routine and inlining it, in
 dedicated routines, drawing left and top first, then changing pen
 and drawing bottom and right.  Lots of reductions in assignments to the
 canvas which really speeds things up.
9)  Added OldHorizMult and OldVertMult variables to the form, used in the
 formsize to determine if we really need to redrawn the screen in order
 to reduce screen flicker on resizing.  Makes a big difference
10) Changed the fontsize routine to cast the sender as TComponent to read
 the tag property from - makes it more generic.
11) Modified the DrawCharacter routine to accept the passed HorizMult and
 VertMult values already calculated, that way I don't need to
 recalculate them in the DrawCharacter routine speeds drawing up.
12) Moved the form level variables to be private rather than public.  They
 don't need to be public, so they shouldn't be.
13) The fontsize of the textbox now fixed at 8 pt.  No need to vary it and it
 solves a problem with large fonts
14) Changed the drawcharacters routine to solve incorrect clipping/drawing
 problems - text will get clipped at the frame edges for that cell.
15) Changed the MinMax sizes to use the systemmetrics frame and caption sizes
 so that things are sized better.
16) Added in some custom hint processing when over characters values 0-31 to show
 a textual interpretation of the character.  When over any other character it
 shows a larger version of that character.  The font used is always that of the
 form, the size is adjustable, using the value as stored in
 'Software\Gexperts\character chart\Zoom Font Size'
 Gerald, perhaps you should add something for this in gexperts config;
19) Changed the requirements to double click to put chartacters in the edit box
 to be a single click instead.
}

Interface

Uses
  SysUtils,
  Windows,
  Messages,
  Graphics,
  Forms,
  ExtCtrls,
  Controls,
  Classes,
  StdCtrls,
  Buttons,
  Menus,
  IniFiles,
  ComCtrls,
  uFrmMain;
  //vgNLS;
//ToolIntf, ExptIntf;

Type
  TfmAsciiChart = Class(TForm)
    Panel1: TPanel;
    Bevel1: TBevel;
    btnCharHigh: TSpeedButton;
    FontComboName: TComboBox;
    PopupMenu1: TPopupMenu;
    ShowFontPalette1: TMenuItem;
    N1: TMenuItem;
    ShowLowCharacters1: TMenuItem;
    ShowHighCharacters1: TMenuItem;
    N2: TMenuItem;
    FontSize8: TMenuItem;
    FontSize10: TMenuItem;
    FontSize12: TMenuItem;
    N3: TMenuItem;
    btnCharInt: TSpeedButton;
    N4: TMenuItem;
    CVInt: TMenuItem;
    CVHex: TMenuItem;
    HintTimer: TTimer;
    FontSizeEdit: TEdit;
    FontSizeUpDown: TUpDown;
    btnCharLow: TSpeedButton;
    btnCharHex: TSpeedButton;
    StatusBar: TStatusBar;
    HintActive1: TMenuItem;
    Help: TMenuItem;
    sbtnValue: TSpeedButton;
    sbtnChar: TSpeedButton;
    txtChars: TEdit;
    Procedure Formpaint(Sender: TObject);
    Procedure btnCharHighClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FontComboNameChange(Sender: TObject);
    Procedure btnSizeClick(Sender: TObject);
    Procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    Procedure FormResize(Sender: TObject);
    Procedure ShowFontPalette1Click(Sender: TObject);
    Procedure PopupMenu1Popup(Sender: TObject);
    Procedure btnCharIntClick(Sender: TObject);
    Procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    Procedure HintTimerTimer(Sender: TObject);
    Procedure FormDeactivate(Sender: TObject);
    Procedure FontSizeUpDownClick(Sender: TObject; Button: TUDBtnType);
    Procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    Procedure FontSizeEditChange(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormKeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure HintActive1Click(Sender: TObject);
    Procedure FontComboNameEnter(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    procedure sbtnValueClick(Sender: TObject);
    procedure sbtnCharClick(Sender: TObject);
  Private
    AutoClearText: Boolean;
    ClickClose: Boolean;
    BaseNum: Integer;
    CharPos: Integer;
    FontSize: Integer;
    FontName: String;
    ShowFontPalette: Boolean;
    ShowHex: Boolean;
    OldHorizMult: Integer;
    OldVertMult: Integer;
    FActive: Boolean;
    FHint: THintWindow;
    OldCharPos: Integer;
    ZoomFontSize: Integer;
    //tran: TvgTranslator;
    Procedure WMGetMinMaxInfo(Var Msg: TWMGetMinMaxInfo); Message WM_GETMINMAXINFO;
    Procedure DrawCharacter(Const CharValue: Integer; Const CharText: String; Const HorizMult, VertMult: Integer);
    Procedure GetFonts;
    Procedure SetFontName(Const NewFontName: String);
    Procedure KillHint;
    Procedure ApplyText;
  Public
    { Public declarations }
    Procedure DoHint(Sender: TObject);
    Procedure DoDeactivate(Sender: TObject);
  End;

Var
  fmAsciiChart: TfmAsciiChart = Nil;

Implementation

{$R *.DFM}

//Uses
  //MainEdit,
  {dbugintf, }
  //AppUtils;

Const
  DescLow: Array[0..31] Of String =
  ('Null', 'Start of Header', 'Start of Text', 'End of Text',
    'End of Transmission', 'Enquiry', 'Acknowledgement', 'Bell',
    'Backspace', 'Horizontal Tab', 'Linefeed', 'Vertical Tab',
    'Form Feed', 'Carriage Return', 'Shift Out', 'Shift in',
    'Delete', 'Device Control 1', 'Device Control 2', 'Device Control 3',
    'Device Control 4', 'Negative Acknowledge', 'Synchronize', 'End Block',
    'Cancel', 'End Message', 'Sub', 'Escape',
    'Form Separator', 'Group Separator', 'Record Separator', 'Unit Separator');

  secASCIIChart = 'ASCII Chart';

Procedure TfmAsciiChart.FormShow(Sender: TObject);
Begin
  //tran.LanguageFile := CurrentLan;
  //tran.Translate;
  SetFontName(FontName);
  //  SendDebug('Font Name:'+FontName);
End;

Procedure TfmAsciiChart.FormCreate(Sender: TObject);
Begin
  // do not localize any of the following items
  GetFonts;
  { Initial values - if they don't exist in the registry
    then everything is still OK }
  AutoClearText := True;
  ClickClose := True;
  BaseNum := 0;
  FontSize := 8;
  //FontName := 'MS Sans Serif';
  FontName := frmTinnMain.FontName;
  ShowFontPalette := True;
  ShowHex := False;
  //  SetPlace := False;
  OldHorizMult := 0;
  OldVertMult := 0;
  ZoomFontSize := 32;
  //Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + GetDefaultIniName);
  {Try
    FontSize := Ini.ReadInteger(secASCIIChart, 'Font Size', FontSize);
    FontName := Ini.ReadString(secASCIIChart, 'Font Name', FontName);
    BaseNum := Ini.ReadInteger(secASCIIChart, 'Font Base', BaseNum);
    ShowFontPalette := Ini.ReadBool(secASCIIChart, 'Show Font Palette', ShowFontPalette);
    ShowHex := Ini.ReadBool(secASCIIChart, 'Show Hex', ShowHex);
    ZoomFontSize := Ini.ReadInteger(secASCIIChart, 'Zoom Font Size', ZoomFontSize);
    txtChars.Text := Ini.ReadString(secASCIIChart, 'Edit Display Text', txtChars.Text);
    HintActive1.Checked := Ini.ReadBool(secASCIIChart, 'Show Hint', HintActive1.Checked);
    AutoClearText := Ini.ReadBool(secASCIIChart, 'AutoClearText', AutoClearText);
    ClickClose := Ini.ReadBool(secASCIIChart, 'ClickClose', ClickClose);
  Finally
    Ini.Free;
  End;  }

  If BaseNum = 0 Then
    btnCharLow.Down := True
  Else
    btnCharHigh.Down := True;

  If ShowHex = True Then
    btnCharHex.Down := True
  Else
    btnCharInt.Down := True;

  sbtnChar.Down := true;

  FontSizeUpDown.Position := FontSize;
  //      SendDebug('Font Size:'+IntTostr(FontSize));
  ShowFontPalette := Not ShowFontPalette;
  ShowFontPalette1Click(Self);
  //  if SetPlace then
  //    SetWindowPlacement(Handle, @Place);
  Application.OnHint := DoHint;
  Application.OnDeactivate := DoDeactivate;
  //tran := TvgTranslator.Create(Self);
End;

Procedure TfmAsciiChart.FormDestroy(Sender: TObject);
Begin
  fmAsciiChart := Nil;
End;

Procedure TfmAsciiChart.Formpaint(Sender: TObject);
{ It's much quicker to draw the characters in one style, change
  styles then draw all the others in the other style than do each draw
  one after another changing styles as I go along }
Var
  I, J: Integer; { general loop counters }
  X, Y: Integer; { screen pixel locations }
  HorizMult, VertMult: Integer; { logical screen width/height segments }
  Start: Integer; { low charnum for character rendering }
Begin
  If BaseNum = 0 Then Start := 32 Else Start := 0;
  HorizMult := Self.ClientWidth Div 8;
  VertMult := (Self.ClientHeight - Panel1.Height - StatusBar.Height) Div 16;
  Canvas.Brush.Style := BsClear;
  { draw the character value as Int or Hex on screen }
  Canvas.Font.Name := 'MS Sans Serif'; // do not localize
  Canvas.Font.Size := 8;
  Canvas.Font.Color := clGrayText;
  { Only do the if check once for improved speed rather than every iteration }
  If ShowHex Then Begin
    For I := 0 To 127 Do Begin
      X := I Div 16;
      Y := I Mod 16;
      Canvas.TextOut(X * HorizMult + 2, Y * VertMult + 28, IntToHex(BaseNum + I, 2));
    End;
  End
  Else Begin
    For I := 0 To 127 Do Begin
      X := I Div 16;
      Y := I Mod 16;
      Canvas.TextOut(X * HorizMult + 2, Y * VertMult + 28, IntToStr(BaseNum + I));
    End;
  End;
  { Draw in the characters 0-31 if required }
  Canvas.Font.Color := clWindowText;
  If BaseNum = 0 Then Begin
    DrawCharacter(0, 'NUL', HorizMult, VertMult); // Ctrl @, NULL
    DrawCharacter(1, 'SOH', HorizMult, VertMult); // Ctrl A, Start of Header
    DrawCharacter(2, 'STX', HorizMult, VertMult); // Ctrl B,Start of Text
    DrawCharacter(3, 'ETX', HorizMult, VertMult); // Ctrl C,End of Text
    DrawCharacter(4, 'EOT', HorizMult, VertMult); // Ctrl D,End of Transmission
    DrawCharacter(5, 'ENQ', HorizMult, VertMult); // Ctrl E,Enquiry
    DrawCharacter(6, 'ACK', HorizMult, VertMult); // Ctrl F,Acknowlodge
    DrawCharacter(7, 'BEL', HorizMult, VertMult); // Ctrl G,Bell
    DrawCharacter(8, 'BS', HorizMult, VertMult); // Ctrl H,Backspace
    DrawCharacter(9, 'TAB', HorizMult, VertMult); // Ctrl I,Horizontal Tab
    DrawCharacter(10, 'LF', HorizMult, VertMult); // Ctrl J,Linefeed
    DrawCharacter(11, 'VT', HorizMult, VertMult); // Ctrl K,Vertical Tab
    DrawCharacter(12, 'FF', HorizMult, VertMult); // Ctrl L,Form Feed
    DrawCharacter(13, 'CR', HorizMult, VertMult); // Ctrl M,Carridge Return
    DrawCharacter(14, 'SO', HorizMult, VertMult); // Ctrl N,Shift Out
    DrawCharacter(15, 'SI', HorizMult, VertMult); // Ctrl O,Shift in
    DrawCharacter(16, 'DLE', HorizMult, VertMult); // Ctrl P,Delete
    DrawCharacter(17, 'DC1', HorizMult, VertMult); // Ctrl Q,Device Control 1
    DrawCharacter(18, 'DC2', HorizMult, VertMult); // Ctrl R,Device Control 2
    DrawCharacter(19, 'DC3', HorizMult, VertMult); // Ctrl S,Device Control 3
    DrawCharacter(20, 'DC4', HorizMult, VertMult); // Ctrl T,Device Control 4
    DrawCharacter(21, 'NAK', HorizMult, VertMult); // Ctrl U,Negative Acknowledge
    DrawCharacter(22, 'SYN', HorizMult, VertMult); // Ctrl V,Synchronise
    DrawCharacter(23, 'ETB', HorizMult, VertMult); // Ctrl W,End Block ??
    DrawCharacter(24, 'CAN', HorizMult, VertMult); // Ctrl X,Cancel
    DrawCharacter(25, 'EM', HorizMult, VertMult); // Ctrl Y,End Message
    DrawCharacter(26, 'SUB', HorizMult, VertMult); // Ctrl Z,Sub
    DrawCharacter(27, 'ESC', HorizMult, VertMult); // Ctrl [,Escape
    DrawCharacter(28, 'FS', HorizMult, VertMult); // Ctrl \,Form Separator
    DrawCharacter(29, 'GS', HorizMult, VertMult); // Ctrl ],Group Separator
    DrawCharacter(30, 'RS', HorizMult, VertMult); // Ctrl ^,Record Separator
    DrawCharacter(31, 'US', HorizMult, VertMult); // Ctrl _,Unit Separator
  End;

  { draw the character of that number on screen }
  With Canvas.Font Do Begin
    Name := FontName;
    Size := FontSize;
  End;

  For I := Start To 127 Do
    DrawCharacter(I, Chr(BaseNum + I), HorizMult, VertMult);

  { Draw the boxes on the screen }
  { Only two colour assignments to canvas speeds things up }
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := PsSolid;
  { 1) draw left and top sides }
  Canvas.Pen.Color := clBtnHighlight;
  For I := 0 To 7 Do
    For J := 0 To 15 Do
      Canvas.Polyline([Point(I * HorizMult, (J + 1) * VertMult + 24),
        Point(I * HorizMult, J * VertMult + 25),
          Point((I + 1) * HorizMult - 1, J * VertMult + 25)]);
  { 2) draw right and bottom sides }
  Canvas.Pen.Color := clBtnShadow;
  For I := 0 To 7 Do
    For J := 0 To 15 Do
      Canvas.Polyline([Point((I + 1) * HorizMult - 1, J * VertMult + 25),
        Point((I + 1) * HorizMult - 1, (J + 1) * VertMult + 24),
          Point(I * HorizMult - 1, (J + 1) * VertMult + 24)]);
End;

Procedure TfmAsciiChart.DrawCharacter(Const CharValue: Integer; Const CharText: String; Const HorizMult, VertMult: Integer);
{ This draws the text on the screen at the relevant location }
Var
  X, Y: Integer; { Screen Locations }
  MyRect: TRect; { general drawing reectangle }
  VOffset, HOffset: Integer; { V and H offsets for bounding box of character in font }
Begin
  X := CharValue Div 16;
  Y := CharValue Mod 16;
  VOffset := (VertMult - Canvas.TextHeight(CharText)) Div 2;
  HOffset := (HorizMult - 24 - Canvas.TextWidth(CharText)) Div 2;
  MyRect.Left := X * HorizMult + 24;
  MyRect.Right := (X + 1) * HorizMult;
  MyRect.Top := Y * VertMult + 26;
  MyRect.Bottom := (Y + 1) * VertMult + 26;
  Canvas.TextRect(MyRect, MyRect.Left + HOffset, MyRect.Top + VOffset, CharText);
End;

Procedure TfmAsciiChart.FormResize(Sender: TObject);
Var
  HorizMult, VertMult: Integer; { logical screen width/height segments }
Begin
  If ShowFontPalette Then
    txtChars.SetBounds(284, 0, Self.ClientWidth - 284, txtChars.Height)
  Else
    txtChars.SetBounds(0, 0, Self.ClientWidth, txtChars.Height);
  HorizMult := Self.ClientWidth Div 8;
  VertMult := (Self.ClientHeight - Panel1.Height - StatusBar.Height) Div 16;
  If (HorizMult <> OldHorizMult) Or (VertMult <> OldVertMult) Then Begin
    OldHorizMult := HorizMult;
    OldVertMult := VertMult;
    Self.Refresh;
  End;
  KillHint;
End;

Procedure TfmAsciiChart.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{ charpos is the ordinal value of the cell clicked on }
Var
  HorizMult, VertMult: Integer; { logical screen width/height segments }
  XPos, YPos: Integer; { X and Y cells clicked on }
Begin
  HorizMult := Self.ClientWidth Div 8;
  VertMult := (Self.ClientHeight - Panel1.Height - StatusBar.Height) Div 16;
  XPos := X Div HorizMult;
  YPos := (Y - 25) Div VertMult;
  { only generate charpos if clicking inside the boundaries of the cells
    avoids the clicking beyond the right/bottom extents of the cells }
  If (XPos < 8) And (YPos < 16) Then
    CharPos := BaseNum + XPos * 16 + YPos
  Else
    CharPos := -1;
  If Button = MbRight Then
    PopupMenu1.Popup(X + Left + GetSystemMetrics(SM_CXFRAME),
      Y + Self.Top + GetSystemMetrics(SM_CYFRAME) + GetSystemMetrics(SM_CYCAPTION))
  Else Begin
    If (CharPos > -1) And (CharPos < 256) Then Begin
      txtChars.Text := txtChars.Text + Chr(CharPos);
      If ClickClose Then Begin
        ApplyText;
        Close;
      End;
    End;
  End;
End;

Procedure TfmAsciiChart.btnCharHighClick(Sender: TObject);
{ this draw characters 128-255 }
Begin
  If BaseNum = 0 Then Begin
    BaseNum := 128;
    btnCharHigh.Down := True;
  End
  Else Begin
    BaseNum := 0;
    btnCharLow.Down := True;
  End;
  Self.Refresh;
End;

Procedure TfmAsciiChart.FontComboNameChange(Sender: TObject);
{ this updates the font used for drawing characters }
Begin
  FontName := FontComboName.Text;
  txtChars.Font.Name := FontName;
  Self.Refresh;
End;

Procedure TfmAsciiChart.btnSizeClick(Sender: TObject);
{ the tag property of the speedbuttons or menu items is used to
  hold the newfont size - Tag is a property of TComponent so
  cast the sender as that to read the property }
Var
  NewFontSize: Integer; { Size of the font I will be changing to }
Begin
  NewFontSize := (Sender As TComponent).Tag;
  Case NewFontSize Of
    8: FontSizeUpDown.Position := 8;
    10: FontSizeUpDown.Position := 10;
    12: FontSizeUpDown.Position := 12;
  Else
    Exit;
  End;
  If NewFontSize = FontSize Then Exit; { No change so no need to redraw }
  FontSize := NewFontSize;
  Self.Refresh;
End;

Procedure TfmAsciiChart.ShowFontPalette1Click(Sender: TObject);

  Procedure SetControlsEnabled(Const Enabled: Boolean);
  Begin
    FontComboName.Visible := Enabled;
    FontSizeUpDown.Visible := Enabled;
    FontSizeEdit.Visible := Enabled;
    btnCharLow.Visible := Enabled;
    btnCharHigh.Visible := Enabled;
    btnCharInt.Visible := Enabled;
    btnCharHex.Visible := Enabled;
  End;

Begin
  ShowFontPalette := Not ShowFontPalette;
  If ShowFontPalette Then Begin
    SetControlsEnabled(True);
    txtChars.SetBounds(278, 0, Self.ClientWidth - 278, txtChars.Height);
  End
  Else Begin
    SetControlsEnabled(False);
    txtChars.SetBounds(0, 0, Self.ClientWidth, txtChars.Height);
  End;
End;

Procedure TfmAsciiChart.PopupMenu1Popup(Sender: TObject);
Begin
  { check low/high menu item }
  ShowLowCharacters1.Checked := (BaseNum = 0);
  { select the correct fontsize element }
  Case FontSize Of
    8: FontSize8.Checked := True;
    10: FontSize10.Checked := True;
    12: FontSize12.Checked := True;
  Else
    // Do Nothing
  End;
  { check the show font palette item }
  ShowFontPalette1.Checked := ShowFontPalette;
  { Check the hex/integer menu item }
  CVHex.Checked := ShowHex;
End;

Procedure TfmAsciiChart.WMGetMinMaxInfo(Var Msg: TWMGetMinMaxInfo);
Begin
  With Msg.MinMaxInfo^ Do Begin
    PtMinTrackSize.X := 400 + 2 * GetSystemMetrics(SM_CXFRAME);
    PtMinTrackSize.Y := 331 + 2 * GetSystemMetrics(SM_CYFRAME) + GetSystemMetrics(SM_CYCAPTION);
  End;
  Msg.Result := 0;
End;

Function EnumFontsProc(Var LogFont: TLogFont; Var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; Stdcall;
Var
  S: TStrings;
  Temp: String;
Begin
  S := TStrings(Data);
  Temp := LogFont.LfFaceName;
  If (S.Count = 0) Or (AnsiCompareText(S[S.Count - 1], Temp) <> 0) Then
    S.Add(Temp);
  Result := 1;
End;

Procedure TfmAsciiChart.GetFonts;
Var
  DC: HDc;
  LFont: TLogFont;
Begin
  DC := GetDC(0);
  Try
    { obviously for a Win95/98/NT version only simplify this bit }//! ?????
    If Lo(GetVersion) >= 4 Then Begin
      FillChar(LFont, SizeOf(LFont), 0);
      LFont.LfCharSet := DEFAULT_CHARSET;
      EnumFontFamiliesEx(DC, LFont, @EnumFontsProc, LongInt(FontComboName.Items), 0);
    End
    Else
      EnumFonts(DC, Nil, @EnumFontsProc, Pointer(FontComboName.Items));
    FontComboName.Sorted := True;
  Finally
    ReleaseDC(0, DC);
  End;
End;

Procedure TfmAsciiChart.SetFontName(Const NewFontName: String);
{ this sets the font name in the combo to be correct -
  otherwise it would be blank }
Var
  I: Integer;
Begin
  If FontComboName.Text = NewFontName Then Exit;
  With FontComboName Do
    For I := 0 To Items.Count - 1 Do Begin
      If CompareText(Items[I], NewFontName) = 0 Then Begin
        ItemIndex := I;
        Break;
      End;
    End;
End;

Procedure TfmAsciiChart.btnCharIntClick(Sender: TObject);
Begin
  ShowHex := Not ShowHex;
  If ShowHex Then
    btnCharHex.Down := True
  Else
    btnCharInt.Down := True;
  Self.Refresh;
End;

Procedure TfmAsciiChart.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
{ charpos is the ordinal value of the cell clicked on }
Var
  HorizMult, VertMult: Integer; { logical screen width/height segments }
  XPos, YPos: Integer; { X and Y cells clicked on }
  TheRect: TRect; { the drawing area of the custom hint }
  TheString: String; { the hint string }
  ThePoint: TPoint; { A point variable, used to offset my rect }
  CharPos: Integer; { Override the global Charpos variable }
Begin
  HorizMult := Self.ClientWidth Div 8;
  VertMult := (Self.ClientHeight - Panel1.Height - StatusBar.Height) Div 16;
  XPos := X Div HorizMult;
  YPos := (Y - 25) Div VertMult;
  { only generate charpos if clicking inside the boundaries of the cells
    avoids the clicking beyond the right/bottom extents of the cells }
  If (XPos < 8) And (YPos < 16) Then
    CharPos := BaseNum + XPos * 16 + YPos
  Else
    Exit;
  { create my custom hint }
  If (OldCharPos <> CharPos) And Self.Active Then Begin
    KillHint;
    FHint := THintWindow.Create(Self);
    FHint.Color := ClInfoBk;
    If (BaseNum = 0) And (CharPos < 32) And (OldCharPos <> CharPos) Then Begin
      TheString := DescLow[CharPos];
      StatusBar.Font.Name := 'MS Sans Serif'; // do not localize
    End
    Else Begin
      TheString := Chr(CharPos);
      StatusBar.Font.Name := FontName;
      With FHint.Canvas.Font Do Begin
        CharSet := DEFAULT_CHARSET;
        Name := FontName;
        Size := ZoomFontSize;
      End;
    End;
    TheRect := FHint.CalcHintRect(Screen.Width, TheString, Nil);
    ThePoint := ClientToScreen(Point((XPos + 1) * HorizMult - 1, (YPos + 1) * VertMult + 24));
    OffsetRect(TheRect, ThePoint.x, ThePoint.Y);
    If HintActive1.Checked Then
      FHint.ActivateHint(theRect, TheString);
    StatusBar.SimpleText := TheString;
    FActive := True;
    HintTimer.Enabled := True;
    OldCharPos := CharPos;
  End;
End;

Procedure TfmAsciiChart.KillHint;
Begin
  FActive := False;
  If Assigned(FHint) Then Begin
    FHint.ReleaseHandle;
    FHint.Free;
    FHint := Nil;
  End;
  HintTimer.Enabled := False;
End;

Procedure TfmAsciiChart.HintTimerTimer(Sender: TObject);
Begin
  HintTimer.Enabled := False;
  KillHint;
End;

Procedure TfmAsciiChart.DoHint(Sender: TObject);
Begin
  KillHint;
End;

Procedure TfmAsciiChart.FormDeactivate(Sender: TObject);
Begin
  KillHint;
End;

Procedure TfmAsciiChart.DoDeactivate(Sender: TObject);
Begin
  KillHint;
End;

Procedure TfmAsciiChart.FontSizeUpDownClick(Sender: TObject;
  Button: TUDBtnType);
Begin
  FontSize := FontSizeUpDown.Position;
  Self.Refresh;
End;

Procedure TfmAsciiChart.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{ charpos is the ordinal value of the cell clicked on }
Var
  HorizMult, VertMult: Integer; { logical screen width/height segments }
  XPos, YPos: Integer; { X and Y cells clicked on }
Begin
  HorizMult := Self.ClientWidth Div 8;
  VertMult := (Self.ClientHeight - Panel1.Height - StatusBar.Height) Div 16;
  XPos := X Div HorizMult;
  YPos := (Y - 25) Div VertMult;
  { only generate charpos if clicking inside the boundaries of the cells
    avoids the clicking beyond the right/bottom extents of the cells }
  If (XPos < 8) And (YPos < 16) Then
    CharPos := BaseNum + XPos * 16 + YPos
  Else
    CharPos := -1;
End;

Procedure TfmAsciiChart.FontSizeEditChange(Sender: TObject);
Var
  NewFontSize: Integer;
Begin
  NewFontSize := StrToIntDef(FontSizeEdit.Text, 8);
  If (NewFontSize < 6) Or (NewFontSize > 20) Or (NewFontSize = FontSize) Then
    Exit;
  FontSize := NewFontSize;
  Self.Refresh;
End;

Procedure TfmAsciiChart.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  If Key = VK_ESCAPE Then Begin
    Key := $0;
    Close;
  End
  Else If Key = 13 Then Begin
    Key := $0;
    ApplyText;
    Close;
  End;
End;

Procedure TfmAsciiChart.FontComboNameEnter(Sender: TObject);
Begin
  FontComboName.Perform(CB_SETDROPPEDWIDTH, 175, 0);
End;

Procedure TfmAsciiChart.HintActive1Click(Sender: TObject);
Begin
  HintActive1.Checked := Not HintActive1.Checked;
End;

Procedure TfmAsciiChart.ApplyText;
Var
  s: String;
  I: Integer;
  tmpstr : string;
Begin
  {With frmJediEdit Do If (txtChars.Text <> '') And (CurrentEditor <> Nil) Then Begin
      s := '';
      For i := 1 To Length(txtChars.Text) Do
        If ShowHex Then
          s := s + '#$' + Format('%x', [Ord(txtChars.Text[i])])
        Else
          s := s + '#' + IntToStr(Ord(txtChars.Text[i]));
      CurrentEditor.SelText := s;
    End; }
  For i := 1 To Length(txtChars.Text) Do
  begin
    If ShowHex Then
      s := s + '#$' + Format('%x', [Ord(txtChars.Text[i])])
    Else
      s := s + '#' + IntToStr(Ord(txtChars.Text[i]));
    tmpstr := tmpstr + txtChars.Text[i];
  end;
  if (sbtnChar.Down) then
    frmTinnMain.AsciiString := tmpstr
  else
    frmTinnMain.AsciiString := s; 
End;

procedure TfmAsciiChart.sbtnValueClick(Sender: TObject);
begin
  Self.Refresh;
end;

procedure TfmAsciiChart.sbtnCharClick(Sender: TObject);
begin
  Self.Refresh;
end;

Initialization
End.

