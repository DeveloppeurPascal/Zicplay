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
    function getName: string; override;
    function getUniqID: string; override;
    function hasPlaylistSetupDialog: Boolean; override;
  end;

implementation

uses
  System.IOUtils;

{ TZicPlayConnectorMyMusic }

function TZicPlayConnectorMyMusic.getName: string;
begin
  result := CConnectorName;
end;

function TZicPlayConnectorMyMusic.getUniqID: string;
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

// if assigned(TZicPlayConnectorMyMusic.current) then
// TZicPlayConnectorMyMusic.current.Free;

end.
