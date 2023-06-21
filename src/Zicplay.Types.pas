unit Zicplay.Types;

interface

uses
  System.Generics.Collections,
  System.Classes,
  System.JSON;

type
  TSong = class;
  TSongList = class;
  ISongSourceType = interface;
  TSongSource = class;
  TSongSourceList = class;

  /// <summary>
  /// A function getting the UniqID of a song to answer with it's local file name and path (realy local or in a cache)
  /// Used as event.
  /// </summary>
  TSongFileNameEvent = function(AUniqID: string): string of object;

  /// <summary>
  /// Song infos (from MP3 metadata or others)
  /// </summary>
  TSong = class
  private
    FFilename: string;
    FSongList: TSongList;
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
    FSongSource: TSongSource;
    FDuration: integer;
    procedure SetAlbum(const Value: string);
    procedure SetArtist(const Value: string);
    procedure SetCategory(const Value: string);
    procedure SetFilename(const Value: string);
    procedure SetOrder(const Value: integer);
    procedure SetPublishedDate(const Value: TDate);
    procedure SetSongList(const Value: TSongList);
    procedure SetTitle(const Value: string);
    function GetPublishedYear: word;
    procedure SetonGetFilename(const Value: TSongFileNameEvent);
    procedure SetUniqID(const Value: string);
    function GetFileName: string;
    procedure SetSongSource(const Value: TSongSource);
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
    /// Unique ID of the song for the song source
    /// </summary>
    property UniqID: string read FUniqID write SetUniqID;
    /// <summary>
    /// Source for this song
    /// </summary>
    property SongSource: TSongSource read FSongSource write SetSongSource;
    /// <summary>
    /// Song list for this song
    /// </summary>
    property SongList: TSongList read FSongList write SetSongList;
    /// <summary>
    /// Return the file name and local path of this song to open it in the TMediaPlayer component
    /// </summary>
    property FileName: string read GetFileName write SetFilename;
    /// <summary>
    /// Called each time property FileName is read if the FFileName field is empty.
    /// Use it for your source connectors if the song has no local file (to access to a local cache).
    /// </summary>
    property onGetFilename: TSongFileNameEvent read FonGetFilename
      write SetonGetFilename;

    /// <summary>
    /// Load song datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);
    /// <summary>
    /// Save song datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);
  end;

  /// <summary>
  /// Songs list
  /// </summary>
  TSongList = class(TList<TSong>)
  private
    FSongSource: TSongSource;
    procedure SetSongSource(const Value: TSongSource);
  protected
  public
    /// <summary>
    /// Source for this list of songs
    /// </summary>
    property SongSource: TSongSource read FSongSource write SetSongSource;

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
  end; // TODO : add a ClearAndFreeItems() method

  /// <summary>
  /// Used as callback procedure between a connector source and a song source
  /// </summary>
  TZicPlayGetSongListProc = reference to procedure(ASongList: TSongList);

  /// <summary>
  /// Interface for Zicplay source connectors (see it like a driver)
  /// </summary>
  ISongSourceType = interface
    ['{2A668080-A4BC-4E5B-8640-4EA0809E21DA}']
    /// <summary>
    /// Name of this connector (displayed to the users)
    /// </summary>
    function getName: string;

    /// <summary>
    /// Uniq ID (a GUID is fine) for this connector
    /// </summary>
    function getUniqID: string;

    /// <summary>
    /// Display setup dialog for a source
    /// </summary>
    procedure SourceSetupDialog(Params: TJSONObject);

    /// <summary>
    /// Display setup dialog for the connector
    /// </summary>
    procedure ConnectorSetupDialog;

    /// <summary>
    /// True if the ConnectorSetupDialog procedure can be called to display a dialog box from the Tools menu
    /// False if no setup dialog for this connector
    /// </summary>
    function hasConnectorSetupDialog: boolean;

    /// <summary>
    /// return the song list from a source parameters
    /// </summary>
    procedure GetSongList(Params: TJSONObject;
      CallbackProc: TZicPlayGetSongListProc);

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
  /// List of registered source connectors
  /// (it's a singleton, use TSongSourceTypeList.Current to access to it's instance)
  /// </summary>
  TSongSourceTypeList = class
  private
    List: TList<ISongSourceType>;
    class var SongSourceTypeListInstance: TSongSourceTypeList;
    constructor Create;
    destructor Destroy; override;
  protected
  public
    /// <summary>
    /// Return the singleton instance of this class
    /// </summary>
    class function Current: TSongSourceTypeList;
    /// <summary>
    /// Used to register sources connectors
    /// </summary>
    procedure Register(ASongSourceType: ISongSourceType);
    /// <summary>
    /// Sort the items in the list by alphabetical order of their name.
    /// </summary>
    procedure Sort;
    /// <summary>
    /// Return the number of registered connectors (aka "source type")
    /// </summary>
    function Count: integer;
    /// <summary>
    /// Return the registered connector at specified index (if available)
    /// </summary>
    function SourceTypeAt(AIndex: integer): ISongSourceType;
    /// <summary>
    /// Return the registered connector from it's UniqID (if available)
    /// </summary>
    function SourceTypeFromUID(AUniqID: string): ISongSourceType;
  end;

  /// <summary>
  /// Song source (configured in the program)
  /// (a list from a connected source connector)
  /// </summary>
  TSongSource = class
  private
    FName: string;
    FSongList: TSongList;
    FSongSourceType: ISongSourceType;
    procedure SetConnected(const Value: boolean);
    procedure SetName(const Value: string);
    procedure SetSongList(const Value: TSongList);
    procedure SetSongSourceType(const Value: ISongSourceType);
    function GetConnected: boolean;
  protected
    FParams: TJSONObject;
  public
    /// <summary>
    /// Name of this song source
    /// </summary>
    property Name: string read FName write SetName;
    /// <summary>
    /// True if the connector is okay, False if not (MP3 files not available)
    /// </summary>
    property Connected: boolean read GetConnected write SetConnected;
    /// <summary>
    /// List of songs from this source
    /// </summary>
    property SongList: TSongList read FSongList write SetSongList;
    /// <summary>
    /// Link to the source type (connector / driver)
    /// </summary>
    property SongSourceType: ISongSourceType read FSongSourceType
      write SetSongSourceType;

    /// <summary>
    /// Load source connector datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);
    /// <summary>
    /// Save source connector datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);

    /// <summary>
    /// Display connector setup dialog for this source
    /// </summary>
    procedure ShowSetupDialog;

    /// <summary>
    /// Load song list from its connector
    /// (can take a very long time depending on the connector type and list size)
    /// </summary>
    procedure RefreshSongList;

    /// <summary>
    /// Instance constructor
    /// </summary>
    constructor Create;
    /// <summary>
    /// Instance destructor
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// List of configured song sources on this device
  /// </summary>
  TSongSourceList = class(TList<TSongSource>)
  private
    class var SongSourceListInstance: TSongSourceList;
  protected
  public
    /// <summary>
    /// Return the singleton instance of this class
    /// </summary>
    class function Current: TSongSourceList;
    /// <summary>
    /// Sort the items in the list by alphabetical order of their name.
    /// </summary>
    procedure Sort;
    /// <summary>
    /// Load source connector datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);
    /// <summary>
    /// Save source connector datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);
  end; // TODO : add a ClearAndFreeItems() method

implementation

uses
  System.DateUtils,
  System.SysUtils,
  System.Generics.Defaults;

{ TSong }

function TSong.GetDurationAsTime: string;
begin
  // TODO : à compléter
  result := 'n/a';
end;

function TSong.GetFileName: string;
begin
  if (not FFilename.isempty) then
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
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSong.SaveToStream(AStream: TStream);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
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
  FFilename := Value;
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

procedure TSong.SetSongList(const Value: TSongList);
begin
  FSongList := Value;
end;

procedure TSong.SetSongSource(const Value: TSongSource);
begin
  FSongSource := Value;
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

{ TSongList }

procedure TSongList.LoadFromStream(AStream: TStream);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongList.SaveToStream(AStream: TStream);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongList.SetSongSource(const Value: TSongSource);
begin
  FSongSource := Value;
end;

procedure TSongList.SortByAlbum;
begin
  Sort(TComparer<TSong>.Construct(
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
end;

procedure TSongList.SortByArtist;
begin
  Sort(TComparer<TSong>.Construct(
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
end;

procedure TSongList.SortByCategoryAlbum;
begin
  Sort(TComparer<TSong>.Construct(
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
end;

procedure TSongList.SortByCategoryTitle;
begin
  Sort(TComparer<TSong>.Construct(
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
end;

procedure TSongList.SortByTitle;
begin
  Sort(TComparer<TSong>.Construct(
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
end;

{ TSongSourceTypeList }

function TSongSourceTypeList.Count: integer;
begin
  result := List.Count;
end;

constructor TSongSourceTypeList.Create;
begin
  List := TList<ISongSourceType>.Create;
end;

class function TSongSourceTypeList.Current: TSongSourceTypeList;
begin
  if not assigned(SongSourceTypeListInstance) then
    SongSourceTypeListInstance := TSongSourceTypeList.Create;
  if assigned(SongSourceTypeListInstance) then
    result := SongSourceTypeListInstance
  else
    result := nil;
end;

destructor TSongSourceTypeList.Destroy;
begin
  List.Free;
  inherited;
end;

procedure TSongSourceTypeList.Register(ASongSourceType: ISongSourceType);
var
  i: integer;
  ItemFound: boolean;
begin
  ItemFound := false;
  for i := 0 to List.Count - 1 do
    if List[i].getUniqID = ASongSourceType.getUniqID then
    begin
      ItemFound := true;
      break;
    end;
  if not ItemFound then
    List.Add(ASongSourceType);
end;

procedure TSongSourceTypeList.Sort;
begin
  List.Sort(TComparer<ISongSourceType>.Construct(
    function(const A, B: ISongSourceType): integer
    begin
      if A.getName = B.getName then
        result := 0
      else if A.getName < B.getName then
        result := -1
      else
        result := 1;
    end));
end;

function TSongSourceTypeList.SourceTypeAt(AIndex: integer): ISongSourceType;
begin
  if (AIndex >= 0) and (AIndex < List.Count) then
    result := List.Items[AIndex]
  else
    result := nil;
end;

function TSongSourceTypeList.SourceTypeFromUID(AUniqID: string)
  : ISongSourceType;
var
  i: integer;
begin
  result := nil;
  for i := 0 to List.Count - 1 do
    if (List.Items[i].getUniqID = AUniqID) then
    begin
      result := List.Items[i];
      break;
    end;
end;

{ TSongSource }

constructor TSongSource.Create;
begin
  FParams := TJSONObject.Create;
end;

destructor TSongSource.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TSongSource.GetConnected: boolean;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
  raise Exception.Create('no code in this method');
end;

procedure TSongSource.LoadFromStream(AStream: TStream);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongSource.RefreshSongList;
begin
  if assigned(SongSourceType) then
    SongSourceType.GetSongList(FParams,
      procedure(ASongList: TSongList)
      begin
      end)
  else
    raise Exception.Create('No connector for this source.');
end;

procedure TSongSource.SaveToStream(AStream: TStream);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongSource.SetConnected(const Value: boolean);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
  raise Exception.Create('no code in this method');
end;

procedure TSongSource.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TSongSource.SetSongList(const Value: TSongList);
begin
  FSongList := Value;
end;

procedure TSongSource.SetSongSourceType(const Value: ISongSourceType);
begin
  FSongSourceType := Value;
end;

procedure TSongSource.ShowSetupDialog;
begin
  if assigned(SongSourceType) then
    SongSourceType.SourceSetupDialog(FParams)
  else
    raise Exception.Create('No connector for this source.');
end;

{ TSongSourceList }

class function TSongSourceList.Current: TSongSourceList;
begin
  if not assigned(SongSourceListInstance) then
    SongSourceListInstance := TSongSourceList.Create;
  if assigned(SongSourceListInstance) then
    result := SongSourceListInstance
  else
    result := nil;
end;

procedure TSongSourceList.LoadFromStream(AStream: TStream);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongSourceList.SaveToStream(AStream: TStream);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongSourceList.Sort;
begin
  inherited Sort(TComparer<TSongSource>.Construct(
    function(const A, B: TSongSource): integer
    begin
      if A.Name = B.Name then
        result := 0
      else if A.Name < B.Name then
        result := -1
      else
        result := 1;
    end));
end;

initialization

finalization

TSongSourceTypeList.SongSourceTypeListInstance.Free;

end.
