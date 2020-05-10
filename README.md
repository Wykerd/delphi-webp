# delphi-webp

Library for encoding and decoding Webp images in Delphi.

The library also provides a VCL component for rendering images in VCL applications.

Based on [Delphi Unit by Henri Gourvest](https://code.google.com/archive/p/delphi-webp/source/default/source)

Provides API and helper functions to use [libwebp by Google](https://developers.google.com/speed/webp/docs/api)

# Usage

You need to download or compile the latest libwebp dynamic link library to use this library. See [BUILDING.md](/BUILDING.md) for build instructions.

You can use the libwebp.pas unit to interact directly with the libwebp API, documentation for the API is available at https://developers.google.com/speed/webp/docs/api or you can use the WebpHelpers.pas unit which provide easy to use helper functions which wrap around the API. See below for documentation regarding the helpers.

## WebHelpers unit

This library provides some basic helper functions for encoding and decoding Webp formatted images.

### Encoding
There are two helpers for encoding images to Webp: `WebpEncode` and `WebpLosslessEncode`

These procedure allows you to encode images from other formats to Webp easily using the Windows API's GDI+ bitmap object and libwebp.

The procedures takes a TGPBitmap as input and outputs the resulting Webp image buffer to a stream or byte array.

See example usage below:

```pascal
var 
    bmp : TGPBitmap;
    ms : TMemoryStream;
begin
    ms := TMemoryStream.Create;
    bmp := TGPBitmap.Create('image.png');
    // params are 
    // 1. stream to write to
    // 2. bitmap object containing the image data
    // 3. Quality factor from 0 to 100
    WebpEncode(ms, bmp, 100);
    // WebpLosslessEncode(ms, bmp); // Lossless webp encode.
    // save the webp image to a file
    ms.SaveToFile('out.webp');
    // Remember to free the objects after use
    bmp.free;
    ms.free;
end.
```

### Decoding
There is a helper called `WebpDecode` to help with decoding Webp images and load it into a `TGPBitmap` object.

It takes a file stream as input and outputs the decoded image data buffer and bitmap object.

See usage example below:
```pascal
var
    fs : TFileStream;
    bmp : TGPBitmap;
    dat : PByte;
begin
    fs := TFileStream.Create('input.webp', fmOpenRead);
    WebpDecode(fs, dat, bmp);
    bmp.Save('decoded.png', gPNG);
    // Free the memory
    bmp.Free;
    fs.Free;
    // Free the buffer. You must use this function as the buffer must be free'd by the libwebp dll.
    WebPFree(dat);
end.
```

## VCL TWebpImage in Vcl.WebpImage unit

Control for displaying Webp images based on `TGraphicControl`. Coded to be easy to use. 

See example below or in file `examples\display_vcl`

```pascal
var
  img : TWebpImage;
begin
  img := TWebpImage.Create(self);
  img.Parent := self;
  img.Align := alClient;
  img.Stretch := true;
  img.Proportional := true;
  img.Center := true; // center image in canvas.
  // img.Offset := Point(10, 10); // offset the image on the canvas.
  // img.Scale := 1.5; // upscale the image. Great for making a image viewer.
  img.LoadFromFile('image.webp');
  // img.LoadFromStream(stream); // Load image from TStream or decendant
end.
```

# License
This code is licensed under the same terms as WebM:

Software License Agreement:  http://www.webmproject.org/license/software/

Additional IP Rights Grant:  http://www.webmproject.org/license/additional/