unit Zicplay.Types;

interface

uses
  System.Generics.Collections,
  System.Messaging,
  System.Classes,
  System.JSON;

type
  TPlaylistsCounter = word;
  TSongsCounter = word;

  TPlaylist = class;
  IConnector = interface;

  /// <summary>
  /// A function getting the UniqID of a song to answer with it's local file name and path (realy local or in a cache)
  /// Used as event.
  /// </summary>
  TSongFileNameEvent = function(AUniqID: string): string of object;

  /// <summary>
  /// Used as callback procedure between a connector and a playlist
  /// </summary>
  TZicPlayGetPlaylistProc = reference to procedure(APlaylist: TPlaylist);

  /// <summary>
  /// Song infos (from MP3 metadata or others)
  /// </summary>
  TSong = class
  private const
    CDataVersion = 1;

  var
    FFilename: string;
    FPlaylist: TPlaylist;
    FOrder: integer;
    FTitle: string;
    FTitleLowerCase: string;
    FArtist: string;
    FArtistLowerCase: string;
    FCategory: string;
    FCategoryLowerCase: string;
    FAlbum: string;
    FAlbumLowerCase: string;
    FPublishedDate: TDate;
    FUniqID: string;
    FonGetFilename: TSongFileNameEvent;
    FDuration: integer;
    procedure SetAlbum(const Value: string);
    procedure SetArtist(const Value: string);
    procedure SetCategory(const Value: string);
    procedure SetFilename(const Value: string);
    procedure SetOrder(const Value: integer);
    procedure SetPublishedDate(const Value: TDate);
    procedure SetPlaylist(const Value: TPlaylist);
    procedure SetTitle(const Value: string);
    function GetPublishedYear: word;
    procedure SetonGetFilename(const Value: TSongFileNameEvent);
    procedure SetUniqID(const Value: string);
    function GetFileName: string;
    procedure SetDuration(const Value: integer);
    function GetDurationAsTime: string;
  protected
  public
    /// <summary>
    /// Song title
    /// </summary>
    property Title: string read FTitle write SetTitle;
    property TitleLowerCase: string read FTitleLowerCase;
    /// <summary>
    /// Artist (or artists) : singer, musician, ...
    /// </summary>
    property Artist: string read FArtist write SetArtist;
    property ArtistLowerCase: string read FArtistLowerCase;
    /// <summary>
    /// Name of the album or single
    /// </summary>
    property Album: string read FAlbum write SetAlbum;
    property AlbumLowerCase: string read FAlbumLowerCase;
    /// <summary>
    /// Duration of this song in seconds
    /// </summary>
    property Duration: integer read FDuration write SetDuration;
    /// <summary>
    /// Return the duration in HH:MM:SS string format
    /// </summary>
    property DurationAsTime: string read GetDurationAsTime;
    /// <summary>
    /// Publication date (at least the year if known)
    /// </summary>
    property PublishedDate: TDate read FPublishedDate write SetPublishedDate;
    /// <summary>
    /// Publication year (extracted from PublishedDate)
    /// </summary>
    property PublishedYear: word read GetPublishedYear;
    /// <summary>
    /// Category of the song (dance, techno, classic, ...)
    /// </summary>
    property Category: string read FCategory write SetCategory;
    property CategoryLowerCase: string read FCategoryLowerCase;
    /// <summary>
    /// Order of the song in it's album
    /// </summary>
    property Order: integer read FOrder write SetOrder;
    /// <summary>
    /// Unique ID of the song for its playlist
    /// </summary>
    property UniqID: string read FUniqID write SetUniqID;
    /// <summary>
    /// Playlist source for this song
    /// </summary>
    property Playlist: TPlaylist read FPlaylist write SetPlaylist;
    /// <summary>
    /// Return the file name and local path of this song to open it in the TMediaPlayer component
    /// </summary>
    property FileName: string read GetFileName write SetFilename;
    /// <summary>
    /// Called each time property FileName is read if the FFileName field is empty.
    /// Use it for your connectors if the song has no local file (to access to a local cache).
    /// </summary>
    property onGetFilename: TSongFileNameEvent read FonGetFilename
      write SetonGetFilename;
    // TODO : (pprem) how to use it ? => plus un truc � faire au niveau du connecteur

    /// <summary>
    /// Load song datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);
    /// <summary>
    /// Save song datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);

    constructor Create(APlaylist: TPlaylist);
  end;

  /// <summary>
  /// Playlist (list of songs from a connector)
  /// </summary>
  TPlaylist = class(TThreadList<TSong>)
  private const
    CDataVersion = 2;
    CCacheVersion = 1;

  var
    FEnabled: boolean;
    FConnector: IConnector;
    FText: string;
    FConnectorParams: TJSONObject;
    FUniqID: string;
    FCacheDate: integer;
    function GetSongsCount: integer;
    procedure SetConnector(const Value: IConnector);
    procedure SetText(const Value: string);
    procedure SetConnectorParams(const Value: TJSONObject);
    function GetUniqID: string;
    procedure SetEnabled(const Value: boolean);
  protected
    procedure LoadSongsList;
    procedure SaveSongsList;
  public
    /// <summary>
    /// Connector for this playlist
    /// </summary>
    property Connector: IConnector read FConnector write SetConnector;

    /// <summary>
    /// Playlist name
    /// </summary>
    property Text: string read FText write SetText;

    /// <summary>
    /// Params to use with this connector to get the songs
    /// </summary>
    property ConnectorParams: TJSONObject read FConnectorParams
      write SetConnectorParams;

    /// <summary>
    /// Uniq Id of the playlist
    /// A GUID generated when the list is created, to link it to other
    /// files or classes.
    /// </summary>
    property UniqID: string read GetUniqID;

    /// <summary>
    /// True is the songs in this playlists are available in the global playlist
    /// False is it's songs are not shown on the global playlist
    /// </summary>
    property Enabled: boolean read FEnabled write SetEnabled;

    /// <summary>
    /// Returns the number of songs in the playlist
    /// </summary>
    property Count: integer read GetSongsCount;

    /// <summary>
    /// Return the song at index AIndex if it exists
    /// </summary>
    function GetSongAt(AIndex: integer): TSong;

    /// <summary>
    /// Sort the songs in this list by Album / Order / Title
    /// </summary>
    procedure SortByAlbum;

    /// <summary>
    /// Sort the songs in this list by Artist / Album / Order / Title
    /// </summary>
    procedure SortByArtist;

    /// <summary>
    /// Sort the songs in this list by Title / Album
    /// </summary>
    procedure SortByTitle;

    /// <summary>
    /// Sort the songs in this list by Category / Album / Order / Title
    /// </summary>
    procedure SortByCategoryAlbum;

    /// <summary>
    /// Sort the songs in this list by Category / Title / Album
    /// </summary>
    procedure SortByCategoryTitle;

    /// <summary>
    /// Load song list datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);

    /// <summary>
    /// Save song list datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);

    /// <summary>
    /// Load the list of song from the local cache.
    // Start a reload from the connector if AForceReaload is True
    /// </summary>
    procedure RefreshSongsList(ACallbackProc: TZicPlayGetPlaylistProc;
      AForceReload: boolean = false);

    constructor Create;
    destructor Destroy; override;
  end; // TODO : add a ClearAndFreeItems() method

  /// <summary>
  /// Interface for Zicplay connectors (see it like a driver)
  /// </summary>
  IConnector = interface
    ['{2A668080-A4BC-4E5B-8640-4EA0809E21DA}']
    /// <summary>
    /// Name of this connector (displayed to the users)
    /// </summary>
    function getName: string;

    /// <summary>
    /// Uniq ID (a GUID is fine) for this connector
    /// </summary>
    function GetUniqID: string;

    /// <summary>
    /// Display setup dialog for a playlist using this connector
    /// </summary>
    procedure PlaylistSetupDialog(AParams: TJSONObject);

    /// <summary>
    /// True if the PlaylistSetupDialog procedure can be called to display a dialog box from the playlist options
    /// False if no setup dialog for this connector
    /// </summary>
    function hasPlaylistSetupDialog: boolean;

    /// <summary>
    /// Display setup dialog for a connector
    /// </summary>
    procedure SetupDialog;

    /// <summary>
    /// True if the SetupDialog procedure can be called to display a dialog box from the Tools menu
    /// False if no setup dialog for this connector
    /// </summary>
    function hasSetupDialog: boolean;

    /// <summary>
    /// Return the playlist from a connector (with playlist parameters)
    /// </summary>
    procedure GetPlaylist(AParams: TJSONObject;
      ACallbackProc: TZicPlayGetPlaylistProc);

    /// <summary>
    /// Load connector parameters from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);

    /// <summary>
    /// Save connector parameters in a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);
  end;

  /// <summary>
  /// List of registered connectors
  /// (it's a singleton, use TConnectorsList.Current to access to it's instance)
  /// </summary>
  TConnectorsList = class
  private
    List: TList<IConnector>;
    class var FCurrent: TConnectorsList;
    constructor Create;
    destructor Destroy; override;
  protected
  public
    /// <summary>
    /// Return the singleton instance of this class
    /// </summary>
    class function Current: TConnectorsList;
    /// <summary>
    /// Used to register the connectors
    /// </summary>
    procedure Register(AConnector: IConnector);
    /// <summary>
    /// Sort the items in the list by alphabetical order of their name.
    /// </summary>
    procedure Sort;
    /// <summary>
    /// Return the number of registered connectors
    /// </summary>
    function Count: integer;
    /// <summary>
    /// Return the registered connector at specified index (if available)
    /// </summary>
    function GetConnectorAt(AIndex: integer): IConnector;
    /// <summary>
    /// Return the registered connector from it's UniqID (if available)
    /// </summary>
    function GetConnectorFromUID(AUniqID: string): IConnector;
  end;

  /// <summary>
  /// Base connector if you want an ancestor for your connectors instead of
  /// using the interface IConnector.
  /// </summary>
  TConnector = class(TInterfacedObject, IConnector)
  private
    class var FCurrent: TConnector;
  public
    /// <summary>
    /// Return current instance of this connector
    /// </summary>
    class property Current: TConnector read FCurrent;

    /// <summary>
    /// Name of this connector (displayed to the users)
    /// </summary>
    function getName: string; virtual; abstract;

    /// <summary>
    /// Uniq ID (a GUID is fine) for this connector
    /// </summary>
    function GetUniqID: string; virtual; abstract;

    /// <summary>
    /// Display setup dialog for a playlist using this connector
    /// </summary>
    procedure PlaylistSetupDialog(AParams: TJSONObject); virtual; abstract;

    /// <summary>
    /// True if the PlaylistSetupDialog procedure can be called to display a dialog box from the playlist options
    /// False if no setup dialog for this connector
    /// </summary>
    function hasPlaylistSetupDialog: boolean; virtual;

    /// <summary>
    /// Display setup dialog for a connector
    /// </summary>
    procedure SetupDialog; virtual;

    /// <summary>
    /// True if the SetupDialog procedure can be called to display a dialog box from the Tools menu
    /// False if no setup dialog for this connector
    /// </summary>
    function hasSetupDialog: boolean; virtual;

    /// <summary>
    /// Return the playlist from a connector (with playlist parameters)
    /// </summary>
    procedure GetPlaylist(AParams: TJSONObject;
      ACallbackProc: TZicPlayGetPlaylistProc); virtual; abstract;

    /// <summary>
    /// Load connector parameters from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream); virtual;

    /// <summary>
    /// Save connector parameters in a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream); virtual;

    /// <summary>
    /// Create an instance of this connector
    /// </summary>
    constructor Create;

    /// <summary>
    /// Destroy current instance of this connector
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Subscribe to this mesage to be notified when a new song is played.
  /// The song could be "nil" if no song is available after previous one.
  /// </summary>
  TNowPlayingMessage = class(TMessage<TSong>)
  end;

  /// <summary>
  /// Subscribe to this message to be notified when a new playlist is added
  /// to the configuration.
  /// </summary>
  TNewPlaylistMessage = class(TMessage<TPlaylist>)
  end;

  /// <summary>
  /// Subscribe to this message to be notified when a playlist has been
  /// changed (settings of the playlist and its connector)
  /// </summary>
  TPlaylistUpdatedMessage = class(TMessage<TPlaylist>)
  end;

implementation

uses
  System.IOUtils,
  fmx.DialogService,
  System.DateUtils,
  System.SysUtils,
  System.Generics.Defaults,
  uConfig,
  Olf.RTL.Streams,
  Olf.RTL.DateAndTime;

{ TSong }

constructor TSong.Create(APlaylist: TPlaylist);
begin
  inherited Create;
  FFilename := '';
  FPlaylist := APlaylist;
  FOrder := 0;
  FTitle := '';
  FTitleLowerCase := '';
  FArtist := '';
  FArtistLowerCase := '';
  FCategory := '';
  FCategoryLowerCase := '';
  FAlbum := '';
  FAlbumLowerCase := '';
  FPublishedDate := 0;
  FUniqID := '';
  FDuration := 0;
end;

function TSong.GetDurationAsTime: string;
begin
  // TODO : � compl�ter
  result := 'n/a';
end;

function TSong.GetFileName: string;
begin
  if (not FFilename.isempty) and tfile.Exists(FFilename) then
    result := FFilename
  else if assigned(onGetFilename) then
    result := onGetFilename(FUniqID)
  else
    result := '';
end;

function TSong.GetPublishedYear: word;
begin
  result := yearof(PublishedDate);
  // TODO : replace by TDate.getYear when a helpers will be available
end;

procedure TSong.LoadFromStream(AStream: TStream);
var
  DataVersion: word;
  guid: string;
  JSON: string;
begin
  if not assigned(AStream) then
    raise exception.Create
      ('Where do you expect I load this song''s settings from ?');

  AStream.Read(DataVersion, sizeof(DataVersion));
  if (DataVersion > CDataVersion) then
    raise exception.Create
      ('The program is too old to read the settings for this song.');

  if (DataVersion >= 1) then
  begin
    FileName := LoadStringFromStream(AStream);
    AStream.Read(FOrder, sizeof(FOrder));
    Title := LoadStringFromStream(AStream);
    Artist := LoadStringFromStream(AStream);
    Category := LoadStringFromStream(AStream);
    Album := LoadStringFromStream(AStream);
    PublishedDate := date8todate(LoadStringFromStream(AStream));
    UniqID := LoadStringFromStream(AStream);
    AStream.Read(FDuration, sizeof(FDuration));
  end;
end;

procedure TSong.SaveToStream(AStream: TStream);
var
  DataVersion: word;
begin
  if not assigned(AStream) then
    raise exception.Create('Where do you expect I save the settings to ?');

  DataVersion := CDataVersion;
  AStream.write(DataVersion, sizeof(DataVersion));

  SaveStringToStream(FFilename, AStream);
  AStream.write(FOrder, sizeof(FOrder));
  SaveStringToStream(FTitle, AStream);
  SaveStringToStream(FArtist, AStream);
  SaveStringToStream(FCategory, AStream);
  SaveStringToStream(FAlbum, AStream);
  SaveStringToStream(datetostring8(FPublishedDate), AStream);
  SaveStringToStream(FUniqID, AStream);
  AStream.write(FDuration, sizeof(FDuration));
end;

procedure TSong.SetAlbum(const Value: string);
begin
  FAlbum := Value;
  FAlbumLowerCase := FAlbum.ToLower;
end;

procedure TSong.SetArtist(const Value: string);
begin
  FArtist := Value;
  FArtistLowerCase := FArtist.ToLower;
end;

procedure TSong.SetCategory(const Value: string);
begin
  FCategory := Value;
  FCategoryLowerCase := FCategory.ToLower;
end;

procedure TSong.SetDuration(const Value: integer);
begin
  FDuration := Value;
end;

procedure TSong.SetFilename(const Value: string);
begin
  if tfile.Exists(FFilename) then
    FFilename := Value
  else
    FFilename := '';
end;

procedure TSong.SetonGetFilename(const Value: TSongFileNameEvent);
begin
  FonGetFilename := Value;
end;

procedure TSong.SetOrder(const Value: integer);
begin
  FOrder := Value;
end;

procedure TSong.SetPublishedDate(const Value: TDate);
begin
  FPublishedDate := Value;
end;

procedure TSong.SetPlaylist(const Value: TPlaylist);
begin
  FPlaylist := Value;
end;

procedure TSong.SetTitle(const Value: string);
begin
  FTitle := Value;
  FTitleLowerCase := FTitle.ToLower;
end;

procedure TSong.SetUniqID(const Value: string);
begin
  FUniqID := Value;
end;

{ TPlaylist }

constructor TPlaylist.Create;
begin
  inherited;
  FConnector := nil;
  FConnectorParams := TJSONObject.Create;
  FText := '';
  FEnabled := true;
  FUniqID := '';
end;

destructor TPlaylist.Destroy;
begin
  FConnectorParams.Free;
  inherited;
end;

function TPlaylist.GetSongAt(AIndex: integer): TSong;
var
  List: TList<TSong>;
begin
  if (AIndex < 0) or (AIndex >= Count) then
  begin
    result := nil;
    exit;
  end;

  List := LockList;
  try
    result := List[AIndex];
  finally
    UnlockList;
  end;
end;

function TPlaylist.GetSongsCount: integer;
var
  List: TList<TSong>;
begin
  List := LockList;
  try
    result := List.Count;
  finally
    UnlockList;
  end;
end;

function TPlaylist.GetUniqID: string;
var
  i: integer;
  LGuid: string;
begin
  if FUniqID.isempty then
  begin
    LGuid := TGUID.NewGuid.ToString;
    for i := 0 to length(LGuid) - 1 do
    begin
      if CharInSet(LGuid.Chars[i], ['0' .. '9', 'A' .. 'Z', 'a' .. 'z']) then
        FUniqID := FUniqID + LGuid.Chars[i];
    end;
    tconfig.Current.hasConfigChanged := true;
  end;
  result := FUniqID;
end;

procedure TPlaylist.LoadFromStream(AStream: TStream);
var
  DataVersion: word;
  ConnectorGuid: string;
  JSON: string;
begin
  if not assigned(AStream) then
    raise exception.Create
      ('Where do you expect I load this playlist''s settings from ?');

  AStream.Read(DataVersion, sizeof(DataVersion));
  if (DataVersion > CDataVersion) then
    raise exception.Create
      ('The program is too old to read the settings for this playlist.');

  if (DataVersion >= 1) then
  begin
    FText := LoadStringFromStream(AStream);

    ConnectorGuid := LoadStringFromStream(AStream);
    FConnector := TConnectorsList.Current.GetConnectorFromUID(ConnectorGuid);

    JSON := LoadStringFromStream(AStream);
    FConnectorParams.Free;
    FConnectorParams := TJSONObject.ParseJSONValue(JSON) as TJSONObject;
  end;

  if (DataVersion >= 2) then
  begin
    AStream.Read(FEnabled, sizeof(FEnabled));

    FUniqID := LoadStringFromStream(AStream);
  end;
end;

procedure TPlaylist.LoadSongsList;
var
  FileName: string;
  Stream: TFileStream;
  song: TSong;
  nb: TSongsCounter;
  i: integer;
  CacheVersion: word;
begin
  FileName := tconfig.GetDefaultConfigFilePath(UniqID + '.songs');

  if FileName.isempty then
    exit;

  if not tfile.Exists(FileName) then
    exit;

  clear;
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    Stream.Read(CacheVersion, sizeof(CacheVersion));
    if (CacheVersion > CCacheVersion) then
      raise exception.Create
        ('The program is too old to read the settings for this playlist.');

    if (CacheVersion >= 1) then
    begin
      Stream.Read(FCacheDate, sizeof(FCacheDate));

      Stream.Read(nb, sizeof(nb));
      for i := 0 to nb - 1 do
      begin
        song := TSong.Create(self);
        song.LoadFromStream(Stream);
        add(song);
      end;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TPlaylist.RefreshSongsList(ACallbackProc: TZicPlayGetPlaylistProc;
  AForceReload: boolean);
begin
  tthread.CreateAnonymousThread(
    procedure
    begin
      try
        LoadSongsList;
        tthread.Synchronize(nil,
          procedure
          begin
            ACallbackProc(self);
          end);
      except
        AForceReload := true;
      end;

      if AForceReload then
        Connector.GetPlaylist(ConnectorParams,
          procedure(APlaylist: TPlaylist)
          begin
            // TODO : � compl�ter
            SaveSongsList;
            tthread.Synchronize(nil,
              procedure
              begin
                ACallbackProc(self);
              end);
          end);
    end).Start;
end;

procedure TPlaylist.SaveSongsList;
var
  FileName: string;
  Stream: TFileStream;
  nb: TSongsCounter;
  i: integer;
  CacheVersion: word;
  List: TList<TSong>;
begin
  FileName := tconfig.GetDefaultConfigFilePath(UniqID + '.songs');

  if FileName.isempty then
    exit;

  Stream := TFileStream.Create(FileName, fmOpenwrite + fmcreate);
  try
    CacheVersion := CCacheVersion;
    Stream.write(CacheVersion, sizeof(CacheVersion));

    FCacheDate := FormatDateTime('yyyymmdd', now).ToInteger;
    Stream.write(FCacheDate, sizeof(FCacheDate));

    List := LockList;
    try
      nb := List.Count;
      Stream.write(nb, sizeof(nb));
      for i := 0 to nb - 1 do
        List[i].SaveToStream(Stream);
    finally
      UnlockList
    end;
  finally
    Stream.Free;
  end;
end;

procedure TPlaylist.SaveToStream(AStream: TStream);
var
  DataVersion: word;
begin
  if not assigned(AStream) then
    raise exception.Create('Where do you expect I save the settings to ?');

  DataVersion := CDataVersion;
  AStream.write(DataVersion, sizeof(DataVersion));

  SaveStringToStream(FText, AStream);

  SaveStringToStream(FConnector.GetUniqID, AStream);

  SaveStringToStream(FConnectorParams.ToJSON, AStream);

  AStream.write(FEnabled, sizeof(FEnabled));
  SaveStringToStream(FUniqID, AStream);
end;

procedure TPlaylist.SetConnector(const Value: IConnector);
begin
  FConnector := Value;
  tconfig.Current.hasConfigChanged := true;
end;

procedure TPlaylist.SetConnectorParams(const Value: TJSONObject);
begin
  FConnectorParams := Value;
end;

procedure TPlaylist.SetEnabled(const Value: boolean);
begin
  if (FEnabled = Value) then
    exit;

  FEnabled := Value;
  tconfig.Current.hasConfigChanged := true;
end;

procedure TPlaylist.SetText(const Value: string);
begin
  if (FText = Value) then
    exit;

  FText := Value;
  tconfig.Current.hasConfigChanged := true;
end;

procedure TPlaylist.SortByAlbum;
var
  List: TList<TSong>;
begin
  List := LockList;
  try
    List.Sort(TComparer<TSong>.Construct(
      function(const A, B: TSong): integer
      begin
        if (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
          (A.FTitleLowerCase = B.FTitleLowerCase) then
          result := 0
        else if (A.FAlbumLowerCase < B.FAlbumLowerCase) or
          ((A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder < B.FOrder)) or
          ((A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
          (A.FTitleLowerCase < B.FTitleLowerCase)) then
          result := -1
        else
          result := 1;
      end));
  finally
    UnlockList;
  end;
end;

procedure TPlaylist.SortByArtist;
var
  List: TList<TSong>;
begin
  List := LockList;
  try
    List.Sort(TComparer<TSong>.Construct(
      function(const A, B: TSong): integer
      begin
        if (A.FArtistLowerCase = B.FArtistLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
          (A.FTitleLowerCase = B.FTitleLowerCase) then
          result := 0
        else if (A.FArtistLowerCase < B.FArtistLowerCase) or
          ((A.FArtistLowerCase = B.FArtistLowerCase) and
          (A.FAlbumLowerCase < B.FAlbumLowerCase)) or
          ((A.FArtistLowerCase = B.FArtistLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder < B.FOrder)) or
          ((A.FArtistLowerCase = B.FArtistLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
          (A.FTitleLowerCase < B.FTitleLowerCase)) then
          result := -1
        else
          result := 1;
      end));
  finally
    UnlockList;
  end;
end;

procedure TPlaylist.SortByCategoryAlbum;
var
  List: TList<TSong>;
begin
  List := LockList;
  try
    List.Sort(TComparer<TSong>.Construct(
      function(const A, B: TSong): integer
      begin
        if (A.FCategoryLowerCase = B.FCategoryLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
          (A.FTitleLowerCase = B.FTitleLowerCase) then
          result := 0
        else if (A.FCategoryLowerCase < B.FCategoryLowerCase) or
          ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
          (A.FAlbumLowerCase < B.FAlbumLowerCase)) or
          ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder < B.FOrder)) or
          ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) and (A.FOrder = B.FOrder) and
          (A.FTitleLowerCase < B.FTitleLowerCase)) then
          result := -1
        else
          result := 1;
      end));
  finally
    UnlockList;
  end;
end;

procedure TPlaylist.SortByCategoryTitle;
var
  List: TList<TSong>;
begin
  List := LockList;
  try
    List.Sort(TComparer<TSong>.Construct(
      function(const A, B: TSong): integer
      begin
        if (A.FCategoryLowerCase = B.FCategoryLowerCase) and
          (A.FTitleLowerCase = B.FTitleLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) then
          result := 0
        else if (A.FCategoryLowerCase < B.FCategoryLowerCase) or
          ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
          (A.FTitleLowerCase < B.FTitleLowerCase)) or
          ((A.FCategoryLowerCase = B.FCategoryLowerCase) and
          (A.FTitleLowerCase = B.FTitleLowerCase) and
          (A.FAlbumLowerCase < B.FAlbumLowerCase)) then
          result := -1
        else
          result := 1;
      end));
  finally
    UnlockList;
  end;
end;

procedure TPlaylist.SortByTitle;
var
  List: TList<TSong>;
begin
  List := LockList;
  try
    List.Sort(TComparer<TSong>.Construct(
      function(const A, B: TSong): integer
      begin
        if (A.FTitleLowerCase = B.FTitleLowerCase) and
          (A.FAlbumLowerCase = B.FAlbumLowerCase) then
          result := 0
        else if (A.FTitleLowerCase < B.FTitleLowerCase) or
          ((A.FTitleLowerCase = B.FTitleLowerCase) and
          (A.FAlbumLowerCase < B.FAlbumLowerCase)) then
          result := -1
        else
          result := 1;
      end));
  finally
    UnlockList;
  end;
end;

{ TConnectorsList }

function TConnectorsList.Count: integer;
begin
  result := List.Count;
end;

constructor TConnectorsList.Create;
begin
  List := TList<IConnector>.Create;
end;

class function TConnectorsList.Current: TConnectorsList;
begin
  if not assigned(FCurrent) then
    FCurrent := TConnectorsList.Create;

  if assigned(FCurrent) then
    result := FCurrent
  else
    result := nil;
end;

destructor TConnectorsList.Destroy;
begin
  FCurrent := nil;
  List.Free;
  inherited;
end;

procedure TConnectorsList.Register(AConnector: IConnector);
var
  i: integer;
  ItemFound: boolean;
begin
  ItemFound := false;
  for i := 0 to List.Count - 1 do
    if List[i].GetUniqID = AConnector.GetUniqID then
    begin
      ItemFound := true;
      break;
    end;
  if not ItemFound then
    List.add(AConnector);
end;

procedure TConnectorsList.Sort;
begin
  List.Sort(TComparer<IConnector>.Construct(
    function(const A, B: IConnector): integer
    begin
      if A.getName = B.getName then
        result := 0
      else if A.getName < B.getName then
        result := -1
      else
        result := 1;
    end));
end;

function TConnectorsList.GetConnectorAt(AIndex: integer): IConnector;
begin
  if (AIndex >= 0) and (AIndex < List.Count) then
    result := List.Items[AIndex]
  else
    result := nil;
end;

function TConnectorsList.GetConnectorFromUID(AUniqID: string): IConnector;
var
  i: integer;
begin
  result := nil;
  for i := 0 to List.Count - 1 do
    if (List.Items[i].GetUniqID = AUniqID) then
    begin
      result := List.Items[i];
      break;
    end;
end;

{ TConnector }

constructor TConnector.Create;
begin
  inherited;
  FCurrent := self;
end;

destructor TConnector.Destroy;
begin
  FCurrent := nil;
  inherited;
end;

function TConnector.hasPlaylistSetupDialog: boolean;
begin
  result := false;
end;

function TConnector.hasSetupDialog: boolean;
begin
  result := true;
end;

procedure TConnector.LoadFromStream(AStream: TStream);
begin
  // does nothing by default (no parameter to load for this object)
end;

procedure TConnector.SaveToStream(AStream: TStream);
begin
  // does nothing by default (no parameter to save for this object)
end;

procedure TConnector.SetupDialog;
begin
  tdialogservice.ShowMessage(getName);
end;

initialization

finalization

TConnectorsList.Current.Free;

end.
