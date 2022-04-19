object dmSyn: TdmSyn
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 199
  Top = 163
  Height = 479
  Width = 741
  object SynPas: TSynPasSyn
    CommentAttri.Foreground = clRed
    KeyAttri.Foreground = clNavy
    StringAttri.Foreground = clBlue
    Left = 108
    Top = 60
  end
  object SynHTML: TSynHTMLSyn
    DefaultFilter = 'HTML Document (*.html,*.htm)|*.html;*.htm'
    CommentAttri.Foreground = clSilver
    IdentifierAttri.Foreground = clMaroon
    Left = 108
    Top = 108
  end
  object SynJScript: TSynJScriptSyn
    DefaultFilter = 'Javascript files (*.js)|*.js'
    CommentAttri.Foreground = clGreen
    IdentifierAttri.Foreground = clBlack
    KeyAttri.Foreground = clNavy
    StringAttri.Foreground = clBlue
    Left = 28
    Top = 264
  end
  object SynSQL: TSynSQLSyn
    DefaultFilter = 
      'SQL files (*.sql;*.spc;*.bdy;*.pks;*.pkb)|*.sql;*.spc;*.bdy;*.pk' +
      's;*.pkb'
    CommentAttri.Foreground = clBackground
    KeyAttri.Foreground = clNavy
    NumberAttri.Foreground = clMaroon
    StringAttri.Foreground = clRed
    SQLDialect = sqlOracle
    Left = 108
    Top = 156
  end
  object SynPerl: TSynPerlSyn
    DefaultFilter = 'Perl files (*.pl,*.pm,*.cgi)|*.pl;*.pm;*.cgi'
    CommentAttri.Foreground = clInactiveCaptionText
    IdentifierAttri.Foreground = clTeal
    KeyAttri.Foreground = clActiveCaption
    KeyAttri.Style = []
    NumberAttri.Foreground = clMaroon
    OperatorAttri.Foreground = clMaroon
    StringAttri.Foreground = clMaroon
    SymbolAttri.Foreground = clPurple
    VariableAttri.Foreground = clFuchsia
    VariableAttri.Style = []
    Left = 104
    Top = 208
  end
  object SynCpp: TSynCppSyn
    DefaultFilter = 'C++ files (*.cpp,*.h,*.hpp)|*.cpp;*.h;*.hpp'
    CommentAttri.Foreground = clTeal
    DirecAttri.Foreground = clRed
    KeyAttri.Foreground = clNavy
    NumberAttri.Foreground = clBlue
    StringAttri.Foreground = clBlue
    SymbolAttri.Foreground = clPurple
    Left = 28
    Top = 156
  end
  object SynJava: TSynJavaSyn
    DefaultFilter = 'Java files (*.java)|*.java'
    CommentAttri.Foreground = clTeal
    KeyAttri.Foreground = clNavy
    NumberAttri.Foreground = clBlue
    StringAttri.Foreground = clBlue
    Left = 160
    Top = 264
  end
  object SynIni: TSynIniSyn
    SectionAttri.Foreground = clHighlight
    KeyAttri.Style = [fsBold]
    StringAttri.Background = clTeal
    Left = 28
    Top = 208
  end
  object SynGeneralSyn1: TSynGeneralSyn
    DefaultFilter = '*.*'
    Comments = []
    DetectPreprocessor = False
    IdentifierChars = 
      '!"#$%&'#39'()*+-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`a' +
      'bcdefghijklmnopqrstuvwxyz{|}~ÄÅÇÉÑÖÜáàâäãåçéèêëíìîïñóòôöõúùûü†°' +
      '¢£§•¶ß®©™´¨≠ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ‡·' +
      '‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛ˇ'
    Left = 28
    Top = 8
  end
  object SynPHPsimple: TSynPHPSyn
    DefaultFilter = 
      'PHP Files (*.php,*.php3,*.phtml,*.inc)|*.php;*.php3;*.phtml;*.in' +
      'c'
    CommentAttri.Foreground = clMaroon
    IdentifierAttri.Foreground = clHighlight
    KeyAttri.Foreground = clTeal
    NumberAttri.Foreground = clGreen
    StringAttri.Foreground = clPurple
    VariableAttri.Foreground = clBlue
    Left = 28
    Top = 56
  end
  object SynVBScript: TSynVBScriptSyn
    DefaultFilter = 'MS VBScript Files (*.vbs)|*.vbs'
    CommentAttri.Foreground = clGreen
    IdentifierAttri.Foreground = clNavy
    StringAttri.Foreground = clBlue
    Left = 28
    Top = 104
  end
  object SynASP: TSynMultiSyn
    DefaultFilter = 'ASP Files (*.asp)|*.asp'
    Schemes = <
      item
        CaseSensitive = False
        StartExpr = '<%'
        EndExpr = '%>'
        Highlighter = SynVBScript
        SchemeName = 'ASP'
      end
      item
        CaseSensitive = False
        StartExpr = '<script language=["'#39']?javascript["'#39']?'
        EndExpr = '</script>'
        Highlighter = SynJScript
        MarkerAttri.Background = clLime
        SchemeName = 'JavaScript'
      end>
    DefaultHighlighter = SynHTML
    DefaultLanguageName = 'ASP'
    Left = 316
    Top = 76
  end
  object SynASPNET: TSynMultiSyn
    DefaultFilter = 'ASP.net Files (*.aspx,*.asmx)|*.aspx,*.asmx'
    Schemes = <
      item
        CaseSensitive = False
        StartExpr = '<script runat=["'#39']?server["'#39']?'
        EndExpr = '</script>'
        Highlighter = SynJava
        MarkerAttri.Background = clSilver
        MarkerAttri.Foreground = clBlue
        SchemeName = 'C#'
      end
      item
        CaseSensitive = False
        StartExpr = '<%'
        EndExpr = '%>'
        Highlighter = SynVBScript
        SchemeName = 'Asp'
      end
      item
        CaseSensitive = False
        StartExpr = '<asp:'
        EndExpr = '</asp'
        Highlighter = SynVBScript
        MarkerAttri.Background = clSilver
        MarkerAttri.Foreground = clYellow
        SchemeName = 'ASPTag'
      end
      item
        CaseSensitive = False
        StartExpr = '<script language=["'#39']?javascript["'#39']?'
        EndExpr = '</script>'
        Highlighter = SynJScript
        MarkerAttri.Background = clLime
        SchemeName = 'JavaScript'
      end>
    DefaultHighlighter = SynHTML
    DefaultLanguageName = 'ASP.net'
    Left = 316
    Top = 176
  end
  object SynHTMLComplex: TSynMultiSyn
    DefaultFilter = 'HTML Document (*.htm,*.html)|*.htm;*.html'
    Schemes = <
      item
        CaseSensitive = False
        StartExpr = '<script'
        EndExpr = '</script>'
        Highlighter = SynJScript
        SchemeName = 'JavaScript'
      end>
    DefaultHighlighter = SynHTML
    DefaultLanguageName = 'HTMLComplex'
    Left = 316
    Top = 32
  end
  object SynCss: TSynCssSyn
    Left = 108
    Top = 20
  end
  object SynXML: TSynXMLSyn
    DefaultFilter = 
      'XML Files (*.xml,*.xsd,*.xsl,*.xslt,*.dtd)|*.xml;*.xsd;*.xsl;*.x' +
      'slt;*.dtd'
    WantBracesParsed = False
    Left = 192
    Top = 120
  end
  object SynAsmSyn: TSynAsmSyn
    Left = 28
    Top = 324
  end
  object SynCS: TSynCSSyn
    KeyAttri.Foreground = clNavy
    StringAttri.Foreground = clRed
    Left = 104
    Top = 260
  end
  object SynPHPcomplex: TSynMultiSyn
    DefaultFilter = 
      'PHP Files (*.php,*.php3,*.phtml,*.inc)|*.php;*.php3;*.phtml;*.in' +
      'c'
    Schemes = <
      item
        CaseSensitive = False
        StartExpr = '<script'
        EndExpr = '</script>'
        Highlighter = SynJScript
        SchemeName = 'JavaScript'
      end
      item
        CaseSensitive = False
        StartExpr = '<\?'
        EndExpr = '\?>'
        Highlighter = SynPHPsimple
        SchemeName = 'PHP'
      end>
    DefaultHighlighter = SynHTML
    DefaultLanguageName = 'PHPcomplex'
    Left = 316
    Top = 128
  end
  object SynPythonSyn1: TSynPythonSyn
    Left = 316
    Top = 228
  end
end
