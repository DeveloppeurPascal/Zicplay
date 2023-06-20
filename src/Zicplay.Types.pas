unit Zicplay.Types;

interface

uses
  System.Generics.Collections,
  System.Classes;

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
    FArtist: string;
    FCategory: string;
    FAlbum: string;
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
    /// <summary>
    /// Artist (or artists) : singer, musician, ...
    /// </summary>
    property Artist: string read FArtist write SetArtist;
    /// <summary>
    /// Name of the album or single
    /// </summary>
    property Album: string read FAlbum write SetAlbum;
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
  TSongList = class(TObjectList<TSong>)
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
  end;

  /// <summary>
  /// Interface for Zicplay source connectors (see it like a driver)
  /// </summary>
  ISongSourceType = interface
    ['{2A668080-A4BC-4E5B-8640-4EA0809E21DA}']
    // TODO : à compléter
  end;

  /// <summary>
  /// List of registered source connectors
  /// </summary>
  TSongSourceTypeList = class
  private
    List: tlist<ISongSourceType>;
    constructor Create;
    destructor Destroy; override;
  protected
  public
    class function Current: TSongSourceTypeList;
    procedure Register(ASongSourceType: ISongSourceType);
  end;

  /// <summary>
  /// Song source (configured in the program)
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
    property Name: string read FName write SetName;
    property Connected: boolean read GetConnected write SetConnected;
    property SongList: TSongList read FSongList write SetSongList;
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
  end;

  /// <summary>
  /// List of configured song sources on this device
  /// </summary>
  TSongSourceList = class(TObjectList<TSongSource>)
  private
  protected
  public
    /// <summary>
    /// Load source connector datas from a stream
    /// </summary>
    procedure LoadFromStream(AStream: TStream);
    /// <summary>
    /// Save source connector datas to a stream
    /// </summary>
    procedure SaveToStream(AStream: TStream);
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils;

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
end;

procedure TSong.SetArtist(const Value: string);
begin
  FArtist := Value;
end;

procedure TSong.SetCategory(const Value: string);
begin
  FCategory := Value;
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
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongList.SortByArtist;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongList.SortByCategoryAlbum;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongList.SortByCategoryTitle;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TSongList.SortByTitle;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

{ TSongSourceTypeList }

constructor TSongSourceTypeList.Create;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
  raise Exception.Create('no code in this method');
end;

class function TSongSourceTypeList.Current: TSongSourceTypeList;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
  raise Exception.Create('no code in this method');
end;

destructor TSongSourceTypeList.Destroy;
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
  raise Exception.Create('no code in this method');
  inherited;
end;

procedure TSongSourceTypeList.Register(ASongSourceType: ISongSourceType);
begin
  // TODO : à compléter
{$MESSAGE warn 'todo'}
  raise Exception.Create('no code in this method');
end;

{ TSongSource }

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

{ TSongSourceList }

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

end.
