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
/// File last update : 2024-09-01T14:31:24.000+02:00
/// Signature : 8649f3ea5b876fb6583797a41c839c6e0f632356
/// ***************************************************************************
/// </summary>

unit ZicPlay.Connector.MyMusic;

interface

uses
  ZicPlay.Connector.FileSystem,
  System.JSON,
  ZicPlay.Types;

type
  TZicPlayConnectorMyMusic = class(TZicPlayConnectorFileSystem)
  private const
    CConnectorName = 'My Music';
    CConnectorGUID = '6B3510A0-2972-48C8-80CF-9C43436B5794';
  protected
    procedure LoadParamsFromPlaylist(AParams: TJSONObject;
      var SearchFolder: string; var SearchSubFolders: Boolean); override;
    procedure SaveParamsToPlaylist(ASearchFolder: string;
      ASearchSubFolders: Boolean; Params: TJSONObject); override;
  public
    function GetName: string; override;
    function GetUniqID: string; override;
    function hasPlaylistSetupDialog: Boolean; override;
  end;

implementation

uses
  System.IOUtils;

{ TZicPlayConnectorMyMusic }

function TZicPlayConnectorMyMusic.GetName: string;
begin
  result := CConnectorName;
end;

function TZicPlayConnectorMyMusic.GetUniqID: string;
begin
  result := CConnectorGUID;
end;

function TZicPlayConnectorMyMusic.hasPlaylistSetupDialog: Boolean;
begin
  result := false;
end;

procedure TZicPlayConnectorMyMusic.LoadParamsFromPlaylist(AParams: TJSONObject;
  var SearchFolder: string; var SearchSubFolders: Boolean);
begin
  SearchFolder := tpath.GetMusicPath;
  SearchSubFolders := true;
end;

procedure TZicPlayConnectorMyMusic.SaveParamsToPlaylist(ASearchFolder: string;
  ASearchSubFolders: Boolean; Params: TJSONObject);
begin
  inherited SaveParamsToPlaylist(tpath.GetMusicPath, true, Params);
end;

initialization

TConnectorsList.current.Register(TZicPlayConnectorMyMusic.create);

finalization

// TODO : find a way to free the instance if Delphi don't do it by itself

end.
