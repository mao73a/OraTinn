�
 TFMASCIICHART 0  TPF0TfmAsciiChartfmAsciiChartLeftTop� Width�HeightfCaptionASCII ChartColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style 	Icon.Data
�              �     (       @         �                       �  �   �� �   � � ��  ��� ��� �ʦ ��� ��� f�� 3�� ��� ��� ��� f�� 3��  �� ��� ̙� ��� f�� 3��  �� �f� �f� �f� ff� 3f�  f� �3� �3� �3� f3� 33�  3� � � � � f � 3 � ��� ��� ��� f�� f�� 3��  �� ��� ��� ��� f�� 3��  �� ��� ̙� ��� f�� 3��  �� �f� �f� �f� ff� 3f�  f� �3� �3� �3� f3� 33�  3� � � � � � � f � 3 �   � ��� ��� ��� f�� 3��  �� �̙ �̙ �̙ f̙ 3̙  ̙ ��� ̙� ��� f�� 3��  �� �f� �f� �f� ff� 3f�  f� �3� �3� �3� f3� 33�  3� � � � � � � f � 3 �   � ��f ��f ��f f�f 3�f  �f ��f ��f ��f f�f 3�f  �f ��f ̙f ��f f�f 3�f  �f �ff �ff �ff fff 3ff  ff �3f �3f �3f f3f 33f  3f � f � f � f f f 3 f   f ��3 ��3 ��3 f�3 3�3  �3 ��3 ��3 ��3 f�3 3�3  �3 ��3 ̙3 ��3 f�3 3�3  �3 �f3 �f3 �f3 ff3 3f3  f3 �33 �33 �33 f33 333  33 � 3 � 3 � 3 f 3 3 3   3 ��  ��  f�  3�  ��  ��  ��  f�  3�   �  ��  ̙  ��  f�  3�   �  �f  �f  �f  ff   f  3f  �3  �3  �3  f3  33   3  �   �   f   3     �   �   �   �   w   U   D   "  �   �   �   �   w   U   D   "  ��� UUU www www DDD """  w   U   D   "   ��� ��� ���   �  �   �� �   � � ��  ���                                                      ������                       �� ������                    ������������                  ������� ������                 ���������������                ��������� �����        ������� ��������� ���         � ����� ���������� �       ��� ������� ���������         ���� ��� ��  ���������          ���� ���  �����������          ���� �  ������������            ���  ��������������            ��������� ���������            �������   ���������             ����   ��������              ���� �� ��������               ���� � ���������               ���� � ���������                ����  ��������                 ����  ��������                  �������������                  �������������                  �����UU������                    ��UUU������                   UUU����                     U���                      U�                        U                                                                      ��������� �� �� �� �� �  �        �  �  ��  ��  ��  �� �� �� �� �� �� �� �� �� �� �� �� �������������
KeyPreview	OldCreateOrder	PositionpoDesktopCenterScaledShowHint	OnCreate
FormCreate	OnDestroyFormDestroyOnDeactivateFormDeactivate	OnKeyDownFormKeyDownOnMouseDownFormMouseDownOnMouseMoveFormMouseMove	OnMouseUpFormMouseUpOnPaint	FormPaintOnResize
FormResizeOnShowFormShowPixelsPerInch`
TextHeight TBevelBevel1Left TopWidth�HeightAlignalTopShape	bsTopLine  TPanelPanel1Left Top Width�HeightAlignalTop
BevelOuterbvNoneTabOrder  TSpeedButtonbtnCharHighLeftTop WidthHeightHint,Toggles display of High/Low ASCII Characters
GroupIndexCaption&HighParentShowHintShowHint	Spacing�OnClickbtnCharHighClick  TSpeedButton
btnCharIntLeft>Top WidthHeightHint,Toggles character values between Hex and Int
GroupIndexCaption&DecParentShowHintShowHint	Spacing�OnClickbtnCharIntClick  TSpeedButton
btnCharLowLeft Top WidthHeightHint,Toggles display of High/Low ASCII Characters
GroupIndexCaption&LowParentShowHintShowHint	Spacing�OnClickbtnCharHighClick  TSpeedButton
btnCharHexLeft\Top WidthHeightHint,Toggles character values between Hex and Int
GroupIndexCaptionHe&xParentShowHintShowHint	Spacing�OnClickbtnCharIntClick  TSpeedButton	sbtnValueLeft|Top Width!HeightHintReturns the value
GroupIndexCaption&ValueParentShowHintShowHint	OnClicksbtnValueClick  TSpeedButtonsbtnCharLeft� Top WidthHeightHintReturns the char
GroupIndexDown	Caption&CharParentShowHintShowHint	OnClicksbtnCharClick  	TComboBoxFontComboNameLeft� Top WidthtHeightHintCharacter FontStylecsDropDownListCtl3D	DropDownCountFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style 
ItemHeightParentCtl3D
ParentFontParentShowHintShowHint	TabOrder OnChangeFontComboNameChangeOnEnterFontComboNameEnter  TEditFontSizeEditLeft4Top WidthHeight	MaxLengthTabOrderText6OnChangeFontSizeEditChange  TUpDownFontSizeUpDownLeftQTop WidthHeight	AssociateFontSizeEditMinMaxPositionTabOrderWrapOnClickFontSizeUpDownClick  TEdittxtCharsLeftdTop WidthzHeightHintSelected CharactersAutoSizeParentShowHintShowHint	TabOrderVisible   
TStatusBar	StatusBarLeft Top6Width�HeightPanels SimplePanel  
TPopupMenu
PopupMenu1	AutoPopupOnPopupPopupMenu1PopupLeft@Top  	TMenuItemShowLowCharacters1CaptionShow Characters 0-127
GroupIndex	RadioItem	OnClickbtnCharHighClick  	TMenuItemShowHighCharacters1CaptionShow Characters 128-255
GroupIndex	RadioItem	OnClickbtnCharHighClick  	TMenuItemN3Caption-
GroupIndex  	TMenuItemCVIntCaptionCharacter Values as Integer
GroupIndex	RadioItem	OnClickbtnCharIntClick  	TMenuItemCVHexCaptionCharacter Values as Hex
GroupIndex	RadioItem	OnClickbtnCharIntClick  	TMenuItemN4Caption-
GroupIndex  	TMenuItem	FontSize8TagCaptionFont Size := 8
GroupIndex	RadioItem	OnClickbtnSizeClick  	TMenuItem
FontSize10Tag
CaptionFont Size := 10
GroupIndex	RadioItem	OnClickbtnSizeClick  	TMenuItem
FontSize12TagCaptionFont Size := 12
GroupIndex	RadioItem	OnClickbtnSizeClick  	TMenuItemN2Caption-
GroupIndex  	TMenuItemShowFontPalette1CaptionShow Font Palette
GroupIndexOnClickShowFontPalette1Click  	TMenuItemHintActive1Caption	Show HintChecked	
GroupIndexOnClickHintActive1Click  	TMenuItemN1Caption-
GroupIndex  	TMenuItemHelpCaptionHelp
GroupIndexShortCutp   TTimer	HintTimerInterval�OnTimerHintTimerTimerLeftTop    