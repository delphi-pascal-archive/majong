object Fres: TFres
  Left = 214
  Top = 147
  Width = 391
  Height = 350
  Caption = 'Fres'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 369
    Height = 265
    Caption = 'Modes d'#39'affichage disponibles'
    TabOrder = 0
    object ListBox1: TListBox
      Left = 8
      Top = 16
      Width = 353
      Height = 238
      IntegralHeight = True
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = ListBox1DblClick
    end
  end
  object Button1: TButton
    Left = 11
    Top = 280
    Width = 174
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 200
    Top = 280
    Width = 177
    Height = 25
    Caption = 'Annuler'
    TabOrder = 2
    OnClick = Button2Click
  end
end
