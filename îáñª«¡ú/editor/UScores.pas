unit UScores;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Spin;

type
  Tscores=array[1..20] of string[43];
type
  TForm2 = class(TForm)
    SpeedButton6: TSpeedButton;
    SpeedButton8: TSpeedButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    SpinEdit4: TSpinEdit;
    Label6: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Déclarations privées }
    procedure AfficheScore(n:byte);
    procedure SaveScore(n:byte);
  public
    { Déclarations publiques }
    scores:Tscores;
  end;

var
  Form2: TForm2;
  select:integer=1;

implementation

{$R *.dfm}


procedure TForm2.AfficheScore(n:byte);
var
 s:string;
 i,e:integer;
begin
 s:=scores[n];
 delete(s,1,4);
 edit1.Text:=trimright(copy(s,1,20));
 delete(s,1,20+4);
 val(copy(s,1,2),i,e); spinedit1.Value:=i;
 delete(s,1,3);
 val(copy(s,1,2),i,e); spinedit2.Value:=i;
 delete(s,1,3);
 val(copy(s,1,2),i,e); spinedit3.Value:=i;
 delete(s,1,6);
 val(s,i,e); spinedit4.Value:=i;

end;

procedure TForm2.SaveScore(n:byte);
var
 s:string;
 i:integer;
// '01.                      -- 99:59:59 -- 000'
begin
 s:='';
 if n<10 then s:=s+'0';
 s:=s+inttostr(n)+'. '+edit1.text+stringofchar(' ',20-length(edit1.Text))+' -- ';
 if spinedit1.value<10 then s:=s+'0';
 s:=s+inttostr(spinedit1.value)+':';
 if spinedit2.value<10 then s:=s+'0';
 s:=s+inttostr(spinedit2.value)+':';
 if spinedit3.value<10 then s:=s+'0';
 s:=s+inttostr(spinedit3.value)+' -- ';
 if spinedit3.value<10 then s:=s+'0';
 if spinedit4.value<100 then s:=s+'0';
 s:=s+inttostr(spinedit4.value);
 scores[n]:=s;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
 label2.caption:='1';
 select:=1;
 AfficheScore(1);
end;

procedure TForm2.SpeedButton6Click(Sender: TObject);
begin
if select>1 then
 begin
  savescore(select);
  dec(select);
  label2.Caption:=inttostr(select);
  affichescore(select);
 end;
end;

procedure TForm2.SpeedButton8Click(Sender: TObject);
begin
if select<20 then
 begin
  savescore(select);
  inc(select);
  label2.Caption:=inttostr(select);
  affichescore(select);
 end;
end;

procedure TForm2.BitBtn3Click(Sender: TObject);
var
 i:integer;
begin
for i:=select to 19 do scores[i]:=scores[i+1];
scores[20]:='20.                      -- 99:59:59 -- 000';
affichescore(select);
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
var
 i:integer;
begin
 for i:=1 to 20 do
  begin
   scores[i][1]:=char(48+i div 10);
   scores[i][2]:=char(48+i mod 10);
  end;

end;

end.
