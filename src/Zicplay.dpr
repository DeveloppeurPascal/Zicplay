program Zicplay;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  Zicplay.Types in 'Zicplay.Types.pas',
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm},
  Gamolf.FMX.MusicLoop in '..\lib-externes\Delphi-Game-Engine\src\Gamolf.FMX.MusicLoop.pas',
  uDMIcons in 'uDMIcons.pas' {DMIcons: TDataModule},
  u_urlOpen in '..\lib-externes\librairies\src\u_urlOpen.pas',
  ZicPlay.Connector.FileSystem in 'ZicPlay.Connector.FileSystem.pas',
  ZicPlay.Connector.FileSystem.PlaylistSetupDialog in 'ZicPlay.Connector.FileSystem.PlaylistSetupDialog.pas' {frmPlaylistSetupDialog},
  ZicPlay.Connector.MyMusic in 'ZicPlay.Connector.MyMusic.pas',
  ZicPlay.Config in 'ZicPlay.Config.pas',
  fPlaylist in 'fPlaylist.pas' {frmPlaylist},
  fSelectConnector in 'fSelectConnector.pas' {frmSelectConnector},
  Olf.RTL.DateAndTime in '..\lib-externes\librairies\src\Olf.RTL.DateAndTime.pas',
  ID3v1 in '..\lib-externes\Audio-Tools-Library\MP3-IDtags-Reader\ID3v1.pas',
  ID3v2 in '..\lib-externes\Audio-Tools-Library\MP3-IDtags-Reader\ID3v2.pas',
  Olf.RTL.Maths.Conversions in '..\lib-externes\librairies\src\Olf.RTL.Maths.Conversions.pas',
  _StyleContainerAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\_StyleContainerAncestor.pas' {__StyleContainerAncestor: TDataModule},
  _TFormAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\_TFormAncestor.pas' {__TFormAncestor},
  _TFrameAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\_TFrameAncestor.pas' {__TFrameAncestor: TFrame},
  uDMAboutBox in '..\lib-externes\FMX-Tools-Starter-Kit\src\uDMAboutBox.pas' {AboutBox: TDataModule},
  uDMAboutBoxLogoStorrage in 'uDMAboutBoxLogoStorrage.pas' {dmAboutBoxLogo: TDataModule},
  uStyleDarkByDefault in '..\lib-externes\FMX-Tools-Starter-Kit\src\uStyleDarkByDefault.pas' {StyleDarkByDefault: TDataModule},
  uStyleLightByDefault in '..\lib-externes\FMX-Tools-Starter-Kit\src\uStyleLightByDefault.pas' {StyleLightByDefault: TDataModule},
  uStyleManager in '..\lib-externes\FMX-Tools-Starter-Kit\src\uStyleManager.pas',
  uTranslate in '..\lib-externes\FMX-Tools-Starter-Kit\src\uTranslate.pas',
  uTxtAboutDescription in 'uTxtAboutDescription.pas',
  uTxtAboutLicense in 'uTxtAboutLicense.pas',
  _MainFormAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\_MainFormAncestor.pas',
  uConsts in 'uConsts.pas',
  uConfig in '..\lib-externes\FMX-Tools-Starter-Kit\src\uConfig.pas',
  Olf.RTL.CryptDecrypt in '..\lib-externes\librairies\src\Olf.RTL.CryptDecrypt.pas',
  Olf.RTL.Language in '..\lib-externes\librairies\src\Olf.RTL.Language.pas',
  Olf.RTL.Params in '..\lib-externes\librairies\src\Olf.RTL.Params.pas',
  Olf.RTL.Streams in '..\lib-externes\librairies\src\Olf.RTL.Streams.pas',
  Olf.RTL.SystemAppearance in '..\lib-externes\librairies\src\Olf.RTL.SystemAppearance.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMIcons, DMIcons);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
