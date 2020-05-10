program example;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  System.Classes,
  libwebp in '..\..\src\libwebp.pas',
  WebpHelpers in '..\..\src\WebpHelpers.pas';
  
var
  stream: TMemoryStream;
  fs: TFileStream;
  bmp : TGPBitmap;
  dat : PByte;
begin
  try
    WriteLn('Using libwebp encoder version: ' + GetWebpVersionString(WebPGetEncoderVersion));
    WriteLn('Using libwebp decoder version: ' + GetWebpVersionString(WebPGetDecoderVersion));
    // Demo
    stream := TMemoryStream.Create;
    bmp := TGPBitmap.Create('test.png');
    WebpEncode(stream, bmp, 100);
    stream.SaveToFile('_.webp');
    bmp.Free;
    stream.Free;
    Writeln('DONE ENCODE');
    fs := TFileStream.Create('_.webp', fmOpenRead);
    WebpDecode(fs, dat, bmp);
    bmp.Save('decoded.png', gPNG);
    bmp.free;
    WebPFree(dat);
    fs.Free;
    Writeln('DONE DECODE');
    writeln('DONE');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
