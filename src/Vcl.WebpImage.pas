unit Vcl.WebpImage;

interface

uses
  System.Math,
  System.Classes,
  System.SysUtils,
  System.Types,
  Vcl.Controls,
  libwebp,
  WebpHelpers,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ;

type
  TWebpImage = class (TGraphicControl)
  private
    FBitmap: TGPBitmap;
    FData: PByte;
    FOffset: TPoint;
    FStretch: boolean;
    FCenter: boolean;
    FScale: real;
    FProportional: boolean;
    procedure SetOffset(const Value: TPoint);
    procedure SetCenter(const Value: boolean);
    procedure SetProportional(const Value: boolean);
    procedure SetScale(const Value: real);
    procedure SetStretch(const Value: boolean);
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Bitmap : TGPBitmap read FBitmap write FBitmap;
    property Stretch : boolean read FStretch write SetStretch;
    property Proportional : boolean read FProportional write SetProportional;
    property Center : boolean read FCenter write SetCenter;
    property Scale : real read FScale write SetScale;
    property Offset : TPoint read FOffset write SetOffset;
    procedure Paint; override;
    procedure LoadFromFile(filename: string);
    procedure LoadFromStream(stream : TStream);
  end;

implementation

{ TWebpImage }

constructor TWebpImage.Create(AOwner: TComponent);
begin
  inherited;
  Bitmap := TGPBitmap.Create();
  // defaults
  Stretch := false;
  Proportional := false;
  Scale := 1;
  Center := false;
  Offset := Point(0, 0);
end;

destructor TWebpImage.Destroy;
begin
  Bitmap.Destroy;
  WebPFree(FData);
  inherited;
end;

procedure TWebpImage.LoadFromFile(filename: string);
var
  fs : TFileStream;
  data : PByte;
begin
  WebPFree(FData);
  fs := TFileStream.Create(filename, fmOpenRead);
  try
    WebpDecode(fs, data, FBitmap);
    FData := data;
  finally
    fs.Free;
  end;
  Paint;
end;

procedure TWebpImage.LoadFromStream(stream: TStream);
var
  data: PByte;
begin
  WebPFree(FData);
  WebpDecode(stream, data, FBitmap);
  FData := data;
  Paint;
end;

procedure TWebpImage.Paint;
var
  G : TGPGraphics;
  destRect, srcRect : TGPRect;
begin
  inherited;
  // First Caculate the bounding rectangles
  destRect.X := 0;
  destRect.Y := 0;
  destRect.Width := Bitmap.GetWidth;
  destRect.Height := Bitmap.GetHeight;

  srcRect.X := 0;
  srcRect.Y := 0;
  srcRect.Width := Bitmap.GetWidth;
  srcRect.Height := Bitmap.GetHeight;

  if Stretch then
  begin
    destRect.Width := Width;
    destRect.Height := Height;
  end;

  destRect.Height := Floor(destRect.Height * Scale);
  destRect.Width := Floor(destRect.Width * Scale);

  if Stretch and Proportional then
  begin
    if (Height > 0) and (srcRect.Height > 0) then
      if (srcRect.Width / srcRect.Height) - (Width / Height) < 0 then
        destRect.Width := Floor(srcRect.Width * (destRect.Height / srcRect.Height))
      else
        destRect.Height := Floor(srcRect.Height * (destRect.Width / srcRect.Width))
  end;

  destRect.X := destRect.X - Offset.X;
  destRect.Y := destRect.Y - Offset.Y;

  if Center then
  begin
    destRect.X := Floor((Width / 2) - (destRect.Width / 2));
    destRect.Y := Floor((Height / 2) - (destRect.Height / 2));
  end;

  // Draw to canvas
  Canvas.Lock;
  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetCompositingMode(CompositingModeSourceOver);
    G.SetInterpolationMode(InterpolationModeDefault);
    G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.DrawImage(bitmap, destRect, srcRect.x, srcRect.Y, srcRect.Width, srcRect.Height, UnitPixel);
  finally
    G.Free;
    Canvas.Unlock;
  end;
end;

procedure TWebpImage.SetCenter(const Value: boolean);
begin
  FCenter := Value;
  if Parent <> nil then Paint
end;

procedure TWebpImage.SetOffset(const Value: TPoint);
begin
  FOffset := Value;
  if Parent <> nil then Paint
end;

procedure TWebpImage.SetProportional(const Value: boolean);
begin
  FProportional := Value;
  if Parent <> nil then Paint
end;

procedure TWebpImage.SetScale(const Value: real);
begin
  FScale := Value;
  if Parent <> nil then Paint
end;

procedure TWebpImage.SetStretch(const Value: boolean);
begin
  FStretch := Value;
  if Parent <> nil then Paint
end;

end.