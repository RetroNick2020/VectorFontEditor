{$MODE OBJFPC}{$H+}
{
  Borland CHR Stroke Font Library for Free Pascal
  
  Based on the CHR format used by Turbo Pascal/C BGI graphics.
  
  File Structure:
  1. Header:
     - "PK" signature (2 bytes)
     - Description string (variable, terminated by $1A)
     - Header size (2 bytes, typically $80)
     - Font name (4 bytes)
     - Font size (2 bytes)
     - Version info (4 bytes)
     - Padding to HeaderSize
  
  2. Stroke Header (at HeaderSize offset):
     - $2B marker (1 byte)
     - Character count (2 bytes)
     - Undefined (1 byte)
     - Starting character (1 byte)
     - Strokes offset (2 bytes) - offset from stroke header to stroke data
     - Scan flag (1 byte)
     - Origin to ascender (1 byte, signed)
     - Origin to baseline (1 byte, signed)
     - Origin to descender (1 byte, signed)
     - Reserved (5 bytes)
     
  3. Character offset table (2 bytes per character)
  4. Character width table (1 byte per character)
  5. Stroke data
  
  Stroke encoding:
  - 2 bytes per command
  - Byte 0: bit 7 = X operation (0=end/scan, 1=move/draw), bits 6-0 = |X| with bit 6 as sign
  - Byte 1: bit 7 = Y operation (0=move, 1=draw), bits 6-0 = |Y| with bit 6 as sign
  - $00 $00 = end of character
  - $00 $80 = scan (special marker)
}
unit BorlandCHR;

interface

uses
  Classes, SysUtils;

const
  CHR_MAX_GLYPHS = 256;
  CHR_MAX_STROKES = 4096;

type
  TCHRStrokeCmd = (chsMoveTo, chsLineTo, chsEnd, chsScan);
  
  TCHRStrokePoint = record
    Cmd: TCHRStrokeCmd;
    X, Y: Integer;
  end;
  
  TCHRGlyph = record
    Width: Integer;
    Strokes: array of TCHRStrokePoint;
    StrokeCount: Integer;
    Defined: Boolean;
  end;
  
  TCHRFont = class
  private
    FGlyphs: array[0..CHR_MAX_GLYPHS-1] of TCHRGlyph;
    FDescription: string;
    FFontName: string;
    FFirstChar: Integer;
    FLastChar: Integer;
    FCharacterCount: Integer;
    FOriginToAscender: ShortInt;
    FOriginToBaseline: ShortInt;
    FOriginToDescender: ShortInt;
    FHeaderSize: Word;
    FLoaded: Boolean;
    
    function ReadByte(Stream: TStream): Byte;
    function ReadWord(Stream: TStream): Word;
    function ReadSignedByte(Stream: TStream): ShortInt;
    procedure WriteByte(Stream: TStream; B: Byte);
    procedure WriteWord(Stream: TStream; W: Word);
    procedure WriteSignedByte(Stream: TStream; B: ShortInt);
    
    procedure EncodeStrokeCommand(Stream: TStream; const Cmd: TCHRStrokePoint);
  public
    constructor Create;
    destructor Destroy; override;
    
    function LoadFromFile(const FileName: string): Boolean;
    function LoadFromStream(Stream: TStream): Boolean;
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure Clear;
    
    // Glyph access
    function GetGlyph(CharCode: Integer): TCHRGlyph;
    procedure SetGlyph(CharCode: Integer; const Glyph: TCHRGlyph);
    function GetStrokeCount(CharCode: Integer): Integer;
    function GetStrokePoint(CharCode, StrokeIdx: Integer; out Cmd: TCHRStrokeCmd; out X, Y: Integer): Boolean;
    function GetCharWidth(CharCode: Integer): Integer;
    
    // Properties
    property Description: string read FDescription write FDescription;
    property FontName: string read FFontName write FFontName;
    property FirstChar: Integer read FFirstChar write FFirstChar;
    property LastChar: Integer read FLastChar;
    property CharacterCount: Integer read FCharacterCount;
    property OriginToAscender: ShortInt read FOriginToAscender write FOriginToAscender;
    property OriginToBaseline: ShortInt read FOriginToBaseline write FOriginToBaseline;
    property OriginToDescender: ShortInt read FOriginToDescender write FOriginToDescender;
    property Loaded: Boolean read FLoaded;
  end;

implementation

constructor TCHRFont.Create;
var
  I: Integer;
begin
  inherited Create;
  FDescription := 'Created with Vector Font Editor';
  FFontName := 'FONT';
  FFirstChar := 32;
  FCharacterCount := 0;
  FOriginToAscender := 8;
  FOriginToBaseline := 0;
  FOriginToDescender := -2;
  FHeaderSize := $80;
  FLoaded := False;
  
  for I := 0 to CHR_MAX_GLYPHS - 1 do
  begin
    FGlyphs[I].Width := 8;
    FGlyphs[I].StrokeCount := 0;
    FGlyphs[I].Defined := False;
    SetLength(FGlyphs[I].Strokes, 0);
  end;
end;

destructor TCHRFont.Destroy;
var
  I: Integer;
begin
  for I := 0 to CHR_MAX_GLYPHS - 1 do
    SetLength(FGlyphs[I].Strokes, 0);
  inherited Destroy;
end;

procedure TCHRFont.Clear;
var
  I: Integer;
begin
  for I := 0 to CHR_MAX_GLYPHS - 1 do
  begin
    FGlyphs[I].Width := 8;
    FGlyphs[I].StrokeCount := 0;
    FGlyphs[I].Defined := False;
    SetLength(FGlyphs[I].Strokes, 0);
  end;
  FLoaded := False;
  FCharacterCount := 0;
end;

function TCHRFont.ReadByte(Stream: TStream): Byte;
begin
  if Stream.Read(Result, 1) < 1 then
    Result := 0;
end;

function TCHRFont.ReadWord(Stream: TStream): Word;
var
  B: array[0..1] of Byte;
begin
  if Stream.Read(B, 2) < 2 then
    Result := 0
  else
    Result := B[0] or (Word(B[1]) shl 8);
end;

function TCHRFont.ReadSignedByte(Stream: TStream): ShortInt;
var
  B: Byte;
begin
  if Stream.Read(B, 1) < 1 then
    Result := 0
  else
    Result := ShortInt(B);
end;

procedure TCHRFont.WriteByte(Stream: TStream; B: Byte);
begin
  Stream.WriteBuffer(B, 1);
end;

procedure TCHRFont.WriteWord(Stream: TStream; W: Word);
var
  B: array[0..1] of Byte;
begin
  B[0] := W and $FF;
  B[1] := (W shr 8) and $FF;
  Stream.WriteBuffer(B, 2);
end;

procedure TCHRFont.WriteSignedByte(Stream: TStream; B: ShortInt);
begin
  Stream.WriteBuffer(B, 1);
end;

function TCHRFont.LoadFromFile(const FileName: string): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

function TCHRFont.LoadFromStream(Stream: TStream): Boolean;
var
  Sig: array[0..1] of Char;
  Ch: Char;
  I, J, CharIdx: Integer;
  StrokeCheck: Byte;
  CharOffsets: array of Word;
  CharWidths: array of Byte;
  StrokesOffset: SmallInt;
  StrokeDataStart: Int64;
  HeaderStart: Int64;
  FontNameField: array[0..3] of Char;
  XByte, YByte: Byte;
  XOp, YOp: Byte;
  XVal, YVal: ShortInt;
  StrokeIdx: Integer;
  MaxIterations: Integer;
begin
  Result := False;
  Clear;
  
  // Read and verify signature
  Stream.Read(Sig, 2);
  if (Sig[0] <> 'P') or (Sig[1] <> 'K') then Exit;
  
  // Read description (until $1A marker)
  FDescription := '';
  while Stream.Position < 256 do
  begin
    Stream.Read(Ch, 1);
    if Ch = #$1A then Break;
    if Ord(Ch) >= 32 then
      FDescription := FDescription + Ch;
  end;
  
  // Read header info
  FHeaderSize := ReadWord(Stream);
  Stream.Read(FontNameField, 4);
  FFontName := string(FontNameField);
  ReadWord(Stream); // Font size
  ReadByte(Stream); // Font major
  ReadByte(Stream); // Font minor
  ReadByte(Stream); // Revision major
  ReadByte(Stream); // Revision minor
  
  // Skip to stroke header at HeaderSize
  HeaderStart := FHeaderSize;
  Stream.Position := HeaderStart;
  
  // Read stroke header
  StrokeCheck := ReadByte(Stream);
  if StrokeCheck <> $2B then Exit; // Not a stroked font
  
  FCharacterCount := SmallInt(ReadWord(Stream));
  ReadByte(Stream); // Undefined
  FFirstChar := ReadByte(Stream);
  StrokesOffset := SmallInt(ReadWord(Stream));
  ReadSignedByte(Stream); // Scan flag
  FOriginToAscender := ReadSignedByte(Stream);
  FOriginToBaseline := ReadSignedByte(Stream);
  FOriginToDescender := ReadSignedByte(Stream);
  
  // Skip reserved bytes (4 bytes font name + 1 undefined)
  Stream.Read(FontNameField, 4);
  ReadByte(Stream);
  
  FLastChar := FFirstChar + FCharacterCount - 1;
  
  // Validate character count
  if (FCharacterCount <= 0) or (FCharacterCount > 256) then Exit;
  
  // Read character offset table
  SetLength(CharOffsets, FCharacterCount);
  for I := 0 to FCharacterCount - 1 do
    CharOffsets[I] := ReadWord(Stream);
  
  // Read character width table
  SetLength(CharWidths, FCharacterCount);
  for I := 0 to FCharacterCount - 1 do
    CharWidths[I] := ReadByte(Stream);
  
  // Calculate stroke data start position
  StrokeDataStart := HeaderStart + StrokesOffset;
  
  // Parse stroke data for each character
  for I := 0 to FCharacterCount - 1 do
  begin
    CharIdx := FFirstChar + I;
    if (CharIdx < 0) or (CharIdx >= CHR_MAX_GLYPHS) then Continue;
    
    FGlyphs[CharIdx].Width := CharWidths[I];
    FGlyphs[CharIdx].Defined := True;
    
    // Position at character's stroke data
    Stream.Position := StrokeDataStart + CharOffsets[I];
    
    // Allocate max strokes, will trim later
    SetLength(FGlyphs[CharIdx].Strokes, CHR_MAX_STROKES);
    StrokeIdx := 0;
    MaxIterations := 1000;
    
    while (Stream.Position < Stream.Size) and (MaxIterations > 0) and (StrokeIdx < CHR_MAX_STROKES) do
    begin
      Dec(MaxIterations);
      
      XByte := ReadByte(Stream);
      YByte := ReadByte(Stream);
      
      // Extract opcode bits (bit 7)
      XOp := (XByte shr 7) and 1;
      YOp := (YByte shr 7) and 1;
      
      // End of character (both opcodes 0)
      if (XOp = 0) and (YOp = 0) then
        Break;
      
      // Scan marker (XOp=0, YOp=1) - skip
      if (XOp = 0) and (YOp = 1) then
        Continue;
      
      // MoveTo or LineTo command
      // Decode using sign extension: bits 0-6 as value, bit 6 extended to bit 7 for sign
      // Formula: (byte & 0x7F) | ((byte & 0x40) << 1)
      XVal := ShortInt((XByte and $7F) or ((XByte and $40) shl 1));
      YVal := ShortInt((YByte and $7F) or ((YByte and $40) shl 1));
      // Negate Y as per BGI format (Y is stored inverted relative to screen coordinates)
      YVal := -YVal;
      
      // Determine operation: XOp=1 means valid move/draw, YOp determines which
      if XOp = 1 then
      begin
        if YOp = 0 then
          FGlyphs[CharIdx].Strokes[StrokeIdx].Cmd := chsMoveTo
        else
          FGlyphs[CharIdx].Strokes[StrokeIdx].Cmd := chsLineTo;
        
        FGlyphs[CharIdx].Strokes[StrokeIdx].X := XVal;
        FGlyphs[CharIdx].Strokes[StrokeIdx].Y := YVal;
        Inc(StrokeIdx);
      end;
    end;
    
    FGlyphs[CharIdx].StrokeCount := StrokeIdx;
    SetLength(FGlyphs[CharIdx].Strokes, StrokeIdx);
  end;
  
  SetLength(CharOffsets, 0);
  SetLength(CharWidths, 0);
  
  FLoaded := True;
  Result := True;
end;

procedure TCHRFont.EncodeStrokeCommand(Stream: TStream; const Cmd: TCHRStrokePoint);
var
  XByte, YByte: Byte;
  XVal, YVal: ShortInt;
begin
  case Cmd.Cmd of
    chsEnd:
      begin
        WriteByte(Stream, $00);
        WriteByte(Stream, $00);
      end;
    chsScan:
      begin
        WriteByte(Stream, $00);
        WriteByte(Stream, $80);
      end;
    chsMoveTo:
      begin
        XVal := Cmd.X;
        YVal := Cmd.Y;  // Store Y as-is (positive = above baseline)
        
        // Encode X: bit 7 = 1 (opcode for move/draw), bits 0-6 = signed value
        XByte := Byte(XVal) and $7F;
        XByte := XByte or $80;  // Set opcode bit
        
        // Encode Y: bit 7 = 0 (MoveTo), bits 0-6 = signed value
        YByte := Byte(YVal) and $7F;
        // bit 7 stays 0 for MoveTo
        
        WriteByte(Stream, XByte);
        WriteByte(Stream, YByte);
      end;
    chsLineTo:
      begin
        XVal := Cmd.X;
        YVal := Cmd.Y;  // Store Y as-is (positive = above baseline)
        
        // Encode X: bit 7 = 1 (opcode), bits 0-6 = signed value
        XByte := Byte(XVal) and $7F;
        XByte := XByte or $80;  // Set opcode bit
        
        // Encode Y: bit 7 = 1 (LineTo), bits 0-6 = signed value
        YByte := Byte(YVal) and $7F;
        YByte := YByte or $80;  // Set opcode bit for LineTo
        
        WriteByte(Stream, XByte);
        WriteByte(Stream, YByte);
      end;
  end;
end;

procedure TCHRFont.SaveToFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCHRFont.SaveToStream(Stream: TStream);
var
  I, J: Integer;
  DescWithMarker: string;
  Padding: array[0..127] of Byte;
  PadLen: Integer;
  FontNameField: array[0..3] of Char;
  StrokesOffset: SmallInt;
  CharOffsets: array of Word;
  CharWidths: array of Byte;
  StrokeData: TMemoryStream;
  CurrentOffset: Word;
  EndCmd: TCHRStrokePoint;
  FontSizePos, FontSize: Word;
  DataStartPos: Int64;
begin
  // Find first and last defined characters
  FFirstChar := 255;
  FLastChar := 0;
  for I := 0 to CHR_MAX_GLYPHS - 1 do
    if FGlyphs[I].Defined then
    begin
      if I < FFirstChar then FFirstChar := I;
      if I > FLastChar then FLastChar := I;
    end;
  
  if FFirstChar > FLastChar then
  begin
    FFirstChar := 32;
    FLastChar := 127;
  end;
  
  FCharacterCount := FLastChar - FFirstChar + 1;
  
  // Write PK signature
  WriteByte(Stream, Ord('P'));
  WriteByte(Stream, Ord('K'));
  
  // Write description with $1A terminator
  DescWithMarker := #8#8+FDescription + #$1A;
  Stream.Write(DescWithMarker[1], Length(DescWithMarker));
  
  // Write header size
  WriteWord(Stream, FHeaderSize);
  
  // Write font name (4 chars)
  FillChar(FontNameField, 4, ' ');
  for I := 0 to Length(FFontName) - 1 do
    if I < 4 then
      FontNameField[I] := FFontName[I + 1];
  Stream.Write(FontNameField, 4);
  
  // Font size placeholder (will update later)
  FontSizePos := Stream.Position;
  WriteWord(Stream, 0);
  
  // Version info
  WriteByte(Stream, 1); // Font major
  WriteByte(Stream, 0); // Font minor
  WriteByte(Stream, 1); // Revision major
  WriteByte(Stream, 0); // Revision minor
  
  // Pad to header size
  FillChar(Padding, SizeOf(Padding), 0);
  PadLen := FHeaderSize - Stream.Position;
  if PadLen > 0 then
    Stream.Write(Padding, PadLen);
  
  DataStartPos := Stream.Position;
  
  // Build stroke data first to calculate offsets
  StrokeData := TMemoryStream.Create;
  try
    SetLength(CharOffsets, FCharacterCount);
    SetLength(CharWidths, FCharacterCount);
    CurrentOffset := 0;
    
    for I := 0 to FCharacterCount - 1 do
    begin
      CharOffsets[I] := CurrentOffset;
      CharWidths[I] := FGlyphs[FFirstChar + I].Width;
      
      // Write stroke commands
      for J := 0 to FGlyphs[FFirstChar + I].StrokeCount - 1 do
        EncodeStrokeCommand(StrokeData, FGlyphs[FFirstChar + I].Strokes[J]);
      
      // Write end marker
      EndCmd.Cmd := chsEnd;
      EndCmd.X := 0;
      EndCmd.Y := 0;
      EncodeStrokeCommand(StrokeData, EndCmd);
      
      CurrentOffset := StrokeData.Position;
    end;
    
    // Calculate strokes offset: header (16) + offsets (count*2) + widths (count)
    StrokesOffset := 16 + (FCharacterCount * 2) + FCharacterCount;
    
    // Write stroke header
    WriteByte(Stream, $2B); // Stroke font marker
    WriteWord(Stream, FCharacterCount);
    WriteByte(Stream, 0); // Undefined
    WriteByte(Stream, FFirstChar);
    WriteWord(Stream, StrokesOffset);
    WriteByte(Stream, 0); // Scan flag
    WriteSignedByte(Stream, FOriginToAscender);
    WriteSignedByte(Stream, FOriginToBaseline);
    WriteSignedByte(Stream, FOriginToDescender);
    FillChar(FontNameField, 4, 0);
    Stream.Write(FontNameField, 4);
    WriteByte(Stream, 0); // Undefined
    
    // Write character offset table
    for I := 0 to FCharacterCount - 1 do
      WriteWord(Stream, CharOffsets[I]);
    
    // Write character width table
    for I := 0 to FCharacterCount - 1 do
      WriteByte(Stream, CharWidths[I]);
    
    // Write stroke data
    StrokeData.Position := 0;
    Stream.CopyFrom(StrokeData, StrokeData.Size);
    
    // Update font size in header
    FontSize := Stream.Position - DataStartPos;
    Stream.Position := FontSizePos;
    WriteWord(Stream, FontSize);
    
  finally
    StrokeData.Free;
  end;
  
  SetLength(CharOffsets, 0);
  SetLength(CharWidths, 0);
end;

function TCHRFont.GetGlyph(CharCode: Integer): TCHRGlyph;
begin
  if (CharCode >= 0) and (CharCode < CHR_MAX_GLYPHS) then
    Result := FGlyphs[CharCode]
  else
  begin
    Result.Width := 8;
    Result.StrokeCount := 0;
    Result.Defined := False;
  end;
end;

procedure TCHRFont.SetGlyph(CharCode: Integer; const Glyph: TCHRGlyph);
var
  I: Integer;
begin
  if (CharCode < 0) or (CharCode >= CHR_MAX_GLYPHS) then Exit;
  
  FGlyphs[CharCode].Width := Glyph.Width;
  FGlyphs[CharCode].StrokeCount := Glyph.StrokeCount;
  FGlyphs[CharCode].Defined := Glyph.Defined;
  SetLength(FGlyphs[CharCode].Strokes, Glyph.StrokeCount);
  for I := 0 to Glyph.StrokeCount - 1 do
    FGlyphs[CharCode].Strokes[I] := Glyph.Strokes[I];
end;

function TCHRFont.GetStrokeCount(CharCode: Integer): Integer;
begin
  if (CharCode >= 0) and (CharCode < CHR_MAX_GLYPHS) and FGlyphs[CharCode].Defined then
    Result := FGlyphs[CharCode].StrokeCount
  else
    Result := 0;
end;

function TCHRFont.GetStrokePoint(CharCode, StrokeIdx: Integer; out Cmd: TCHRStrokeCmd; out X, Y: Integer): Boolean;
begin
  Result := False;
  Cmd := chsMoveTo;
  X := 0;
  Y := 0;
  
  if (CharCode < 0) or (CharCode >= CHR_MAX_GLYPHS) then Exit;
  if not FGlyphs[CharCode].Defined then Exit;
  if (StrokeIdx < 0) or (StrokeIdx >= FGlyphs[CharCode].StrokeCount) then Exit;
  
  Cmd := FGlyphs[CharCode].Strokes[StrokeIdx].Cmd;
  X := FGlyphs[CharCode].Strokes[StrokeIdx].X;
  Y := FGlyphs[CharCode].Strokes[StrokeIdx].Y;
  Result := True;
end;

function TCHRFont.GetCharWidth(CharCode: Integer): Integer;
begin
  if (CharCode >= 0) and (CharCode < CHR_MAX_GLYPHS) and FGlyphs[CharCode].Defined then
    Result := FGlyphs[CharCode].Width
  else
    Result := 8;
end;

end.
