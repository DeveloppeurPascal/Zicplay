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
  FMX.Layouts;

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
  private
    FPlayedSong: TSong;
    FDefaultCaption: string;
    FCurrentSongsList: TPlaylist;
    FCurrentSongsListNotFiltered: TPlaylist;
    procedure SetPlayedSong(const Value: TSong);
    procedure SetCurrentSongsList(const Value: TPlaylist);
    { Déclarations privées }
    procedure RefreshListView;
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
    Procedure PlayNextSong;
    function GetPreviousSong: TSong;
    procedure PlayPreviousSong;
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

procedure TfrmMain.btnNextClick(Sender: TObject);
begin
  PlayNextSong;
end;

procedure TfrmMain.btnPauseClick(Sender: TObject);
begin
  if assigned(PlayedSong) then
    MusicLoop.Pause;
end;

procedure TfrmMain.btnPlayClick(Sender: TObject);
begin
  if assigned(ListView1.Selected) and
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
  cb: tcheckbox;
begin
  TConfig.Current.LoadFromFile;

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
        mnuConnectors.Text := 'Connectors'; // TODO : à traduire
      end;
      mnu := TMenuItem.Create(Self);
      mnu.Parent := mnuConnectors;
      mnu.Text := Connector.getName;
      mnu.OnClick := ConnectorMenuClick;
      mnu.Tagstring := Connector.getUniqID;
    end;
  end;

  mvPlaylists.Visible := TConfig.Current.mvPlaylistsVisible;

  mnuPlaylistSeparator.Visible := (TConfig.Current.Playlists.Count > 0);
  for i := 0 to TConfig.Current.Playlists.Count - 1 do
  begin
    mnu := TMenuItem.Create(Self);
    mnu.Parent := mnuPlaylist;
    mnu.Text := TConfig.Current.Playlists[i].Text;
    mnu.IsChecked := TConfig.Current.Playlists[i].enabled;
    mnu.OnClick := PlaylistMenuClick;
    mnu.TagObject := TConfig.Current.Playlists[i];

    cb := tcheckbox.Create(Self);
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

    if TConfig.Current.Playlists[i].enabled then
      TConfig.Current.Playlists[i].RefreshSongsList(
        procedure(APlaylist: TPlaylist)
        var
          i: integer;
        begin
          for i := 0 to APlaylist.Count - 1 do
            CurrentSongsListNotFiltered.Add(APlaylist.GetSongAt(i));
          RefreshListView;
        end);
  end;
  SubscribeToNewPlaylistMessage;
  SubscribeToPlaylistUpdatedMessage;

  caption := AboutDialog.Titre + ' ' + AboutDialog.VersionNumero;
{$IFDEF DEBUG}
  caption := caption + ' [DEBUG MODE]';
{$ENDIF}
  FDefaultCaption := caption;

  lblSongPlayed.Text := '';
  SubscribeToNowPlayingMessage;

  edtSearch.Text := '';
  edtSearch.Tagstring := '';

  UpdatePlayPauseButton;

  tbVolume.Value := MusicLoop.Volume;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
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
  SongIndex := -1;
  for i := 0 to CurrentSongsList.Count - 1 do
    if CurrentSongsList.GetSongAt(i) = PlayedSong then
    begin
      SongIndex := i;
      break;
    end;
  if (SongIndex >= 0) and (SongIndex + 1 < CurrentSongsList.Count) then
    result := CurrentSongsList.GetSongAt(SongIndex + 1)
  else
    // TODO : if REPEAT ALL is selected, choose first song of the list
    result := nil;
end;

function TfrmMain.GetPreviousSong: TSong;
var
  i, SongIndex: integer;
begin
  SongIndex := -1;
  for i := 0 to CurrentSongsList.Count - 1 do
    if CurrentSongsList.GetSongAt(i) = PlayedSong then
    begin
      SongIndex := i;
      break;
    end;
  if (SongIndex > 0) and (SongIndex < CurrentSongsList.Count) then
    result := CurrentSongsList.GetSongAt(SongIndex - 1)
  else
    // TODO : if REPEAT ALL is selected, choose last song of the list
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

procedure TfrmMain.PlaylistEnableChange(Sender: TObject);
var
  cb: tcheckbox;
  Playlist: TPlaylist;
begin
  if (Sender is tcheckbox) then
    cb := Sender as tcheckbox
  else
    exit;

  if assigned(cb.TagObject) and (cb.TagObject is TPlaylist) then
    Playlist := cb.TagObject as TPlaylist
  else
    exit;

  Playlist.enabled := cb.IsChecked;
  TMessageManager.DefaultManager.SendMessage(Self,
    TPlaylistUpdatedMessage.Create(Playlist));
  // TODO : refresh global playlist content avec on screen listview
end;

procedure TfrmMain.PlaylistMenuClick(Sender: TObject);
begin
  if (Sender is TMenuItem) and ((Sender as TMenuItem).TagObject is TPlaylist)
  then
    TfrmPlaylist.Execute((Sender as TMenuItem).TagObject as TPlaylist)
  else
    raise exception.Create('No playlist to setup !');
end;

procedure TfrmMain.PlayNextSong;
var
  Song: TSong;
  i: integer;
begin
  Song := GetNextSong;
  if assigned(Song) then
  begin
    for i := 0 to ListView1.items.Count - 1 do
      if ListView1.items[i].TagObject = Song then
      begin
        ListView1ButtonClick(ListView1, ListView1.items[i], nil);
        break;
      end;
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
    for i := 0 to ListView1.items.Count - 1 do
      if ListView1.items[i].TagObject = Song then
      begin
        ListView1ButtonClick(ListView1, ListView1.items[i], nil);
        break;
      end;
  end
  else
    PlayedSong := nil;
end;

procedure TfrmMain.RefreshListView;
var
  item: TListViewItem;
  i: integer;
  Song: TSong;
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
      Song := CurrentSongsList.GetSongAt(i);
      item := ListView1.items.Add;
      try
        item.Text := Song.Title;
        item.Detail := Song.Artist + ' / ' + Song.Album;
        // song.FileName;
        item.TagObject := Song;
        if (Song = PlayedSong) then
        begin
          item.ButtonText := 'Pause';
          item.Tag := SubscribeToNowPlayingMessage(item);
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
  UpdatePlayPauseButton;
end;

procedure TfrmMain.SearchEditButton1Click(Sender: TObject);
var
  Playlist: TPlaylist;
  i: integer;
  Song: TSong;
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
        Song := CurrentSongsListNotFiltered.GetSongAt(i);
        if Song.TitleLowerCase.Contains(FindText) or
          Song.ArtistLowerCase.Contains(FindText) or
          Song.AlbumLowerCase.Contains(FindText) or
          Song.CategoryLowerCase.Contains(FindText) then
          Playlist.Add(Song);
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

procedure TfrmMain.SubscribeToNewPlaylistMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TNewPlaylistMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TNewPlaylistMessage;
      mnu: TMenuItem;
      cb: tcheckbox;
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

          cb := tcheckbox.Create(Self);
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

          if Playlist.enabled then
            Playlist.RefreshSongsList(
              procedure(APlaylist: TPlaylist)
              var
                i: integer;
              begin
                for i := 0 to APlaylist.Count - 1 do
                  CurrentSongsListNotFiltered.Add(APlaylist.GetSongAt(i));
                RefreshListView;
              end);
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

procedure TfrmMain.SubscribeToPlaylistUpdatedMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TPlaylistUpdatedMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TPlaylistUpdatedMessage;
      mnu: TMenuItem;
      cb: tcheckbox;
      i: integer;
      Playlist: TPlaylist;
    begin
      if (M is TPlaylistUpdatedMessage) then
      begin
        msg := M as TPlaylistUpdatedMessage;
        if assigned(msg.Value) then
        begin
          Playlist := msg.Value;

          if (mnuPlaylist.itemsCount > 0) then
            for i := 0 to mnuPlaylist.itemsCount - 1 do
              if (mnuPlaylist.items[i] is TMenuItem) then
              begin
                mnu := mnuPlaylist.items[i] as TMenuItem;
                if assigned(mnu.TagObject) and (mnu.TagObject is TPlaylist) and
                  (Playlist = (mnu.TagObject as TPlaylist)) then
                begin
                  mnu.Text := Playlist.Text;
                  mnu.IsChecked := Playlist.enabled;
                end;
              end;

          if (mvPlaylistsArea.Content.ChildrenCount > 0) then
            for i := 0 to mvPlaylistsArea.Content.ChildrenCount - 1 do
              if (mvPlaylistsArea.Content.Children[i] is tcheckbox) then
              begin
                cb := mvPlaylistsArea.Content.Children[i] as tcheckbox;
                if assigned(cb.TagObject) and (cb.TagObject is TPlaylist) and
                  (Playlist = (cb.TagObject as TPlaylist)) then
                begin
                  cb.Text := Playlist.Text;
                  cb.IsChecked := Playlist.enabled;
                end;
              end;

          if Playlist.enabled then
            Playlist.RefreshSongsList(
              procedure(APlaylist: TPlaylist)
              var
                i: integer;
              begin
                for i := 0 to APlaylist.Count - 1 do
                  CurrentSongsListNotFiltered.Add(APlaylist.GetSongAt(i));
                RefreshListView;
              end)
          else
          begin
            i := 0;
            while (i < CurrentSongsListNotFiltered.Count) do
              if CurrentSongsListNotFiltered.GetSongAt(i).Playlist = Playlist
              then
                CurrentSongsListNotFiltered.delete(i)
              else
                inc(i);
            RefreshListView;
          end;
        end;
      end;
    end);
end;

procedure TfrmMain.tbVolumeTracking(Sender: TObject);
begin
  MusicLoop.Volume := trunc(tbVolume.Value);
end;

procedure TfrmMain.timerIsSongFinishedTimer(Sender: TObject);
begin
  if not assigned(PlayedSong) then
    exit;

  if not MusicLoop.isPlaying then // Music has finished
  begin
    // TODO : if REPEAT 1 is selected, replay the song
    PlayNextSong;
  end;
end;

procedure TfrmMain.UpdatePlayPauseButton;
var
  Song: TSong;
begin
  Song := GetPreviousSong;
  btnPrevious.enabled := assigned(Song);
  btnPlay.enabled := assigned(ListView1.Selected) and
    (ListView1.Selected.TagObject <> PlayedSong);
  btnPause.enabled := assigned(PlayedSong);
  btnPause.IsPressed := btnPause.enabled and MusicLoop.isPaused;
  btnStop.enabled := assigned(PlayedSong);
  Song := GetNextSong;
  btnNext.enabled := assigned(Song);
end;

initialization

{$IFDEF DEBUG}
// ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
  TDialogService.PreferredMode := TDialogService.TPreferredMode.Sync;

end.
