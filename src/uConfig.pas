unit uConfig;

interface

uses
  system.Generics.Collections,
  system.Classes,
  system.Messaging,
  Zicplay.Types;

type
  TPlaylistsList = class(TList<TPlaylist>)
  private
  protected
  public
    procedure Add(APlaylist: TPlaylist);
    procedure SortByName;
  end;

  TConfig = class
  private const
    CDataVersion = 2;

  var
    FmvPlaylistsVisible: boolean;
    FConfigFilename: string;
    FPlaylists: TPlaylistsList;
    FConfigChanged: boolean;
    class var FCurrent: TConfig;
    procedure SetConfigFilename(const Value: string);
    procedure SetPlaylists(const Value: TPlaylistsList);
    class function GetCurrent: TConfig; static;
    procedure SetmvPlaylistsVisible(const Value: boolean);
  protected
    property ConfigFilename: string read FConfigFilename
      write SetConfigFilename;
    constructor Create;
    destructor Destroy; override;
  public
    class property Current: TConfig read GetCurrent;
    property Playlists: TPlaylistsList read FPlaylists write SetPlaylists;
    property mvPlaylistsVisible: boolean read FmvPlaylistsVisible
      write SetmvPlaylistsVisible;
    property hasConfigChanged: boolean read FConfigChanged write FConfigChanged;
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromFile(AFilename: string = '');
    procedure SaveTofile(AFilename: string = '');
    class function GetDefaultConfigFilePath(AConfigFileName
      : string = ''): string;
  end;

implementation

uses
  system.Generics.Defaults,
  system.JSON,
  system.IOUtils,
  system.SysUtils;

class function TConfig.GetDefaultConfigFilePath(AConfigFileName
  : string): string;
var
  filename: string;
  folder: string;
  app_name: string;
begin
  app_name := TPath.GetFileNameWithoutExtension(paramstr(0));

{$IF Defined(DEBUG)}
  filename := app_name + '-debug.par';
  folder := TPath.combine(TPath.combine(TPath.GetDocumentsPath,
    'OlfSoftware-DEBUG'), app_name + '-debug');
{$ELSE if Defined(RELEASE)}
  filename := app_name + '.par';
  folder := TPath.combine(TPath.combine(TPath.GetDocumentsPath, 'OlfSoftware'),
    app_name);
{$ELSE}
{$MESSAGE FATAL 'setup problem'}
{$ENDIF}
  if not tdirectory.Exists(folder) then
    tdirectory.CreateDirectory(folder);

  if (AConfigFileName.IsEmpty) then
    result := TPath.combine(folder, filename)
  else
    result := TPath.combine(folder, AConfigFileName);
end;

{ TZicPlayConfig }

constructor TConfig.Create;
begin
  inherited;
  Playlists := TPlaylistsList.Create;
  FConfigChanged := false;
  FmvPlaylistsVisible := false;
end;

destructor TConfig.Destroy;
begin
  Playlists.Free;
  inherited;
end;

class function TConfig.GetCurrent: TConfig;
begin
  if not assigned(FCurrent) then
    FCurrent := TConfig.Create;

  result := FCurrent;
end;

procedure TConfig.LoadFromFile(AFilename: string);
var
  Stream: TFileStream;
begin
  AFilename := AFilename.Trim;

  if AFilename.IsEmpty then
    AFilename := GetDefaultConfigFilePath;
  // raise exception.Create('No filename to load the config.');

  FConfigFilename := AFilename;

  if not tfile.Exists(AFilename) then
    exit;

  Stream := TFileStream.Create(AFilename, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TConfig.LoadFromStream(AStream: TStream);
var
  DataVersion: word;
  nb: TPlaylistsCounter;
  i: integer;
  Playlist: TPlaylist;
begin
  if not assigned(AStream) then
    raise exception.Create('Where do you expect I load the config from ?');

  AStream.Read(DataVersion, sizeof(DataVersion));
  if (DataVersion > CDataVersion) then
    raise exception.Create('The program is too old to read this config file.');

  if (DataVersion >= 1) then
  begin
    Playlists.Clear;
    // TODO : DANGER is the load is done on a filled playlist with played songs
    AStream.Read(nb, sizeof(nb));
    for i := 1 to nb do
    begin
      Playlist := TPlaylist.Create;
      Playlist.LoadFromStream(AStream);
      Playlists.Add(Playlist);
    end;
    Playlists.SortByName;
  end;

  if (DataVersion >= 2) then
    AStream.Read(FmvPlaylistsVisible, sizeof(FmvPlaylistsVisible));
end;

procedure TConfig.SaveTofile(AFilename: string);
var
  Stream: TFileStream;
begin
  AFilename := AFilename.Trim;

  if AFilename.IsEmpty then
    AFilename := FConfigFilename;

  if AFilename.IsEmpty then
    raise exception.Create('No filename to save the config.');

  Stream := TFileStream.Create(AFilename, fmcreate + fmOpenWrite);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TConfig.SaveToStream(AStream: TStream);
var
  DataVersion: word;
  nb: TPlaylistsCounter;
  Playlist: TPlaylist;
begin
  if not assigned(AStream) then
    raise exception.Create('Where do you expect I save the config to ?');

  DataVersion := CDataVersion;
  AStream.Write(DataVersion, sizeof(DataVersion));

  nb := Playlists.Count;
  AStream.Write(nb, sizeof(nb));
  if (nb > 0) then
    for Playlist in Playlists do
      Playlist.SaveToStream(AStream);

  AStream.Write(FmvPlaylistsVisible, sizeof(FmvPlaylistsVisible));

  FConfigChanged := false;
end;

procedure TConfig.SetConfigFilename(const Value: string);
begin
  FConfigFilename := Value;
end;

procedure TConfig.SetmvPlaylistsVisible(const Value: boolean);
begin
  FmvPlaylistsVisible := Value;
  FConfigChanged := true;
end;

procedure TConfig.SetPlaylists(const Value: TPlaylistsList);
begin
  FPlaylists := Value;
end;

{ TPlaylistsList }

procedure TPlaylistsList.Add(APlaylist: TPlaylist);
begin
  inherited Add(APlaylist);
  TMessageManager.DefaultManager.SendMessage(Self,
    TNewPlaylistMessage.Create(APlaylist));
end;

procedure TPlaylistsList.SortByName;
begin
  Sort(TComparer<TPlaylist>.Construct(
    function(const A, B: TPlaylist): integer
    begin
      if (A.Text = B.Text) then
        result := 0
      else if (A.Text < B.Text) then
        result := -1
      else
        result := 1;
    end));
end;

initialization

finalization

if TConfig.Current.hasConfigChanged then
  TConfig.Current.SaveTofile;

TConfig.Current.Free;

end.
