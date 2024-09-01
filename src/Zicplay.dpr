program Zicplay;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  Zicplay.Types in 'Zicplay.Types.pas',
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\sources\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\sources\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm},
  Gamolf.FMX.MusicLoop in '..\lib-externes\Delphi-Game-Engine\src\Gamolf.FMX.MusicLoop.pas',
  uDMIcons in 'uDMIcons.pas' {DMIcons: TDataModule},
  u_urlOpen in '..\lib-externes\librairies\src\u_urlOpen.pas',
  ZicPlay.Connector.FileSystem in 'ZicPlay.Connector.FileSystem.pas',
  ZicPlay.Connector.FileSystem.PlaylistSetupDialog in 'ZicPlay.Connector.FileSystem.PlaylistSetupDialog.pas' {frmPlaylistSetupDialog},
  ZicPlay.Connector.MyMusic in 'ZicPlay.Connector.MyMusic.pas',
  uConfig in 'uConfig.pas',
  fPlaylist in 'fPlaylist.pas' {frmPlaylist},
  fSelectConnector in 'fSelectConnector.pas' {frmSelectConnector},
  Olf.RTL.Streams in '..\lib-externes\librairies\src\Olf.RTL.Streams.pas',
  Olf.RTL.DateAndTime in '..\lib-externes\librairies\src\Olf.RTL.DateAndTime.pas',
  ID3v1 in '..\lib-externes\Audio-Tools-Library\MP3-IDtags-Reader\ID3v1.pas',
  ID3v2 in '..\lib-externes\Audio-Tools-Library\MP3-IDtags-Reader\ID3v2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMIcons, DMIcons);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
