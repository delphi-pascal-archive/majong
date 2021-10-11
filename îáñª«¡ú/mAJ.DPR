program maj;

uses
  Forms,
  UMaj in 'UMaj.pas' {Form1},
  Uscore in 'Uscore.pas' {Form2},
  Unom in 'Unom.pas' {Form3},
  Ures in 'Ures.pas' {Fres};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TFres, Fres);
  Application.Run;
end.
