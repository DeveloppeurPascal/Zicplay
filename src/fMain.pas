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
  Zicplay.Types;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    AboutDialog: TOlfAboutDialog;
    PopupMenu1: TPopupMenu;
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
    procedure FormCreate(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure btnLoadMP3ListClick(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
  private
    FPlayedSong: TSong;
    procedure SetPlayedSong(const Value: TSong);
    { Déclarations privées }
  public
    { Déclarations publiques }
    property PlayedSong: TSong read FPlayedSong write SetPlayedSong;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.IOUtils,
  Gamolf.FMX.MusicLoop;

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
var
  i: integer;
  files: TStringDynArray;
  item: TListViewItem;
  song: TSong;
begin
  ListView1.Items.Clear;
  files := tdirectory.GetFiles(tpath.GetMusicPath);
  for i := 0 to length(files) - 1 do
    if (tpath.GetExtension(files[i]).ToLower = '.mp3') then
    begin
      song := TSong.Create;
      song.Title := tpath.GetFileNameWithoutExtension(files[i]);
      song.Artist := ''; // TODO : à compléter
      song.Album := ''; // TODO : à compléter
      song.Duration := 0; // TODO : à compléter
      song.PublishedDate := 2023; // TODO : à compléter
      song.Category := 'mp3'; // TODO : à compléter
      song.Order := 0; // TODO : à compléter
      song.UniqID := files[i];
      song.SongSource := nil;
      song.FileName := files[i];
      song.onGetFilename := nil;
      item := ListView1.Items.Add;
      item.Text := song.Title;
      item.Detail := song.FileName;
      item.TagObject := song;
      item.ButtonText := 'Play';
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
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
  caption := AboutDialog.Titre + ' ' + AboutDialog.VersionNumero;
{$IFDEF DEBUG}
  caption := caption + ' [DEBUG MODE]';
{$ENDIF}
end;

procedure TForm1.ListView1ButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
begin
  if assigned(AItem.TagObject) and (AItem.TagObject is TSong) then
    PlayedSong := AItem.TagObject as TSong;
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
      MusicLoop.Play(FPlayedSong.FileName);
    end;
  end;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
