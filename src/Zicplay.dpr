program Zicplay;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {Form1},
  Zicplay.Types in 'Zicplay.Types.pas',
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\sources\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\sources\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm},
  Gamolf.FMX.MusicLoop in '..\lib-externes\Delphi-Game-Engine\src\Gamolf.FMX.MusicLoop.pas',
  uDMIcons in 'uDMIcons.pas' {DMIcons: TDataModule},
  u_urlOpen in '..\lib-externes\librairies\u_urlOpen.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDMIcons, DMIcons);
  Application.Run;
end.
