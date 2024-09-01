/// <summary>
/// ***************************************************************************
///
/// ZicPlay
///
/// Copyright 2023-2024 Patrick Prémartin under AGPL 3.0 license.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
/// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS IN THE SOFTWARE.
///
/// ***************************************************************************
///
/// ZicPlay is a MP3 player based on playlists from multiple sources.
///
/// ***************************************************************************
///
/// Author(s) :
/// Patrick PREMARTIN
///
/// Site :
/// https://zicplay.olfsoftware.fr/
///
/// Project site :
/// https://github.com/DeveloppeurPascal/Zicplay
///
/// ***************************************************************************
/// File last update : 2024-09-01T14:38:06.000+02:00
/// Signature : a50b005c84af12052109da8a0729c12cc624d45c
/// ***************************************************************************
/// </summary>

unit uConsts;

interface

uses
  System.Types;

const
  /// <summary>
  /// Version number of your project, don't forget to update the
  /// Project/Options/Versions infos before compiling a public RELEASE
  /// </summary>
  CAboutVersionNumber = '1.3';

  /// <summary>
  /// Version date of your project, change it when you publish a new public release
  /// </summary>
  CAboutVersionDate = '20240901';

  /// <summary>
  /// Title of your project used in the About box and as the main form caption
  /// </summary>
  CAboutTitle = 'ZicPlay';

  /// <summary>
  /// The copyright to show in the About box
  /// </summary>
  CAboutCopyright = '2023-2024 Patrick Prémartin';
  // 2024 your name or anything else

  /// <summary>
  /// The website URL of your project (used in the About box)
  /// </summary>
  CAboutURL = 'https://zicplay.olfsoftware.fr';

  /// <summary>
  /// Website open by Tools / Support menu option
  /// </summary>
  // TODO : corriger le lien
  CSupportURL = CAboutURL + 'userhelp.html';

  /// <summary>
  /// Default language used if the system language is not supported
  /// (of course you have to translate all textes of the program in this
  /// language, so use yours or English by default)
  /// </summary>
  /// <remarks>
  /// use 2 letters ISO code
  /// </remarks>
  CDefaultLanguage = 'en';

  /// <summary>
  /// Used as a folder name to store your projects settings
  /// </summary>
  /// <remarks>
  /// Don't use a path, only a name to use as a folder name.
  /// The real paths are calculated automatically depending on the platform.
  /// </remarks>
  // for example your name, label or company name (avoid spaces, accents and special characters)
  CEditorFolderName = 'OlfSoftware';

  /// <summary>
  /// Used as a subfolder name to store your projects settings
  /// </summary>
  /// Don't use a path, only a name to use a a folder name.
  /// The real paths are calculated automatically depending on the platform.
  /// </remarks>
  // for exemple your project title (avoid spaces, accents and special characters)
  CProjectFolderName = 'Zicplay';

  /// <summary>
  /// The GUID to use for this project when saving/loading files like a project
  /// documentto check they are from this program and not an other one.
  /// </summary>
  CProjectGUID = '{0D01ACD3-4B08-423F-8980-B9B718EF6849}';

  /// <summary>
  /// Show the About box dialog when F1 key is used
  /// </summary>
  CShowAboutBoxWithF1 = true;

type
{$SCOPEDENUMS ON}
  TStyleMode = (Light, Dark, System, Custom);

const
  /// <summary>
  /// Name of the default style used when the user choose the light mode.
  /// </summary>
  CDefaultStyleLight = 'polar light';
  /// <summary>
  /// Name of the default style used when the user choose the dark mode.
  /// </summary>
  CDefaultStyleDark = 'polar dark';
  /// <summary>
  /// Name of the default style used when the user choose the custom mode.
  /// </summary>
  CDefaultStyleCustom = 'default';
  /// <summary>
  /// Default style mode to use in the program.
  /// </summary>
  CDefaultStyleMode = TStyleMode.Custom;
  // TODO : thèmes désactivés à cause de https://embt.atlassian.net/servicedesk/customer/portal/1/RSS-1675

{$IF Defined(RELEASE)}

var
  GConfigXORKey: TByteDynArray;
  GDocumentsXORKey: TByteDynArray;
{$ENDIF}

implementation

uses
  System.Classes,
  System.SysUtils;

initialization

try
  if CAboutTitle.Trim.IsEmpty then
    raise Exception.Create
      ('Please give a title to your project in CAboutTitle !');

  if CEditorFolderName.Trim.IsEmpty then
    raise Exception.Create
      ('Please give an editor folder name in CEditorFolderName !');

  if CProjectFolderName.Trim.IsEmpty then
    raise Exception.Create
      ('Please give a project folder name in CProjectFolderName !');

  if CDefaultLanguage.Trim.IsEmpty then
    raise Exception.Create
      ('Please specify a default language ISO code in CDefaultLanguage !');

  if (CDefaultLanguage <> CDefaultLanguage.Trim.ToLower) then
    raise Exception.Create('Please use "' + CDefaultLanguage.Trim.ToLower +
      '" as CDefaultLanguage value.');

{$IFDEF RELEASE}
  if (CProjectGUID = '{8346EB88-E9AB-4578-A416-DA1D904229D4}') then
    raise Exception.Create('Wrong GUID. Change it in project settings !');
{$ENDIF}
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ELSE}
  ReportMemoryLeaksOnShutdown := false;
{$ENDIF}
{$IF Defined(RELEASE)}
  // Path to the Pascal file where you fill GConfigXORKey variable.
  // This variable is used to crypt/decrypt the settings data in RELEASE mode.
  //
  // Template file is in ____PRIVATE\src\ConfigFileXORKey.inc
  // Copy it to a private folder (not in the code repository for security reasons)
  // Customize it
  // Update it's path to the Include directive
  //
  // Don't share the key file. If you need to modify it, you won't be able to
  // open the previous configuration file!
{$I '..\_PRIVATE\src\ConfigFileXORKey.inc'}

  // Path to the Pascal file where you fill GProjectDataXORKey variable.
  // This variable is used to crypt/decrypt the settings data in RELEASE mode.
  //
  // Template file is in ____PRIVATE\src\DocumentsFileXORKey.inc
  // Copy it to a private folder (not in the code repository for security reasons)
  // Customize it
  // Update it's path to the Include directive
  //
  // Don't share the key file. If you need to modify it, you won't be able to
  // open the previous configuration file!
{$I '..\_PRIVATE\src\DocumentsFileXORKey.inc'}
{$ENDIF}
except
  on e: Exception do
  begin
    var
    s := e.message;
    tthread.forcequeue(nil,
      procedure
      begin
        raise Exception.Create(s);
      end);
  end;
end;

end.
