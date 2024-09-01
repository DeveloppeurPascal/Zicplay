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
  FMX.MultiView,
  FMX.Layouts,
  Gamolf.FMX.MusicLoop,
  System.Messaging;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    mnuMacOS: TMenuItem;
    mnuFile: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    mnuFileQuit: TMenuItem;
    mnuTools: TMenuItem;
    mnuToolsOptions: TMenuItem;
    ActionList1: TActionList;
    actAbout: TAction;
    actQuit: TAction;
    actToolsOptions: TAction;
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
    procedure actQuitExecute(Sender: TObject);
    procedure actToolsOptionsExecute(Sender: TObject);
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
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
  private
    FPlayedSong: TSong;
    FCurrentSongsList: TPlaylist;
    FCurrentSongsListNotFiltered: TPlaylist;
    FStopTimer: integer;
    MusicPlayer: TMusicLoop;
    procedure SetPlayedSong(const Value: TSong);
    procedure SetCurrentSongsList(const Value: TPlaylist);
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
  protected
    procedure DoTranslateTexts(const Sender: TObject; const Msg: TMessage);
    procedure DoShow; override;
    procedure DoHide; override;
    /// <summary>
    /// Show/hide TMainMenu items depending on there sub menus items visibility
    /// </summary>
    procedure RefreshMenuItemsVisibility(const Menu: TMainMenu);
      overload; virtual;
    /// <summary>
    /// Show/hide a TMenuItem depending on its sub menus items visibility
    /// </summary>
    function RefreshMenuItemsVisibility(const MenuItem: TMenuItem;
      const FirstLevel: boolean): boolean; overload; virtual;
  public
    property PlayedSong: TSong read FPlayedSong write SetPlayedSong;
    property CurrentSongsList: TPlaylist read FCurrentSongsList
      write SetCurrentSongsList;
    property CurrentSongsListNotFiltered: TPlaylist
      read FCurrentSongsListNotFiltered write SetCurrentSongsListNotFiltered;
    /// <summary>
    /// This method is called each time a global translation broadcast is sent
    /// with current language as argument.
    /// </summary>
    procedure TranslateTexts(const Language: string); virtual;
    procedure AfterConstruction; override;
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
  u_urlOpen,
  Zicplay.Config,
  fPlaylist,
  uDMAboutBox,
  uConsts,
  uTranslate,
  uConfig,
  uStyleManager;

procedure TfrmMain.AboutDialogURLClick(const AURL: string);
begin
  if AURL.IsEmpty then
    exit;

  url_Open_In_Browser(AURL);
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  TAboutBox.Current.ShowModal;
end;

procedure TfrmMain.actQuitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actToolsOptionsExecute(Sender: TObject);
begin
  showmessage('No option dialog in this release.');
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TfrmMain.AfterConstruction;
begin
  inherited;
{$IFDEF MACOS}
  mnuFileQuit.Visible := false;
  mnuHelpAbout.parent := mnuMacOS;
{$ENDIF}
  RefreshMenuItemsVisibility(MainMenu1);

{$IFDEF MACOS}
  TThread.ForceQueue(nil,
    procedure
    begin
      TProjectStyle.Current.EnableDefaultStyle;
    end);
{$ELSE}
  TProjectStyle.Current.EnableDefaultStyle;
{$ENDIF}
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
  TZPConfig.Current.PlayIntro := cbPlayIntro.IsChecked;
end;

procedure TfrmMain.cbPlayNextRandomChange(Sender: TObject);
begin
  TZPConfig.Current.PlayNextRandom := cbPlayNextRandom.IsChecked;
end;

procedure TfrmMain.cbRepeatAllChange(Sender: TObject);
begin
  TZPConfig.Current.PlayRepeatAll := cbRepeatAll.IsChecked;
  UpdatePlayPauseButton;
end;

procedure TfrmMain.cbRepeatCurrentSongChange(Sender: TObject);
begin
  TZPConfig.Current.PlayRepeatOne := cbRepeatCurrentSong.IsChecked;
end;

procedure TfrmMain.cbSortListChange(Sender: TObject);
begin
  RefreshListView;
end;

procedure TfrmMain.ClearEditButton1Click(Sender: TObject);
begin
  edtSearch.Text := '';
  TZPConfig.Current.FilterText := '';
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

procedure TfrmMain.DoHide;
begin
  inherited;
  TMessageManager.DefaultManager.Unsubscribe(TTranslateTextsMessage,
    DoTranslateTexts, true);
end;

procedure TfrmMain.DoShow;
begin
  inherited;
  TranslateTexts(tconfig.Current.Language);
  TMessageManager.DefaultManager.SubscribeToMessage(TTranslateTextsMessage,
    DoTranslateTexts);
end;

procedure TfrmMain.DoTranslateTexts(const Sender: TObject; const Msg: TMessage);
begin
  if not assigned(self) then
    exit;

  if assigned(Msg) and (Msg is TTranslateTextsMessage) then
    TranslateTexts((Msg as TTranslateTextsMessage).Language);
end;

procedure TfrmMain.edtSearchKeyDown(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkreturn then
    SearchEditButton1Click(self)
  else if Key = vkEscape then
    ClearEditButton1Click(self);
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
  if TZPConfig.Current.hasConfigChanged then
    TZPConfig.Current.SaveTofile;

  tparallel.For(0, TZPConfig.Current.Playlists.Count - 1,
    procedure(i: integer)
    begin
      if TZPConfig.Current.Playlists[i].hasChanged then
        TZPConfig.Current.Playlists[i].Save;
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
  TZPConfig.Current.LoadFromFile;

  MusicPlayer := TMusicLoop.Create;

  lblSongPlayed.Text := '';
  lblNbSongs.Text := '';

  edtSearch.Text := TZPConfig.Current.FilterText;
  cbSortList.ItemIndex := TZPConfig.Current.SortType;
  tbVolume.Value := TZPConfig.Current.Volume;
  MusicPlayer.Volume := TZPConfig.Current.Volume;
  // TODO : changing the musicloop volume does nothing until the first song is played
  cbRepeatAll.IsChecked := TZPConfig.Current.PlayRepeatAll;
  cbRepeatCurrentSong.IsChecked := TZPConfig.Current.PlayRepeatOne;
  cbPlayIntro.IsChecked := TZPConfig.Current.PlayIntro;
  cbPlayNextRandom.IsChecked := TZPConfig.Current.PlayNextRandom;

  FCurrentSongsList := nil;
  CurrentSongsListNotFiltered := TPlaylist.Create;

{$IF Defined(ANDROID) or Defined(IOS)}
  MainMenu1.Visible := false;
{$ENDIF}
  mnuToolsOptions.Visible := false;
  // TODO : à réactiver lorsque l'option sera disponible

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
        mnuConnectors := TMenuItem.Create(self);
        mnuConnectors.parent := mnuTools;
        mnuConnectors.Text := 'Connectors'; // TODO : à traduire
      end;
      mnu := TMenuItem.Create(self);
      mnu.parent := mnuConnectors;
      mnu.Text := Connector.getName;
      mnu.OnClick := ConnectorMenuClick;
      mnu.Tagstring := Connector.getUniqID;
    end;
  end;

  if TZPConfig.Current.mvPlaylistsVisible then
    mvPlaylists.ShowMaster
  else
    mvPlaylists.HideMaster;

  mnuPlaylistSeparator.Visible := (TZPConfig.Current.Playlists.Count > 0);
  for i := 0 to TZPConfig.Current.Playlists.Count - 1 do
  begin
    mnu := TMenuItem.Create(self);
    mnu.parent := mnuPlaylist;
    mnu.Text := TZPConfig.Current.Playlists[i].Text;
    mnu.IsChecked := TZPConfig.Current.Playlists[i].enabled;
    mnu.OnClick := PlaylistMenuClick;
    mnu.TagObject := TZPConfig.Current.Playlists[i];

    cb := TCheckBox.Create(self);
    cb.parent := mvPlaylistsArea;
    cb.Align := talignlayout.Top;
    cb.Text := TZPConfig.Current.Playlists[i].Text;
    cb.IsChecked := TZPConfig.Current.Playlists[i].enabled;
    cb.OnChange := PlaylistEnableChange;
    cb.TagObject := TZPConfig.Current.Playlists[i];
    cb.Margins.Top := 10;
    cb.Margins.right := 10;
    cb.Margins.Bottom := 10;
    cb.Margins.Left := 10;
  end;
  SubscribeToNewPlaylistMessage;
  SubscribeToPlaylistUpdatedMessage;

  TThread.ForceQueue(nil,
    procedure
    begin
      tparallel.For(0, TZPConfig.Current.Playlists.Count - 1,
        procedure(i: integer)
        begin
          TZPConfig.Current.Playlists[i].RefreshSongsList;
        end);
    end);

  SubscribeToNowPlayingMessage;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: integer;
      Song: TSong;
    begin
      sleep(1000);
      exit;
      // duration not initialized for macOS before playing the file
      // it works on Windows for refresh the list in background

      // TODO : optimize this code : don't loop undefinitly on the same list if nothing has changed
      // TODO : add a parameter to allow or not this feature (disable it in platforms not compatible like macOS)
      i := 0;
      while (not TThread.CheckTerminated) do
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
          TThread.Synchronize(nil,
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
    end)//.start;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  MusicPlayer.Free;
  CurrentSongsListNotFiltered.Free;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
var KeyChar: WideChar; Shift: TShiftState);
begin
  if CShowAboutBoxWithF1 and (KeyChar = #0) and (Key = vkF1) then
  begin
    Key := 0;
    TAboutBox.Current.ShowModal;
  end;
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
  TZPConfig.Current.mvPlaylistsVisible := false;
end;

procedure TfrmMain.mvPlaylistsShown(Sender: TObject);
begin
  TZPConfig.Current.mvPlaylistsVisible := true;
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
  TMessageManager.DefaultManager.SendMessage(self,
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

procedure TfrmMain.RefreshMenuItemsVisibility(const Menu: TMainMenu);
var
  i: integer;
begin
  if assigned(Menu) and (Menu.ItemsCount > 0) then
    for i := 0 to Menu.ItemsCount - 1 do
      if (Menu.Items[i] is TMenuItem) then
        (Menu.Items[i] as TMenuItem).Visible :=
          RefreshMenuItemsVisibility((Menu.Items[i] as TMenuItem), true);
end;

function TfrmMain.RefreshMenuItemsVisibility(const MenuItem: TMenuItem;
const FirstLevel: boolean): boolean;
var
  i: integer;
begin
  if assigned(MenuItem) then
  begin
    if (MenuItem.ItemsCount > 0) then
    begin
      result := false;
      for i := 0 to MenuItem.ItemsCount - 1 do
      begin
        MenuItem.Items[i].Visible := MenuItem.Items[i].Visible and
          RefreshMenuItemsVisibility(MenuItem.Items[i], false);
        result := result or MenuItem.Items[i].Visible;
      end;
    end
    else
      result := not FirstLevel;
  end
  else
    result := false;
end;

procedure TfrmMain.SearchEditButton1Click(Sender: TObject);
begin
  TZPConfig.Current.FilterText := edtSearch.Text;
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
      MusicPlayer.Volume := TZPConfig.Current.Volume;
    end;
    TMessageManager.DefaultManager.SendMessage(self,
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
  TZPConfig.Current.SortType := cbSortList.ItemIndex;
end;

procedure TfrmMain.SubscribeToNewPlaylistMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TNewPlaylistMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      Msg: TNewPlaylistMessage;
      mnu: TMenuItem;
      cb: TCheckBox;
      Playlist: TPlaylist;
    begin
      if (M is TNewPlaylistMessage) then
      begin
        Msg := M as TNewPlaylistMessage;
        if assigned(Msg.Value) then
        begin
          Playlist := Msg.Value;
          mnuPlaylistSeparator.Visible := true;
          mnu := TMenuItem.Create(self);
          mnu.parent := mnuPlaylist;
          mnu.Text := Playlist.Text;
          mnu.OnClick := PlaylistMenuClick;
          mnu.TagObject := Playlist;

          RefreshMenuItemsVisibility(MainMenu1);

          cb := TCheckBox.Create(self);
          cb.parent := mvPlaylistsArea;
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
      Msg: TNowPlayingMessage;
    begin
      if (M is TNowPlayingMessage) then
      begin
        Msg := M as TNowPlayingMessage;
        if assigned(Msg.Value) then
        begin
          lblSongPlayed.Text := 'Playing : ' + Msg.Value.Title;
          TAboutBox.Current.OlfAboutDialog1.MainFormCaptionPrefix :=
            Msg.Value.Title;
        end
        else
        begin
          lblSongPlayed.Text := '';
          TAboutBox.Current.OlfAboutDialog1.MainFormCaptionPrefix := '';
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
      Msg: TNowPlayingMessage;
    begin
      if (M is TNowPlayingMessage) then
      begin
        Msg := M as TNowPlayingMessage;
        // refresh current item in the TListView
        if assigned(AItem) and assigned(AItem.TagObject) and
          (AItem.TagObject is TSong) then
          RefreshListItem(AItem, AItem.TagObject as TSong);
        // update item's button text
        if Msg.Value = AItem.TagObject then
          AItem.ButtonText := 'Stop'
        else
        begin
          AItem.ButtonText := 'Play';
          // access violation on Mac after Unsubscribe
          // => using ForceQueue may fix the bug
          TThread.ForceQueue(nil,
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
      Msg: TPlaylistUpdatedMessage;
      mnu: TMenuItem;
      cb: TCheckBox;
      i: integer;
      Playlist: TPlaylist;
      GlobalPlaylistHasChanged: boolean;
      Song: TSong;
    begin
      if (M is TPlaylistUpdatedMessage) then
      begin
        Msg := M as TPlaylistUpdatedMessage;
        if assigned(Msg.Value) then
        begin
          Playlist := Msg.Value;

          if (mnuPlaylist.ItemsCount > 0) then
            for i := 0 to mnuPlaylist.ItemsCount - 1 do
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
  TZPConfig.Current.Volume := Volume;
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
    (MusicPlayer.CurrentTimeInSeconds > TZPConfig.Current.PlayIntroDuration)
  then
    MusicPlayer.Stop;
end;

procedure TfrmMain.TranslateTexts(const Language: string);
begin
  // TODO : add texts translation here !
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

TDialogService.PreferredMode := TDialogService.TPreferredMode.Sync;
randomize;

end.
