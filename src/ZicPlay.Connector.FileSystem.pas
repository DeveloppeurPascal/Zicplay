unit ZicPlay.Connector.FileSystem;

interface

uses
System.JSON,
  ZicPlay.Types;

type
  TZicPlayConnectorFileSystem = class(TConnector)
  private
  const
  CFileSystemConnector='File system connector';
  CGUID = 'B4E2E63F-EA08-4DBB-A55E-1299548C2DEB';
  protected
  public
    function getName: string; override;
    procedure GetPlaylist(Params: TJSONObject;
      CallbackProc: TZicPlayGetPlaylistProc); override;
    function getUniqID: string; override;
    function hasPlaylistSetupDialog: Boolean; override;
    procedure PlaylistSetupDialog(Params: TJSONObject); override;
  end;

implementation

{ TZicPlayConnectorFileSystem }

function TZicPlayConnectorFileSystem.getName: string;
begin
result := CFileSystemConnector;
end;

procedure TZicPlayConnectorFileSystem.GetPlaylist(Params: TJSONObject;
  CallbackProc: TZicPlayGetPlaylistProc);
begin
  inherited;
// TODO : à compléter
end;

function TZicPlayConnectorFileSystem.getUniqID: string;
begin
result := cguid;
end;

function TZicPlayConnectorFileSystem.hasPlaylistSetupDialog: Boolean;
begin
result := true;
end;

procedure TZicPlayConnectorFileSystem.PlaylistSetupDialog(Params: TJSONObject);
begin
  inherited;
// TODO : à compléter
end;

initialization

TConnectorsList.current.Register(TZicPlayConnectorFileSystem.Create);

finalization

end.
