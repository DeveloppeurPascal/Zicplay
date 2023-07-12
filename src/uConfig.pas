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
  end;

  TNewPlaylistMessage = class(TMessage<TPlaylist>)
  end;

  TConfig = class
  private const
    CDataVersion = 1;

  var
    FConfigFilename: string;
    FPlaylists: TPlaylistsList;
    class var FCurrent: TConfig;
    procedure SetConfigFilename(const Value: string);
    procedure SetPlaylists(const Value: TPlaylistsList);
    class function GetCurrent: TConfig; static;
  protected
    property ConfigFilename: string read FConfigFilename
      write SetConfigFilename;
    constructor Create;
    destructor Destroy; override;
  public
    class property Current: TConfig read GetCurrent;
    property Playlists: TPlaylistsList read FPlaylists write SetPlaylists;
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromFile(AFilename: string = '');
    procedure SaveTofile(AFilename: string = '');
  end;

implementation

uses
  system.JSON,
  system.IOUtils,
  system.SysUtils;

type
  TZicPlayCounter = word;

function GetDefaultConfigFilePath: string;
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

  result := TPath.combine(folder, filename);
end;

{ TZicPlayConfig }

constructor TConfig.Create;
begin
  inherited;
  Playlists := TPlaylistsList.Create;
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
  nb: TZicPlayCounter;
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
    AStream.Read(nb, sizeof(nb));
    for i := 1 to nb do
    begin
      Playlist := TPlaylist.Create;
      Playlist.LoadFromStream(AStream);
      Playlists.Add(Playlist);
    end;
  end;
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
  nb: TZicPlayCounter;
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
end;

procedure TConfig.SetConfigFilename(const Value: string);
begin
  FConfigFilename := Value;
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

initialization

finalization

TConfig.Current.Free;

end.
