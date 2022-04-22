object dlgSynColor: TdlgSynColor
  Left = 200
  Top = 158
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Sytnax Colors'
  ClientHeight = 363
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 557
    Height = 325
    BevelOuter = bvNone
    TabOrder = 0
    object GroupBox2: TGroupBox
      Left = 4
      Top = 4
      Width = 141
      Height = 317
      Caption = 'Highlighters'
      TabOrder = 0
      object lbHighlighters: TListBox
        Left = 8
        Top = 16
        Width = 117
        Height = 281
        BorderStyle = bsNone
        ExtendedSelect = False
        ItemHeight = 13
        TabOrder = 0
        OnClick = lbHighlightersClick
      end
    end
    object GroupBox3: TGroupBox
      Left = 148
      Top = 4
      Width = 401
      Height = 145
      Caption = 'Highlighter Colors'
      TabOrder = 1
      object Label2: TLabel
        Left = 8
        Top = 16
        Width = 38
        Height = 13
        Caption = 'Element'
      end
      object Label3: TLabel
        Left = 140
        Top = 16
        Width = 24
        Height = 13
        Caption = 'Color'
      end
      object lbElements: TListBox
        Left = 12
        Top = 32
        Width = 121
        Height = 105
        BorderStyle = bsNone
        ExtendedSelect = False
        ItemHeight = 13
        TabOrder = 0
        OnClick = lbElementsClick
      end
      object cgColors: TColorGrid
        Left = 148
        Top = 32
        Width = 116
        Height = 104
        BackgroundIndex = 15
        TabOrder = 1
        OnClick = ElementChange
      end
      object GroupBox1: TGroupBox
        Left = 276
        Top = 16
        Width = 117
        Height = 93
        Caption = 'Text Attributes'
        TabOrder = 2
        object cbTextBold: TCheckBox
          Left = 8
          Top = 20
          Width = 65
          Height = 17
          Caption = 'Bold'
          TabOrder = 0
          OnClick = ElementChange
        end
        object cbTextItalics: TCheckBox
          Left = 8
          Top = 40
          Width = 61
          Height = 17
          Caption = 'Italics'
          TabOrder = 1
          OnClick = ElementChange
        end
        object cbTextUnderline: TCheckBox
          Left = 8
          Top = 60
          Width = 81
          Height = 17
          Caption = 'Underline'
          TabOrder = 2
          OnClick = ElementChange
        end
      end
      object edColor: TPanel
        Left = 280
        Top = 114
        Width = 22
        Height = 22
        TabOrder = 3
        OnClick = Panel2Click
      end
      object Button1: TButton
        Left = 312
        Top = 112
        Width = 75
        Height = 25
        Caption = 'Set backg.'
        TabOrder = 4
        OnClick = Button1Click
      end
    end
    object GroupBox4: TGroupBox
      Left = 148
      Top = 152
      Width = 401
      Height = 169
      Caption = 'Sample Code'
      TabOrder = 2
      object synSample: TSynEdit
        Left = 12
        Top = 16
        Width = 381
        Height = 145
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        BorderStyle = bsNone
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Gutter.Visible = False
        Gutter.Width = 0
        Lines.Strings = (
          '{ Syntax highlighting }'
          'procedure TForm1.Button1Click(Sender: TObject);'
          'var'
          '  Number, I, X: Integer;'
          'begin'
          '  Number := 123456;'
          '  Caption := '#39'The Number is'#39' + #32 + IntToStr(Number);'
          '  for I := 0 to Number do'
          '  begin'
          '    Inc(X);'
          '    Dec(X);'
          '    X := X + 1.0;'
          '    X := X - $5E;'
          '  end;'
          '  {$R+}'
          '  asm'
          '    mov AX, 1234H'
          '    mov Number, AX'
          '  end;'
          '  {$R-}'
          'end;'
          '')
        RemovedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 16496
          end>
      end
    end
  end
  object BitBtn1: TBitBtn
    Left = 396
    Top = 332
    Width = 75
    Height = 25
    Caption = 'Save'
    Default = True
    ModalResult = 1
    NumGlyphs = 2
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object BitBtn3: TBitBtn
    Left = 476
    Top = 332
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    NumGlyphs = 2
    TabOrder = 2
    OnClick = BitBtn3Click
  end
  object ColorDialog: TColorDialog
    Left = 504
    Top = 64
  end
end
