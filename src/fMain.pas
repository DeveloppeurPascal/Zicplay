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
  TForm1 = class(TForm)
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
  private
    FPlayedSong: TSong;
    FDefaultCaption: string;
    FCurrentSongsList: TSongList;
    FCurrentSongsListNotFiltered: TSongList;
    procedure SetPlayedSong(const Value: TSong);
    procedure SetCurrentSongsList(const Value: TSongList);
    { Déclarations privées }
    procedure RefreshListView;
    function SubscribeToZicPlayMessage(AItem: TListviewItem): integer;
    procedure SetCurrentSongsListNotFiltered(const Value: TSongList);
    procedure ConnectorMenuClick(Sender: TObject);
  public
    { Déclarations publiques }
    property PlayedSong: TSong read FPlayedSong write SetPlayedSong;
    property CurrentSongsList: TSongList read FCurrentSongsList
      write SetCurrentSongsList;
    property CurrentSongsListNotFiltered: TSongList
      read FCurrentSongsListNotFiltered write SetCurrentSongsListNotFiltered;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.IOUtils,
  System.Messaging,
  Gamolf.FMX.MusicLoop;

function ReverseString(From: string): string;
// TODO : for dev tests only, remove it
begin
  result := '';
  for var i := length(From) - 1 downto 0 do
    result := result + From.Chars[i];
end;

Type
  TZicPlayMessage = TMessage<TSong>;

procedure TForm1.actAboutExecute(Sender: TObject);
begin
  AboutDialog.Execute;
end;

procedure TForm1.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TForm1.actOptionsExecute(Sender: TObject);
begin
  showmessage('No option dialog in this release.');
  // TODO : à compléter
{$MESSAGE warn 'todo'}
end;

procedure TForm1.btnLoadMP3ListClick(Sender: TObject);
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
  songlist: TSongList;
begin
  btnLoadMP3List.Visible := false;

  songlist := TSongList.Create;
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
        song.SongSource := nil;
        song.FileName := files[i];
        song.onGetFilename := nil;

        songlist.Add(song);
      end;

    case cbSortList.ItemIndex of
      0: // sort by title
        songlist.SortByTitle;
      1: // sort by artist
        songlist.SortByArtist;
      2: // sort by album
        songlist.SortByAlbum;
      3: // sort by category + album
        songlist.SortByCategoryAlbum;
      4: // sort by caterogy + Title
        songlist.SortByCategoryTitle;
      -1: // do nothing
        ;
    else
      raise exception.Create('I don''t know how to sort this list !');
    end;

  except
    songlist.Free;
    raise;
  end;

  CurrentSongsListNotFiltered := nil;
  CurrentSongsListNotFiltered := songlist;
end;

procedure TForm1.cbSortListChange(Sender: TObject);
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

  RefreshListView; // TODO : replace by a message or event from the songlist
end;

procedure TForm1.ClearEditButton1Click(Sender: TObject);
begin
  edtSearch.Text := '';
  SearchEditButton1Click(Self);
end;

procedure TForm1.ConnectorMenuClick(Sender: TObject);
var
  sst: ISongSourceType;
begin
  if (Sender is TMenuItem) and not(Sender as TMenuItem).Tagstring.IsEmpty then
  begin
    sst := TSongSourcetypeList.Current.SourceTypeFromUID
      ((Sender as TMenuItem).Tagstring);
    if assigned(sst) and sst.hasConnectorSetupDialog then
      sst.ConnectorSetupDialog;
  end;
end;

procedure TForm1.edtSearchKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkreturn then
    SearchEditButton1Click(Self)
  else if Key = vkEscape then
    ClearEditButton1Click(Self);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
  mnu: TMenuItem;
  sstl: TSongSourcetypeList;
  sst: ISongSourceType;
begin
  // TODO : load program parameters

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
  sstl := TSongSourcetypeList.Current;
  sstl.Sort;
  for i := 0 to sstl.Count - 1 do
  begin
    sst := sstl.SourceTypeAt(i);
    if sst.hasConnectorSetupDialog then
    begin
      mnu := TMenuItem.Create(Self);
      mnu.Parent := mnuOptions;
      mnu.Text := sst.getName;
      mnu.OnClick := ConnectorMenuClick;
      mnu.Tagstring := sst.getUniqID;
      if not mnuOptions.Visible then
        mnuOptions.Visible := true;
    end;
  end;

  caption := AboutDialog.Titre + ' ' + AboutDialog.VersionNumero;
{$IFDEF DEBUG}
  caption := caption + ' [DEBUG MODE]';
{$ENDIF}
  FDefaultCaption := caption;

  TMessageManager.DefaultManager.SubscribeToMessage(TZicPlayMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TZicPlayMessage;
    begin
      if (M is TZicPlayMessage) then
      begin
        msg := M as TZicPlayMessage;
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

procedure TForm1.ListView1ButtonClick(const Sender: TObject;
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

procedure TForm1.RefreshListView;
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
        TMessageManager.DefaultManager.Unsubscribe(TZicPlayMessage,
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

procedure TForm1.SearchEditButton1Click(Sender: TObject);
var
  songlist: TSongList;
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
    songlist := TSongList.Create;
    try
      for i := 0 to CurrentSongsListNotFiltered.Count - 1 do
      begin
        // TODO : change filtering method (case sensitive, keyword or full text, choose on what property, ...)
        song := CurrentSongsListNotFiltered[i];
        if song.TitleLowerCase.Contains(FindText) or
          song.ArtistLowerCase.Contains(FindText) or
          song.AlbumLowerCase.Contains(FindText) or
          song.CategoryLowerCase.Contains(FindText) then
          songlist.Add(song);
      end;

      CurrentSongsList := nil;
      CurrentSongsList := songlist;
    except
      songlist.Free;
      raise;
    end;
  end;
end;

procedure TForm1.SetCurrentSongsList(const Value: TSongList);
begin
  if (Value = nil) and (FCurrentSongsList <> FCurrentSongsListNotFiltered) then
    FCurrentSongsList.Free;

  if (FCurrentSongsList <> Value) then
  begin
    FCurrentSongsList := Value;
    RefreshListView;
  end;
end;

procedure TForm1.SetCurrentSongsListNotFiltered(const Value: TSongList);
begin
  if (FCurrentSongsListNotFiltered <> Value) then
  begin
    FCurrentSongsListNotFiltered := Value;
    CurrentSongsList := FCurrentSongsListNotFiltered;
  end;
end;

procedure TForm1.SetPlayedSong(const Value: TSong);
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
      TZicPlayMessage.Create(FPlayedSong));
  end;
end;

function TForm1.SubscribeToZicPlayMessage(AItem: TListviewItem): integer;
begin
  result := TMessageManager.DefaultManager.SubscribeToMessage(TZicPlayMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TZicPlayMessage;
    begin
      if (M is TZicPlayMessage) then
      begin
        msg := M as TZicPlayMessage;
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
              TMessageManager.DefaultManager.Unsubscribe(TZicPlayMessage,
                AItem.Tag, true);
              AItem.Tag := 0;
            end);
        end;
      end;
    end);
end;

procedure TForm1.timerIsSongFinishedTimer(Sender: TObject);
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

end.
