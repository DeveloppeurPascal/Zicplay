unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Menus, Olf.FMX.AboutDialog;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    AboutDialog: TOlfAboutDialog;
    PopupMenu1: TPopupMenu;
    MacSystemMenu: TMenuItem;
    mnuFile: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuExit: TMenuItem;
    mnuTools: TMenuItem;
    mnuOptions: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuOptionsClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses Zicplay.Types;

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IF Defined(ANDROID) or Defined(IOS)}
  MainMenu1.Visible := false;
{$ELSEIF Defined(MACOS) and not Defined(IOS)}
  mnuExit.Visible := false; // already exists for Mac
  mnuFile.Visible := false; // empty => no display
  mnuOptions.Parent := MacSystemMenu;
  mnuOptions.text := 'Preferences'; // TODO : translate text
  mnuTools.Visible := false; // empty => no display
{$ELSE}
  MacSystemMenu.Visible := false;
{$ENDIF}
  caption := AboutDialog.Titre + ' ' + AboutDialog.VersionNumero;
{$IFDEF DEBUG}
  caption := caption + ' [DEBUG MODE]';
{$ENDIF}
end;

procedure TForm1.mnuAboutClick(Sender: TObject);
begin
  AboutDialog.Execute;
end;

procedure TForm1.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.mnuOptionsClick(Sender: TObject);
begin
  showmessage('No option dialog in this release.');
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

end.
