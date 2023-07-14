unit ZicPlay.Connector.FileSystem;

interface

uses
  System.JSON,
  ZicPlay.Types;

type
  TZicPlayConnectorFileSystem = class(TConnector)
  private const
    CConnectorName = 'File System';
    CConnectorGUID = 'B4E2E63F-EA08-4DBB-A55E-1299548C2DEB';
  protected
    procedure GetPlaylist(ASearchFolder: string; ASearchSubFolders: Boolean;
      ACallbackProc: TZicPlayGetPlaylistProc); overload; virtual;
    procedure LoadParamsFromPlaylist(AParams: TJSONObject;
      var SearchFolder: string; var SearchSubFolders: Boolean); virtual;
    procedure SaveParamsToPlaylist(ASearchFolder: string;
      ASearchSubFolders: Boolean; Params: TJSONObject); virtual;
  public
    function getName: string; override;
    procedure GetPlaylist(AParams: TJSONObject;
      ACallbackProc: TZicPlayGetPlaylistProc); overload; override;
    function getUniqID: string; override;
    function hasPlaylistSetupDialog: Boolean; override;
    procedure PlaylistSetupDialog(AParams: TJSONObject); override;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Types,
  ZicPlay.Connector.FileSystem.PlaylistSetupDialog;

{ TZicPlayConnectorFileSystem }

function TZicPlayConnectorFileSystem.getName: string;
begin
  result := CConnectorName;
end;

procedure TZicPlayConnectorFileSystem.GetPlaylist(AParams: TJSONObject;
  ACallbackProc: TZicPlayGetPlaylistProc);
var
  SearchFolder: string;
  SearchSubFolders: Boolean;
begin
  if not assigned(ACallbackProc) then
    raise exception.create('How do you expect to retrieve the playlist ?');

  LoadParamsFromPlaylist(AParams, SearchFolder, SearchSubFolders);

  if not tdirectory.Exists(SearchFolder) then
    raise exception.create('Can''t access to "' + SearchFolder + '".');
  // TODO : perhaps return an empty (with error) playlist or nil to the callbackproc

  tthread.CreateAnonymousThread(
    procedure
    begin
      GetPlaylist(SearchFolder, SearchSubFolders, ACallbackProc);
    end).Start;
end;

procedure TZicPlayConnectorFileSystem.GetPlaylist(ASearchFolder: string;
ASearchSubFolders: Boolean; ACallbackProc: TZicPlayGetPlaylistProc);
  procedure GetFilesFromFolder(AFolder: string; AInSubFoldersToo: Boolean;
  var AFiles: TStringDynArray);
  var
    fs: TStringDynArray;
    i, j: integer;
  begin
    try
      fs := tdirectory.GetFiles(AFolder);
      if length(fs) > 0 then
      begin
        j := length(AFiles);
        setlength(AFiles, j + length(fs));
        for i := 0 to length(fs) - 1 do
          AFiles[j + i] := fs[i];
      end;

      if not AInSubFoldersToo then
        exit;

      fs := tdirectory.GetDirectories(AFolder);
      if length(fs) > 0 then
        for i := 0 to length(fs) - 1 do
          GetFilesFromFolder(fs[i], AInSubFoldersToo, AFiles);
    except

    end;
  end;

var
  i: integer;
  Files: TStringDynArray;
  Song: TSong;
  Playlist: TPlaylist;
begin
  Playlist := TPlaylist.create;
  try
    Playlist.Connector := self;

    setlength(Files, 0);
    GetFilesFromFolder(ASearchFolder, ASearchSubFolders, Files);

    for i := 0 to length(Files) - 1 do
      if (tpath.GetExtension(Files[i]).ToLower = '.mp3') then
      begin
        // TODO : get ID3 tags from the MP3 file and fill the TSong properties
        Song := TSong.create(Playlist);
        Song.Title := tpath.GetFileNameWithoutExtension(Files[i]);
        Song.Artist := 'artists ' + Song.Title.ToLower;
        Song.Album := tpath.GetDirectoryName(ASearchFolder);
        Song.Duration := random(60 * 5);
        Song.PublishedDate := now;
        Song.Category := 'mp3';
        Song.Order := 0;
        Song.UniqID := Files[i];
        Song.FileName := Files[i];
        Song.onGetFilename := nil;

        Playlist.Add(Song);
      end;

  except
    Playlist.Free;
    raise;
  end;

  if assigned(ACallbackProc) then
    ACallbackProc(Playlist);
end;

function TZicPlayConnectorFileSystem.getUniqID: string;
begin
  result := CConnectorGUID;
end;

function TZicPlayConnectorFileSystem.hasPlaylistSetupDialog: Boolean;
begin
  result := true;
end;

procedure TZicPlayConnectorFileSystem.PlaylistSetupDialog(AParams: TJSONObject);
var
  Folder: string;
  InSubFolders: Boolean;
begin
  LoadParamsFromPlaylist(AParams, Folder, InSubFolders);
  TfrmPlaylistSetupDialog.Execute(Folder, InSubFolders,
    procedure(AFolder: string; AInSubFolders: Boolean)
    begin
      SaveParamsToPlaylist(AFolder, AInSubFolders, AParams);
    end);
end;

procedure TZicPlayConnectorFileSystem.SaveParamsToPlaylist
  (ASearchFolder: string; ASearchSubFolders: Boolean; Params: TJSONObject);
begin
  if not assigned(Params) then
    raise exception.create('Needs the params to find songs files.');

  Params.RemovePair('folder').Free;
  Params.addpair('folder', ASearchFolder);
  Params.RemovePair('sub').Free;
  Params.addpair('sub', ASearchSubFolders);
end;

procedure TZicPlayConnectorFileSystem.LoadParamsFromPlaylist
  (AParams: TJSONObject; var SearchFolder: string;
var SearchSubFolders: Boolean);
begin
  if not assigned(AParams) then
    raise exception.create('Needs the params to find songs files.');

  if not AParams.TryGetValue<string>('folder', SearchFolder) then
    SearchFolder := tpath.GetMusicPath;

  if not AParams.TryGetValue<Boolean>('sub', SearchSubFolders) then
    SearchSubFolders := false;
end;

initialization

TConnectorsList.current.Register(TZicPlayConnectorFileSystem.create);

finalization

// if assigned(TZicPlayConnectorFileSystem.current) then
// TZicPlayConnectorFileSystem.current.Free;

// TODO : find a way to free the instance if Delphi don't do it by itself

end.
