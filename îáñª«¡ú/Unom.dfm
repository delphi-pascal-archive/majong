object Form3: TForm3
  Left = 211
  Top = 272
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Form3'
  ClientHeight = 88
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 60
    Height = 13
    Caption = 'Votre nom ? '
  end
  object Edit1: TEdit
    Left = 0
    Top = 24
    Width = 281
    Height = 21
    MaxLength = 20
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 32
    Top = 56
    Width = 209
    Height = 25
    TabOrder = 1
    Kind = bkOK
  end
end
