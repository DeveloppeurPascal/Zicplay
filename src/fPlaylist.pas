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
/// File last update : 2024-09-01T15:23:46.000+02:00
/// Signature : 82112411350a975ccd6f2d3c949c40220dee52c5
/// ***************************************************************************
/// </summary>

unit fPlaylist;

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
  FMX.Edit,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Layouts,
  System.JSON,
  Zicplay.Types,
  System.Messaging;

type
  TfrmPlaylist = class(TForm)
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout1: TGridPanelLayout;
    btnSave: TButton;
    btnCancel: TButton;
    lblPlaylistName: TLabel;
    edtPlaylistName: TEdit;
    lblConnector: TLabel;
    edtConnector: TEdit;
    btnConnectorSelect: TButton;
    btnConnectorSetup: TButton;
    cbEnabled: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnConnectorSelectClick(Sender: TObject);
    procedure btnConnectorSetupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fPlaylist: tplaylist;
    fPlaylistConnector: IConnector;
    fPlaylistParams: TJSONObject;
    FNeedAPlaylistRefresh: boolean;
    procedure SetPlaylistConnector(const Value: IConnector);
    procedure SetPlaylistName(const Value: string);
    procedure SetPlaylist(const Value: tplaylist);
  protected
    procedure DoTranslateTexts(const Sender: TObject; const Msg: TMessage);
    procedure DoShow; override;
    procedure DoHide; override;
  public
    property PlaylistName: string write SetPlaylistName;
    property PlaylistConnector: IConnector write SetPlaylistConnector;
    property Playlist: tplaylist write SetPlaylist;
    class procedure Execute(APlaylist: tplaylist);
    destructor Destroy; override;
    /// <summary>
    /// This method is called each time a global translation broadcast is sent
    /// with current language as argument.
    /// </summary>
    procedure TranslateTexts(const Language: string); virtual;
  end;

implementation

{$R *.fmx}

uses
  Zicplay.Config,
  fSelectConnector,
  uTranslate,
  uConfig;

procedure TfrmPlaylist.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmPlaylist.btnConnectorSelectClick(Sender: TObject);
begin
  TfrmSelectConnector.Execute(
    procedure(AConnector: IConnector)
    begin
      if assigned(AConnector) then
        PlaylistConnector := AConnector;
    end);
end;

procedure TfrmPlaylist.btnConnectorSetupClick(Sender: TObject);
begin
  if fPlaylistConnector.hasPlaylistSetupDialog then
    fPlaylistConnector.PlaylistSetupDialog(fPlaylistParams,
      procedure
      begin
        FNeedAPlaylistRefresh := true;
      end)
  else
    raise exception.Create('No setup dialog for this connector.');
end;

procedure TfrmPlaylist.btnSaveClick(Sender: TObject);
var
  InsertMode: boolean;
begin
  edtPlaylistName.Text := edtPlaylistName.Text.Trim;
  if edtPlaylistName.Text.IsEmpty then
  begin
    edtPlaylistName.setfocus;
    raise exception.Create('Each playlist needs a name.');
  end;

  if not assigned(fPlaylistConnector) then
  begin
    btnConnectorSelect.setfocus;
    raise exception.Create('Choose a connector before saving this playlist.');
  end;

  InsertMode := not assigned(fPlaylist);
  if InsertMode then
    fPlaylist := tplaylist.Create;

  if assigned(fPlaylist) then
  begin
    fPlaylist.Text := edtPlaylistName.Text;
    fPlaylist.Enabled := cbEnabled.IsChecked;
    fPlaylist.Connector := fPlaylistConnector;
    fPlaylist.ConnectorParams.Free;
    fPlaylist.ConnectorParams := TJSONObject.ParseJSONValue
      (fPlaylistParams.ToJSON) as TJSONObject;

    if InsertMode then
      TzpConfig.Current.Playlists.Add(fPlaylist);

    TzpConfig.Current.SaveTofile;

    if FNeedAPlaylistRefresh then
      fPlaylist.RefreshSongsList(true)
    else
      TPlaylistupdatedMessage.Broadcast(fPlaylist);
  end;

  close;
end;

destructor TfrmPlaylist.Destroy;
begin
  fPlaylistParams.Free;
  inherited;
end;

procedure TfrmPlaylist.DoHide;
begin
  inherited;
  TMessageManager.DefaultManager.Unsubscribe(TTranslateTextsMessage,
    DoTranslateTexts, true);
end;

procedure TfrmPlaylist.DoShow;
begin
  inherited;
  TranslateTexts(tconfig.Current.Language);
  TMessageManager.DefaultManager.SubscribeToMessage(TTranslateTextsMessage,
    DoTranslateTexts);
end;

procedure TfrmPlaylist.DoTranslateTexts(const Sender: TObject;
const Msg: TMessage);
begin
  if not assigned(Self) then
    exit;

  if assigned(Msg) and (Msg is TTranslateTextsMessage) then
    TranslateTexts((Msg as TTranslateTextsMessage).Language);
end;

class procedure TfrmPlaylist.Execute(APlaylist: tplaylist);
var
  f: TfrmPlaylist;
begin
  f := TfrmPlaylist.Create(nil);
  f.Playlist := APlaylist;
{$IF Defined(ANDROID) or Defined(IOS)}
  f.show;
{$ELSE}
  f.showmodal;
{$ENDIF}
end;

procedure TfrmPlaylist.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tthread.ForceQueue(nil,
    procedure
    begin
      Self.Free;
    end);
end;

procedure TfrmPlaylist.FormCreate(Sender: TObject);
begin
  Playlist := nil;
  FNeedAPlaylistRefresh := false;
end;

procedure TfrmPlaylist.SetPlaylist(const Value: tplaylist);
begin
  fPlaylist := Value;
  if assigned(fPlaylist) then
  begin
    PlaylistName := fPlaylist.Text;
    cbEnabled.IsChecked := fPlaylist.Enabled;
    PlaylistConnector := fPlaylist.Connector;
    fPlaylistParams := TJSONObject.ParseJSONValue
      (fPlaylist.ConnectorParams.ToJSON) as TJSONObject;
  end
  else
  begin
    PlaylistName := '';
    cbEnabled.IsChecked := true;
    PlaylistConnector := nil;
    fPlaylistParams.Free;
    fPlaylistParams := TJSONObject.Create;
  end;
end;

procedure TfrmPlaylist.SetPlaylistConnector(const Value: IConnector);
begin
  edtConnector.ReadOnly := true;
  if assigned(Value) then
  begin
    edtConnector.Text := Value.getName;
    btnConnectorSelect.Enabled := false;
    edtConnector.Enabled := false; // disable the select button too
    btnConnectorSetup.Enabled := Value.hasPlaylistSetupDialog;
    fPlaylistConnector := Value;
  end
  else
  begin
    edtConnector.Text := '';
    btnConnectorSelect.Enabled := true;
    btnConnectorSetup.Enabled := false;
    fPlaylistConnector := nil;
  end;
end;

procedure TfrmPlaylist.SetPlaylistName(const Value: string);
begin
  edtPlaylistName.Text := Value;
end;

procedure TfrmPlaylist.TranslateTexts(const Language: string);
begin
  // TODO : add texts translation here !
end;

end.
