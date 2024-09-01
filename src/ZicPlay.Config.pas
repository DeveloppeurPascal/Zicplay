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
/// File last update : 2024-09-01T18:28:18.000+02:00
/// Signature : 05f13b51fd0dbfed764c3189290e2620bb1f5238
/// ***************************************************************************
/// </summary>

unit ZicPlay.Config;

interface

uses
  system.Generics.Collections,
  system.Classes,
  system.Messaging,
  ZicPlay.Types;

type
  TPlaylistsList = class(TList<TPlaylist>)
  private
  protected
  public
    procedure Add(APlaylist: TPlaylist);
    procedure SortByName;
  end;

  TZPConfig = class
  private const
    CDataVersion = 4;

  var
    FmvPlaylistsVisible: boolean;
    FConfigFilename: string;
    FPlaylists: TPlaylistsList;
    FConfigChanged: boolean;
    FPlayRepeatAll: boolean;
    FPlayRepeatOne: boolean;
    FPlayIntroDuration: integer;
    FPlayNextRandom: boolean;
    FVolume: integer;
    FPlayIntro: boolean;
    FSortType: integer;
    FFilterText: string;
    procedure SetFilterText(const Value: string);
    procedure SetSortType(const Value: integer);
    procedure SetPlayIntro(const Value: boolean);
    procedure SetPlayIntroDuration(const Value: integer);
    procedure SetPlayNextRandom(const Value: boolean);
    procedure SetPlayRepeatAll(const Value: boolean);
    procedure SetPlayRepeatOne(const Value: boolean);
    procedure SetVolume(const Value: integer);
    procedure SetConfigFilename(const Value: string);
    procedure SetPlaylists(const Value: TPlaylistsList);
    procedure SetmvPlaylistsVisible(const Value: boolean);
    class var FCurrent: TZPConfig;
    class function GetCurrent: TZPConfig; static;
  protected
    property ConfigFilename: string read FConfigFilename
      write SetConfigFilename;
    constructor Create;
    destructor Destroy; override;
  public
    class property Current: TZPConfig read GetCurrent;
    property Playlists: TPlaylistsList read FPlaylists write SetPlaylists;
    property mvPlaylistsVisible: boolean read FmvPlaylistsVisible
      write SetmvPlaylistsVisible;
    property Volume: integer read FVolume write SetVolume;
    property PlayIntro: boolean read FPlayIntro write SetPlayIntro;
    property PlayIntroDuration: integer read FPlayIntroDuration
      write SetPlayIntroDuration;
    property PlayNextRandom: boolean read FPlayNextRandom
      write SetPlayNextRandom;
    property PlayRepeatAll: boolean read FPlayRepeatAll write SetPlayRepeatAll;
    property PlayRepeatOne: boolean read FPlayRepeatOne write SetPlayRepeatOne;
    property hasConfigChanged: boolean read FConfigChanged write FConfigChanged;
    property FilterText: string read FFilterText write SetFilterText;
    property SortType: integer read FSortType write SetSortType;
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromFile(AFilename: string = '');
    procedure SaveTofile(AFilename: string = '');
    class function GetDefaultConfigFilePath: string;
    class function GetDefaultFilePath(const AFilename: string): string;
  end;

implementation

uses
  system.Generics.Defaults,
  system.JSON,
  system.IOUtils,
  system.SysUtils,
  Olf.RTL.Streams,
  uConfig;

class function TZPConfig.GetDefaultConfigFilePath: string;
var
  Suffixe, OldFilePath: string;
begin
{$IFDEF DEBUG}
  Suffixe := '-debug';
{$ELSE}
  Suffixe := '';
{$ENDIF}
  result := GetDefaultFilePath('zp' + Suffixe + '.dat');
  if not tfile.Exists(result) then
  begin
    OldFilePath := GetDefaultFilePath('Zicplay' + Suffixe + '.par');
    if tfile.Exists(OldFilePath) then
      tfile.Move(OldFilePath, result);
  end;
end;

class function TZPConfig.GetDefaultFilePath(const AFilename: string): string;
begin
  result := tpath.combine(tpath.GetDirectoryName(tconfig.Current.GetPath),
    AFilename);
end;

{ TZicPlayConfig }

constructor TZPConfig.Create;
begin
  inherited;
  Playlists := TPlaylistsList.Create;
  FConfigChanged := false;
  FmvPlaylistsVisible := false;
  FVolume := 100;
  FPlayIntro := false;
{$IFDEF RELEASE}
  FPlayIntroDuration := 30;
{$ELSE}
  FPlayIntroDuration := 5;
{$ENDIF}
  FPlayNextRandom := false;
  FPlayRepeatAll := false;
  FPlayRepeatOne := false;
  FFilterText := '';
  FSortType := -1;
end;

destructor TZPConfig.Destroy;
begin
  Playlists.Free;
  inherited;
end;

class function TZPConfig.GetCurrent: TZPConfig;
begin
  if not assigned(FCurrent) then
    FCurrent := TZPConfig.Create;

  result := FCurrent;
end;

procedure TZPConfig.LoadFromFile(AFilename: string);
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

procedure TZPConfig.LoadFromStream(AStream: TStream);
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
    // TODO : DANGER if the load is done on a filled playlist with played songs
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

  if (DataVersion >= 3) then
  begin
    AStream.Read(FVolume, sizeof(FVolume));
    AStream.Read(FPlayIntro, sizeof(FPlayIntro));
    AStream.Read(FPlayIntroDuration, sizeof(FPlayIntroDuration));
    AStream.Read(FPlayNextRandom, sizeof(FPlayNextRandom));
    AStream.Read(FPlayRepeatAll, sizeof(FPlayRepeatAll));
    AStream.Read(FPlayRepeatOne, sizeof(FPlayRepeatOne));
  end;

  if (DataVersion >= 4) then
  begin
    FFilterText := LoadStringFromStream(AStream);
    AStream.Read(FSortType, sizeof(FSortType));
  end;
end;

procedure TZPConfig.SaveTofile(AFilename: string);
var
  Stream: TFileStream;
  Folder: string;
begin
  AFilename := AFilename.Trim;

  if AFilename.IsEmpty then
    AFilename := FConfigFilename;

  if AFilename.IsEmpty then
    raise exception.Create('No filename to save the config.');

  Folder := tpath.GetDirectoryName(AFilename);
  if not tdirectory.Exists(Folder) then
    tdirectory.CreateDirectory(Folder);

  Stream := TFileStream.Create(AFilename, fmcreate + fmOpenWrite);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TZPConfig.SaveToStream(AStream: TStream);
var
  DataVersion: word;
  nb: TPlaylistsCounter;
  Playlist: TPlaylist;
begin
  if not assigned(AStream) then
    raise exception.Create('Where do you expect I save the config to ?');

  // version 1 and later
  DataVersion := CDataVersion;
  AStream.Write(DataVersion, sizeof(DataVersion));

  nb := Playlists.Count;
  AStream.Write(nb, sizeof(nb));
  if (nb > 0) then
    for Playlist in Playlists do
      Playlist.SaveToStream(AStream);

  // version 2 and later
  AStream.Write(FmvPlaylistsVisible, sizeof(FmvPlaylistsVisible));

  // version 3 and later
  AStream.Write(FVolume, sizeof(FVolume));
  AStream.Write(FPlayIntro, sizeof(FPlayIntro));
  AStream.Write(FPlayIntroDuration, sizeof(FPlayIntroDuration));
  AStream.Write(FPlayNextRandom, sizeof(FPlayNextRandom));
  AStream.Write(FPlayRepeatAll, sizeof(FPlayRepeatAll));
  AStream.Write(FPlayRepeatOne, sizeof(FPlayRepeatOne));

  // version 4 and later
  SaveStringToStream(FFilterText, AStream);
  AStream.Write(FSortType, sizeof(FSortType));

  FConfigChanged := false;
end;

procedure TZPConfig.SetConfigFilename(const Value: string);
begin
  FConfigFilename := Value;
end;

procedure TZPConfig.SetFilterText(const Value: string);
begin
  if (FFilterText = Value) then
    exit;

  FFilterText := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetmvPlaylistsVisible(const Value: boolean);
begin
  if (FmvPlaylistsVisible = Value) then
    exit;

  FmvPlaylistsVisible := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetPlayIntro(const Value: boolean);
begin
  if (FPlayIntro = Value) then
    exit;

  FPlayIntro := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetPlayIntroDuration(const Value: integer);
begin
  if (FPlayIntroDuration = Value) then
    exit;

  FPlayIntroDuration := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetPlaylists(const Value: TPlaylistsList);
begin
  FPlaylists := Value;
end;

procedure TZPConfig.SetPlayNextRandom(const Value: boolean);
begin
  if (FPlayNextRandom = Value) then
    exit;

  FPlayNextRandom := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetPlayRepeatAll(const Value: boolean);
begin
  if (FPlayRepeatAll = Value) then
    exit;

  FPlayRepeatAll := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetPlayRepeatOne(const Value: boolean);
begin
  if (FPlayRepeatOne = Value) then
    exit;

  FPlayRepeatOne := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetSortType(const Value: integer);
begin
  if (FSortType = Value) then
    exit;

  FSortType := Value;
  FConfigChanged := true;
end;

procedure TZPConfig.SetVolume(const Value: integer);
begin
  if (FVolume = Value) then
    exit;

  FVolume := Value;
  FConfigChanged := true;
end;

{ TPlaylistsList }

procedure TPlaylistsList.Add(APlaylist: TPlaylist);
begin
  inherited Add(APlaylist);
  TNewPlaylistMessage.Broadcast(APlaylist);
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

if TZPConfig.Current.hasConfigChanged then
  TZPConfig.Current.SaveTofile;

TZPConfig.Current.Free;

end.
