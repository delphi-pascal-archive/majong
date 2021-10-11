object Form2: TForm2
  Left = 330
  Top = 158
  BorderStyle = bsDialog
  Caption = 'Scores'
  ClientHeight = 261
  ClientWidth = 233
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton6: TSpeedButton
    Left = 50
    Top = 8
    Width = 25
    Height = 25
    Hint = 'D'#233'cale vers la gauche'
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000130B0000130B00001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333333303333333333333300333333333333309033333
      3333333099903333333333099999000000033099999999999990099999999999
      9990309999999999999033099999000000033330999033333333333309033333
      3333333330033333333333333303333333333333333333333333}
    ParentShowHint = False
    ShowHint = True
    OnClick = SpeedButton6Click
  end
  object SpeedButton8: TSpeedButton
    Left = 150
    Top = 8
    Width = 25
    Height = 25
    Hint = 'D'#233'cale vers la droite'
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000130B0000130B00001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333333333303333333333333330033333333333333090
      3333333333330999033330000000999990330999999999999903099999999999
      9990099999999999990330000000999990333333333309990333333333333090
      3333333333333003333333333333303333333333333333333333}
    ParentShowHint = False
    ShowHint = True
    OnClick = SpeedButton8Click
  end
  object Label1: TLabel
    Left = 8
    Top = 44
    Width = 31
    Height = 13
    Caption = 'Nom : '
  end
  object Label2: TLabel
    Left = 80
    Top = 8
    Width = 65
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = '1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 93
    Width = 101
    Height = 13
    Caption = 'Temps (HH:MM:SS) :'
  end
  object Label4: TLabel
    Left = 56
    Top = 117
    Width = 17
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = ':'
  end
  object Label5: TLabel
    Left = 120
    Top = 117
    Width = 17
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = ':'
  end
  object Label6: TLabel
    Left = 8
    Top = 149
    Width = 129
    Height = 13
    Caption = 'Nombre de pi'#232'ces retir'#233'es :'
  end
  object Edit1: TEdit
    Left = 8
    Top = 64
    Width = 217
    Height = 21
    MaxLength = 20
    TabOrder = 0
  end
  object SpinEdit1: TSpinEdit
    Left = 8
    Top = 112
    Width = 49
    Height = 22
    MaxValue = 99
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object SpinEdit2: TSpinEdit
    Left = 72
    Top = 112
    Width = 49
    Height = 22
    MaxValue = 59
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object SpinEdit3: TSpinEdit
    Left = 136
    Top = 112
    Width = 49
    Height = 22
    MaxValue = 59
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object SpinEdit4: TSpinEdit
    Left = 8
    Top = 168
    Width = 65
    Height = 22
    MaxValue = 144
    MinValue = 0
    TabOrder = 4
    Value = 0
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 232
    Width = 105
    Height = 25
    TabOrder = 5
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 120
    Top = 232
    Width = 105
    Height = 25
    TabOrder = 6
    Kind = bkCancel
  end
  object BitBtn3: TBitBtn
    Left = 56
    Top = 200
    Width = 121
    Height = 25
    Caption = 'Supprimer'
    TabOrder = 7
    OnClick = BitBtn3Click
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      333333333333333333333333000033338833333333333333333F333333333333
      0000333911833333983333333388F333333F3333000033391118333911833333
      38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
      911118111118333338F3338F833338F3000033333911111111833333338F3338
      3333F8330000333333911111183333333338F333333F83330000333333311111
      8333333333338F3333383333000033333339111183333333333338F333833333
      00003333339111118333333333333833338F3333000033333911181118333333
      33338333338F333300003333911183911183333333383338F338F33300003333
      9118333911183333338F33838F338F33000033333913333391113333338FF833
      38F338F300003333333333333919333333388333338FFF830000333333333333
      3333333333333333333888330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
end
