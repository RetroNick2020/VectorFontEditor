{$MODE OBJFPC}{$H+}
{
  Windows Vector FON Font Creator Library for Free Pascal
  
  Creates Windows 2.x/3.x NE format FON files with vector (stroke) fonts.
  
  Vector fonts store characters as a series of pen strokes (MoveTo/LineTo commands)
  rather than bitmaps, allowing them to scale smoothly to any size.

  Compatible with Windows 10 font viewer (fontview.exe).
  Produces NE executables with both RT_FONTDIR and RT_FONT resources.
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
    procedure WritePadTo(Stream: TStream; TargetPos: LongWord);
    function BuildFontResource: TMemoryStream;
    function BuildFontDirEntry(FontRes: TMemoryStream): TMemoryStream;
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

procedure TVectorFontCreator.WritePadTo(Stream: TStream; TargetPos: LongWord);
begin
  while Stream.Position < TargetPos do
    WriteByte(Stream, 0);
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

{ ======================================================================
  Build the FNT font resource (version 1.0, vector)
  ====================================================================== }

function TVectorFontCreator.BuildFontResource: TMemoryStream;
var
  I, J: Integer;
  CharCount: Integer;
  CharTableOffset: LongWord;
  FaceNameOffset: LongWord;
  StrokeDataOffset: LongWord;
  StrokeOffsets: array of Word;
  TotalStrokeBytes: Integer;
  FirstDef, LastDef: Integer;
  AvgWidth, MaxWidth: Integer;
  WidthSum, DefCount: Integer;
  CurX, CurY: Integer;
  DX, DY: Integer;
  StrokeBytes: array of Byte;
  DefCharOff, BreakCharOff: Integer;
begin
  Result := TMemoryStream.Create;
  
  // Find first and last defined characters (including those with no strokes)
  FirstDef := 255;
  LastDef := 0;
  for I := 0 to 255 do
    if FGlyphs[I].Defined then
    begin
      if I < FirstDef then FirstDef := I;
      if I > LastDef then LastDef := I;
    end;
  
  if FirstDef > LastDef then
  begin
    FirstDef := 32;
    LastDef := 126;
  end;

  // Always include space (32) in the range — required for valid dfBreakChar
  if FirstDef > 32 then FirstDef := 32;
  
  CharCount := LastDef - FirstDef + 2; // +1 for range, +1 for sentinel
  
  // Calculate average and max width
  WidthSum := 0;
  DefCount := 0;
  MaxWidth := 0;
  for I := FirstDef to LastDef do
    if FGlyphs[I].Defined then
    begin
      if FGlyphs[I].Width > 0 then
      begin
        WidthSum := WidthSum + FGlyphs[I].Width;
        Inc(DefCount);
      end;
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
  SetLength(StrokeBytes, 0);
  SetLength(StrokeOffsets, CharCount);
  TotalStrokeBytes := 0;
  
  for I := 0 to CharCount - 1 do
  begin
    StrokeOffsets[I] := TotalStrokeBytes;
    
    if (FirstDef + I <= LastDef) and FGlyphs[FirstDef + I].Defined and
       (FGlyphs[FirstDef + I].StrokeCount > 0) then
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
  
  // FNT 1.0 layout (matching original Windows vector fonts):
  //   Header (117 bytes)
  //   Character table (CharCount * 4 bytes)
  //   Face name string (null-terminated) — between char table and stroke data
  //   Stroke data
  // dfDevice = 0 (no device name string)
  // dfFace points to face name between char table and stroke data
  // dfBitsOffset points to stroke data after the face name

  CharTableOffset := 117;
  FaceNameOffset := CharTableOffset + LongWord(CharCount * 4);
  StrokeDataOffset := FaceNameOffset + LongWord(Length(FFontName)) + 1; // +1 for null

  // Compute dfDefaultChar and dfBreakChar safely
  // These are offsets from dfFirstChar
  if (Ord('.') >= FirstDef) and (Ord('.') <= LastDef) then
    DefCharOff := Ord('.') - FirstDef
  else
    DefCharOff := 0;

  if (Ord(' ') >= FirstDef) and (Ord(' ') <= LastDef) then
    BreakCharOff := Ord(' ') - FirstDef
  else
    BreakCharOff := 0;

  // === FNT Header (117 bytes) ===
  WriteWord(Result, $0100);                    // 0: dfVersion = 1.0
  WriteDWord(Result, StrokeDataOffset +        // 2: dfSize = total resource size
    LongWord(TotalStrokeBytes));
  WriteString(Result, FCopyright, 60);         // 6: dfCopyright (60 bytes)
  WriteWord(Result, $0001);                    // 66: dfType (bit 0 = vector)
  WriteWord(Result, FPointSize);               // 68: dfPoints (nominal point size)
  WriteWord(Result, 96);                       // 70: dfVertRes (DPI)
  WriteWord(Result, 96);                       // 72: dfHorizRes (DPI)
  WriteWord(Result, FAscent);                  // 74: dfAscent
  WriteWord(Result, 0);                        // 76: dfInternalLeading
  WriteWord(Result, 0);                        // 78: dfExternalLeading
  WriteByte(Result, Ord(FItalic));             // 80: dfItalic
  WriteByte(Result, Ord(FUnderline));          // 81: dfUnderline
  WriteByte(Result, Ord(FStrikeOut));          // 82: dfStrikeOut
  WriteWord(Result, Word(FWeight));            // 83: dfWeight
  WriteByte(Result, Byte(FCharSet));           // 85: dfCharSet
  WriteWord(Result, 0);                        // 86: dfPixWidth (0 = variable)
  WriteWord(Result, FHeight);                  // 88: dfPixHeight
  WriteByte(Result, Byte(FPitchFamily));       // 90: dfPitchAndFamily
  WriteWord(Result, AvgWidth);                 // 91: dfAvgWidth
  WriteWord(Result, MaxWidth);                 // 93: dfMaxWidth
  WriteByte(Result, FirstDef);                 // 95: dfFirstChar
  WriteByte(Result, LastDef);                  // 96: dfLastChar
  WriteByte(Result, DefCharOff);               // 97: dfDefaultChar
  WriteByte(Result, BreakCharOff);             // 98: dfBreakChar
  WriteWord(Result, 0);                        // 99: dfWidthBytes
  WriteDWord(Result, 0);                       // 101: dfDevice (0 = no device name)
  WriteDWord(Result, FaceNameOffset);          // 105: dfFace
  WriteDWord(Result, 0);                       // 109: dfBitsPointer (reserved)
  WriteDWord(Result, StrokeDataOffset);        // 113: dfBitsOffset

  // Verify header size
  if Result.Position <> 117 then
    raise Exception.CreateFmt('FNT header size mismatch: expected 117, got %d',
      [Result.Position]);
  
  // === Character table (offset:2, width:2 per entry, FNT 1.0 format) ===
  for I := 0 to CharCount - 1 do
  begin
    WriteWord(Result, StrokeOffsets[I]);
    if (FirstDef + I <= LastDef) and FGlyphs[FirstDef + I].Defined and
       (FGlyphs[FirstDef + I].Width > 0) then
      WriteWord(Result, FGlyphs[FirstDef + I].Width)
    else
      WriteWord(Result, AvgWidth);
  end;

  // === Face name (null-terminated) — placed between char table and stroke data ===
  WriteString(Result, FFontName, Length(FFontName));
  WriteByte(Result, 0);
  
  // === Stroke data ===
  if TotalStrokeBytes > 0 then
    Result.WriteBuffer(StrokeBytes[0], TotalStrokeBytes);

  SetLength(StrokeOffsets, 0);
  SetLength(StrokeBytes, 0);
end;

{ ======================================================================
  Build FONTDIR entry
  Contains: ordinal (2) + partial FNT header (113 bytes) + device + face
  ====================================================================== }

function TVectorFontCreator.BuildFontDirEntry(FontRes: TMemoryStream): TMemoryStream;
var
  DevNameOff, FaceNameOff: LongWord;
  B: Byte;
begin
  Result := TMemoryStream.Create;

  // Number of fonts in this file
  WriteWord(Result, 1);

  // Font ordinal number
  WriteWord(Result, 1);

  // Copy first 113 bytes of the FNT resource (header up to dfBitsPointer)
  FontRes.Position := 0;
  Result.CopyFrom(FontRes, 113);

  // Read dfDevice offset from FNT header at offset 101
  FontRes.Position := 101;
  FontRes.ReadBuffer(DevNameOff, 4);

  // Read dfFace offset from FNT header at offset 105
  FontRes.Position := 105;
  FontRes.ReadBuffer(FaceNameOff, 4);

  // Append device name string from FNT resource
  // dfDevice = 0 means no device name — just write a null byte
  if DevNameOff > 0 then
  begin
    FontRes.Position := DevNameOff;
    repeat
      FontRes.ReadBuffer(B, 1);
      Result.WriteBuffer(B, 1);
    until B = 0;
  end
  else
  begin
    B := 0;
    Result.WriteBuffer(B, 1);
  end;

  // Append face name string from FNT resource
  if FaceNameOff > 0 then
  begin
    FontRes.Position := FaceNameOff;
    repeat
      FontRes.ReadBuffer(B, 1);
      Result.WriteBuffer(B, 1);
    until B = 0;
  end
  else
  begin
    B := 0;
    Result.WriteBuffer(B, 1);
  end;
end;

{ ======================================================================
  Build complete NE executable with FONTDIR + FONT resources
  All table offsets are calculated dynamically — no hardcoding.
  ====================================================================== }

function TVectorFontCreator.BuildNEExecutable(FontRes: TMemoryStream): TMemoryStream;
var
  FontDirRes: TMemoryStream;
  FontResSize, FontDirSize: LongWord;
  AlignShift, AlignSize: Word;
  NEHeaderPos: LongWord;

  // Table positions (relative to NE header)
  SegTableOff: Word;
  ResTableOff: Word;
  ResNameOff: Word;
  ModRefOff: Word;
  ImpNameOff: Word;
  EntryTabOff: Word;
  EntryTabSize: Word;
  NonResNameFileOff: LongWord;  // absolute file offset
  NonResNameSize: Word;

  // Resource layout
  ResTableSize: Integer;
  FontDirAligned, FontResAligned: LongWord;
  FontDirFileOff, FontResFileOff: LongWord;

  // Non-resident name table
  NonResNameStr: string;
  CurOff: Word;
  I: Integer;
begin
  Result := TMemoryStream.Create;

  // Build the FONTDIR entry
  FontDirRes := BuildFontDirEntry(FontRes);
  try
    FontResSize := FontRes.Size;
    FontDirSize := FontDirRes.Size;
    AlignShift := 4;   // 1 << 4 = 16-byte alignment
    AlignSize := 1 shl AlignShift;

    // ================================================================
    // Calculate NE table positions (all relative to NE header start)
    // Layout after the 64-byte NE header:
    //   Segment table    (0 entries = 0 bytes)
    //   Resource table
    //   Resident name table
    //   Module reference table (empty)
    //   Imported names table (1 byte: 0x00)
    //   Entry table (1 byte: 0x00)
    // ================================================================

    CurOff := 64;  // start right after the 64-byte NE header

    // Segment table (0 entries)
    SegTableOff := CurOff;
    // no bytes consumed

    // Resource table
    ResTableOff := CurOff;
    // Resource table layout:
    //   2 bytes: alignment shift
    //   FONTDIR type block: 2+2+4 = 8 bytes header + 12 bytes per entry = 20 bytes
    //   FONT type block:    2+2+4 = 8 bytes header + 12 bytes per entry = 20 bytes
    //   2 bytes: end marker (type=0)
    //   Resource name strings: 1 len + 7 "FONTDIR" = 8 bytes
    ResTableSize := 2 + 20 + 20 + 2 + 8;
    CurOff := CurOff + ResTableSize;

    // Resident name table
    ResNameOff := CurOff;
    // Content: length byte + name + ordinal word + terminator byte
    CurOff := CurOff + 1 + Length(FFontName) + 2 + 1;

    // Module reference table (empty, 0 entries)
    ModRefOff := CurOff;

    // Imported names table (empty: just a 0x00 length byte)
    ImpNameOff := CurOff;
    CurOff := CurOff + 1;

    // Entry table (empty: 2 bytes matching original Windows fonts)
    EntryTabOff := CurOff;
    EntryTabSize := 2;
    CurOff := CurOff + EntryTabSize;

    // ================================================================
    // Calculate resource data positions (absolute file offsets)
    // Resources go after NE tables, aligned to AlignSize boundaries
    // ================================================================

    // Absolute position after all NE tables
    // NE header is at file offset $80, tables end at $80 + CurOff
    FontDirFileOff := (($80 + CurOff) + AlignSize - 1) and (not (AlignSize - 1));
    FontDirAligned := (FontDirSize + AlignSize - 1) and (not (AlignSize - 1));

    FontResFileOff := FontDirFileOff + FontDirAligned;
    FontResAligned := (FontResSize + AlignSize - 1) and (not (AlignSize - 1));

    // Non-resident name table goes after font resource
    NonResNameFileOff := FontResFileOff + FontResAligned;
    NonResNameStr := FFontName + ' font';
    NonResNameSize := 1 + Length(NonResNameStr) + 2 + 1; // len + str + ord + term

    // ================================================================
    // Write DOS MZ stub header (64 bytes + padding to $80)
    // ================================================================
    WriteWord(Result, $5A4D);           // 00: MZ signature
    WriteWord(Result, $0080);           // 02: Bytes on last page
    WriteWord(Result, $0001);           // 04: Pages in file
    WriteWord(Result, $0000);           // 06: Relocations
    WriteWord(Result, $0004);           // 08: Header size in paragraphs
    WriteWord(Result, $0000);           // 0A: Min extra paragraphs
    WriteWord(Result, $FFFF);           // 0C: Max extra paragraphs
    WriteWord(Result, $0000);           // 0E: Initial SS
    WriteWord(Result, $00B8);           // 10: Initial SP
    WriteWord(Result, $0000);           // 12: Checksum
    WriteWord(Result, $0000);           // 14: Initial IP
    WriteWord(Result, $0000);           // 16: Initial CS
    WriteWord(Result, $0040);           // 18: Relocation table offset
    WriteWord(Result, $0000);           // 1A: Overlay number
    for I := 0 to 15 do                // 1C-3B: Reserved
      WriteWord(Result, 0);
    WriteDWord(Result, $00000080);      // 3C: NE header offset

    WritePadTo(Result, $80);

    // ================================================================
    // Write NE header (64 bytes)
    // ================================================================
    NEHeaderPos := Result.Position;     // = $80

    WriteWord(Result, $454E);           // 00: NE signature
    WriteByte(Result, 5);               // 02: Linker version
    WriteByte(Result, 10);              // 03: Linker revision
    WriteWord(Result, EntryTabOff);     // 04: Entry table offset (relative to NE)
    WriteWord(Result, EntryTabSize);    // 06: Entry table length in bytes
    WriteDWord(Result, $00000000);      // 08: CRC
    WriteWord(Result, $8000);           // 0C: Module flags: LIBRARY
    WriteWord(Result, $0000);           // 0E: Auto data segment number
    WriteWord(Result, $0000);           // 10: Initial heap size
    WriteWord(Result, $0000);           // 12: Initial stack size
    WriteDWord(Result, $00000000);      // 14: CS:IP entry point
    WriteDWord(Result, $00000000);      // 18: SS:SP initial stack
    WriteWord(Result, $0000);           // 1C: Segment table entry count = 0
    WriteWord(Result, $0000);           // 1E: Module reference table entry count = 0
    WriteWord(Result, NonResNameSize);  // 20: Non-resident name table size
    WriteWord(Result, SegTableOff);     // 22: Segment table offset
    WriteWord(Result, ResTableOff);     // 24: Resource table offset
    WriteWord(Result, ResNameOff);      // 26: Resident name table offset
    WriteWord(Result, ModRefOff);       // 28: Module reference table offset
    WriteWord(Result, ImpNameOff);      // 2A: Imported names table offset
    WriteDWord(Result, NonResNameFileOff); // 2C: Non-resident name table (absolute)
    WriteWord(Result, $0000);           // 30: Movable entry point count
    WriteWord(Result, AlignShift);      // 32: Segment alignment shift count
    WriteWord(Result, $0000);           // 34: Resource segment count
    WriteByte(Result, $02);             // 36: Target OS = Windows
    WriteByte(Result, $00);             // 37: Additional flags
    WriteWord(Result, $0000);           // 38: Fast-load offset
    WriteWord(Result, $0000);           // 3A: Fast-load length
    WriteWord(Result, $0000);           // 3C: Reserved
    WriteWord(Result, $0300);           // 3E: Expected Windows version 3.0

    // Verify we wrote exactly 64 bytes of NE header
    if Result.Position <> NEHeaderPos + 64 then
      raise Exception.CreateFmt('NE header size error: expected %d, got %d',
        [NEHeaderPos + 64, Result.Position]);

    // ================================================================
    // Write Resource Table
    // ================================================================
    WriteWord(Result, AlignShift);      // Alignment shift count

    // --- RT_FONTDIR type block (type $8007) ---
    WriteWord(Result, $8007);           // Type ID: RT_FONTDIR
    WriteWord(Result, $0001);           // Count = 1
    WriteDWord(Result, $00000000);      // Reserved
    // FONTDIR resource entry
    // Name ID: offset from resource table start to "FONTDIR" name string
    // String is at: align(2) + FONTDIR block(20) + FONT block(20) + end(2) = 44 = $2C
    WriteWord(Result, Word(FontDirFileOff shr AlignShift));  // Offset
    WriteWord(Result, Word((FontDirSize + AlignSize - 1) shr AlignShift)); // Size
    WriteWord(Result, $0C50);           // Flags: MOVEABLE | PRELOAD
    WriteWord(Result, $002C);           // Name: offset $2C to "FONTDIR" string
    WriteDWord(Result, $00000000);      // Reserved

    // --- RT_FONT type block (type $8008) ---
    WriteWord(Result, $8008);           // Type ID: RT_FONT
    WriteWord(Result, $0001);           // Count = 1
    WriteDWord(Result, $00000000);      // Reserved
    // FONT resource entry
    WriteWord(Result, Word(FontResFileOff shr AlignShift));  // Offset
    WriteWord(Result, Word((FontResSize + AlignSize - 1) shr AlignShift)); // Size
    WriteWord(Result, $1C30);           // Flags: MOVEABLE | PURE | PRELOAD
    WriteWord(Result, $8001);           // Name ID: ordinal 1
    WriteDWord(Result, $00000000);      // Reserved

    // End of resource types
    WriteWord(Result, $0000);

    // Resource name strings (referenced by name offsets above)
    WriteByte(Result, 7);               // Length of "FONTDIR"
    WriteString(Result, 'FONTDIR', 7);  // "FONTDIR" (no null terminator)

    // ================================================================
    // Write Resident Name Table
    // ================================================================
    WriteByte(Result, Length(FFontName));
    WriteString(Result, FFontName, Length(FFontName));
    WriteWord(Result, $0000);           // Ordinal 0 = module name
    WriteByte(Result, $00);             // End of table

    // ================================================================
    // Module reference table (empty, 0 entries)
    // Imported names table (empty: 1 byte)
    // ================================================================
    WriteByte(Result, $00);             // Empty imported names table

    // ================================================================
    // Entry table (empty: 2 bytes matching original Windows fonts)
    // ================================================================
    WriteByte(Result, $00);             // End of entry table byte 1
    WriteByte(Result, $00);             // End of entry table byte 2

    // ================================================================
    // Pad to FONTDIR resource position and write it
    // ================================================================
    WritePadTo(Result, FontDirFileOff);
    FontDirRes.Position := 0;
    Result.CopyFrom(FontDirRes, FontDirRes.Size);

    // ================================================================
    // Pad to FONT resource position and write it
    // ================================================================
    WritePadTo(Result, FontResFileOff);
    FontRes.Position := 0;
    Result.CopyFrom(FontRes, FontRes.Size);

    // ================================================================
    // Pad to non-resident name table and write it
    // ================================================================
    WritePadTo(Result, NonResNameFileOff);
    WriteByte(Result, Length(NonResNameStr));
    WriteString(Result, NonResNameStr, Length(NonResNameStr));
    WriteWord(Result, $0000);           // Ordinal 0 = module description
    WriteByte(Result, $00);             // End of table

  finally
    FontDirRes.Free;
  end;
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
