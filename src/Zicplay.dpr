(* C2PP
  ***************************************************************************

  ZicPlay

  Copyright 2023-2025 Patrick Prémartin under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  ZicPlay is a MP3 player based on playlists from multiple sources.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://zicplay.olfsoftware.fr/

  Project site :
  https://github.com/DeveloppeurPascal/Zicplay

  ***************************************************************************
  File last update : 2025-10-16T10:43:26.211+02:00
  Signature : 2e6c848a74d68a8a3a7d728a6402fb181e069702
  ***************************************************************************
*)

program Zicplay;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  Zicplay.Types in 'Zicplay.Types.pas',
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm},
  Gamolf.FMX.MusicLoop in '..\lib-externes\Delphi-Game-Engine\src\Gamolf.FMX.MusicLoop.pas',
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
  Olf.RTL.SystemAppearance in '..\lib-externes\librairies\src\Olf.RTL.SystemAppearance.pas',
  uStylePolarLight in '..\_PRIVATE\src\uStylePolarLight.pas' {StylePolarLight: TDataModule},
  uStylePolarDark in '..\_PRIVATE\src\uStylePolarDark.pas' {StylePolarDark: TDataModule},
  uStyleImpressiveDark in '..\_PRIVATE\src\uStyleImpressiveDark.pas' {StyleImpressiveDark: TDataModule},
  uStyleImpressiveLight in '..\_PRIVATE\src\uStyleImpressiveLight.pas' {StyleImpressiveLight: TDataModule},
  Olf.FMX.SelectDirectory in '..\lib-externes\Delphi-FMXExtend-Library\src\Olf.FMX.SelectDirectory.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
