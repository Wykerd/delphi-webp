unit u_vcl_example;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, libwebp, WebpHelpers, Winapi.GDIPAPI, Winapi.GDIPOBJ, Math, Vcl.WebpImage;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  img : TWebpImage;
begin
  img := TWebpImage.Create(self);
  img.Parent := self;
  img.Align := alClient;
  img.stretch := true;
  img.proportional := true;
  img.Center := true;
  img.LoadFromFile('_.webp');
end;

end.
