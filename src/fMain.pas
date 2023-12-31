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
  uDMIcons,
  FMX.MultiView,
  FMX.Layouts,
  Gamolf.FMX.MusicLoop;

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
    ListView1: TListView;
    lblSongPlayed: TLabel;
    cbSortList: TComboBox;
    edtSearch: TEdit;
    SearchEditButton1: TSearchEditButton;
    ClearEditButton1: TClearEditButton;
    timerIsSongFinished: TTimer;
    mnuPlaylist: TMenuItem;
    mnuPlaylistCreate: TMenuItem;
    mnuPlaylistSeparator: TMenuItem;
    mvPlaylists: TMultiView;
    mvPlaylistsArea: TVertScrollBox;
    lPlayPauseButtons: TLayout;
    btnNext: TButton;
    btnStop: TButton;
    btnPause: TButton;
    btnPlay: TButton;
    btnPrevious: TButton;
    FlowLayout1: TFlowLayout;
    btnPlaylists: TButton;
    tbVolume: TTrackBar;
    lVolume: TLayout;
    lblVolume: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    cbPlayIntro: TCheckBox;
    cbRepeatAll: TCheckBox;
    cbPlayNextRandom: TCheckBox;
    cbRepeatCurrentSong: TCheckBox;
    lblNbSongs: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure cbSortListChange(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure ClearEditButton1Click(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure timerIsSongFinishedTimer(Sender: TObject);
    procedure AboutDialogURLClick(const AURL: string);
    procedure mnuPlaylistCreateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnPreviousClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure ListView1Change(Sender: TObject);
    procedure tbVolumeTracking(Sender: TObject);
    procedure cbRepeatAllChange(Sender: TObject);
    procedure cbPlayIntroChange(Sender: TObject);
    procedure cbPlayNextRandomChange(Sender: TObject);
    procedure cbRepeatCurrentSongChange(Sender: TObject);
    procedure mvPlaylistsShown(Sender: TObject);
    procedure mvPlaylistsHidden(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPlayedSong: TSong;
    FDefaultCaption: string;
    FCurrentSongsList: TPlaylist;
    FCurrentSongsListNotFiltered: TPlaylist;
    FStopTimer: integer;
    MusicPlayer: TMusicLoop;
    procedure SetPlayedSong(const Value: TSong);
    procedure SetCurrentSongsList(const Value: TPlaylist);
    { D�clarations priv�es }
    procedure RefreshListView;
    procedure RefreshListItem(Item: TListViewItem; Song: TSong);
    procedure SetCurrentSongsListNotFiltered(const Value: TPlaylist);
    procedure ConnectorMenuClick(Sender: TObject);
    procedure PlaylistMenuClick(Sender: TObject);
    procedure PlaylistEnableChange(Sender: TObject);
    function SubscribeToNowPlayingMessage(AItem: TListViewItem)
      : integer; overload;
    procedure SubscribeToNowPlayingMessage; overload;
    procedure SubscribeToNewPlaylistMessage;
    procedure SubscribeToPlaylistUpdatedMessage;
    procedure UpdatePlayPauseButton;
    function GetNextSong: TSong;
    Procedure PlayNextSong(ARandom: boolean = false);
    function GetPreviousSong: TSong;
    procedure PlayPreviousSong;
    procedure FilterSongsList;
    procedure SortSongsList;
  public
    { D�clarations publiques }
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
  FMX.Media,
  System.Threading,
  FMX.DialogService,
  System.JSON,
  System.IOUtils,
  System.Messaging,
  u_urlOpen,
  uConfig,
  fPlaylist;

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
  // TODO : � compl�ter
{$MESSAGE warn 'todo'}
end;

procedure TfrmMain.btnNextClick(Sender: TObject);
begin
  PlayNextSong;
end;

procedure TfrmMain.btnPauseClick(Sender: TObject);
begin
  if assigned(PlayedSong) then
    MusicPlayer.Pause;
end;

procedure TfrmMain.btnPlayClick(Sender: TObject);
begin
  if not assigned(ListView1.Selected) and (ListView1.Items.Count > 0) then
    ListView1ButtonClick(ListView1, ListView1.Items[0], nil)
  else if assigned(ListView1.Selected) and
    (ListView1.Selected.TagObject <> PlayedSong) then
    ListView1ButtonClick(ListView1, ListView1.Selected, nil);
end;

procedure TfrmMain.btnPreviousClick(Sender: TObject);
begin
  PlayPreviousSong;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  if assigned(PlayedSong) then
    PlayedSong := nil;
end;

procedure TfrmMain.cbPlayIntroChange(Sender: TObject);
begin
  TConfig.Current.PlayIntro := cbPlayIntro.IsChecked;
end;

procedure TfrmMain.cbPlayNextRandomChange(Sender: TObject);
begin
  TConfig.Current.PlayNextRandom := cbPlayNextRandom.IsChecked;
end;

procedure TfrmMain.cbRepeatAllChange(Sender: TObject);
begin
  TConfig.Current.PlayRepeatAll := cbRepeatAll.IsChecked;
  UpdatePlayPauseButton;
end;

procedure TfrmMain.cbRepeatCurrentSongChange(Sender: TObject);
begin
  TConfig.Current.PlayRepeatOne := cbRepeatCurrentSong.IsChecked;
end;

procedure TfrmMain.cbSortListChange(Sender: TObject);
begin
  RefreshListView;
end;

procedure TfrmMain.ClearEditButton1Click(Sender: TObject);
begin
  edtSearch.Text := '';
  TConfig.Current.FilterText := '';
  RefreshListView;
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

procedure TfrmMain.FilterSongsList;
var
  Playlist: TPlaylist;
  i: integer;
  Song: TSong;
  FindText: string;
begin
  if not assigned(CurrentSongsListNotFiltered) then
    exit;

  FindText := edtSearch.Text.trim.ToLower;

  if FindText.IsEmpty then
    CurrentSongsList := CurrentSongsListNotFiltered
  else
  begin
    Playlist := TPlaylist.Create;
    try
      for i := 0 to CurrentSongsListNotFiltered.Count - 1 do
      begin
        // TODO : change filtering method (case sensitive, keyword or full text, choose on what property, ...)
        Song := CurrentSongsListNotFiltered.GetSongAt(i);
        if Song.TitleLowerCase.Contains(FindText) or
          Song.ArtistLowerCase.Contains(FindText) or
          Song.AlbumLowerCase.Contains(FindText) or
          Song.CategoryLowerCase.Contains(FindText) or
          Song.PublishedYear.tostring.StartsWith(FindText) then
          Playlist.Add(Song);
      end;

      CurrentSongsList := Playlist;
    except
      Playlist.Free;
      raise;
    end;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // The uConfig.Finalization is not executed on Mac (and won't be on iOS/Android)
  // Saving the settings here will fix the problem.
  if TConfig.Current.hasConfigChanged then
    TConfig.Current.SaveTofile;

  tparallel.For(0, TConfig.Current.Playlists.Count - 1,
    procedure(i: integer)
    begin
      if TConfig.Current.Playlists[i].hasChanged then
        TConfig.Current.Playlists[i].Save;
    end);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i: integer;
  mnuConnectors, mnu: TMenuItem;
  ConnectorsList: TConnectorsList;
  Connector: IConnector;
  cb: TCheckBox;
begin
  TConfig.Current.LoadFromFile;

  MusicPlayer := TMusicLoop.Create;

{$IFDEF DEBUG}
  caption := '[DEBUG] ' + AboutDialog.Titre + ' v' + AboutDialog.VersionNumero;
{$ELSE}
  caption := AboutDialog.Titre + ' v' + AboutDialog.VersionNumero;
{$ENDIF}
  FDefaultCaption := caption;
  lblSongPlayed.Text := '';
  lblNbSongs.Text := '';

  edtSearch.Text := TConfig.Current.FilterText;
  cbSortList.ItemIndex := TConfig.Current.SortType;
  tbVolume.Value := TConfig.Current.Volume;
  MusicPlayer.Volume := TConfig.Current.Volume;
  // TODO : changing the musicloop volume does nothing until the first song is played
  cbRepeatAll.IsChecked := TConfig.Current.PlayRepeatAll;
  cbRepeatCurrentSong.IsChecked := TConfig.Current.PlayRepeatOne;
  cbPlayIntro.IsChecked := TConfig.Current.PlayIntro;
  cbPlayNextRandom.IsChecked := TConfig.Current.PlayNextRandom;

  FCurrentSongsList := nil;
  CurrentSongsListNotFiltered := TPlaylist.Create;

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
        mnuConnectors.Text := 'Connectors'; // TODO : � traduire
      end;
      mnu := TMenuItem.Create(Self);
      mnu.Parent := mnuConnectors;
      mnu.Text := Connector.getName;
      mnu.OnClick := ConnectorMenuClick;
      mnu.Tagstring := Connector.getUniqID;
    end;
  end;

  if TConfig.Current.mvPlaylistsVisible then
    mvPlaylists.ShowMaster
  else
    mvPlaylists.HideMaster;

  mnuPlaylistSeparator.Visible := (TConfig.Current.Playlists.Count > 0);
  for i := 0 to TConfig.Current.Playlists.Count - 1 do
  begin
    mnu := TMenuItem.Create(Self);
    mnu.Parent := mnuPlaylist;
    mnu.Text := TConfig.Current.Playlists[i].Text;
    mnu.IsChecked := TConfig.Current.Playlists[i].enabled;
    mnu.OnClick := PlaylistMenuClick;
    mnu.TagObject := TConfig.Current.Playlists[i];

    cb := TCheckBox.Create(Self);
    cb.Parent := mvPlaylistsArea;
    cb.Align := talignlayout.Top;
    cb.Text := TConfig.Current.Playlists[i].Text;
    cb.IsChecked := TConfig.Current.Playlists[i].enabled;
    cb.OnChange := PlaylistEnableChange;
    cb.TagObject := TConfig.Current.Playlists[i];
    cb.Margins.Top := 10;
    cb.Margins.right := 10;
    cb.Margins.Bottom := 10;
    cb.Margins.Left := 10;
  end;
  SubscribeToNewPlaylistMessage;
  SubscribeToPlaylistUpdatedMessage;

  tthread.ForceQueue(nil,
    procedure
    begin
      tparallel.For(0, TConfig.Current.Playlists.Count - 1,
        procedure(i: integer)
        begin
          TConfig.Current.Playlists[i].RefreshSongsList;
        end);
    end);

  SubscribeToNowPlayingMessage;

  tthread.CreateAnonymousThread(
    procedure
    var
      i: integer;
      Song: TSong;
    begin
      sleep(1000);
      exit;
      // duration not initialized for macOS before playing the file
      // it works on Windows for refresh the list in background

      // TODO : optimize this code : don't loop undefinitly on the same list is nothing has changed
      // TODO : add a parameter to allow or not this feature (disable it in platforms not compatible like macOS)
      i := 0;
      while (not tthread.CheckTerminated) do
      begin
        sleep(200 + random(500));

        if not assigned(CurrentSongsList) then
          continue;

        Song := CurrentSongsList.GetSongAt(i);
        if not assigned(Song) then
        begin
          i := 0;
          continue;
        end;
        if (Song.Duration < 0) then
          tthread.Synchronize(nil,
            procedure
            var
              MediaPlayer: TMediaPlayer;
              j: integer;
              NewDuration: integer;
            begin
              try
                MediaPlayer := TMediaPlayer.Create(nil);
                try
                  MediaPlayer.FileName := Song.FileName;
                  // duration not initialized for macOS before playing the file
                  NewDuration := trunc(MediaPlayer.Duration / MediaTimeScale);
                  if NewDuration > 0 then
                  begin
                    Song.Duration := NewDuration;
                    for j := 0 to ListView1.ItemCount - 1 do
                      if ListView1.Items[i].TagObject = Song then
                      begin
                        RefreshListItem(ListView1.Items[i], Song);
                        exit;
                      end;
                  end;
                finally
                  MediaPlayer.Free;
                end;
              except
                Song.Duration := -1;
              end;
            end);
        inc(i);
      end;
    end).start;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  MusicPlayer.Free;
  CurrentSongsListNotFiltered.Free;
end;

procedure TfrmMain.FormResize(Sender: TObject);
var
  C: tcontrol;
  YMax: single;
  YBottom: single;
  i: integer;
  HeightFlowlayout: single;
  HeightToolbar: single;
begin
  YMax := 0;
  for i := 0 to FlowLayout1.ChildrenCount - 1 do
    if (FlowLayout1.Children[i] is tcontrol) then
    begin
      C := FlowLayout1.Children[i] as tcontrol;
      YBottom := C.position.y + C.Height + C.Margins.Bottom;
      if YMax < YBottom then
        YMax := YBottom;
    end;
  HeightFlowlayout := FlowLayout1.Padding.Top + YMax +
    FlowLayout1.Padding.Bottom;
  if (FlowLayout1.Height <> HeightFlowlayout) then
    FlowLayout1.Height := HeightFlowlayout;
  // value updated after next process message
  HeightToolbar := ToolBar1.Padding.Top + FlowLayout1.Margins.Top +
    HeightFlowlayout + FlowLayout1.Margins.Bottom + ToolBar1.Padding.Bottom;
  if (ToolBar1.Height <> HeightToolbar) then
    ToolBar1.Height := HeightToolbar;
end;

function TfrmMain.GetNextSong: TSong;
var
  i, SongIndex: integer;
begin
  if not assigned(CurrentSongsList) then
  begin
    result := nil;
    exit;
  end;

  SongIndex := -1;
  for i := 0 to CurrentSongsList.Count - 1 do
    if CurrentSongsList.GetSongAt(i) = PlayedSong then
    begin
      SongIndex := i;
      break;
    end;
  if (SongIndex >= 0) and (SongIndex + 1 < CurrentSongsList.Count) then
    result := CurrentSongsList.GetSongAt(SongIndex + 1)
  else if cbRepeatAll.IsChecked then
    result := CurrentSongsList.GetSongAt(0)
  else
    result := nil;
end;

function TfrmMain.GetPreviousSong: TSong;
var
  i, SongIndex: integer;
begin
  if not assigned(CurrentSongsList) then
  begin
    result := nil;
    exit;
  end;

  SongIndex := -1;
  for i := 0 to CurrentSongsList.Count - 1 do
    if CurrentSongsList.GetSongAt(i) = PlayedSong then
    begin
      SongIndex := i;
      break;
    end;
  if (SongIndex > 0) and (SongIndex < CurrentSongsList.Count) then
    result := CurrentSongsList.GetSongAt(SongIndex - 1)
  else if cbRepeatAll.IsChecked then
    result := CurrentSongsList.GetSongAt(CurrentSongsList.Count - 1)
  else
    result := nil;
end;

procedure TfrmMain.ListView1ButtonClick(const Sender: TObject;
const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  isPlaying: boolean;
begin
  if assigned(AItem) and assigned(AItem.TagObject) and (AItem.TagObject is TSong)
  then
  begin
    isPlaying := (AItem as TListViewItem).Tag <> 0;
    (AItem as TListViewItem).Tag := SubscribeToNowPlayingMessage
      (AItem as TListViewItem);
    if (not isPlaying) then
      PlayedSong := AItem.TagObject as TSong
    else
      PlayedSong := nil;

    if ListView1.Selected <> AItem then
      ListView1.Selected := AItem;

    UpdatePlayPauseButton;
  end;
end;

procedure TfrmMain.ListView1Change(Sender: TObject);
begin
  UpdatePlayPauseButton;
end;

procedure TfrmMain.mnuPlaylistCreateClick(Sender: TObject);
begin
  TfrmPlaylist.Execute(nil);
end;

procedure TfrmMain.mvPlaylistsHidden(Sender: TObject);
begin
  TConfig.Current.mvPlaylistsVisible := false;
end;

procedure TfrmMain.mvPlaylistsShown(Sender: TObject);
begin
  TConfig.Current.mvPlaylistsVisible := true;
end;

procedure TfrmMain.PlaylistEnableChange(Sender: TObject);
var
  cb: TCheckBox;
  Playlist: TPlaylist;
begin
  if (Sender is TCheckBox) then
    cb := Sender as TCheckBox
  else
    exit;

  if assigned(cb.TagObject) and (cb.TagObject is TPlaylist) then
    Playlist := cb.TagObject as TPlaylist
  else
    exit;

  Playlist.enabled := cb.IsChecked;
  TMessageManager.DefaultManager.SendMessage(Self,
    TPlaylistUpdatedMessage.Create(Playlist));
end;

procedure TfrmMain.PlaylistMenuClick(Sender: TObject);
begin
  if (Sender is TMenuItem) and ((Sender as TMenuItem).TagObject is TPlaylist)
  then
    TfrmPlaylist.Execute((Sender as TMenuItem).TagObject as TPlaylist)
  else
    raise exception.Create('No playlist to setup !');
end;

procedure TfrmMain.PlayNextSong(ARandom: boolean);
var
  Song: TSong;
  i: integer;
  nb, num: integer;
begin
  if ARandom then
  begin
    nb := CurrentSongsList.Count;
    if (nb < 1) then
      Song := nil
    else
    begin
      num := random(nb);
      if (num < 0) or (num >= nb) then
        raise exception.Create('Next song found out of range in random mode.');
      Song := CurrentSongsList.GetSongAt(num);
      if not assigned(Song) then
        raise exception.Create('No song found in random mode.');
    end;
  end
  else
    Song := GetNextSong;
  if assigned(Song) then
  begin
    for i := 0 to ListView1.Items.Count - 1 do
      if ListView1.Items[i].TagObject = Song then
      begin
        ListView1ButtonClick(ListView1, ListView1.Items[i], nil);
        exit;
      end;
    raise exception.Create('Next song not found in current list of songs.');
  end
  else
    PlayedSong := nil;
end;

procedure TfrmMain.PlayPreviousSong;
var
  Song: TSong;
  i: integer;
begin
  Song := GetPreviousSong;
  if assigned(Song) then
  begin
    for i := 0 to ListView1.Items.Count - 1 do
      if ListView1.Items[i].TagObject = Song then
      begin
        ListView1ButtonClick(ListView1, ListView1.Items[i], nil);
        break;
      end;
  end
  else
    PlayedSong := nil;
end;

procedure TfrmMain.RefreshListItem(Item: TListViewItem; Song: TSong);
begin
  if not assigned(Item) then
    raise exception.Create('No item to refresh !');
  if not assigned(Song) then
    raise exception.Create('No song to attach to this item !');
  Item.Text := Song.Title;
  if not Song.Album.IsEmpty then
    Item.Text := Item.Text + ' (' + Song.Album + ')';
  Item.Detail := '';
  if not Song.Artist.IsEmpty then
  begin
    if not Item.Detail.IsEmpty then
      Item.Detail := Item.Detail + ' - ';
    Item.Detail := Item.Detail + Song.Artist;
  end;
  if not Song.Category.IsEmpty then
  begin
    if not Item.Detail.IsEmpty then
      Item.Detail := Item.Detail + ' - ';
    Item.Detail := Item.Detail + Song.Category;
  end;
  if Song.PublishedYear > 0 then
  begin
    if not Item.Detail.IsEmpty then
      Item.Detail := Item.Detail + ' - ';
    Item.Detail := Item.Detail + Song.PublishedYear.tostring;
  end;
  if Song.Duration > 0 then
  begin
    if not Item.Detail.IsEmpty then
      Item.Detail := Item.Detail + ' - ';
    Item.Detail := Item.Detail + Song.DurationAsTime;
  end;
  Item.TagObject := Song;
end;

procedure TfrmMain.RefreshListView;
var
  Item: TListViewItem;
  i: integer;
  Song: TSong;
begin
  FilterSongsList;
  SortSongsList;
  ListView1.BeginUpdate;
  try
    // remove messaging subscriptions before deleting items
    for i := 0 to ListView1.ItemCount - 1 do
      if assigned(ListView1.Items[i].TagObject) and (ListView1.Items[i].Tag <> 0)
      then
        TMessageManager.DefaultManager.Unsubscribe(TNowPlayingMessage,
          ListView1.Items[i].Tag, true);

    // delete all items of the displayed list
    ListView1.Items.Clear;

    if not assigned(CurrentSongsList) then
      exit;

    // Generate the new list on screen
    for i := 0 to CurrentSongsList.Count - 1 do
    begin
      Song := CurrentSongsList.GetSongAt(i);
      Item := ListView1.Items.Add;
      try
        RefreshListItem(Item, Song);
        if (Song = PlayedSong) then
        begin
          Item.ButtonText := 'Stop';
          Item.Tag := SubscribeToNowPlayingMessage(Item);
          // 0 = not playing,
          // other = playing (value is subcription id to rtl messaging)

          ListView1.Selected := Item;
        end
        else
        begin
          Item.ButtonText := 'Play';
          Item.Tag := 0;
          // 0 = not playing,
          // other = playing (value is subcription id to rtl messaging)
        end;
      except
        Item.Free;
        raise;
      end;
    end;
  finally
    ListView1.EndUpdate;
  end;
  if (ListView1.ItemCount > 1) then
    lblNbSongs.Text := ListView1.ItemCount.tostring + ' songs'
  else
    lblNbSongs.Text := ListView1.ItemCount.tostring + ' song';
  UpdatePlayPauseButton;
end;

procedure TfrmMain.SearchEditButton1Click(Sender: TObject);
begin
  TConfig.Current.FilterText := edtSearch.Text;
  RefreshListView;
end;

procedure TfrmMain.SetCurrentSongsList(const Value: TPlaylist);
begin
  if (FCurrentSongsList <> Value) then
  begin
    if (FCurrentSongsList <> FCurrentSongsListNotFiltered) then
      FCurrentSongsList.Free;

    FCurrentSongsList := Value;
  end;
end;

procedure TfrmMain.SetCurrentSongsListNotFiltered(const Value: TPlaylist);
begin
  if (FCurrentSongsListNotFiltered <> Value) then
  begin
    FCurrentSongsListNotFiltered := Value;
    RefreshListView;
  end;
end;

procedure TfrmMain.SetPlayedSong(const Value: TSong);
begin
  // update song's duration if needed
  if assigned(FPlayedSong) and (MusicPlayer.DurationInSeconds > 0) and
    (FPlayedSong.Duration <> MusicPlayer.DurationInSeconds) then
    FPlayedSong.Duration := MusicPlayer.DurationInSeconds;

  if FPlayedSong <> Value then
  begin
    if (Value = nil) then
    begin
      MusicPlayer.Stop;
      FPlayedSong := nil;
      FStopTimer := 0;
    end
    else
    begin
      FStopTimer := 1 * 1000 div timerIsSongFinished.Interval;
      // stop the timer during 1 second before detecting if the music is played or not
      FPlayedSong := Value;
      // if (MusicPlayer.Filename <> FPlayedSong.Filename) then
      // begin
      MusicPlayer.Free;
      MusicPlayer := TMusicLoop.Create;
      MusicPlayer.Play(FPlayedSong.FileName, false);
      // end
      // else
      // MusicPlayer.Play;
      // TODO : restart the music, don't continue where it has been stopped
      MusicPlayer.Volume := TConfig.Current.Volume;
    end;
    TMessageManager.DefaultManager.SendMessage(Self,
      TNowPlayingMessage.Create(FPlayedSong));
  end;
end;

procedure TfrmMain.SortSongsList;
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
  TConfig.Current.SortType := cbSortList.ItemIndex;
end;

procedure TfrmMain.SubscribeToNewPlaylistMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TNewPlaylistMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TNewPlaylistMessage;
      mnu: TMenuItem;
      cb: TCheckBox;
      Playlist: TPlaylist;
    begin
      if (M is TNewPlaylistMessage) then
      begin
        msg := M as TNewPlaylistMessage;
        if assigned(msg.Value) then
        begin
          Playlist := msg.Value;
          mnuPlaylistSeparator.Visible := true;
          mnu := TMenuItem.Create(Self);
          mnu.Parent := mnuPlaylist;
          mnu.Text := Playlist.Text;
          mnu.OnClick := PlaylistMenuClick;
          mnu.TagObject := Playlist;

          cb := TCheckBox.Create(Self);
          cb.Parent := mvPlaylistsArea;
          cb.Align := talignlayout.Top;
          cb.Text := Playlist.Text;
          cb.IsChecked := Playlist.enabled;
          cb.OnChange := PlaylistEnableChange;
          cb.TagObject := Playlist;
          cb.Margins.Top := 10;
          cb.Margins.right := 10;
          cb.Margins.Bottom := 10;
          cb.Margins.Left := 10;

          Playlist.RefreshSongsList;
        end;
      end;
    end);
end;

procedure TfrmMain.SubscribeToNowPlayingMessage;
begin
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
        UpdatePlayPauseButton;
      end;
    end);
end;

function TfrmMain.SubscribeToNowPlayingMessage(AItem: TListViewItem): integer;
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
        // refresh current item in the TListView
        if assigned(AItem) and assigned(AItem.TagObject) and
          (AItem.TagObject is TSong) then
          RefreshListItem(AItem, AItem.TagObject as TSong);
        // update item's button text
        if msg.Value = AItem.TagObject then
          AItem.ButtonText := 'Stop'
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

procedure TfrmMain.SubscribeToPlaylistUpdatedMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TPlaylistUpdatedMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TPlaylistUpdatedMessage;
      mnu: TMenuItem;
      cb: TCheckBox;
      i: integer;
      Playlist: TPlaylist;
      GlobalPlaylistHasChanged: boolean;
      Song: TSong;
    begin
      if (M is TPlaylistUpdatedMessage) then
      begin
        msg := M as TPlaylistUpdatedMessage;
        if assigned(msg.Value) then
        begin
          Playlist := msg.Value;

          if (mnuPlaylist.itemsCount > 0) then
            for i := 0 to mnuPlaylist.itemsCount - 1 do
              if (mnuPlaylist.Items[i] is TMenuItem) then
              begin
                mnu := mnuPlaylist.Items[i] as TMenuItem;
                if assigned(mnu.TagObject) and (mnu.TagObject is TPlaylist) and
                  (Playlist = (mnu.TagObject as TPlaylist)) then
                begin
                  mnu.Text := Playlist.Text;
                  mnu.IsChecked := Playlist.enabled;
                end;
              end;

          if (mvPlaylistsArea.Content.ChildrenCount > 0) then
            for i := 0 to mvPlaylistsArea.Content.ChildrenCount - 1 do
              if (mvPlaylistsArea.Content.Children[i] is TCheckBox) then
              begin
                cb := mvPlaylistsArea.Content.Children[i] as TCheckBox;
                if assigned(cb.TagObject) and (cb.TagObject is TPlaylist) and
                  (Playlist = (cb.TagObject as TPlaylist)) then
                begin
                  cb.Text := Playlist.Text;
                  cb.IsChecked := Playlist.enabled;
                end;
              end;

          GlobalPlaylistHasChanged := false;
          if not Playlist.enabled then
          begin // remove songs from gobal playlist
            i := 0;
            while (i < CurrentSongsListNotFiltered.Count) do
              if CurrentSongsListNotFiltered.GetSongAt(i).Playlist = Playlist
              then
              begin
                CurrentSongsListNotFiltered.delete(i);
                GlobalPlaylistHasChanged := true;
              end
              else
                inc(i);
          end
          else
          begin // add songs from global playlist if needed
            // remove not available songs
            i := 0;
            while (i < CurrentSongsListNotFiltered.Count) do
            begin
              Song := CurrentSongsListNotFiltered.GetSongAt(i);
              if (Song.Playlist = Playlist) and (not Playlist.HasSong(Song))
              then
              begin
                CurrentSongsListNotFiltered.delete(i);
                GlobalPlaylistHasChanged := true;
              end
              else
                inc(i);
            end;
            // add new songs
            for i := 0 to Playlist.Count - 1 do
            begin
              Song := Playlist.GetSongAt(i);
              if not CurrentSongsListNotFiltered.HasSong(Song) then
              begin
                CurrentSongsListNotFiltered.Add(Song);
                GlobalPlaylistHasChanged := true;
              end;
            end;
          end;
          // refresh the vue if any change to global playlist
          if GlobalPlaylistHasChanged then
            RefreshListView;
        end;
      end;
    end);
end;

procedure TfrmMain.tbVolumeTracking(Sender: TObject);
var
  Volume: integer;
begin
  Volume := trunc(tbVolume.Value);
  MusicPlayer.Volume := Volume;
  TConfig.Current.Volume := Volume;
end;

procedure TfrmMain.timerIsSongFinishedTimer(Sender: TObject);
var
  Song: TSong;
begin
  if not assigned(PlayedSong) then
    exit;

  if FStopTimer > 0 then
  begin
    FStopTimer := FStopTimer - 1;
    exit;
  end;

  if not MusicPlayer.isPlaying then // Music has finished
  begin
    if (cbRepeatCurrentSong.IsChecked) then
    begin
      Song := PlayedSong;
      PlayedSong := nil;
      PlayedSong := Song;
    end
    else
      PlayNextSong(cbPlayNextRandom.IsChecked);
  end
  else if cbPlayIntro.IsChecked and
    (MusicPlayer.CurrentTimeInSeconds > TConfig.Current.PlayIntroDuration) then
    MusicPlayer.Stop;
end;

procedure TfrmMain.UpdatePlayPauseButton;
var
  Song: TSong;
begin
  Song := GetPreviousSong;
  btnPrevious.enabled := assigned(Song);
  btnPlay.enabled := ((not assigned(ListView1.Selected)) and
    (ListView1.Items.Count > 0)) or
    (assigned(ListView1.Selected) and (ListView1.Selected.TagObject <>
    PlayedSong));
  btnPause.enabled := assigned(PlayedSong);
  btnPause.IsPressed := btnPause.enabled and MusicPlayer.isPaused;
  btnStop.enabled := assigned(PlayedSong);
  Song := GetNextSong;
  btnNext.enabled := assigned(Song);
end;

initialization

{$IFDEF DEBUG}
// ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
  TDialogService.PreferredMode := TDialogService.TPreferredMode.Sync;
randomize;

globalusemetal := true;

end.
