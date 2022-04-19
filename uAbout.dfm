object AboutBox: TAboutBox
  Left = 354
  Top = 326
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 235
  ClientWidth = 298
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 281
    Height = 193
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 0
    OnMouseMove = Panel1MouseMove
    object ProgramIcon: TImage
      Left = 16
      Top = 80
      Width = 65
      Height = 57
      Picture.Data = {
        07544269746D617076020000424D760200000000000076000000280000002000
        0000200000000100040000000000000200000000000000000000100000000000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00000000000000000000000000000000000EE8787878EEEEEEE03F30878EEE
        EEE00EE8787878EEEEEEE03F30878EEEEEE00EE8787878EEEEEEE03F30878EEE
        EEE00EE8787878EEEEEEE03F30878EEEEEE00887787877788888803F3088787E
        EEE00788787878878887803F3088887EEEE00788887888878887803F3088887E
        EEE00877888887788888703F308887EEEEE00888777778888888037883088888
        8EE007777777777777703787883087777EE00888888888888803787FF8830888
        888008888888888880378777778830888880077777777788037873F3F3F87808
        88E00888888888803787FFFFFFFF8830EEE00887777778800001111111111100
        EEE00888888888888899B999B99999EEEEE00888888888888899B9B99BB9B9EE
        EEE0088888888888899BB9BB99BB99EEEEE0078888888888899B999B999999EE
        EEE0087788888778899B9B9BB9BB99EEEEE00888778778888E9B9B9BB9999EEE
        EEE0088888788888EE9B99B9BB9BEEEEEEE00EE8888888EEEEE999B9999EEEEE
        EEE00EEEE888EEEEEEEE99BB999EEEEEEEE00EEEEE8EEEEEEEEEE999B9EEEEEE
        EEE00EEEEE8EEEEEEEEEEEE999EEEEEEEEE00EEEEE8EEEEEEEEEEEEE99EEEEEE
        EEE00EEEEE8EEEEEEEEEEEEE9EEEEEEEEEE00EEEEE8EEEEEEEEEEEEEEEEEEEEE
        EEE00EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE00000000000000000000000000000
        0000}
      Stretch = True
      IsControl = True
    end
    object ProductName: TLabel
      Left = 88
      Top = 80
      Width = 96
      Height = 13
      Caption = 'Tinn Is Not Notepad'
      IsControl = True
    end
    object Version: TLabel
      Left = 88
      Top = 96
      Width = 60
      Height = 13
      Caption = 'Beta Version'
      IsControl = True
    end
    object Label3: TLabel
      Left = 16
      Top = 148
      Width = 187
      Height = 13
      Caption = 'Physical Memory Available to Windows:'
    end
    object PhysMem: TLabel
      Left = 212
      Top = 100
      Width = 6
      Height = 13
      Caption = '0'
    end
    object FreeRes: TLabel
      Left = 212
      Top = 120
      Width = 6
      Height = 13
      Caption = '0'
    end
    object Label4: TLabel
      Left = 112
      Top = 168
      Width = 73
      Height = 13
      Caption = 'Memory in Use:'
    end
    object Label1: TLabel
      Left = 88
      Top = 112
      Width = 71
      Height = 13
      Caption = 'Under the GPL'
      IsControl = True
    end
    object lblURL2: TLabel
      Left = 88
      Top = 128
      Width = 116
      Height = 13
      Caption = 'http://tinn.solarvoid.com'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      OnClick = lblURL2Click
      OnMouseDown = lblURL2MouseDown
      OnMouseMove = lblURL2MouseMove
      OnMouseUp = lblURL2MouseUp
      IsControl = True
    end
    object Label2: TLabel
      Left = 88
      Top = 8
      Width = 157
      Height = 16
      Caption = 'OraTinn - Tinn for Oracle(r)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = FormCreate
    end
    object Label5: TLabel
      Left = 88
      Top = 40
      Width = 56
      Height = 13
      Caption = 'based upon'
    end
  end
  object OKButton: TButton
    Left = 111
    Top = 208
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
