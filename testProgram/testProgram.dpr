program testProgram;

uses
  Vcl.Forms,
  unit1 in 'unit1.pas' {Form1},
  TProgramRegistrationClass in '..\TProgramRegistrationClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
