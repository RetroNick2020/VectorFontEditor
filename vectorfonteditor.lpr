program VectorFontEditor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  VectorFontMain, about,
  VectorFontCreator,
  WinFont,
  BorlandCHR;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='VectorFontEditor';

  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmVectorMain, frmVectorMain);
  Application.CreateForm(TFormAbout, FormAbout);
  Application.Run;
end.
