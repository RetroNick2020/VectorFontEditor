unit about;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLIntf;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    GoToItchIOButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    OkButton: TButton;
    procedure GoToItchIOButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}

{ TFormAbout }

procedure TFormAbout.OkButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TFormAbout.GoToItchIOButtonClick(Sender: TObject);
begin
  OpenUrl('https://retronick2020.itch.io/');
end;

end.

