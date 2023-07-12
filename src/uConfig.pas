unit uConfig;

interface

uses
  system.Generics.Collections,
  system.Classes,
  Zicplay.Types;

type
  TPlaylistsList = class(TList<TPlaylist>)
  private
  protected
  public
  end;

  TZicPlayConfig = class
  private const
    CDataVersion = 1;

  var
    FConfigFilename: string;
    FPlaylists: TPlaylistsList;
    class var FCurrent: TZicPlayConfig;
    procedure SetConfigFilename(const Value: string);
    procedure SetPlaylists(const Value: TPlaylistsList);
    class function GetCurrent: TZicPlayConfig; static;
  protected
    property ConfigFilename: string read FConfigFilename
      write SetConfigFilename;
    constructor Create;
    destructor Destroy; override;
  public
    class property Current: TZicPlayConfig read GetCurrent;
    property Playlists: TPlaylistsList read FPlaylists write SetPlaylists;
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromFile(AFilename: string);
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

constructor TZicPlayConfig.Create;
begin
  inherited;
  Playlists := TPlaylistsList.Create;
end;

destructor TZicPlayConfig.Destroy;
begin
  Playlists.Free;
  inherited;
end;

class function TZicPlayConfig.GetCurrent: TZicPlayConfig;
begin
  if not assigned(FCurrent) then
    FCurrent := TZicPlayConfig.Create;

  result := FCurrent;
end;

procedure TZicPlayConfig.LoadFromFile(AFilename: string);
var
  Stream: TFileStream;
begin
  AFilename := AFilename.Trim;

  if AFilename.IsEmpty then
    raise exception.Create('No filename to load the config.');

  if not tfile.Exists(AFilename) then
    exit;

  Stream := TFileStream.Create(AFilename, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
    FConfigFilename := AFilename;
  end;
end;

procedure TZicPlayConfig.LoadFromStream(AStream: TStream);
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

procedure TZicPlayConfig.SaveTofile(AFilename: string);
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

procedure TZicPlayConfig.SaveToStream(AStream: TStream);
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

procedure TZicPlayConfig.SetConfigFilename(const Value: string);
begin
  FConfigFilename := Value;
end;

procedure TZicPlayConfig.SetPlaylists(const Value: TPlaylistsList);
begin
  FPlaylists := Value;
end;

initialization

TZicPlayConfig.Current.LoadFromFile(GetDefaultConfigFilePath);

finalization

TZicPlayConfig.Current.Free;

end.
