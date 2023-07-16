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
  ZicPlay.Connector.FileSystem.PlaylistSetupDialog,
  FMX.Media,
  ID3v1,
  ID3v2;

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

  function GetNewSong(Playlist: TPlaylist; Title, Artist, Album, Year,
    Genre: string; Duration: integer): tsong;
  begin
    // TODO : add "Language" field to TSong
    // TODO : add "Url" field to TSong
    // TODO : add "TrackNumber" field to TSong
    // TODO : add "AlbumTracksCount" field to TSong
    // TODO : add "Copyright" field to TSong
    result := tsong.create(Playlist);
    result.Title := Title;
    result.Artist := Artist;
    result.Album := Album;
    try
      if (Year.length = 4) then
        result.PublishedDate := encodedate(Year.tointeger, 1, 1)
      else if (Year.length = 010) then // hope its YYYY-MM-DD
        result.PublishedDate := encodedate(Year.substring(0, 4).tointeger,
          Year.substring(6, 2).tointeger, Year.substring(8, 2).tointeger)
      else if (Year.length > 4) then
        result.PublishedDate := encodedate(Year.substring(0, 4).tointeger, 1, 1)
      else
        result.PublishedDate := now;
    except
      // TODO : list all values in libraries or add a log somewhere to see how to handle it
      result.PublishedDate := now;
    end;
    result.Category := Genre;
    result.Duration := Duration;
  end;

var
  i: integer;
  Files: TStringDynArray;
  Song: tsong;
  Playlist: TPlaylist;
  ID3v1: TID3v1;
  ID3v2: TID3V2;
  MediaPlayer: TMediaPlayer;
begin
  ID3v1 := TID3v1.create;
  try
    ID3v2 := TID3V2.create;
    try
      MediaPlayer := TMediaPlayer.create(nil);
      try
        Playlist := TPlaylist.create;
        try
          Playlist.Connector := self;

          setlength(Files, 0);
          GetFilesFromFolder(ASearchFolder, ASearchSubFolders, Files);

          // TODO : add WAV files (wav)
          // TODO : add WMA files (Windows Media Player)
          // TODO : add M4A files (QuickTime)
          // TODO : add OGG files (OGG Vorbis)
          // TODO : add MID files (midi)
          // TODO : add MOD files (Module Tracker & co)
          for i := 0 to length(Files) - 1 do
            if (tpath.GetExtension(Files[i]).ToLower = '.mp3') then
            begin
              if ID3v2.ReadFromFile(Files[i]) and ID3v2.Exists then
                // TODO : get song duration
                Song := GetNewSong(Playlist, ID3v2.Title, ID3v2.Artist,
                  ID3v2.Album, ID3v2.Year, ID3v2.Genre, 0)
              else if ID3v1.ReadFromFile(Files[i]) and ID3v1.Exists then
                // TODO : get song duration
                Song := GetNewSong(Playlist, ID3v1.Title, ID3v1.Artist,
                  ID3v1.Album, ID3v1.Year, ID3v1.Genre, 0)
              else
                Song := GetNewSong(Playlist,
                  tpath.GetFileNameWithoutExtension(Files[i]), 'unknown',
                  tpath.GetFileNameWithoutExtension(Files[i]),
                  FormatDateTime('yyyy-mm-dd', now), 'none', 0);
//              if (Song.Duration = 0) then
//              begin
//                MediaPlayer.FileName := Files[i];
//                Song.Duration := trunc(MediaPlayer.Duration / MediaTimeScale);
//              end;
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
      finally
        MediaPlayer.Free;
      end;
    finally
      ID3v2.Free;
    end;
  finally
    ID3v1.Free;
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
