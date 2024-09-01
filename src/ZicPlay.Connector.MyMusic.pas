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
