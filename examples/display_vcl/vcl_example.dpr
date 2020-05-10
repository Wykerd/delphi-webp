program vcl_example;

uses
  Vcl.Forms,
  u_vcl_example in 'u_vcl_example.pas' {Form1},
  libwebp in '..\..\src\libwebp.pas',
  WebpHelpers in '..\..\src\WebpHelpers.pas',
  Vcl.WebpImage in '..\..\src\Vcl.WebpImage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
