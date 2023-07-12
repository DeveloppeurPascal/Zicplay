unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Menus,
  Olf.FMX.AboutDialog,
  System.Actions,
  FMX.ActnList,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  Zicplay.Types,
  FMX.Edit,
  FMX.ListBox,
  uDMIcons;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    AboutDialog: TOlfAboutDialog;
    MacSystemMenu: TMenuItem;
    mnuFile: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuExit: TMenuItem;
    mnuTools: TMenuItem;
    mnuOptions: TMenuItem;
    ActionList1: TActionList;
    actAbout: TAction;
    actExit: TAction;
    actOptions: TAction;
    btnAbout: TSpeedButton;
    btnOptions: TSpeedButton;
    btnLoadMP3List: TButton;
    ListView1: TListView;
    lblSongPlayed: TLabel;
    cbSortList: TComboBox;
    edtSearch: TEdit;
    SearchEditButton1: TSearchEditButton;
    ClearEditButton1: TClearEditButton;
    timerIsSongFinished: TTimer;
    btnMyMusic: TButton;
    mnuPlaylist: TMenuItem;
    mnuPlaylistCreate: TMenuItem;
    mnuPlaylistSeparator: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure btnLoadMP3ListClick(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure cbSortListChange(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure ClearEditButton1Click(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure timerIsSongFinishedTimer(Sender: TObject);
    procedure AboutDialogURLClick(const AURL: string);
    procedure btnMyMusicClick(Sender: TObject);
    procedure mnuPlaylistCreateClick(Sender: TObject);
  private
    FPlayedSong: TSong;
    FDefaultCaption: string;
    FCurrentSongsList: TPlaylist;
    FCurrentSongsListNotFiltered: TPlaylist;
    procedure SetPlayedSong(const Value: TSong);
    procedure SetCurrentSongsList(const Value: TPlaylist);
    { Déclarations privées }
    procedure RefreshListView;
    function SubscribeToZicPlayMessage(AItem: TListviewItem): integer;
    procedure SetCurrentSongsListNotFiltered(const Value: TPlaylist);
    procedure ConnectorMenuClick(Sender: TObject);
    procedure PlaylistMenuClick(Sender: TObject);
  public
    { Déclarations publiques }
    property PlayedSong: TSong read FPlayedSong write SetPlayedSong;
    property CurrentSongsList: TPlaylist read FCurrentSongsList
      write SetCurrentSongsList;
    property CurrentSongsListNotFiltered: TPlaylist
      read FCurrentSongsListNotFiltered write SetCurrentSongsListNotFiltered;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  System.JSON,
  System.IOUtils,
  System.Messaging,
  Gamolf.FMX.MusicLoop,
  u_urlOpen,
  uConfig,
  fPlaylist;

function ReverseString(From: string): string;
// TODO : for dev tests only, remove it
begin
  result := '';
  for var i := length(From) - 1 downto 0 do
    result := result + From.Chars[i];
end;

Type
  TNowPlayingMessage = class(TMessage<TSong>)
  end;

procedure TfrmMain.AboutDialogURLClick(const AURL: string);
begin
  if AURL.IsEmpty then
    exit;

  url_Open_In_Browser(AURL);
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  AboutDialog.Execute;
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actOptionsExecute(Sender: TObject);
begin
  showmessage('No option dialog in this release.');
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TfrmMain.btnLoadMP3ListClick(Sender: TObject);
  procedure recursif(AFolder: string; var AFiles: TStringDynArray);
  var
    fs: TStringDynArray;
    i, j: integer;
  begin
    // if length(AFiles) > 50 then
    // exit;
    try
      fs := tdirectory.GetFiles(AFolder);
      if length(fs) > 0 then
      begin
        j := length(AFiles);
        setlength(AFiles, j + length(fs));
        for i := 0 to length(fs) - 1 do
          AFiles[j + i] := fs[i];
      end;
      fs := tdirectory.GetDirectories(AFolder);
      if length(fs) > 0 then
        for i := 0 to length(fs) - 1 do
          recursif(fs[i], AFiles);
    except

    end;
  end;

var
  i: integer;
  files: TStringDynArray;
  song: TSong;
  Playlist: TPlaylist;
begin
  btnLoadMP3List.Visible := false;

  Playlist := TPlaylist.Create;
  try
{$IFDEF RELEASE}
{$IF Defined(MACOS) and not Defined(IOS)}
    setlength(files, 0);
    recursif('/Volumes/PatrickPremartin1To/Musiques/Music', files);
    // TODO : for PP use only (temporary code)
{$ENDIF}
{$ELSE}
    files := tdirectory.GetFiles(tpath.GetMusicPath);
{$ENDIF}
    for i := 0 to length(files) - 1 do
      if (tpath.GetExtension(files[i]).ToLower = '.mp3') then
      begin
        song := TSong.Create;
        song.Title := tpath.GetFileNameWithoutExtension(files[i]);
        song.Artist := ReverseString(song.Title); // TODO : à compléter
        song.Album := random(maxint).tostring; // TODO : à compléter
        song.Duration := random(60 * 5); // TODO : à compléter
        song.PublishedDate := now; // TODO : à compléter
        song.Category := 'mp3'; // TODO : à compléter
        song.Order := 0; // TODO : à compléter
        song.UniqID := files[i];
        song.Playlist := nil;
        song.FileName := files[i];
        song.onGetFilename := nil;

        Playlist.Add(song);
      end;

    case cbSortList.ItemIndex of
      0: // sort by title
        Playlist.SortByTitle;
      1: // sort by artist
        Playlist.SortByArtist;
      2: // sort by album
        Playlist.SortByAlbum;
      3: // sort by category + album
        Playlist.SortByCategoryAlbum;
      4: // sort by caterogy + Title
        Playlist.SortByCategoryTitle;
      -1: // do nothing
        ;
    else
      raise exception.Create('I don''t know how to sort this list !');
    end;

  except
    Playlist.Free;
    raise;
  end;

  CurrentSongsListNotFiltered := nil;
  CurrentSongsListNotFiltered := Playlist;
end;

procedure TfrmMain.btnMyMusicClick(Sender: TObject);
var
  jso: tjsonobject;
begin
  jso := tjsonobject.Create;
  try
    TConnectorsList.Current.GetConnectorFromUID
      ('6B3510A0-2972-48C8-80CF-9C43436B5794').GetPlaylist(jso,
      procedure(APlaylist: TPlaylist)
      begin
        CurrentSongsListNotFiltered := nil;
        CurrentSongsListNotFiltered := APlaylist;
      end);
  finally
    jso.Free;
  end;
end;

procedure TfrmMain.cbSortListChange(Sender: TObject);
begin
  if not assigned(CurrentSongsList) then
    exit;

  case cbSortList.ItemIndex of
    0: // sort by title
      CurrentSongsList.SortByTitle;
    1: // sort by artist
      CurrentSongsList.SortByArtist;
    2: // sort by album
      CurrentSongsList.SortByAlbum;
    3: // sort by category + album
      CurrentSongsList.SortByCategoryAlbum;
    4: // sort by caterogy + Title
      CurrentSongsList.SortByCategoryTitle;
    -1: // do nothing
      ;
  else
    raise exception.Create('I don''t know how to sort this list !');
  end;

  RefreshListView; // TODO : replace by a message or event from the Playlist
end;

procedure TfrmMain.ClearEditButton1Click(Sender: TObject);
begin
  edtSearch.Text := '';
  SearchEditButton1Click(Self);
end;

procedure TfrmMain.ConnectorMenuClick(Sender: TObject);
var
  Connector: IConnector;
begin
  if (Sender is TMenuItem) and (not(Sender as TMenuItem).Tagstring.IsEmpty) then
  begin
    Connector := TConnectorsList.Current.GetConnectorFromUID
      ((Sender as TMenuItem).Tagstring);
    if assigned(Connector) and Connector.hasSetupDialog then
      Connector.SetupDialog;
  end;
end;

procedure TfrmMain.edtSearchKeyDown(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkreturn then
    SearchEditButton1Click(Self)
  else if Key = vkEscape then
    ClearEditButton1Click(Self);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i: integer;
  mnuConnectors, mnu: TMenuItem;
  ConnectorsList: TConnectorsList;
  Connector: IConnector;
begin
  TConfig.Current.LoadFromFile;

  lblSongPlayed.Text := '';

{$IF Defined(ANDROID) or Defined(IOS)}
  MainMenu1.Visible := false;
{$ELSEIF Defined(MACOS) and not Defined(IOS)}
  mnuExit.Visible := false; // already exists for Mac
  mnuFile.Visible := false; // empty => no display
  mnuOptions.Parent := MacSystemMenu;
  mnuOptions.Text := 'Preferences'; // TODO : translate text
  mnuTools.Visible := false; // empty => no display
{$ELSE}
  MacSystemMenu.Visible := false;
{$ENDIF}
  //
  mnuConnectors := nil;
  ConnectorsList := TConnectorsList.Current;
  ConnectorsList.Sort;
  for i := 0 to ConnectorsList.Count - 1 do
  begin
    Connector := ConnectorsList.GetConnectorAt(i);
    if Connector.hasSetupDialog then
    begin
      if not assigned(mnuConnectors) then
      begin
        if not mnuTools.Visible then
          mnuTools.Visible := true;
        mnuConnectors := TMenuItem.Create(Self);
        mnuConnectors.Parent := mnuTools;
        mnuConnectors.Text := 'Connectors'; // TODO : à traduire
      end;
      mnu := TMenuItem.Create(Self);
      mnu.Parent := mnuConnectors;
      mnu.Text := Connector.getName;
      mnu.OnClick := ConnectorMenuClick;
      mnu.Tagstring := Connector.getUniqID;
    end;
  end;

  mnuPlaylistSeparator.Visible := (TConfig.Current.Playlists.Count > 0);
  for i := 0 to TConfig.Current.Playlists.Count - 1 do
  begin
    mnu := TMenuItem.Create(Self);
    mnu.Parent := mnuPlaylist;
    mnu.Text := TConfig.Current.Playlists[i].Text;
    mnu.OnClick := PlaylistMenuClick;
    mnu.TagObject := TConfig.Current.Playlists[i];
  end;
  TMessageManager.DefaultManager.SubscribeToMessage(TNewPlaylistMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TNewPlaylistMessage;
      mnu: TMenuItem;
    begin
      if (M is TNewPlaylistMessage) then
      begin
        msg := M as TNewPlaylistMessage;
        if assigned(msg.Value) then
        begin
          mnuPlaylistSeparator.Visible := true;
          mnu := TMenuItem.Create(Self);
          mnu.Parent := mnuPlaylist;
          mnu.Text := msg.Value.Text;
          mnu.OnClick := PlaylistMenuClick;
          mnu.TagObject := msg.Value;
        end;
      end;
    end);

  caption := AboutDialog.Titre + ' ' + AboutDialog.VersionNumero;
{$IFDEF DEBUG}
  caption := caption + ' [DEBUG MODE]';
{$ENDIF}
  FDefaultCaption := caption;

  TMessageManager.DefaultManager.SubscribeToMessage(TNowPlayingMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TNowPlayingMessage;
    begin
      if (M is TNowPlayingMessage) then
      begin
        msg := M as TNowPlayingMessage;
        if assigned(msg.Value) then
        begin
          lblSongPlayed.Text := 'Playing : ' + msg.Value.Title;
          caption := FDefaultCaption + ' - ' + msg.Value.Title;
        end
        else
        begin
          lblSongPlayed.Text := '';
          caption := FDefaultCaption;
        end;
      end;
    end);

  edtSearch.Text := '';
  edtSearch.Tagstring := '';
end;

procedure TfrmMain.ListView1ButtonClick(const Sender: TObject;
const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  isPlaying: boolean;
begin
  if assigned(AItem) and assigned(AItem.TagObject) and (AItem.TagObject is TSong)
  then
  begin
    isPlaying := (AItem as TListviewItem).Tag <> 0;
    (AItem as TListviewItem).Tag := SubscribeToZicPlayMessage
      (AItem as TListviewItem);
    if (not isPlaying) then
      PlayedSong := AItem.TagObject as TSong
    else
      PlayedSong := nil;

    if ListView1.Selected <> AItem then
      ListView1.Selected := AItem;
  end;
end;

procedure TfrmMain.mnuPlaylistCreateClick(Sender: TObject);
begin
  TfrmPlaylist.Execute(nil);
end;

procedure TfrmMain.PlaylistMenuClick(Sender: TObject);
begin
  if (Sender is TMenuItem) and ((Sender as TMenuItem).TagObject is TPlaylist)
  then
    TfrmPlaylist.Execute((Sender as TMenuItem).TagObject as TPlaylist)
  else
    raise exception.Create('No playlist to setup !');
end;

procedure TfrmMain.RefreshListView;
var
  item: TListviewItem;
  i: integer;
  song: TSong;
begin
  ListView1.BeginUpdate;
  try
    // remove messaging subscriptions before deleting items
    for i := 0 to ListView1.ItemCount - 1 do
      if assigned(ListView1.items[i].TagObject) and (ListView1.items[i].Tag <> 0)
      then
        TMessageManager.DefaultManager.Unsubscribe(TNowPlayingMessage,
          ListView1.items[i].Tag, true);

    // delete all items of the displayed list
    ListView1.items.Clear;

    if not assigned(CurrentSongsList) then
      exit;

    // Generate the new list on screen
    for i := 0 to CurrentSongsList.Count - 1 do
    begin
      song := CurrentSongsList[i];
      item := ListView1.items.Add;
      try
        item.Text := song.Title;
        item.Detail := song.Artist + ' / ' + song.Album; // song.FileName;
        item.TagObject := song;
        if (song = PlayedSong) then
        begin
          item.ButtonText := 'Pause';
          item.Tag := SubscribeToZicPlayMessage(item);
          // 0 = not playing,
          // other = playing (value is subcription id to rtl messaging)

          ListView1.Selected := item;
        end
        else
        begin
          item.ButtonText := 'Play';
          item.Tag := 0;
          // 0 = not playing,
          // other = playing (value is subcription id to rtl messaging)
        end;
      except
        item.Free;
        raise;
      end;
    end;
  finally
    ListView1.EndUpdate;
  end;
end;

procedure TfrmMain.SearchEditButton1Click(Sender: TObject);
var
  Playlist: TPlaylist;
  i: integer;
  song: TSong;
  FindText: string;
begin
  if not assigned(CurrentSongsListNotFiltered) then
    exit;

  FindText := edtSearch.Text.trim.ToLower;
  if FindText.Equals(edtSearch.Tagstring) then
    exit;
  edtSearch.Tagstring := FindText;

  if FindText.IsEmpty then
  begin
    if (CurrentSongsList <> CurrentSongsListNotFiltered) then
    begin
      CurrentSongsList := nil;
      CurrentSongsList := CurrentSongsListNotFiltered;
    end;
  end
  else
  begin
    Playlist := TPlaylist.Create;
    try
      for i := 0 to CurrentSongsListNotFiltered.Count - 1 do
      begin
        // TODO : change filtering method (case sensitive, keyword or full text, choose on what property, ...)
        song := CurrentSongsListNotFiltered[i];
        if song.TitleLowerCase.Contains(FindText) or
          song.ArtistLowerCase.Contains(FindText) or
          song.AlbumLowerCase.Contains(FindText) or
          song.CategoryLowerCase.Contains(FindText) then
          Playlist.Add(song);
      end;

      CurrentSongsList := nil;
      CurrentSongsList := Playlist;
    except
      Playlist.Free;
      raise;
    end;
  end;
end;

procedure TfrmMain.SetCurrentSongsList(const Value: TPlaylist);
begin
  if (Value = nil) and (FCurrentSongsList <> FCurrentSongsListNotFiltered) then
    FCurrentSongsList.Free;

  if (FCurrentSongsList <> Value) then
  begin
    FCurrentSongsList := Value;
    RefreshListView;
  end;
end;

procedure TfrmMain.SetCurrentSongsListNotFiltered(const Value: TPlaylist);
begin
  if (FCurrentSongsListNotFiltered <> Value) then
  begin
    FCurrentSongsListNotFiltered := Value;
    CurrentSongsList := FCurrentSongsListNotFiltered;
  end;
end;

procedure TfrmMain.SetPlayedSong(const Value: TSong);
begin
  if FPlayedSong <> Value then
  begin
    if (Value = nil) then
    begin
      MusicLoop.Stop;
      FPlayedSong := nil;
    end
    else
    begin
      FPlayedSong := Value;
      MusicLoop.Play(FPlayedSong.FileName, false);
    end;
    TMessageManager.DefaultManager.SendMessage(Self,
      TNowPlayingMessage.Create(FPlayedSong));
  end;
end;

function TfrmMain.SubscribeToZicPlayMessage(AItem: TListviewItem): integer;
begin
  result := TMessageManager.DefaultManager.SubscribeToMessage
    (TNowPlayingMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TNowPlayingMessage;
    begin
      if (M is TNowPlayingMessage) then
      begin
        msg := M as TNowPlayingMessage;
        if msg.Value = AItem.TagObject then
          AItem.ButtonText := 'Pause'
        else
        begin
          AItem.ButtonText := 'Play';
          // access violation on Mac after Unsubscribe
          // => using ForceQueue may fix the bug
          tthread.ForceQueue(nil,
            procedure
            begin
              TMessageManager.DefaultManager.Unsubscribe(TNowPlayingMessage,
                AItem.Tag, true);
              AItem.Tag := 0;
            end);
        end;
      end;
    end);
end;

procedure TfrmMain.timerIsSongFinishedTimer(Sender: TObject);
var
  i: integer;
  SongIndex: integer;
begin
  if not assigned(PlayedSong) then
    exit;

  if not MusicLoop.isPlaying then // Music has finished
  begin
    // TODO : if REPEAT 1 is selected, replay the song
    SongIndex := -1;
    for i := 0 to CurrentSongsList.Count - 1 do
      if CurrentSongsList[i] = PlayedSong then
      begin
        SongIndex := i;
        break;
      end;
    if (SongIndex >= 0) and (SongIndex + 1 < CurrentSongsList.Count) then
    begin
      // PlayedSong := CurrentSongsList[SongIndex + 1]
      for i := 0 to ListView1.items.Count - 1 do
        if ListView1.items[i].TagObject = CurrentSongsList[SongIndex + 1] then
        begin
          ListView1ButtonClick(Self, ListView1.items[i], nil);
          break;
        end;
    end
    else
    begin
      // TODO : if REPEAT ALL is selected, play first song of the list
      PlayedSong := nil;
    end;
  end;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
TDialogService.PreferredMode := TDialogService.TPreferredMode.Sync;

end.
