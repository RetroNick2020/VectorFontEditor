unit VectorFontMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, ComCtrls, Menus, LCLType, VectorFontCreator, WinFont , BorlandCHR;

Const
  ProgramName = 'RetroNick'#39's FON/CHR Vector Font Editor v1.1';

type
  TEditTool = (etSelect, etMove, etLine, etDelete);
  
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
  PVectorGlyph = ^TVectorGlyph;
  
  { TfrmVectorMain }

  TfrmVectorMain = class(TForm)
    btnAddPoint: TButton;
    btnClearChar: TButton;
    btnClearAll: TButton;
    btnCopyChar: TButton;
    btnDeletePoint: TButton;
    btnFlipH: TButton;
    btnFlipV: TButton;
    btnMoveLeft: TButton;
    btnMoveRight: TButton;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    btnPasteChar: TButton;
    cboBold: TCheckBox;
    cboItalic: TCheckBox;
    cboShowGrid: TCheckBox;
    cboShowPoints: TCheckBox;
    cboUnderline: TCheckBox;
    cmbCharSet: TComboBox;
    cmbPitchFamily: TComboBox;
    cmbZoom: TComboBox;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    edtCopyright: TEdit;
    edtFontName: TEdit;
    edtPreviewText: TEdit;
    gbCharEditor: TGroupBox;
    gbCharList: TGroupBox;
    gbFontProps: TGroupBox;
    gbPreview: TGroupBox;
    gbTools: TGroupBox;
    gbStrokeList: TGroupBox;
    Label1: TLabel;
    lblBaseline: TLabel;
    lblCharSet: TLabel;
    lblCharWidth: TLabel;
    lblCopyright: TLabel;
    lblCurrentChar: TLabel;
    lblFontName: TLabel;
    lblHeight: TLabel;
    lblPitchFamily: TLabel;
    lblPointSize: TLabel;
    lblPreviewText: TLabel;
    lblRangeStart: TLabel;
    lblRangeTo: TLabel;
    lblTool: TLabel;
    lblZoom: TLabel;
    lstChars: TListBox;
    lstStrokes: TListBox;
    MainMenu: TMainMenu;
    mnuAbout: TMenuItem;
    mnuCopy: TMenuItem;
    mnuEdit: TMenuItem;
    mnuExit: TMenuItem;
    mnuFile: TMenuItem;
    mnuHelp: TMenuItem;
    mnuNew: TMenuItem;
    mnuOpen: TMenuItem;
    mnuPaste: TMenuItem;
    mnuRedo: TMenuItem;
    mnuSave: TMenuItem;
    mnuSep1: TMenuItem;
    mnuSep2: TMenuItem;
    mnuTools: TMenuItem;
    mnuUndo: TMenuItem;
    mnuFontMetrics: TMenuItem;
    mnuAddTrailingMoveTo: TMenuItem;
    pnlCharEdit: TPaintBox;
    pnlPreview: TPaintBox;
    pnlToolButtons: TPanel;
    rbToolLine: TRadioButton;
    rbToolMove: TRadioButton;
    rbToolSelect: TRadioButton;
    sbCharEdit: TScrollBox;
    spnAscent: TSpinEdit;
    spnCharWidth: TSpinEdit;
    spnHeight: TSpinEdit;
    spnPointSize: TSpinEdit;
    spnRangeStart: TSpinEdit;
    spnRangeEnd: TSpinEdit;
    btnApplyRange: TButton;
    gbLineMarkers: TGroupBox;
    chkShowBaseline: TCheckBox;
    chkShowAscender: TCheckBox;
    chkShowDescender: TCheckBox;
    chkShowXHeight: TCheckBox;
    spnAscenderLine: TSpinEdit;
    spnDescenderLine: TSpinEdit;
    spnXHeightLine: TSpinEdit;
    lblAscenderVal: TLabel;
    lblDescenderVal: TLabel;
    lblXHeightVal: TLabel;
    lblAutoHint: TLabel;
    lblLineValues: TLabel;
    btnResetLines: TButton;
    btnScanLines: TButton;
    StatusBar: TStatusBar;
    tmrPreview: TTimer;
    procedure btnAddPointClick(Sender: TObject);
    procedure btnApplyRangeClick(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure btnClearCharClick(Sender: TObject);
    procedure btnCopyCharClick(Sender: TObject);
    procedure btnDeletePointClick(Sender: TObject);
    procedure btnFlipHClick(Sender: TObject);
    procedure btnFlipVClick(Sender: TObject);
    procedure btnLoadFontClick(Sender: TObject);
    procedure btnPasteCharClick(Sender: TObject);
    procedure btnSaveFontClick(Sender: TObject);
    procedure btnMoveLeftClick(Sender: TObject);
    procedure btnMoveRightClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure cboShowGridChange(Sender: TObject);
    procedure cboShowPointsChange(Sender: TObject);
    procedure cmbZoomChange(Sender: TObject);
    procedure edtPreviewTextChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lstCharsClick(Sender: TObject);
    procedure lstCharsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure lstStrokesClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuFontMetricsClick(Sender: TObject);
    procedure mnuAddTrailingMoveToClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure mnuRedoClick(Sender: TObject);
    procedure mnuUndoClick(Sender: TObject);
    procedure chkLineMarkerChange(Sender: TObject);
    procedure spnLineMarkerChange(Sender: TObject);
    procedure btnResetLinesClick(Sender: TObject);
    procedure btnScanLinesClick(Sender: TObject);
    procedure pnlCharEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCharEditMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure pnlCharEditMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCharEditPaint(Sender: TObject);
    procedure pnlPreviewPaint(Sender: TObject);
    procedure rbToolChange(Sender: TObject);
    procedure spnCharWidthChange(Sender: TObject);
    procedure spnHeightChange(Sender: TObject);
    procedure spnRangeChange(Sender: TObject);
    procedure tmrPreviewTimer(Sender: TObject);
  private
    FCreator: TVectorFontCreator;
    FCurrentChar: Integer;
    FGlyphs: array[0..255] of TVectorGlyph;
    FUndoStack: array[0..255] of TList;
    FRedoStack: array[0..255] of TList;
    FZoom: Single;
    FShowGrid: Boolean;
    FShowPoints: Boolean;
    FModified: Boolean;
    FCurrentFile: string;
    FInitializing: Boolean;
    FCurrentTool: TEditTool;
    FSelectedPoint: Integer;
    FDragging: Boolean;
    FDragStartX, FDragStartY: Integer;
    FLineStarted: Boolean;
    FLineStartX, FLineStartY: Integer;
    FClipboard: TVectorGlyph;
    FHasClipboard: Boolean;
    FCharRangeStart: Integer;
    FCharRangeEnd: Integer;
    FCharEnabled: array[0..255] of Boolean;
    
    // Line markers
    FShowBaseline: Boolean;
    FShowAscenderLine: Boolean;
    FShowDescenderLine: Boolean;
    FShowXHeightLine: Boolean;
    FAscenderLine: Integer;    // -1 = auto (use spnAscent)
    FDescenderLine: Integer;   // -1 = auto (use spnHeight)
    FXHeightLine: Integer;     // -1 = auto (use 60% of ascent)
    
    procedure UpdateCharList;
    procedure UpdateStrokeList;
    procedure UpdatePreview;
    procedure UpdateStatus;
    procedure UpdateTitle;
    procedure UpdateEditorSize;
    procedure UpdateLineMarkerDisplay;
    procedure EnsureGlyph(Idx: Integer);
    procedure SaveUndoState;
    procedure ClearUndoRedo(Idx: Integer);
    procedure SetModified(V: Boolean);
    function ConfirmSave: Boolean;
    function ScreenToChar(SX, SY: Integer; out CX, CY: Integer): Boolean;
    function CharToScreen(CX, CY: Integer; out SX, SY: Integer): Boolean;
    function FindPointAt(SX, SY: Integer): Integer;
    procedure LoadVectorFont(const FN: string);
    procedure LoadCHRFont(const FN: string);
    procedure SaveCHRFont(const FN: string);
    procedure ApplyCharRange;
    procedure ScanFontLines(out AscenderY, DescenderY, XHeightY: Integer);
  public
  end;

var
  frmVectorMain: TfrmVectorMain;

implementation

{$R *.lfm}

const
  POINT_RADIUS = 4;
  GRID_SIZE = 8;

procedure TfrmVectorMain.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FInitializing := True;
  FCreator := TVectorFontCreator.Create;
  FCurrentChar := 65;
  FZoom := 8.0;
  FShowGrid := True;
  FShowPoints := True;
  FModified := False;
  FCurrentFile := '';
  FCurrentTool := etLine;
  FSelectedPoint := -1;
  FDragging := False;
  FLineStarted := False;
  FHasClipboard := False;
  FCharRangeStart := 32;
  FCharRangeEnd := 127;
  
  // Line markers - default visibility and auto values
  FShowBaseline := True;
  FShowAscenderLine := True;
  FShowDescenderLine := True;
  FShowXHeightLine := True;
  FAscenderLine := -1;   // Auto
  FDescenderLine := -1;  // Auto
  FXHeightLine := -1;    // Auto
  
  for I := 0 to 255 do
  begin
    FGlyphs[I].Width := 0;
    FGlyphs[I].StrokeCount := 0;
    FGlyphs[I].Defined := False;
    SetLength(FGlyphs[I].Strokes, 0);
    FUndoStack[I] := TList.Create;
    FRedoStack[I] := TList.Create;
    FCharEnabled[I] := (I >= 32) and (I <= 127);
  end;
  
  cmbCharSet.Items.AddStrings(['ANSI (0)', 'Default (1)', 'Symbol (2)', 'OEM (255)']);
  cmbCharSet.ItemIndex := 0;
  
  cmbPitchFamily.Items.AddStrings(['Default', 'Fixed', 'Variable', 'Roman', 'Swiss', 'Modern', 'Script', 'Decorative']);
  cmbPitchFamily.ItemIndex := 2;
  
  cmbZoom.Items.AddStrings(['4x', '6x', '8x', '10x', '12x', '16x']);
  cmbZoom.ItemIndex := 2;
  
  edtFontName.Text := 'SAMP';
  edtCopyright.Text := 'Created with RetroNicks Font Editor';
  spnPointSize.Value := 12;
  spnHeight.Value := 16;
  spnAscent.Value := 12;
  edtPreviewText.Text := 'Hello World!';
  cboShowGrid.Checked := True;
  cboShowPoints.Checked := True;
  rbToolLine.Checked := True;
  
  // Initialize default glyphs for printable characters
  for I := 32 to 127 do
    EnsureGlyph(I);
  
  lstChars.Style := lbOwnerDrawFixed;
  lstChars.ItemHeight := 24;
  
  UpdateCharList;
  UpdateStatus;
  UpdateTitle;
  UpdateEditorSize;
  UpdateLineMarkerDisplay;
  
  FInitializing := False;
end;

procedure TfrmVectorMain.FormDestroy(Sender: TObject);
var
  I, J: Integer;
  P: Pointer;
begin
  FCreator.Free;
  for I := 0 to 255 do
  begin
    SetLength(FGlyphs[I].Strokes, 0);
    for J := 0 to FUndoStack[I].Count - 1 do
    begin
      P := FUndoStack[I][J];
      Dispose(PVectorGlyph(P));
    end;
    FUndoStack[I].Free;
    for J := 0 to FRedoStack[I].Count - 1 do
    begin
      P := FRedoStack[I][J];
      Dispose(PVectorGlyph(P));
    end;
    FRedoStack[I].Free;
  end;
  SetLength(FClipboard.Strokes, 0);
end;

procedure TfrmVectorMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not ConfirmSave then CloseAction := caNone;
end;

function TfrmVectorMain.ConfirmSave: Boolean;
var
  R: TModalResult;
begin
  Result := True;
  if FModified then
  begin
    R := MessageDlg('Save Changes?', 'Font has been modified. Save changes?',
      mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    case R of
      mrYes: begin btnSaveFontClick(nil); Result := not FModified; end;
      mrNo: Result := True;
      mrCancel: Result := False;
    end;
  end;
end;

procedure TfrmVectorMain.SetModified(V: Boolean);
begin
  FModified := V;
  UpdateTitle;
end;

procedure TfrmVectorMain.UpdateTitle;
begin
  if FCurrentFile <> '' then
    Caption := ProgramName+' - ' + ExtractFileName(FCurrentFile)
  else
    Caption := ProgramName+' - [Untitled]';
  if FModified then Caption := Caption + ' *';
end;

procedure TfrmVectorMain.EnsureGlyph(Idx: Integer);
begin
  if not FGlyphs[Idx].Defined then
  begin
    FGlyphs[Idx].Width := 8;
    FGlyphs[Idx].StrokeCount := 0;
    SetLength(FGlyphs[Idx].Strokes, 0);
    FGlyphs[Idx].Defined := True;
  end;
end;

procedure TfrmVectorMain.ClearUndoRedo(Idx: Integer);
var
  I: Integer;
  P: Pointer;
begin
  for I := 0 to FUndoStack[Idx].Count - 1 do
  begin
    P := FUndoStack[Idx][I];
    SetLength(PVectorGlyph(P)^.Strokes, 0);
    Dispose(PVectorGlyph(P));
  end;
  FUndoStack[Idx].Clear;
  for I := 0 to FRedoStack[Idx].Count - 1 do
  begin
    P := FRedoStack[Idx][I];
    SetLength(PVectorGlyph(P)^.Strokes, 0);
    Dispose(PVectorGlyph(P));
  end;
  FRedoStack[Idx].Clear;
end;

procedure TfrmVectorMain.SaveUndoState;
var
  P: PVectorGlyph;
  I: Integer;
begin
  New(P);
  P^.Width := FGlyphs[FCurrentChar].Width;
  P^.StrokeCount := FGlyphs[FCurrentChar].StrokeCount;
  P^.Defined := FGlyphs[FCurrentChar].Defined;
  SetLength(P^.Strokes, P^.StrokeCount);
  for I := 0 to P^.StrokeCount - 1 do
    P^.Strokes[I] := FGlyphs[FCurrentChar].Strokes[I];
  
  FUndoStack[FCurrentChar].Add(P);
  
  // Limit undo stack
  if FUndoStack[FCurrentChar].Count > 50 then
  begin
    P := PVectorGlyph(FUndoStack[FCurrentChar][0]);
    SetLength(P^.Strokes, 0);
    Dispose(P);
    FUndoStack[FCurrentChar].Delete(0);
  end;
  
  // Clear redo stack
  while FRedoStack[FCurrentChar].Count > 0 do
  begin
    P := PVectorGlyph(FRedoStack[FCurrentChar][FRedoStack[FCurrentChar].Count - 1]);
    SetLength(P^.Strokes, 0);
    Dispose(P);
    FRedoStack[FCurrentChar].Delete(FRedoStack[FCurrentChar].Count - 1);
  end;
end;

procedure TfrmVectorMain.mnuUndoClick(Sender: TObject);
var
  UndoP, RedoP: PVectorGlyph;
  I: Integer;
begin
  if FUndoStack[FCurrentChar].Count = 0 then Exit;
  
  // Save current state to redo
  New(RedoP);
  RedoP^.Width := FGlyphs[FCurrentChar].Width;
  RedoP^.StrokeCount := FGlyphs[FCurrentChar].StrokeCount;
  RedoP^.Defined := FGlyphs[FCurrentChar].Defined;
  SetLength(RedoP^.Strokes, RedoP^.StrokeCount);
  for I := 0 to RedoP^.StrokeCount - 1 do
    RedoP^.Strokes[I] := FGlyphs[FCurrentChar].Strokes[I];
  FRedoStack[FCurrentChar].Add(RedoP);
  
  // Restore from undo
  UndoP := PVectorGlyph(FUndoStack[FCurrentChar][FUndoStack[FCurrentChar].Count - 1]);
  FUndoStack[FCurrentChar].Delete(FUndoStack[FCurrentChar].Count - 1);
  
  FGlyphs[FCurrentChar].Width := UndoP^.Width;
  FGlyphs[FCurrentChar].StrokeCount := UndoP^.StrokeCount;
  FGlyphs[FCurrentChar].Defined := UndoP^.Defined;
  SetLength(FGlyphs[FCurrentChar].Strokes, UndoP^.StrokeCount);
  for I := 0 to UndoP^.StrokeCount - 1 do
    FGlyphs[FCurrentChar].Strokes[I] := UndoP^.Strokes[I];
  
  SetLength(UndoP^.Strokes, 0);
  Dispose(UndoP);
  
  spnCharWidth.Value := FGlyphs[FCurrentChar].Width;
  FSelectedPoint := -1;
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.mnuRedoClick(Sender: TObject);
var
  UndoP, RedoP: PVectorGlyph;
  I: Integer;
begin
  if FRedoStack[FCurrentChar].Count = 0 then Exit;
  
  // Save current state to undo
  New(UndoP);
  UndoP^.Width := FGlyphs[FCurrentChar].Width;
  UndoP^.StrokeCount := FGlyphs[FCurrentChar].StrokeCount;
  UndoP^.Defined := FGlyphs[FCurrentChar].Defined;
  SetLength(UndoP^.Strokes, UndoP^.StrokeCount);
  for I := 0 to UndoP^.StrokeCount - 1 do
    UndoP^.Strokes[I] := FGlyphs[FCurrentChar].Strokes[I];
  FUndoStack[FCurrentChar].Add(UndoP);
  
  // Restore from redo
  RedoP := PVectorGlyph(FRedoStack[FCurrentChar][FRedoStack[FCurrentChar].Count - 1]);
  FRedoStack[FCurrentChar].Delete(FRedoStack[FCurrentChar].Count - 1);
  
  FGlyphs[FCurrentChar].Width := RedoP^.Width;
  FGlyphs[FCurrentChar].StrokeCount := RedoP^.StrokeCount;
  FGlyphs[FCurrentChar].Defined := RedoP^.Defined;
  SetLength(FGlyphs[FCurrentChar].Strokes, RedoP^.StrokeCount);
  for I := 0 to RedoP^.StrokeCount - 1 do
    FGlyphs[FCurrentChar].Strokes[I] := RedoP^.Strokes[I];
  
  SetLength(RedoP^.Strokes, 0);
  Dispose(RedoP);
  
  spnCharWidth.Value := FGlyphs[FCurrentChar].Width;
  FSelectedPoint := -1;
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.UpdateCharList;
var
  I: Integer;
  SelIdx: Integer;
begin
  lstChars.Items.BeginUpdate;
  try
    lstChars.Items.Clear;
    SelIdx := -1;
    for I := FCharRangeStart to FCharRangeEnd do
    begin
      if FCharEnabled[I] then
      begin
        lstChars.Items.AddObject(IntToStr(I), TObject(PtrInt(I)));
        if I = FCurrentChar then
          SelIdx := lstChars.Items.Count - 1;
      end;
    end;
    if SelIdx >= 0 then
      lstChars.ItemIndex := SelIdx
    else if lstChars.Items.Count > 0 then
    begin
      lstChars.ItemIndex := 0;
      FCurrentChar := PtrInt(lstChars.Items.Objects[0]);
    end;
  finally
    lstChars.Items.EndUpdate;
  end;
end;

procedure TfrmVectorMain.ApplyCharRange;
var
  I: Integer;
begin
  for I := 0 to 255 do
    FCharEnabled[I] := (I >= FCharRangeStart) and (I <= FCharRangeEnd);
  UpdateCharList;
  if lstChars.Items.Count > 0 then
  begin
    lstChars.ItemIndex := 0;
    lstCharsClick(nil);
  end;
end;

procedure TfrmVectorMain.UpdateStrokeList;
var
  I: Integer;
  S: string;
begin
  lstStrokes.Items.BeginUpdate;
  try
    lstStrokes.Items.Clear;
    for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    begin
      if FGlyphs[FCurrentChar].Strokes[I].Cmd = scMoveTo then
        S := Format('%d: MoveTo(%d, %d)', [I, FGlyphs[FCurrentChar].Strokes[I].X,
          FGlyphs[FCurrentChar].Strokes[I].Y])
      else
        S := Format('%d: LineTo(%d, %d)', [I, FGlyphs[FCurrentChar].Strokes[I].X,
          FGlyphs[FCurrentChar].Strokes[I].Y]);
      lstStrokes.Items.Add(S);
    end;
    if FSelectedPoint >= 0 then
      lstStrokes.ItemIndex := FSelectedPoint;
  finally
    lstStrokes.Items.EndUpdate;
  end;
end;

procedure TfrmVectorMain.lstCharsDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  CC, I: Integer;
  S: string;
  SX, SY: Single;
  Scale: Single;
  PrevX, PrevY: Integer;
begin
  if (Index < 0) or (Index >= lstChars.Items.Count) then Exit;
  CC := PtrInt(lstChars.Items.Objects[Index]);
  
  with lstChars.Canvas do
  begin
    if odSelected in State then
      Brush.Color := clHighlight
    else
      Brush.Color := clWindow;
    FillRect(ARect);
    
    if odSelected in State then
      Font.Color := clHighlightText
    else
      Font.Color := clWindowText;
    
    if (CC >= 32) and (CC < 127) then
      S := Format('%3d ''%s''', [CC, Chr(CC)])
    else if CC = 127 then
      S := '127 DEL'
    else if CC < 32 then
      S := Format('%3d ^%s', [CC, Chr(CC + 64)])
    else
      S := Format('%3d #%d', [CC, CC]);
    TextOut(ARect.Left + 4, ARect.Top + 4, S);
    
    // Draw mini preview
    if FGlyphs[CC].Defined and (FGlyphs[CC].StrokeCount > 0) then
    begin
      Scale := (ARect.Bottom - ARect.Top - 4) / spnHeight.Value;
      Pen.Color := clBlack;
      Pen.Style := psSolid;
      Pen.Width := 1;
      PrevX := 0;
      PrevY := 0;
      for I := 0 to FGlyphs[CC].StrokeCount - 1 do
      begin
        SX := ARect.Right - 30 + FGlyphs[CC].Strokes[I].X * Scale;
        SY := ARect.Top + 2 + FGlyphs[CC].Strokes[I].Y * Scale;
        if FGlyphs[CC].Strokes[I].Cmd = scMoveTo then
          MoveTo(Round(SX), Round(SY))
        else
          LineTo(Round(SX), Round(SY));
        PrevX := Round(SX);
        PrevY := Round(SY);
      end;
    end
    else
    begin
      Font.Color := clGray;
      TextOut(ARect.Right - 50, ARect.Top + 4, '(empty)');
    end;
  end;
end;

procedure TfrmVectorMain.lstCharsClick(Sender: TObject);
begin
  if (lstChars.ItemIndex >= 0) and (lstChars.ItemIndex < lstChars.Items.Count) then
  begin
    FCurrentChar := PtrInt(lstChars.Items.Objects[lstChars.ItemIndex]);
    EnsureGlyph(FCurrentChar);
    
    if (FCurrentChar >= 32) and (FCurrentChar < 127) then
      lblCurrentChar.Caption := Format('Editing: %d ''%s''', [FCurrentChar, Chr(FCurrentChar)])
    else
      lblCurrentChar.Caption := Format('Editing: %d', [FCurrentChar]);
    
    spnCharWidth.Value := FGlyphs[FCurrentChar].Width;
    FSelectedPoint := -1;
    FLineStarted := False;
    UpdateStrokeList;
    UpdateEditorSize;
    pnlCharEdit.Invalidate;
    UpdatePreview;
    UpdateStatus;
  end;
end;

procedure TfrmVectorMain.lstStrokesClick(Sender: TObject);
begin
  FSelectedPoint := lstStrokes.ItemIndex;
  pnlCharEdit.Invalidate;
end;

procedure TfrmVectorMain.UpdateEditorSize;
var
  W, H: Integer;
begin
  W := Round(FGlyphs[FCurrentChar].Width * FZoom) + 40;
  H := Round(spnHeight.Value * FZoom) + 40;
  if W < 200 then W := 200;
  if H < 200 then H := 200;
  pnlCharEdit.Width := W;
  pnlCharEdit.Height := H;
end;

procedure TfrmVectorMain.cmbZoomChange(Sender: TObject);
begin
  if FInitializing then Exit;
  case cmbZoom.ItemIndex of
    0: FZoom := 4;
    1: FZoom := 6;
    2: FZoom := 8;
    3: FZoom := 10;
    4: FZoom := 12;
    5: FZoom := 16;
  else
    FZoom := 8;
  end;
  UpdateEditorSize;
  pnlCharEdit.Invalidate;
end;

procedure TfrmVectorMain.cboShowGridChange(Sender: TObject);
begin
  FShowGrid := cboShowGrid.Checked;
  pnlCharEdit.Invalidate;
end;

procedure TfrmVectorMain.cboShowPointsChange(Sender: TObject);
begin
  FShowPoints := cboShowPoints.Checked;
  pnlCharEdit.Invalidate;
end;

procedure TfrmVectorMain.rbToolChange(Sender: TObject);
begin
  if rbToolSelect.Checked then
    FCurrentTool := etSelect
  else if rbToolMove.Checked then
    FCurrentTool := etMove
  else if rbToolLine.Checked then
    FCurrentTool := etLine;
  FLineStarted := False;
  pnlCharEdit.Invalidate;
end;

function TfrmVectorMain.ScreenToChar(SX, SY: Integer; out CX, CY: Integer): Boolean;
begin
  CX := Round((SX - 20) / FZoom);
  CY := Round((SY - 20) / FZoom);
  Result := True;
end;

function TfrmVectorMain.CharToScreen(CX, CY: Integer; out SX, SY: Integer): Boolean;
begin
  SX := Round(CX * FZoom) + 20;
  SY := Round(CY * FZoom) + 20;
  Result := True;
end;

function TfrmVectorMain.FindPointAt(SX, SY: Integer): Integer;
var
  I: Integer;
  PX, PY: Integer;
begin
  Result := -1;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
  begin
    CharToScreen(FGlyphs[FCurrentChar].Strokes[I].X,
                 FGlyphs[FCurrentChar].Strokes[I].Y, PX, PY);
    if (Abs(SX - PX) <= POINT_RADIUS + 2) and (Abs(SY - PY) <= POINT_RADIUS + 2) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TfrmVectorMain.pnlCharEditPaint(Sender: TObject);
var
  PB: TPaintBox;
  I, X, Y, SX, SY, PrevSX, PrevSY: Integer;
  CharW, CharH: Integer;
  GX, GY: Integer;
begin
  PB := TPaintBox(Sender);
  CharW := FGlyphs[FCurrentChar].Width;
  CharH := spnHeight.Value;
  
  // Background
  PB.Canvas.Brush.Color := clWhite;
  PB.Canvas.FillRect(0, 0, PB.Width, PB.Height);
  


  // Grid
   if FShowGrid then
   begin
     PB.Canvas.Pen.Color := clSilver;
     PB.Canvas.Pen.Style := psSolid;
     // Vertical lines
     GX := 0;
     while GX <= PB.Width do //+GRID_SIZE  do
     begin
       CharToScreen(GX, 0, SX, SY);
       PB.Canvas.MoveTo(SX, 20);
       CharToScreen(GX, CharH, SX, SY);
       PB.Canvas.LineTo(SX, PB.Height );
       Inc(GX, GRID_SIZE);
     end;
     // Horizontal lines
     GY := 0;
     while GY <= PB.Height do
     begin
       CharToScreen(0, GY, SX, SY);
       PB.Canvas.MoveTo(20, SY);
       CharToScreen(CharW, GY, SX, SY);
       PB.Canvas.LineTo(PB.Width, SY);
       Inc(GY, GRID_SIZE);
     end;
   end;

  {// Orginal Grid
  if FShowGrid then
  begin
    PB.Canvas.Pen.Color := $E0E0E0;
    PB.Canvas.Pen.Style := psSolid;
    // Vertical lines
    GX := 0;
    while GX <= CharW + GRID_SIZE do
    begin
      CharToScreen(GX, 0, SX, SY);
      PB.Canvas.MoveTo(SX, 20);
      CharToScreen(GX, CharH, SX, SY);
      PB.Canvas.LineTo(SX, SY);
      Inc(GX, GRID_SIZE);
    end;
    // Horizontal lines
    GY := 0;
    while GY <= CharH + GRID_SIZE do
    begin
      CharToScreen(0, GY, SX, SY);
      PB.Canvas.MoveTo(20, SY);
      CharToScreen(CharW, GY, SX, SY);
      PB.Canvas.LineTo(SX, SY);
      Inc(GY, GRID_SIZE);
    end;
  end;
  }

  // Character boundary
  PB.Canvas.Pen.Color := clBlue;
  PB.Canvas.Pen.Style := psSolid;
  PB.Canvas.Pen.Width := 3;
  CharToScreen(0, 0, SX, SY);
  PB.Canvas.MoveTo(SX, SY);
  CharToScreen(CharW, 0, SX, SY);
  PB.Canvas.LineTo(SX, SY);
  CharToScreen(CharW, CharH, SX, SY);
  PB.Canvas.LineTo(SX, SY);
  CharToScreen(0, CharH, SX, SY);
  PB.Canvas.LineTo(SX, SY);
  CharToScreen(0, 0, SX, SY);
  PB.Canvas.LineTo(SX, SY);
  
  // Line markers
  PB.Canvas.Pen.Style := psSolid;
  PB.Canvas.Pen.Width := 1;
  
  // Ascender line (top of capital letters) - Cyan
  if FShowAscenderLine then
  begin
    PB.Canvas.Pen.Color := clTeal;
    if FAscenderLine >= 0 then
      Y := FAscenderLine
    else
      Y := 0;  // Top of character cell
    CharToScreen(0, Y, SX, SY);
    PB.Canvas.MoveTo(20, SY);
    CharToScreen(CharW, Y, SX, SY);
    PB.Canvas.LineTo(SX, SY);
  end;
  
  // X-Height line (top of lowercase x) - Purple
  if FShowXHeightLine then
  begin
    PB.Canvas.Pen.Color := clPurple;
    if FXHeightLine >= 0 then
      Y := FXHeightLine
    else
      Y := Round(spnAscent.Value * 0.6);  // Default 60% of ascent from top
    CharToScreen(0, Y, SX, SY);
    PB.Canvas.MoveTo(20, SY);
    CharToScreen(CharW, Y, SX, SY);
    PB.Canvas.LineTo(SX, SY);
  end;
  
  // Baseline - Red
  if FShowBaseline then
  begin
    PB.Canvas.Pen.Color := clRed;
    CharToScreen(0, spnAscent.Value, SX, SY);
    PB.Canvas.MoveTo(20, SY);
    CharToScreen(CharW, spnAscent.Value, SX, SY);
    PB.Canvas.LineTo(SX, SY);
  end;
  
  // Descender line (bottom of letters like g, y, p) - Orange
  if FShowDescenderLine then
  begin
    PB.Canvas.Pen.Color := $0080FF;  // Orange
    if FDescenderLine >= 0 then
      Y := FDescenderLine
    else
      Y := CharH;  // Bottom of character cell
    CharToScreen(0, Y, SX, SY);
    PB.Canvas.MoveTo(20, SY);
    CharToScreen(CharW, Y, SX, SY);
    PB.Canvas.LineTo(SX, SY);
  end;
  
  // Draw strokes
  PB.Canvas.Pen.Color := clBlack;
  PB.Canvas.Pen.Style := psSolid;
  PB.Canvas.Pen.Width := 2;
  PrevSX := 20;
  PrevSY := 20;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
  begin
    CharToScreen(FGlyphs[FCurrentChar].Strokes[I].X,
                 FGlyphs[FCurrentChar].Strokes[I].Y, SX, SY);
    if FGlyphs[FCurrentChar].Strokes[I].Cmd = scMoveTo then
      PB.Canvas.MoveTo(SX, SY)
    else
    begin
      PB.Canvas.MoveTo(PrevSX, PrevSY);
      PB.Canvas.LineTo(SX, SY);
    end;
    PrevSX := SX;
    PrevSY := SY;
  end;
  PB.Canvas.Pen.Width := 1;
  
  // Draw points
  if FShowPoints then
  begin
    for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    begin
      CharToScreen(FGlyphs[FCurrentChar].Strokes[I].X,
                   FGlyphs[FCurrentChar].Strokes[I].Y, SX, SY);
      
      if I = FSelectedPoint then
      begin
        PB.Canvas.Brush.Color := clRed;
        PB.Canvas.Pen.Color := clMaroon;
      end
      else if FGlyphs[FCurrentChar].Strokes[I].Cmd = scMoveTo then
      begin
        PB.Canvas.Brush.Color := clLime;
        PB.Canvas.Pen.Color := clGreen;
      end
      else
      begin
        PB.Canvas.Brush.Color := clYellow;
        PB.Canvas.Pen.Color := clOlive;
      end;
      
      PB.Canvas.Ellipse(SX - POINT_RADIUS, SY - POINT_RADIUS,
                        SX + POINT_RADIUS, SY + POINT_RADIUS);
    end;
  end;
  
  // Line in progress
  if FLineStarted then
  begin
    PB.Canvas.Pen.Color := clGray;
    PB.Canvas.Pen.Style := psDash;
    CharToScreen(FLineStartX, FLineStartY, SX, SY);
    PB.Canvas.MoveTo(SX, SY);
    // Line to cursor would be drawn during mouse move
  end;

  //Draw Frame
  PB.Canvas.Pen.Style := psSolid;
  PB.Canvas.Pen.Color := clSilver;
  PB.Canvas.Brush.Style := bsClear;
  PB.Canvas.Rectangle(0, 0, PB.Width, PB.Height);

end;

procedure TfrmVectorMain.pnlCharEditMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  CX, CY: Integer;
  PointIdx: Integer;
  Idx: Integer;
begin
  ScreenToChar(X, Y, CX, CY);
  
  if Button = mbLeft then
  begin
    case FCurrentTool of
      etSelect:
        begin
          PointIdx := FindPointAt(X, Y);
          if PointIdx >= 0 then
          begin
            FSelectedPoint := PointIdx;
            lstStrokes.ItemIndex := PointIdx;
          end
          else
            FSelectedPoint := -1;
          pnlCharEdit.Invalidate;
        end;
      
      etMove:
        begin
          PointIdx := FindPointAt(X, Y);
          if PointIdx >= 0 then
          begin
            // Clicked on existing point - start dragging it
            FSelectedPoint := PointIdx;
            lstStrokes.ItemIndex := PointIdx;
            FDragging := True;
            FDragStartX := CX;
            FDragStartY := CY;
            SaveUndoState;
          end
          else
          begin
            // Clicked on empty space - add a new MoveTo at this location
            SaveUndoState;
            Idx := FGlyphs[FCurrentChar].StrokeCount;
            Inc(FGlyphs[FCurrentChar].StrokeCount);
            SetLength(FGlyphs[FCurrentChar].Strokes, FGlyphs[FCurrentChar].StrokeCount);
            FGlyphs[FCurrentChar].Strokes[Idx].Cmd := scMoveTo;
            FGlyphs[FCurrentChar].Strokes[Idx].X := CX;
            FGlyphs[FCurrentChar].Strokes[Idx].Y := CY;
            
            FSelectedPoint := Idx;
            SetModified(True);
            UpdateStrokeList;
            UpdatePreview;
            lstChars.Invalidate;
          end;
          pnlCharEdit.Invalidate;
        end;
      
      etLine:
        begin
          Idx := FGlyphs[FCurrentChar].StrokeCount;
          
          // Check if we should add MoveTo or LineTo
          // Add LineTo if: already started OR previous command was MoveTo
          // Add MoveTo if: no strokes yet OR previous command was LineTo (starting new segment)
          if (Idx > 0) and 
             ((FLineStarted) or (FGlyphs[FCurrentChar].Strokes[Idx-1].Cmd = scMoveTo)) then
          begin
            // Add LineTo - continuing from previous point
            SaveUndoState;
            Inc(FGlyphs[FCurrentChar].StrokeCount);
            SetLength(FGlyphs[FCurrentChar].Strokes, FGlyphs[FCurrentChar].StrokeCount);
            FGlyphs[FCurrentChar].Strokes[Idx].Cmd := scLineTo;
            FGlyphs[FCurrentChar].Strokes[Idx].X := CX;
            FGlyphs[FCurrentChar].Strokes[Idx].Y := CY;
            
            FLineStartX := CX;
            FLineStartY := CY;
            FLineStarted := True;
            FSelectedPoint := Idx;
            SetModified(True);
            UpdateStrokeList;
          end
          else
          begin
            // Add MoveTo - starting a new segment
            FLineStarted := True;
            FLineStartX := CX;
            FLineStartY := CY;
            
            SaveUndoState;
            Inc(FGlyphs[FCurrentChar].StrokeCount);
            SetLength(FGlyphs[FCurrentChar].Strokes, FGlyphs[FCurrentChar].StrokeCount);
            FGlyphs[FCurrentChar].Strokes[Idx].Cmd := scMoveTo;
            FGlyphs[FCurrentChar].Strokes[Idx].X := CX;
            FGlyphs[FCurrentChar].Strokes[Idx].Y := CY;
            
            FSelectedPoint := Idx;
            SetModified(True);
            UpdateStrokeList;
          end;
          pnlCharEdit.Invalidate;
          UpdatePreview;
          lstChars.Invalidate;
        end;
    end;
  end
  else if Button = mbRight then
  begin
    // End current line
    FLineStarted := False;
    pnlCharEdit.Invalidate;
  end;
end;

procedure TfrmVectorMain.pnlCharEditMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  CX, CY: Integer;
  DX, DY: Integer;
begin
  ScreenToChar(X, Y, CX, CY);
  StatusBar.Panels[1].Text := Format('X: %d  Y: %d', [CX, CY]);
  
  if FDragging and (FSelectedPoint >= 0) then
  begin
    FGlyphs[FCurrentChar].Strokes[FSelectedPoint].X := CX;
    FGlyphs[FCurrentChar].Strokes[FSelectedPoint].Y := CY;
    UpdateStrokeList;
    pnlCharEdit.Invalidate;
    tmrPreview.Enabled := True;
  end;
end;

procedure TfrmVectorMain.pnlCharEditMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
  begin
    FDragging := False;
    SetModified(True);
    UpdatePreview;
    lstChars.Invalidate;
  end;
end;

procedure TfrmVectorMain.pnlPreviewPaint(Sender: TObject);
var
  PB: TPaintBox;
  I, J: Integer;
  CharX: Integer;
  Scale: Single;
  SX, SY, PrevSX, PrevSY: Single;
  CharCode: Integer;
begin
  PB := TPaintBox(Sender);
  Scale := 2.0;
  CharX := 10;
  
  PB.Canvas.Brush.Color := clWhite;
  PB.Canvas.FillRect(0, 0, PB.Width, PB.Height);
  
  // Draw baseline first (behind text)
  PB.Canvas.Pen.Color := clRed;
  PB.Canvas.Pen.Style := psDot;
  PB.Canvas.Pen.Width := 1;
  PB.Canvas.MoveTo(0, 10 + Round(spnAscent.Value * Scale));
  PB.Canvas.LineTo(PB.Width, 10 + Round(spnAscent.Value * Scale));
  
  // Draw text with solid lines
  PB.Canvas.Pen.Color := clBlack;
  PB.Canvas.Pen.Style := psSolid;
  PB.Canvas.Pen.Width := 1;
  
  for I := 1 to Length(edtPreviewText.Text) do
  begin
    CharCode := Ord(edtPreviewText.Text[I]);
    if (CharCode >= 0) and (CharCode <= 255) and FGlyphs[CharCode].Defined then
    begin
      PrevSX := CharX;
      PrevSY := 10;
      for J := 0 to FGlyphs[CharCode].StrokeCount - 1 do
      begin
        SX := CharX + FGlyphs[CharCode].Strokes[J].X * Scale;
        SY := 10 + FGlyphs[CharCode].Strokes[J].Y * Scale;
        if FGlyphs[CharCode].Strokes[J].Cmd = scMoveTo then
          PB.Canvas.MoveTo(Round(SX), Round(SY))
        else
        begin
          PB.Canvas.MoveTo(Round(PrevSX), Round(PrevSY));
          PB.Canvas.LineTo(Round(SX), Round(SY));
        end;
        PrevSX := SX;
        PrevSY := SY;
      end;
      CharX := CharX + Round(FGlyphs[CharCode].Width * Scale) + 2;
    end
    else
      CharX := CharX + Round(8 * Scale);
    
    if CharX > PB.Width - 20 then Break;
  end;
end;

procedure TfrmVectorMain.UpdatePreview;
begin
  pnlPreview.Invalidate;
end;

procedure TfrmVectorMain.tmrPreviewTimer(Sender: TObject);
begin
  tmrPreview.Enabled := False;
  UpdatePreview;
  lstChars.Invalidate;
end;

procedure TfrmVectorMain.edtPreviewTextChange(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TfrmVectorMain.spnHeightChange(Sender: TObject);
begin
  if FInitializing then Exit;
  UpdateEditorSize;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  SetModified(True);
end;

procedure TfrmVectorMain.spnCharWidthChange(Sender: TObject);
begin
  if FInitializing then Exit;
  FGlyphs[FCurrentChar].Width := spnCharWidth.Value;
  UpdateEditorSize;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.spnRangeChange(Sender: TObject);
begin
  // Just update the spin edits, actual application happens on Apply button
end;

procedure TfrmVectorMain.btnApplyRangeClick(Sender: TObject);
begin
  FCharRangeStart := spnRangeStart.Value;
  FCharRangeEnd := spnRangeEnd.Value;
  if FCharRangeStart > FCharRangeEnd then
  begin
    // Swap if reversed
    FCharRangeStart := spnRangeEnd.Value;
    FCharRangeEnd := spnRangeStart.Value;
    spnRangeStart.Value := FCharRangeStart;
    spnRangeEnd.Value := FCharRangeEnd;
  end;
  ApplyCharRange;
  StatusBar.Panels[0].Text := Format('Character range: %d to %d', [FCharRangeStart, FCharRangeEnd]);
end;

procedure TfrmVectorMain.btnClearCharClick(Sender: TObject);
begin
  SaveUndoState;
  FGlyphs[FCurrentChar].StrokeCount := 0;
  SetLength(FGlyphs[FCurrentChar].Strokes, 0);
  FSelectedPoint := -1;
  FLineStarted := False;
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnClearAllClick(Sender: TObject);
var
  I: Integer;
begin
  if MessageDlg('Clear All', 'Clear all characters?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    for I := 0 to 255 do
    begin
      ClearUndoRedo(I);
      FGlyphs[I].StrokeCount := 0;
      SetLength(FGlyphs[I].Strokes, 0);
    end;
    FSelectedPoint := -1;
    FLineStarted := False;
    UpdateStrokeList;
    pnlCharEdit.Invalidate;
    UpdatePreview;
    lstChars.Invalidate;
    SetModified(True);
  end;
end;

procedure TfrmVectorMain.btnAddPointClick(Sender: TObject);
var
  Idx: Integer;
begin
  SaveUndoState;
  Idx := FGlyphs[FCurrentChar].StrokeCount;
  Inc(FGlyphs[FCurrentChar].StrokeCount);
  SetLength(FGlyphs[FCurrentChar].Strokes, FGlyphs[FCurrentChar].StrokeCount);
  
  // First point is always MoveTo
  // Otherwise: Move tool adds MoveTo, Line tool adds LineTo
  if Idx = 0 then
    FGlyphs[FCurrentChar].Strokes[Idx].Cmd := scMoveTo
  else if FCurrentTool = etMove then
    FGlyphs[FCurrentChar].Strokes[Idx].Cmd := scMoveTo
  else
    FGlyphs[FCurrentChar].Strokes[Idx].Cmd := scLineTo;
  
  FGlyphs[FCurrentChar].Strokes[Idx].X := FGlyphs[FCurrentChar].Width div 2;
  FGlyphs[FCurrentChar].Strokes[Idx].Y := spnHeight.Value div 2;
  
  FSelectedPoint := Idx;
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnDeletePointClick(Sender: TObject);
var
  I: Integer;
begin
  if FSelectedPoint < 0 then Exit;
  if FSelectedPoint >= FGlyphs[FCurrentChar].StrokeCount then Exit;
  
  SaveUndoState;
  
  for I := FSelectedPoint to FGlyphs[FCurrentChar].StrokeCount - 2 do
    FGlyphs[FCurrentChar].Strokes[I] := FGlyphs[FCurrentChar].Strokes[I + 1];
  
  Dec(FGlyphs[FCurrentChar].StrokeCount);
  SetLength(FGlyphs[FCurrentChar].Strokes, FGlyphs[FCurrentChar].StrokeCount);
  
  if FSelectedPoint >= FGlyphs[FCurrentChar].StrokeCount then
    FSelectedPoint := FGlyphs[FCurrentChar].StrokeCount - 1;
  
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnCopyCharClick(Sender: TObject);
var
  I: Integer;
begin
  FClipboard.Width := FGlyphs[FCurrentChar].Width;
  FClipboard.StrokeCount := FGlyphs[FCurrentChar].StrokeCount;
  FClipboard.Defined := FGlyphs[FCurrentChar].Defined;
  SetLength(FClipboard.Strokes, FClipboard.StrokeCount);
  for I := 0 to FClipboard.StrokeCount - 1 do
    FClipboard.Strokes[I] := FGlyphs[FCurrentChar].Strokes[I];
  FHasClipboard := True;
  StatusBar.Panels[0].Text := Format('Copied char %d', [FCurrentChar]);
end;

procedure TfrmVectorMain.btnPasteCharClick(Sender: TObject);
var
  I: Integer;
begin
  if not FHasClipboard then
  begin
    StatusBar.Panels[0].Text := 'Nothing to paste';
    Exit;
  end;
  
  SaveUndoState;
  FGlyphs[FCurrentChar].Width := FClipboard.Width;
  FGlyphs[FCurrentChar].StrokeCount := FClipboard.StrokeCount;
  FGlyphs[FCurrentChar].Defined := FClipboard.Defined;
  SetLength(FGlyphs[FCurrentChar].Strokes, FClipboard.StrokeCount);
  for I := 0 to FClipboard.StrokeCount - 1 do
    FGlyphs[FCurrentChar].Strokes[I] := FClipboard.Strokes[I];
  
  spnCharWidth.Value := FGlyphs[FCurrentChar].Width;
  FSelectedPoint := -1;
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
  StatusBar.Panels[0].Text := Format('Pasted to char %d', [FCurrentChar]);
end;

procedure TfrmVectorMain.btnFlipHClick(Sender: TObject);
var
  I: Integer;
  W: Integer;
begin
  if FGlyphs[FCurrentChar].StrokeCount = 0 then Exit;
  
  SaveUndoState;
  W := FGlyphs[FCurrentChar].Width;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    FGlyphs[FCurrentChar].Strokes[I].X := W - FGlyphs[FCurrentChar].Strokes[I].X;
  
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnFlipVClick(Sender: TObject);
var
  I: Integer;
  H: Integer;
begin
  if FGlyphs[FCurrentChar].StrokeCount = 0 then Exit;
  
  SaveUndoState;
  H := spnHeight.Value;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    FGlyphs[FCurrentChar].Strokes[I].Y := H - FGlyphs[FCurrentChar].Strokes[I].Y;
  
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnMoveLeftClick(Sender: TObject);
var
  I: Integer;
begin
  if FGlyphs[FCurrentChar].StrokeCount = 0 then Exit;
  
  SaveUndoState;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    Dec(FGlyphs[FCurrentChar].Strokes[I].X);
  
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnMoveRightClick(Sender: TObject);
var
  I: Integer;
begin
  if FGlyphs[FCurrentChar].StrokeCount = 0 then Exit;
  
  SaveUndoState;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    Inc(FGlyphs[FCurrentChar].Strokes[I].X);
  
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnMoveUpClick(Sender: TObject);
var
  I: Integer;
begin
  if FGlyphs[FCurrentChar].StrokeCount = 0 then Exit;
  
  SaveUndoState;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    Dec(FGlyphs[FCurrentChar].Strokes[I].Y);
  
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnMoveDownClick(Sender: TObject);
var
  I: Integer;
begin
  if FGlyphs[FCurrentChar].StrokeCount = 0 then Exit;
  
  SaveUndoState;
  for I := 0 to FGlyphs[FCurrentChar].StrokeCount - 1 do
    Inc(FGlyphs[FCurrentChar].Strokes[I].Y);
  
  UpdateStrokeList;
  pnlCharEdit.Invalidate;
  UpdatePreview;
  lstChars.Invalidate;
  SetModified(True);
end;

procedure TfrmVectorMain.btnLoadFontClick(Sender: TObject);
var
  Ext: string;
begin
  if not ConfirmSave then Exit;
  dlgOpen.Filter := 'All Supported Fonts|*.FON;*.CHR|Windows FON Files (*.FON)|*.FON|Borland CHR Files (*.CHR)|*.CHR|All Files (*.*)|*.*';
  if dlgOpen.Execute then
  begin
    Ext := LowerCase(ExtractFileExt(dlgOpen.FileName));
    if Ext = '.chr' then
      LoadCHRFont(dlgOpen.FileName)
    else
      LoadVectorFont(dlgOpen.FileName);
  end;
end;

procedure TfrmVectorMain.LoadVectorFont(const FN: string);
var
  WF: TWinFont;
  I, J, SC: Integer;
  WFCmd: WinFont.TStrokeCmd;
  X, Y: Integer;
begin
  WF := TWinFont.Create;
  try
    try
      WF.DebugMode := False;
      if not WF.LoadFromFile(FN) then
      begin
        ShowMessage('Failed to load font: ' + FN);
        Exit;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('Exception loading font: ' + E.ClassName + ': ' + E.Message);
        Exit;
      end;
    end;
    
    if WF.FontType <> ftVector then
    begin
      ShowMessage('This is not a vector font. Please use the bitmap font editor.');
      Exit;
    end;
    
    // Clear current data
    for I := 0 to 255 do
    begin
      ClearUndoRedo(I);
      FGlyphs[I].StrokeCount := 0;
      SetLength(FGlyphs[I].Strokes, 0);
      FGlyphs[I].Defined := False;
      FGlyphs[I].Width := 8;
    end;
    
    edtFontName.Text := WF.FontName;
    spnHeight.Value := WF.Height;
    spnAscent.Value := WF.Ascent;
    
    // Copy stroke data from WinFont
    for I := WF.FirstChar to WF.LastChar do
    begin
      SC := WF.GetStrokeCount(I);
      FGlyphs[I].Width := WF.GetCharWidth(I);
      FGlyphs[I].Defined := True;
      
      if SC > 0 then
      begin
        FGlyphs[I].StrokeCount := SC;
        SetLength(FGlyphs[I].Strokes, SC);
        
        for J := 0 to SC - 1 do
        begin
          if WF.GetStrokePoint(I, J, WFCmd, X, Y) then
          begin
            if WFCmd = WinFont.scMoveTo then
              FGlyphs[I].Strokes[J].Cmd := scMoveTo
            else
              FGlyphs[I].Strokes[J].Cmd := scLineTo;
            FGlyphs[I].Strokes[J].X := X;
            FGlyphs[I].Strokes[J].Y := Y;
          end;
        end;
      end;
    end;
    
    FCurrentFile := FN;
    FCurrentChar := 65;
    if FCurrentChar < WF.FirstChar then FCurrentChar := WF.FirstChar;
    if FCurrentChar > WF.LastChar then FCurrentChar := WF.FirstChar;
    
    UpdateCharList;
    lstChars.ItemIndex := FCurrentChar - 32;
    lstCharsClick(nil);
    UpdateStatus;
    SetModified(False);
    StatusBar.Panels[0].Text := 'Loaded: ' + ExtractFileName(FN);
  finally
    WF.Free;
  end;
end;

procedure TfrmVectorMain.LoadCHRFont(const FN: string);
var
  CHR: TCHRFont;
  I, J, SC: Integer;
  CHRCmd: TCHRStrokeCmd;
  X, Y: Integer;
begin
  CHR := TCHRFont.Create;
  try
    try
      if not CHR.LoadFromFile(FN) then
      begin
        ShowMessage('Failed to load CHR font: ' + FN);
        Exit;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('Exception loading CHR font: ' + E.ClassName + ': ' + E.Message);
        Exit;
      end;
    end;
    
    // Clear current data
    for I := 0 to 255 do
    begin
      ClearUndoRedo(I);
      FGlyphs[I].StrokeCount := 0;
      SetLength(FGlyphs[I].Strokes, 0);
      FGlyphs[I].Defined := False;
      FGlyphs[I].Width := 8;
    end;
    
    edtFontName.Text := CHR.FontName;
    spnHeight.Value := Abs(CHR.OriginToAscender) + Abs(CHR.OriginToDescender);
    spnAscent.Value := Abs(CHR.OriginToAscender);
    
    // Update character range
    FCharRangeStart := CHR.FirstChar;
    FCharRangeEnd := CHR.LastChar;
    for I := 0 to 255 do
      FCharEnabled[I] := (I >= FCharRangeStart) and (I <= FCharRangeEnd);
    
    // Copy stroke data from CHR
    // After decode with Y negation: Y positive = DOWN (screen coords)
    // Ascender is at negative Y, baseline at 0, descender at positive Y
    // Editor: Y=0 at top, need to shift so ascender is at top
    for I := CHR.FirstChar to CHR.LastChar do
    begin
      SC := CHR.GetStrokeCount(I);
      FGlyphs[I].Width := CHR.GetCharWidth(I);
      FGlyphs[I].Defined := True;
      
      if SC > 0 then
      begin
        FGlyphs[I].StrokeCount := SC;
        SetLength(FGlyphs[I].Strokes, SC);
        
        for J := 0 to SC - 1 do
        begin
          if CHR.GetStrokePoint(I, J, CHRCmd, X, Y) then
          begin
            if CHRCmd = chsMoveTo then
              FGlyphs[I].Strokes[J].Cmd := scMoveTo
            else
              FGlyphs[I].Strokes[J].Cmd := scLineTo;
            // After Y negation in decode:
            //   Ascender (was +8) is now -8
            //   Baseline (was 0) is still 0
            //   Descender (was -2) is now +2
            // Shift up by ascender value so ascender line is at Y=0
            FGlyphs[I].Strokes[J].X := X;
            FGlyphs[I].Strokes[J].Y := Y + Abs(CHR.OriginToAscender);
          end;
        end;
      end;
    end;
    
    FCurrentFile := FN;
    FCurrentChar := 65;
    if FCurrentChar < CHR.FirstChar then FCurrentChar := CHR.FirstChar;
    if FCurrentChar > CHR.LastChar then FCurrentChar := CHR.FirstChar;
    
    // Set line markers from CHR font values
    // CHR ascender = 0 in editor coords (top)
    // CHR descender maps to editor coords based on height
    FAscenderLine := 0;  // Ascender is at top
    FDescenderLine := spnHeight.Value;  // Descender is at bottom
    spnAscenderLine.Value := FAscenderLine;
    spnDescenderLine.Value := FDescenderLine;
    
    // Scan for x-height from lowercase characters
    ScanFontLines(I, J, FXHeightLine);  // I, J are dummy vars, we only want XHeight
    spnXHeightLine.Value := FXHeightLine;
    
    UpdateCharList;
    lstCharsClick(nil);
    UpdateStatus;
    UpdateLineMarkerDisplay;
    SetModified(False);
    StatusBar.Panels[0].Text := 'Loaded CHR: ' + ExtractFileName(FN);
  finally
    CHR.Free;
  end;
end;

procedure TfrmVectorMain.SaveCHRFont(const FN: string);
var
  CHR: TCHRFont;
  Glyph: TCHRGlyph;
  I, J: Integer;
  MinY, MaxY, Y: Integer;
  UseAutoAscender, UseAutoDescender: Boolean;
begin
  CHR := TCHRFont.Create;
  try
    CHR.FontName :=Copy(edtFontName.Text+'XXXX',1,4); //little hack to always make sure we copy 4 character to Font name even if its empty and no if conditions

    // Find first defined character
    CHR.FirstChar := 255;
    for I := 0 to 255 do
      if FGlyphs[I].Defined and (FGlyphs[I].StrokeCount > 0) then
      begin
        if I < CHR.FirstChar then CHR.FirstChar := I;
      end;
    
    if CHR.FirstChar > 255 then
      CHR.FirstChar := 32;
    
    // Check if we need to auto-calculate ascender/descender
    UseAutoAscender := (FAscenderLine < 0);
    UseAutoDescender := (FDescenderLine < 0);
    
    // First pass: compute min/max Y values from stroke data
    // to determine proper ascender/descender values (if auto)
    MinY := 0;
    MaxY := 0;
    if UseAutoAscender or UseAutoDescender then
    begin
      for I := CHR.FirstChar to 255 do
      begin
        if not FGlyphs[I].Defined then Continue;
        for J := 0 to FGlyphs[I].StrokeCount - 1 do
        begin
          // Convert from editor coords to CHR coords: CHR_Y = Ascent - EditorY
          Y := spnAscent.Value - FGlyphs[I].Strokes[J].Y;
          if Y > MaxY then MaxY := Y;
          if Y < MinY then MinY := Y;
        end;
      end;
    end;
    
    // Set origin values - use manual if set, otherwise auto
    if UseAutoAscender then
      CHR.OriginToAscender := MaxY
    else
      CHR.OriginToAscender := spnAscent.Value - FAscenderLine;  // Convert editor Y to CHR Y
    
    CHR.OriginToBaseline := 0;
    
    if UseAutoDescender then
      CHR.OriginToDescender := MinY
    else
      CHR.OriginToDescender := spnAscent.Value - FDescenderLine;  // Convert editor Y to CHR Y
    
    // Copy glyphs
    for I := CHR.FirstChar to 255 do
    begin
      if not FGlyphs[I].Defined then Continue;
      
      Glyph.Width := FGlyphs[I].Width;
      Glyph.StrokeCount := FGlyphs[I].StrokeCount;
      Glyph.Defined := FGlyphs[I].Defined;
      SetLength(Glyph.Strokes, Glyph.StrokeCount);
      
      for J := 0 to FGlyphs[I].StrokeCount - 1 do
      begin
        if FGlyphs[I].Strokes[J].Cmd = scMoveTo then
          Glyph.Strokes[J].Cmd := chsMoveTo
        else
          Glyph.Strokes[J].Cmd := chsLineTo;
        Glyph.Strokes[J].X := FGlyphs[I].Strokes[J].X;
        // Convert from editor coords to CHR coords: CHR_Y = Ascent - EditorY
        // (The Y negation for file storage is done in EncodeStrokeCommand)
        Glyph.Strokes[J].Y := spnAscent.Value - FGlyphs[I].Strokes[J].Y;
      end;
      
      CHR.SetGlyph(I, Glyph);
      SetLength(Glyph.Strokes, 0);
    end;
    
    CHR.SaveToFile(FN);
    FCurrentFile := FN;
    SetModified(False);
    StatusBar.Panels[0].Text := 'Saved CHR: ' + ExtractFileName(FN);
  except
    on E: Exception do
      ShowMessage('Error saving CHR font: ' + E.Message);
  end;
  CHR.Free;
end;

procedure TfrmVectorMain.btnSaveFontClick(Sender: TObject);
var
  I, J: Integer;
  Strokes: array of VectorFontCreator.TStrokePoint;
  Ext: string;
begin
  dlgSave.Filter := 'Windows FON Files (*.FON)|*.FON|Borland CHR Files (*.CHR)|*.CHR|All Files (*.*)|*.*';
  dlgSave.FileName := edtFontName.Text;
  if dlgSave.Execute then
  begin
    Ext := LowerCase(ExtractFileExt(dlgSave.FileName));
    if Ext = '.chr' then
    begin
      SaveCHRFont(dlgSave.FileName);
    end
    else
    begin
      try
        FCreator.ClearAll;
        FCreator.FontName := edtFontName.Text;
        FCreator.Copyright := edtCopyright.Text;
        FCreator.PointSize := spnPointSize.Value;
        FCreator.Height := spnHeight.Value;
        FCreator.Ascent := spnAscent.Value;
        
        if cboBold.Checked then
          FCreator.Weight := fwBold
        else
          FCreator.Weight := fwNormal;
        FCreator.Italic := cboItalic.Checked;
        FCreator.Underline := cboUnderline.Checked;
        
        for I := 0 to 255 do
        begin
          if FGlyphs[I].Defined and (FGlyphs[I].StrokeCount > 0) then
          begin
            SetLength(Strokes, FGlyphs[I].StrokeCount);
            for J := 0 to FGlyphs[I].StrokeCount - 1 do
            begin
              if FGlyphs[I].Strokes[J].Cmd = scMoveTo then
                Strokes[J].Cmd := VectorFontCreator.scMoveTo
              else
                Strokes[J].Cmd := VectorFontCreator.scLineTo;
              Strokes[J].X := FGlyphs[I].Strokes[J].X;
              Strokes[J].Y := FGlyphs[I].Strokes[J].Y;
            end;
            FCreator.SetCharacter(I, Strokes, FGlyphs[I].Width);
          end;
        end;
        
        FCreator.SaveToFile(dlgSave.FileName);
        FCurrentFile := dlgSave.FileName;
        SetModified(False);
        StatusBar.Panels[0].Text := 'Saved: ' + ExtractFileName(dlgSave.FileName);
      except
        on E: Exception do
          ShowMessage('Error saving font: ' + E.Message);
      end;
    end;
  end;
end;

procedure TfrmVectorMain.mnuNewClick(Sender: TObject);
var
  I: Integer;
begin
  if not ConfirmSave then Exit;
  
  for I := 0 to 255 do
  begin
    ClearUndoRedo(I);
    FGlyphs[I].StrokeCount := 0;
    SetLength(FGlyphs[I].Strokes, 0);
    FGlyphs[I].Defined := False;
  end;
  
  edtFontName.Text := 'MyVector';
  edtCopyright.Text := 'Created with Vector Font Editor';
  spnPointSize.Value := 12;
  spnHeight.Value := 16;
  spnAscent.Value := 12;
  
  for I := 32 to 127 do
    EnsureGlyph(I);
  
  FCurrentFile := '';
  FCurrentChar := 65;
  FSelectedPoint := -1;
  FLineStarted := False;
  
  UpdateCharList;
  lstCharsClick(nil);
  UpdateStatus;
  SetModified(False);
end;

procedure TfrmVectorMain.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVectorMain.mnuAboutClick(Sender: TObject);
begin
  ShowMessage(ProgramName + LineEnding + LineEnding +
    'Create and edit FON/CHR vector/stroke fonts.' + LineEnding + LineEnding +
    'Features:' + LineEnding +
    '- Draw strokes with MoveTo/LineTo' + LineEnding +
    '- Select and move points' + LineEnding +
    '- Undo/Redo support' + LineEnding +
    '- Copy/Paste characters' + LineEnding +
    '- Flip horizontal/vertical' + LineEnding + LineEnding +
    'Built with Lazarus/Free Pascal');
end;

procedure TfrmVectorMain.mnuFontMetricsClick(Sender: TObject);
var
  I, Cnt, MinW, MaxW, TotW, TotStrokes: Integer;
begin
  Cnt := 0;
  MinW := MaxInt;
  MaxW := 0;
  TotW := 0;
  TotStrokes := 0;
  
  for I := 0 to 255 do
    if FGlyphs[I].Defined then
    begin
      Inc(Cnt);
      if FGlyphs[I].Width < MinW then MinW := FGlyphs[I].Width;
      if FGlyphs[I].Width > MaxW then MaxW := FGlyphs[I].Width;
      TotW := TotW + FGlyphs[I].Width;
      TotStrokes := TotStrokes + FGlyphs[I].StrokeCount;
    end;
  
  if Cnt = 0 then
  begin
    ShowMessage('No characters defined.');
    Exit;
  end;
  
  ShowMessage(Format(
    'Font: %s' + LineEnding +
    'Point Size: %d' + LineEnding +
    'Height: %d' + LineEnding +
    'Ascent: %d' + LineEnding + LineEnding +
    'Characters: %d' + LineEnding +
    'Total Strokes: %d' + LineEnding +
    'Min Width: %d' + LineEnding +
    'Max Width: %d' + LineEnding +
    'Avg Width: %.1f',
    [edtFontName.Text, spnPointSize.Value, spnHeight.Value, spnAscent.Value,
     Cnt, TotStrokes, MinW, MaxW, TotW / Cnt]));
end;

procedure TfrmVectorMain.mnuAddTrailingMoveToClick(Sender: TObject);
var
  I, Idx, ModifiedCount: Integer;
  BaselineY: Integer;
begin
  // Baseline Y in editor coordinates = Ascent value
  BaselineY := spnAscent.Value;
  ModifiedCount := 0;
  
  for I := 0 to 255 do
  begin
    // Only process defined characters with at least one stroke
    if not FGlyphs[I].Defined then Continue;
    if FGlyphs[I].StrokeCount = 0 then Continue;
    
    // Check if last command is already a MoveTo at the correct position
    Idx := FGlyphs[I].StrokeCount - 1;
    if (FGlyphs[I].Strokes[Idx].Cmd = scMoveTo) and
       (FGlyphs[I].Strokes[Idx].X = FGlyphs[I].Width) and
       (FGlyphs[I].Strokes[Idx].Y = BaselineY) then
      Continue;  // Already has correct trailing MoveTo
    
    // Add trailing MoveTo at (Width, Baseline)
    Inc(FGlyphs[I].StrokeCount);
    SetLength(FGlyphs[I].Strokes, FGlyphs[I].StrokeCount);
    Idx := FGlyphs[I].StrokeCount - 1;
    FGlyphs[I].Strokes[Idx].Cmd := scMoveTo;
    FGlyphs[I].Strokes[Idx].X := FGlyphs[I].Width;
    FGlyphs[I].Strokes[Idx].Y := BaselineY;
    Inc(ModifiedCount);
  end;
  
  if ModifiedCount > 0 then
  begin
    SetModified(True);
    UpdateStrokeList;
    pnlCharEdit.Invalidate;
    UpdatePreview;
    lstChars.Invalidate;
    ShowMessage(Format('Added trailing MoveTo to %d characters.', [ModifiedCount]));
  end
  else
    ShowMessage('All characters already have correct trailing MoveTo commands.');
end;

procedure TfrmVectorMain.chkLineMarkerChange(Sender: TObject);
begin
  FShowBaseline := chkShowBaseline.Checked;
  FShowAscenderLine := chkShowAscender.Checked;
  FShowDescenderLine := chkShowDescender.Checked;
  FShowXHeightLine := chkShowXHeight.Checked;
  pnlCharEdit.Invalidate;
end;

procedure TfrmVectorMain.spnLineMarkerChange(Sender: TObject);
begin
  if FInitializing then Exit;
  FAscenderLine := spnAscenderLine.Value;
  FDescenderLine := spnDescenderLine.Value;
  FXHeightLine := spnXHeightLine.Value;
  UpdateLineMarkerDisplay;
  pnlCharEdit.Invalidate;
end;

procedure TfrmVectorMain.btnResetLinesClick(Sender: TObject);
begin
  spnAscenderLine.Value := -1;
  spnDescenderLine.Value := -1;
  spnXHeightLine.Value := -1;
  FAscenderLine := -1;
  FDescenderLine := -1;
  FXHeightLine := -1;
  UpdateLineMarkerDisplay;
  pnlCharEdit.Invalidate;
end;

procedure TfrmVectorMain.ScanFontLines(out AscenderY, DescenderY, XHeightY: Integer);
var
  I, J : Integer;
  AscenderChars: set of Char;
  XHeightChars: set of Char;
  DescenderChars: set of Char;
  C: Char;
  AscMinY, XHMinY, DescMaxY: Integer;
  FoundAsc, FoundXH, FoundDesc: Boolean;
begin
  // Characters used to determine each line
  AscenderChars := ['b', 'd', 'f', 'h', 'k', 'l', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 
                    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 
                    'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  XHeightChars := ['a', 'c', 'e', 'm', 'n', 'o', 'r', 's', 'u', 'v', 'w', 'x', 'z'];
  DescenderChars := ['g', 'j', 'p', 'q', 'y'];
  
  AscMinY := MaxInt;
  XHMinY := MaxInt;
  DescMaxY := 0;
  FoundAsc := False;
  FoundXH := False;
  FoundDesc := False;
  
  // Scan ascender characters for minimum Y (top)
  for C in AscenderChars do
  begin
    I := Ord(C);
    if (I >= 0) and (I <= 255) and FGlyphs[I].Defined and (FGlyphs[I].StrokeCount > 0) then
    begin
      for J := 0 to FGlyphs[I].StrokeCount - 1 do
      begin
        if FGlyphs[I].Strokes[J].Y < AscMinY then
          AscMinY := FGlyphs[I].Strokes[J].Y;
      end;
      FoundAsc := True;
    end;
  end;
  
  // Scan x-height characters for minimum Y (top of lowercase)
  for C in XHeightChars do
  begin
    I := Ord(C);
    if (I >= 0) and (I <= 255) and FGlyphs[I].Defined and (FGlyphs[I].StrokeCount > 0) then
    begin
      for J := 0 to FGlyphs[I].StrokeCount - 1 do
      begin
        if FGlyphs[I].Strokes[J].Y < XHMinY then
          XHMinY := FGlyphs[I].Strokes[J].Y;
      end;
      FoundXH := True;
    end;
  end;
  
  // Scan descender characters for maximum Y (bottom)
  for C in DescenderChars do
  begin
    I := Ord(C);
    if (I >= 0) and (I <= 255) and FGlyphs[I].Defined and (FGlyphs[I].StrokeCount > 0) then
    begin
      for J := 0 to FGlyphs[I].StrokeCount - 1 do
      begin
        if FGlyphs[I].Strokes[J].Y > DescMaxY then
          DescMaxY := FGlyphs[I].Strokes[J].Y;
      end;
      FoundDesc := True;
    end;
  end;
  
  // Set results
  if FoundAsc then
    AscenderY := AscMinY
  else
    AscenderY := 0;
    
  if FoundXH then
    XHeightY := XHMinY
  else
    XHeightY := Round(spnAscent.Value * 0.6);
    
  if FoundDesc then
    DescenderY := DescMaxY
  else
    DescenderY := spnHeight.Value;
end;

procedure TfrmVectorMain.btnScanLinesClick(Sender: TObject);
var
  AscY, DescY, XHY: Integer;
begin
  ScanFontLines(AscY, DescY, XHY);
  
  spnAscenderLine.Value := AscY;
  spnDescenderLine.Value := DescY;
  spnXHeightLine.Value := XHY;
  
  FAscenderLine := AscY;
  FDescenderLine := DescY;
  FXHeightLine := XHY;
  
  UpdateLineMarkerDisplay;
  pnlCharEdit.Invalidate;
  
  ShowMessage(Format('Scan complete:' + LineEnding +
    'Ascender: %d' + LineEnding +
    'X-Height: %d' + LineEnding +
    'Baseline: %d' + LineEnding +
    'Descender: %d',
    [AscY, XHY, spnAscent.Value, DescY]));
end;

procedure TfrmVectorMain.UpdateLineMarkerDisplay;
var
  AscVal, DescVal, XHVal, BaseVal: Integer;
begin
  BaseVal := spnAscent.Value;
  
  if FAscenderLine >= 0 then
    AscVal := FAscenderLine
  else
    AscVal := 0;
    
  if FDescenderLine >= 0 then
    DescVal := FDescenderLine
  else
    DescVal := spnHeight.Value;
    
  if FXHeightLine >= 0 then
    XHVal := FXHeightLine
  else
    XHVal := Round(spnAscent.Value * 0.6);
  
  lblLineValues.Caption := Format(
    'Current Values:' + LineEnding +
    'Ascender: %d  X-Height: %d' + LineEnding +
    'Baseline: %d  Descender: %d',
    [AscVal, XHVal, BaseVal, DescVal]);
end;

procedure TfrmVectorMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ssCtrl in Shift then
  begin
    case Key of
      VK_Z: if ssShift in Shift then mnuRedoClick(nil) else mnuUndoClick(nil);
      VK_Y: mnuRedoClick(nil);
      VK_C: btnCopyCharClick(nil);
      VK_V: btnPasteCharClick(nil);
      VK_S: btnSaveFontClick(nil);
      VK_O: btnLoadFontClick(nil);
      VK_N: mnuNewClick(nil);
    end;
  end
  else
  begin
    case Key of
      VK_DELETE: btnDeletePointClick(nil);
      VK_ESCAPE:
        begin
          FLineStarted := False;
          pnlCharEdit.Invalidate;
        end;
    end;
  end;
end;

procedure TfrmVectorMain.UpdateStatus;
var
  Cnt, I, TotalStrokes: Integer;
  CharInfo: string;
begin
  // Count defined characters and total strokes
  Cnt := 0;
  TotalStrokes := 0;
  for I := 0 to 255 do
    if FGlyphs[I].Defined and (FGlyphs[I].StrokeCount > 0) then
    begin
      Inc(Cnt);
      TotalStrokes := TotalStrokes + FGlyphs[I].StrokeCount;
    end;
  
  // Panel 0: Current character info
  if (FCurrentChar >= 0) and (FCurrentChar <= 255) then
  begin
    if FGlyphs[FCurrentChar].Defined then
      CharInfo := Format('Char %d ''%s'' - Width: %d, Strokes: %d', 
        [FCurrentChar, Chr(FCurrentChar), FGlyphs[FCurrentChar].Width, 
         FGlyphs[FCurrentChar].StrokeCount])
    else
      CharInfo := Format('Char %d ''%s'' - Not defined', [FCurrentChar, Chr(FCurrentChar)]);
    StatusBar.Panels[0].Text := CharInfo;
  end;
  
  // Panel 2: Overall font stats
  StatusBar.Panels[2].Text := Format('Chars: %d  Strokes: %d', [Cnt, TotalStrokes]);
end;

end.
