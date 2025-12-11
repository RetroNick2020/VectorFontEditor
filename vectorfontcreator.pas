{$MODE OBJFPC}{$H+}
{
  Windows Vector FON Font Creator Library for Free Pascal
  
  Creates Windows 2.x/3.x NE format FON files with vector (stroke) fonts.
  
  Vector fonts store characters as a series of pen strokes (MoveTo/LineTo commands)
  rather than bitmaps, allowing them to scale smoothly to any size.
}
unit VectorFontCreator;

interface

uses
  Classes, SysUtils;

const
  MAX_GLYPHS = 256;
  MAX_STROKES = 1024;

type
  TStrokeCmd = (scMoveTo, scLineTo);
  
  TStrokePoint = record
    Cmd: TStrokeCmd;
    X, Y: Integer;
  end;
  
  TVectorGlyph = record
    Width: Integer;
    Strokes: array of TStrokePoint;
    StrokeCount: Integer;
    Defined: Boolean;
  end;
  
  TFontWeight = (fwNormal = 400, fwBold = 700);
  TFontCharSet = (csANSI = 0, csDefault = 1, csSymbol = 2, csOEM = 255);
  TFontPitchFamily = (pfDefault = 0, pfFixed = 1, pfVariable = 2,
                      pfRoman = 16, pfSwiss = 32, pfModern = 48,
                      pfScript = 64, pfDecorative = 80);

  TVectorFontCreator = class
  private
    FGlyphs: array[0..MAX_GLYPHS-1] of TVectorGlyph;
    FFontName: string;
    FCopyright: string;
    FPointSize: Integer;
    FHeight: Integer;
    FAscent: Integer;
    FWeight: TFontWeight;
    FItalic: Boolean;
    FUnderline: Boolean;
    FStrikeOut: Boolean;
    FCharSet: TFontCharSet;
    FPitchFamily: TFontPitchFamily;
    FFirstChar: Integer;
    FLastChar: Integer;
    
    procedure WriteWord(Stream: TStream; W: Word);
    procedure WriteDWord(Stream: TStream; DW: LongWord);
    procedure WriteByte(Stream: TStream; B: Byte);
    procedure WriteString(Stream: TStream; const S: string; Len: Integer);
    function BuildFontResource: TMemoryStream;
    function BuildNEExecutable(FontRes: TMemoryStream): TMemoryStream;
  public
    constructor Create;
    destructor Destroy; override;
    
    // Set character strokes
    procedure SetCharacter(CharCode: Integer; const Strokes: array of TStrokePoint; CharWidth: Integer);
    procedure ClearCharacter(CharCode: Integer);
    procedure ClearAll;
    
    // Get character data
    function GetGlyph(CharCode: Integer): TVectorGlyph;
    function HasCharacter(CharCode: Integer): Boolean;
    
    // Add strokes to a character
    procedure BeginChar(CharCode: Integer; CharWidth: Integer);
    procedure MoveTo(CharCode: Integer; X, Y: Integer);
    procedure LineTo(CharCode: Integer; X, Y: Integer);
    
    // Save to file
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    
    // Font properties
    property FontName: string read FFontName write FFontName;
    property Copyright: string read FCopyright write FCopyright;
    property PointSize: Integer read FPointSize write FPointSize;
    property Height: Integer read FHeight write FHeight;
    property Ascent: Integer read FAscent write FAscent;
    property Weight: TFontWeight read FWeight write FWeight;
    property Italic: Boolean read FItalic write FItalic;
    property Underline: Boolean read FUnderline write FUnderline;
    property StrikeOut: Boolean read FStrikeOut write FStrikeOut;
    property CharSet: TFontCharSet read FCharSet write FCharSet;
    property PitchFamily: TFontPitchFamily read FPitchFamily write FPitchFamily;
  end;

implementation

constructor TVectorFontCreator.Create;
var
  I: Integer;
begin
  inherited Create;
  FFontName := 'Vector';
  FCopyright := 'Created with VectorFontCreator';
  FPointSize := 12;
  FHeight := 16;
  FAscent := 12;
  FWeight := fwNormal;
  FItalic := False;
  FUnderline := False;
  FStrikeOut := False;
  FCharSet := csANSI;
  FPitchFamily := pfVariable;
  FFirstChar := 32;
  FLastChar := 255;
  
  for I := 0 to MAX_GLYPHS - 1 do
  begin
    FGlyphs[I].Width := 0;
    FGlyphs[I].StrokeCount := 0;
    FGlyphs[I].Defined := False;
    SetLength(FGlyphs[I].Strokes, 0);
  end;
end;

destructor TVectorFontCreator.Destroy;
var
  I: Integer;
begin
  for I := 0 to MAX_GLYPHS - 1 do
    SetLength(FGlyphs[I].Strokes, 0);
  inherited Destroy;
end;

procedure TVectorFontCreator.WriteWord(Stream: TStream; W: Word);
begin
  Stream.WriteBuffer(W, 2);
end;

procedure TVectorFontCreator.WriteDWord(Stream: TStream; DW: LongWord);
begin
  Stream.WriteBuffer(DW, 4);
end;

procedure TVectorFontCreator.WriteByte(Stream: TStream; B: Byte);
begin
  Stream.WriteBuffer(B, 1);
end;

procedure TVectorFontCreator.WriteString(Stream: TStream; const S: string; Len: Integer);
var
  I: Integer;
  B: Byte;
begin
  for I := 1 to Len do
  begin
    if I <= Length(S) then
      B := Ord(S[I])
    else
      B := 0;
    WriteByte(Stream, B);
  end;
end;

procedure TVectorFontCreator.SetCharacter(CharCode: Integer; const Strokes: array of TStrokePoint; CharWidth: Integer);
var
  I: Integer;
begin
  if (CharCode < 0) or (CharCode >= MAX_GLYPHS) then Exit;
  
  FGlyphs[CharCode].Width := CharWidth;
  FGlyphs[CharCode].StrokeCount := Length(Strokes);
  SetLength(FGlyphs[CharCode].Strokes, Length(Strokes));
  for I := 0 to High(Strokes) do
    FGlyphs[CharCode].Strokes[I] := Strokes[I];
  FGlyphs[CharCode].Defined := True;
end;

procedure TVectorFontCreator.ClearCharacter(CharCode: Integer);
begin
  if (CharCode < 0) or (CharCode >= MAX_GLYPHS) then Exit;
  
  FGlyphs[CharCode].Width := 0;
  FGlyphs[CharCode].StrokeCount := 0;
  SetLength(FGlyphs[CharCode].Strokes, 0);
  FGlyphs[CharCode].Defined := False;
end;

procedure TVectorFontCreator.ClearAll;
var
  I: Integer;
begin
  for I := 0 to MAX_GLYPHS - 1 do
    ClearCharacter(I);
end;

function TVectorFontCreator.GetGlyph(CharCode: Integer): TVectorGlyph;
begin
  if (CharCode >= 0) and (CharCode < MAX_GLYPHS) then
    Result := FGlyphs[CharCode]
  else
  begin
    Result.Width := 0;
    Result.StrokeCount := 0;
    Result.Defined := False;
  end;
end;

function TVectorFontCreator.HasCharacter(CharCode: Integer): Boolean;
begin
  Result := (CharCode >= 0) and (CharCode < MAX_GLYPHS) and FGlyphs[CharCode].Defined;
end;

procedure TVectorFontCreator.BeginChar(CharCode: Integer; CharWidth: Integer);
begin
  if (CharCode < 0) or (CharCode >= MAX_GLYPHS) then Exit;
  
  FGlyphs[CharCode].Width := CharWidth;
  FGlyphs[CharCode].StrokeCount := 0;
  SetLength(FGlyphs[CharCode].Strokes, 0);
  FGlyphs[CharCode].Defined := True;
end;

procedure TVectorFontCreator.MoveTo(CharCode: Integer; X, Y: Integer);
var
  Idx: Integer;
begin
  if (CharCode < 0) or (CharCode >= MAX_GLYPHS) then Exit;
  if not FGlyphs[CharCode].Defined then Exit;
  
  Idx := FGlyphs[CharCode].StrokeCount;
  Inc(FGlyphs[CharCode].StrokeCount);
  SetLength(FGlyphs[CharCode].Strokes, FGlyphs[CharCode].StrokeCount);
  FGlyphs[CharCode].Strokes[Idx].Cmd := scMoveTo;
  FGlyphs[CharCode].Strokes[Idx].X := X;
  FGlyphs[CharCode].Strokes[Idx].Y := Y;
end;

procedure TVectorFontCreator.LineTo(CharCode: Integer; X, Y: Integer);
var
  Idx: Integer;
begin
  if (CharCode < 0) or (CharCode >= MAX_GLYPHS) then Exit;
  if not FGlyphs[CharCode].Defined then Exit;
  
  Idx := FGlyphs[CharCode].StrokeCount;
  Inc(FGlyphs[CharCode].StrokeCount);
  SetLength(FGlyphs[CharCode].Strokes, FGlyphs[CharCode].StrokeCount);
  FGlyphs[CharCode].Strokes[Idx].Cmd := scLineTo;
  FGlyphs[CharCode].Strokes[Idx].X := X;
  FGlyphs[CharCode].Strokes[Idx].Y := Y;
end;

function TVectorFontCreator.BuildFontResource: TMemoryStream;
var
  I, J: Integer;
  CharCount: Integer;
  CharTableOffset: LongWord;
  StrokeDataOffset: LongWord;
  DeviceNameOffset: LongWord;
  FaceNameOffset: LongWord;
  StrokeOffsets: array of Word;
  TotalStrokeBytes: Integer;
  FirstDef, LastDef: Integer;
  AvgWidth, MaxWidth: Integer;
  WidthSum, DefCount: Integer;
  CurX, CurY: Integer;
  DX, DY: Integer;
  StrokeBytes: array of Byte;
  HeaderSize: Integer;
begin
  Result := TMemoryStream.Create;
  
  // Find first and last defined characters
  FirstDef := 255;
  LastDef := 0;
  for I := 0 to 255 do
    if FGlyphs[I].Defined and (FGlyphs[I].StrokeCount > 0) then
    begin
      if I < FirstDef then FirstDef := I;
      if I > LastDef then LastDef := I;
    end;
  
  // If no characters with strokes, use defaults
  if FirstDef > LastDef then
  begin
    FirstDef := 32;
    LastDef := 126;
  end;
  
  CharCount := LastDef - FirstDef + 2; // +1 for range, +1 for sentinel entry
  
  // Calculate average and max width
  WidthSum := 0;
  DefCount := 0;
  MaxWidth := 0;
  for I := FirstDef to LastDef do
    if FGlyphs[I].Defined then
    begin
      WidthSum := WidthSum + FGlyphs[I].Width;
      Inc(DefCount);
      if FGlyphs[I].Width > MaxWidth then
        MaxWidth := FGlyphs[I].Width;
    end;
  if DefCount > 0 then
    AvgWidth := WidthSum div DefCount
  else
    AvgWidth := 8;
  if MaxWidth = 0 then MaxWidth := 8;
  
  // Build stroke data for all characters
  // Format: $80 DX DY = pen up move (relative), DX DY = pen down line (relative)
  // IMPORTANT: Each character's data must start with $80 (MoveTo) for parser to find it
  SetLength(StrokeBytes, 0);
  SetLength(StrokeOffsets, CharCount);
  TotalStrokeBytes := 0;
  
  for I := 0 to CharCount - 1 do
  begin
    StrokeOffsets[I] := TotalStrokeBytes;
    
    if (FirstDef + I <= LastDef) and FGlyphs[FirstDef + I].Defined and (FGlyphs[FirstDef + I].StrokeCount > 0) then
    begin
      CurX := 0;
      CurY := 0;
      
      for J := 0 to FGlyphs[FirstDef + I].StrokeCount - 1 do
      begin
        DX := FGlyphs[FirstDef + I].Strokes[J].X - CurX;
        DY := FGlyphs[FirstDef + I].Strokes[J].Y - CurY;
        CurX := FGlyphs[FirstDef + I].Strokes[J].X;
        CurY := FGlyphs[FirstDef + I].Strokes[J].Y;
        
        // Clamp deltas to signed byte range
        if DX < -128 then DX := -128;
        if DX > 127 then DX := 127;
        if DY < -128 then DY := -128;
        if DY > 127 then DY := 127;
        
        if FGlyphs[FirstDef + I].Strokes[J].Cmd = scMoveTo then
        begin
          // Pen up: $80 DX DY
          SetLength(StrokeBytes, Length(StrokeBytes) + 3);
          StrokeBytes[TotalStrokeBytes] := $80;
          StrokeBytes[TotalStrokeBytes + 1] := Byte(DX);
          StrokeBytes[TotalStrokeBytes + 2] := Byte(DY);
          TotalStrokeBytes := TotalStrokeBytes + 3;
        end
        else
        begin
          // Pen down: DX DY (DX must not be $80)
          if Byte(DX) = $80 then DX := $7F;
          SetLength(StrokeBytes, Length(StrokeBytes) + 2);
          StrokeBytes[TotalStrokeBytes] := Byte(DX);
          StrokeBytes[TotalStrokeBytes + 1] := Byte(DY);
          TotalStrokeBytes := TotalStrokeBytes + 2;
        end;
      end;
    end;
  end;
  
  // FNT 1.0 header layout (offsets and sizes):
  // 0-1: Version (2)
  // 2-5: Size (4)
  // 6-65: Copyright (60)
  // 66-67: Type (2)
  // 68-69: Points (2)
  // 70-71: VertRes (2)
  // 72-73: HorizRes (2)
  // 74-75: Ascent (2)
  // 76-77: InternalLeading (2)
  // 78-79: ExternalLeading (2)
  // 80: Italic (1)
  // 81: Underline (1)
  // 82: StrikeOut (1)
  // 83-84: Weight (2)
  // 85: CharSet (1)
  // 86-87: PixWidth (2)
  // 88-89: PixHeight (2)
  // 90: PitchAndFamily (1)
  // 91-92: AvgWidth (2)
  // 93-94: MaxWidth (2)
  // 95: FirstChar (1)
  // 96: LastChar (1)
  // 97: DefaultChar (1)
  // 98: BreakChar (1)
  // 99-100: WidthBytes (2)
  // 101-104: Device (4)
  // 105-108: Face (4)
  // 109-112: BitsPointer (4)
  // 113-116: BitsOffset (4)
  // Total: 117 bytes
  
  HeaderSize := 117;
  CharTableOffset := HeaderSize;
  StrokeDataOffset := CharTableOffset + LongWord(CharCount * 4);
  DeviceNameOffset := StrokeDataOffset + LongWord(TotalStrokeBytes);
  FaceNameOffset := DeviceNameOffset + 1;
  
  // Write header
  WriteWord(Result, $0100);                    // 0: Version
  WriteDWord(Result, FaceNameOffset + LongWord(Length(FFontName)) + 1); // 2: Size
  WriteString(Result, FCopyright, 60);         // 6: Copyright
  WriteWord(Result, $0001);                    // 66: Type (1 = vector)
  WriteWord(Result, FPointSize * 20);          // 68: Points
  WriteWord(Result, 96);                       // 70: VertRes
  WriteWord(Result, 96);                       // 72: HorizRes
  WriteWord(Result, FAscent);                  // 74: Ascent
  WriteWord(Result, 0);                        // 76: InternalLeading
  WriteWord(Result, 0);                        // 78: ExternalLeading
  WriteByte(Result, Ord(FItalic));             // 80: Italic
  WriteByte(Result, Ord(FUnderline));          // 81: Underline
  WriteByte(Result, Ord(FStrikeOut));          // 82: StrikeOut
  WriteWord(Result, Word(FWeight));            // 83: Weight
  WriteByte(Result, Byte(FCharSet));           // 85: CharSet
  WriteWord(Result, 0);                        // 86: PixWidth
  WriteWord(Result, FHeight);                  // 88: PixHeight
  WriteByte(Result, Byte(FPitchFamily));       // 90: PitchAndFamily
  WriteWord(Result, AvgWidth);                 // 91: AvgWidth
  WriteWord(Result, MaxWidth);                 // 93: MaxWidth
  WriteByte(Result, FirstDef);                 // 95: FirstChar
  WriteByte(Result, LastDef);                  // 96: LastChar
  WriteByte(Result, Ord('.') - FirstDef);      // 97: DefaultChar
  WriteByte(Result, Ord(' ') - FirstDef);      // 98: BreakChar
  WriteWord(Result, 0);                        // 99: WidthBytes
  WriteDWord(Result, DeviceNameOffset);        // 101: Device
  WriteDWord(Result, FaceNameOffset);          // 105: Face
  WriteDWord(Result, 0);                       // 109: BitsPointer
  WriteDWord(Result, StrokeDataOffset);        // 113: BitsOffset
  
  // Verify we're at offset 117
  if Result.Position <> 117 then
    raise Exception.CreateFmt('Header size mismatch: expected 117, got %d', [Result.Position]);
  
  // Write character table (offset:2, width:2 for FNT 1.0)
  for I := 0 to CharCount - 1 do
  begin
    WriteWord(Result, StrokeOffsets[I]);
    if (FirstDef + I <= LastDef) and FGlyphs[FirstDef + I].Defined then
      WriteWord(Result, FGlyphs[FirstDef + I].Width)
    else
      WriteWord(Result, AvgWidth);
  end;
  
  // Write stroke data
  for I := 0 to TotalStrokeBytes - 1 do
    WriteByte(Result, StrokeBytes[I]);
  
  // Write device name (empty string)
  WriteByte(Result, 0);
  
  // Write face name
  WriteString(Result, FFontName, Length(FFontName));
  WriteByte(Result, 0);
  
  SetLength(StrokeOffsets, 0);
  SetLength(StrokeBytes, 0);
end;

function TVectorFontCreator.BuildNEExecutable(FontRes: TMemoryStream): TMemoryStream;
var
  FontResSize: LongWord;
  FontResOffset: LongWord;
  AlignShift: Word;
  NEHeaderPos: LongWord;
  ResTablePos: LongWord;
  ResNameTablePos: LongWord;
  ModRefTablePos: LongWord;
  ImpNameTablePos: LongWord;
  EntryTablePos: LongWord;
  I: Integer;
begin
  Result := TMemoryStream.Create;
  FontResSize := FontRes.Size;
  AlignShift := 4; // 16-byte alignment (1 << 4 = 16)
  
  // === DOS MZ Header (64 bytes) ===
  WriteWord(Result, $5A4D);           // 00: MZ signature
  WriteWord(Result, $0080);           // 02: Bytes on last page
  WriteWord(Result, $0001);           // 04: Pages in file
  WriteWord(Result, $0000);           // 06: Relocations
  WriteWord(Result, $0004);           // 08: Header size in paragraphs (64 bytes)
  WriteWord(Result, $0000);           // 0A: Min extra paragraphs
  WriteWord(Result, $FFFF);           // 0C: Max extra paragraphs
  WriteWord(Result, $0000);           // 0E: Initial SS
  WriteWord(Result, $00B8);           // 10: Initial SP
  WriteWord(Result, $0000);           // 12: Checksum
  WriteWord(Result, $0000);           // 14: Initial IP
  WriteWord(Result, $0000);           // 16: Initial CS
  WriteWord(Result, $0040);           // 18: Relocation table offset (64)
  WriteWord(Result, $0000);           // 1A: Overlay number
  // 1C-3B: Reserved (32 bytes)
  for I := 0 to 15 do
    WriteWord(Result, 0);
  WriteDWord(Result, $00000080);      // 3C: NE header offset = 128
  
  // Pad to offset 128 (0x80)
  while Result.Position < $80 do
    WriteByte(Result, 0);
  
  NEHeaderPos := Result.Position;     // Should be 0x80
  
  // === NE Header (64 bytes) ===
  WriteWord(Result, $454E);           // 00: NE signature
  WriteByte(Result, 5);               // 02: Linker version
  WriteByte(Result, 10);              // 03: Linker revision
  WriteWord(Result, $0040);           // 04: Entry table offset (relative to NE) = 64
  WriteWord(Result, $0000);           // 06: Entry table size = 0
  WriteDWord(Result, $00000000);      // 08: CRC
  WriteWord(Result, $8000);           // 0C: Flags: LIBRARY
  WriteWord(Result, $0000);           // 0E: Auto data segment
  WriteWord(Result, $0000);           // 10: Heap size
  WriteWord(Result, $0000);           // 12: Stack size
  WriteDWord(Result, $00000000);      // 14: CS:IP
  WriteDWord(Result, $00000000);      // 18: SS:SP
  WriteWord(Result, $0000);           // 1C: Segment table entries = 0
  WriteWord(Result, $0000);           // 1E: Module reference entries = 0
  WriteWord(Result, $0000);           // 20: Non-resident name table size = 0
  WriteWord(Result, $0040);           // 22: Segment table offset = 64 (same as entry table)
  WriteWord(Result, $0040);           // 24: Resource table offset = 64
  WriteWord(Result, $0058);           // 26: Resident name table offset = 88
  WriteWord(Result, $0060);           // 28: Module reference table offset = 96
  WriteWord(Result, $0060);           // 2A: Imported names table offset = 96
  WriteDWord(Result, $00000000);      // 2C: Non-resident name table offset
  WriteWord(Result, $0000);           // 30: Moveable entries
  WriteWord(Result, AlignShift);      // 32: Alignment shift = 4
  WriteWord(Result, $0001);           // 34: Resource segments = 1
  WriteByte(Result, $02);             // 36: Target OS: Windows
  WriteByte(Result, $00);             // 37: Additional flags
  WriteWord(Result, $0000);           // 38: Fast-load offset
  WriteWord(Result, $0000);           // 3A: Fast-load size
  WriteWord(Result, $0000);           // 3C: Reserved
  WriteWord(Result, $0300);           // 3E: Windows version 3.0
  
  // === Resource Table (at NE + 0x40 = 0xC0) ===
  ResTablePos := Result.Position;
  WriteWord(Result, AlignShift);      // Alignment shift
  
  // Resource type block for RT_FONT
  WriteWord(Result, $8008);           // Type ID: RT_FONT with high bit
  WriteWord(Result, $0001);           // Count = 1
  WriteDWord(Result, $00000000);      // Reserved
  
  // Resource entry
  // Font resource will be at offset 0x100 (256), which is 0x10 in 16-byte units
  FontResOffset := $0100;
  WriteWord(Result, FontResOffset shr AlignShift); // Offset in alignment units
  WriteWord(Result, (FontResSize + 15) shr AlignShift); // Size in alignment units
  WriteWord(Result, $1C30);           // Flags: MOVEABLE | PURE | PRELOAD
  WriteWord(Result, $8001);           // Resource ID with high bit
  WriteDWord(Result, $00000000);      // Reserved
  
  // End of resource types
  WriteWord(Result, $0000);
  
  // === Resident Name Table (at NE + 0x58 = 0xD8) ===
  ResNameTablePos := Result.Position;
  WriteByte(Result, Length(FFontName));
  WriteString(Result, FFontName, Length(FFontName));
  WriteWord(Result, $0000);           // Ordinal
  WriteByte(Result, $00);             // End of table
  
  // === Module Reference Table (at NE + 0x60 = 0xE0) ===
  ModRefTablePos := Result.Position;
  // Empty - no module references
  
  // === Imported Names Table (same offset) ===
  ImpNameTablePos := Result.Position;
  WriteByte(Result, 0);               // Empty table
  
  // === Entry Table (also empty, at NE + 0x40) ===
  // Already covered by resource table position
  
  // Pad to font resource offset (0x100)
  while Result.Position < FontResOffset do
    WriteByte(Result, 0);
  
  // === Font Resource ===
  FontRes.Position := 0;
  Result.CopyFrom(FontRes, FontRes.Size);
end;

procedure TVectorFontCreator.SaveToFile(const FileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TVectorFontCreator.SaveToStream(Stream: TStream);
var
  FontRes, NEExe: TMemoryStream;
begin
  FontRes := BuildFontResource;
  try
    NEExe := BuildNEExecutable(FontRes);
    try
      NEExe.Position := 0;
      Stream.CopyFrom(NEExe, NEExe.Size);
    finally
      NEExe.Free;
    end;
  finally
    FontRes.Free;
  end;
end;

end.
