unit Ures;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,math;

type
  TFres = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Fres: TFres;
  VosModes: array[0..255] of TDevMode;
  InitialMode: integer;

implementation

uses UMaj;

{$R *.dfm}

function modeexiste(m:tdevicemode;i:integer):boolean;
begin
 result:=false;
 for i:=0 to i-1 do
  if (VosModes[i].dmPelsWidth=m.dmPelsWidth) and (VosModes[i].dmPelsHeight=m.dmPelsHeight) and (VosModes[i].dmBitsPerPel=m.dmBitsPerPel) then result:=true;
end;

procedure TFres.FormShow(Sender: TObject);
var
  Compteur,i: integer;
  m_X, m_y: real;
  m_profondeur: cardinal;
  nbCouleurs: extended;
  EncoreDesModes: bool;
  dm: TDeviceMode;
  hdc: THandle;
  sActuel: string;
begin
  Compteur := 0;
  ListBox1.Items.Clear;
  hdc := Form1.Canvas.Handle;
  m_x := GetDeviceCaps(hdc, HORZRES);
  m_y := GetDeviceCaps(hdc, VERTRES);
  m_Profondeur := GetDeviceCaps(hdc, BITSPIXEL);
  sActuel := '';
  i:=0;
  EnumDisplaySettings(nil, Compteur, dm);

  repeat
   if (dm.dmPelsWidth>=640) and (dm.dmPelsHeight>=480) then
   begin

    if not modeexiste(dm,i) then
     begin
      dm.dmDisplayFrequency:=0;
      if (m_x = dm.dmPelsWidth) and (m_y = dm.dmPelsHeight) and (m_profondeur = dm.dmBitsPerPel) then sActuel := ' -> Mode Actuel';
      nbCouleurs := Power(2, dm.dmBitsPerPel);
      ListBox1.Items.Add(IntToStr(dm.dmPelsWidth) +'x' +IntToStr(dm.dmPelsHeight)+' : ' + FloatToStr(nbCouleurs) +' Couleurs' + ' ' + sActuel);
      VosModes[i] := dm;
      inc(i);
      sActuel := '';
     end;

    end;
    Inc(Compteur);
    EncoreDesModes := EnumDisplaySettings(nil, Compteur, dm);
  until EncoreDesModes = False;
end;

procedure TFres.FormClose(Sender: TObject; var Action: TCloseAction);
begin
action:=cahide;
end;

procedure TFres.Button2Click(Sender: TObject);
begin
close;
end;

procedure TFres.Button1Click(Sender: TObject);
var
  UnNouveauMode: TDevMode;
begin
  if listbox1.ItemIndex=-1 then begin close;exit; end;
  //ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_HIDE);
  UnNouveauMode := VosModes[listbox1.ItemIndex];
  UnNouveauMode.dmDisplayFlags := DM_BITSPERPEL and DM_PELSWIDTH and DM_PELSHEIGHT and DM_DISPLAYFREQUENCY and DM_DISPLAYFLAGS;
  ChangeDisplaySettings(UnNouveauMode, CDS_UPDATEREGISTRY);
  //ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_RESTORE);
  ModifRes:=true;
  close;
end;

procedure TFres.ListBox1DblClick(Sender: TObject);
begin
Button1Click(self);
end;

end.
