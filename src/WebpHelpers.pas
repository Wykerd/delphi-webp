unit WebpHelpers;

interface

uses
  System.SysUtils,
  GDIPAPI,
  GDIPOBJ,
  System.Classes,
  libwebp;

// Encode GUID's from https://stackoverflow.com/questions/16368575/how-to-save-an-image-to-bmp-png-jpg-with-gdi
const
  gGIf: TGUID = '{557CF402-1A04-11D3-9A73-0000F81EF32E}';
  gPNG: TGUID = '{557CF406-1A04-11D3-9A73-0000F81EF32E}';
  gPJG: TGUID = '{557CF401-1A04-11D3-9A73-0000F81EF32E}';
  gBMP: TGUID = '{557CF400-1A04-11D3-9A73-0000F81EF32E}';
  gTIF: TGUID = '{557CF405-1A04-11D3-9A73-0000F81EF32E}';

/// <summary>
///   Compress image using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="stream">
///   Stream to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
/// <param name="quality_factor">
///   The image quality {0-100}. Default is 80.
/// </param>
procedure WebpEncode(var stream: TMemoryStream; img: TGPBitmap; quality_factor: Single = 80); overload;

/// <summary>
///   Compress image using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="buffer">
///   Buffer to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
/// <param name="quality_factor">
///   The image quality {0-100}. Default is 80.
/// </param>
procedure WebpEncode(var buffer: TBytes; img: TGPBitmap; quality_factor: Single = 80); overload;

/// <summary>
///   Compress image losslessly using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="stream">
///   Stream to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
procedure WebpLosslessEncode(var stream: TMemoryStream; img: TGPBitmap); overload;

/// <summary>
///   Compress image losslessly using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="buffer">
///   Buffer to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
procedure WebpLosslessEncode(var buffer: TBytes; img: TGPBitmap); overload;

/// <summary>
///   Decode image to GDI+ Bitmap
/// </summary>
/// <param name="fs">
///   File stream to decode
/// </param>
/// <param name="data">
///   The pointer to the raw decoded data in BGRA format (32bit). YOU MUST FREE IT WITH WebPFree(data)!
/// </param>
/// <param name="bitmap">
///   The bitmap data for the image. YOU MUST FREE IT WITH bitmap.Free!
/// </param>
procedure WebpDecode(fs: TStream; var data: PByte; var bitmap : TGPBitmap);

/// <summary>
///   Return version as string
/// </summary>
function GetWebpVersionString (versionhex : integer) : string;

implementation

procedure WebpEncode(var stream: TMemoryStream; img: TGPBitmap; quality_factor: Single = 80); overload;
var
  rect : TGPRect;
  bmpData: BitmapData;
  ptrEncoded : PByte;
  size: Cardinal;
begin
  // Get image size
  rect.X := 0;
  rect.Y := 0;
  rect.Width := img.GetWidth;
  rect.height := img.GetHeight;
  // Get image data
  img.LockBits(rect, 3, img.GetPixelFormat, bmpData);
  // Check if image has alpha layer.
  if IsAlphaPixelFormat(img.GetPixelFormat) then size := WebPEncodeBGRA(bmpData.Scan0, img.GetWidth, img.GetHeight, bmpData.Stride, quality_factor, ptrEncoded)
  else size := WebPEncodeBGR(bmpData.Scan0, img.GetWidth, img.GetHeight, bmpData.Stride, quality_factor, ptrEncoded);
  // Write buffer to stream
  stream.Write(ptrEncoded^, size);
  // Free buffer
  WebPFree(ptrEncoded);
end;

procedure WebpEncode(var buffer: TBytes; img: TGPBitmap; quality_factor: Single = 80); overload;
var
  stream : TMemoryStream;
begin
  // Helper to convert stream to buffer
  stream := TMemoryStream.Create;
  WebpEncode(stream, img, quality_factor);
  stream.Position := 0;
  SetLength(buffer, stream.Size);
  stream.ReadData(buffer, stream.Size);
  stream.Free;
end;

procedure WebpLosslessEncode(var stream: TMemoryStream; img: TGPBitmap); overload;
var
  rect : TGPRect;
  bmpData: BitmapData;
  ptrEncoded : PByte;
  size: Cardinal;
begin
  // Get image size
  rect.X := 0;
  rect.Y := 0;
  rect.Width := img.GetWidth;
  rect.height := img.GetHeight;
  // Get image data
  img.LockBits(rect, 3, img.GetPixelFormat, bmpData);
  // Check if image has alpha layer.
  if IsAlphaPixelFormat(img.GetPixelFormat) then size := WebPEncodeLosslessBGRA(bmpData.Scan0, img.GetWidth, img.GetHeight, bmpData.Stride, ptrEncoded)
  else size := WebPEncodeLosslessBGR(bmpData.Scan0, img.GetWidth, img.GetHeight, bmpData.Stride, ptrEncoded);
  // Write buffer to stream
  stream.Write(ptrEncoded^, size);
  // Free buffer
  WebPFree(ptrEncoded);
end;

procedure WebpLosslessEncode(var buffer: TBytes; img: TGPBitmap); overload;
var
  stream : TMemoryStream;
begin
  // Helper to convert stream to buffer
  stream := TMemoryStream.Create;
  WebpLosslessEncode(stream, img);
  stream.Position := 0;
  SetLength(buffer, stream.Size);
  stream.ReadData(buffer, stream.Size);
  stream.Free;
end;

procedure WebpDecode(fs: TStream; var data: PByte; var bitmap : TGPBitmap);
var
  buffer: TBytes;
  width, height: integer;
begin
  fs.Position := 0;
  setlength(buffer, fs.Size);
  fs.ReadBuffer(buffer, fs.size);
  data := WebPDecodeBGRA(@buffer[0], fs.Size, @width, @height);
  // Free buffer
  setlength(buffer, 0);
  // Load to image
  bitmap := TGPBitmap.Create(width, height, 4 * width, 2498570, data);
end;

function GetWebpVersionString (versionhex : integer) : string;
var
  maj, min, patch : integer;
begin
  // Determine version
  // Format for version is hex, where first 2 hex is maj, second min, third patch
  // E.g: v2.5.7 is 0x020507
  maj := versionhex div $10000;
  min := (versionhex - (maj * $10000)) div $100;
  patch := (versionhex - (maj * $10000) - (min * $100));
  result := maj.ToString + '.' + min.ToString + '.' + patch.ToString;
end;

end.
