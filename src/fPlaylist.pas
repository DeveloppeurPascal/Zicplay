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
  Zicplay.Types;

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
    { Déclarations privées }
  public
    { Déclarations publiques }
    property PlaylistName: string write SetPlaylistName;
    property PlaylistConnector: IConnector write SetPlaylistConnector;
    property Playlist: tplaylist write SetPlaylist;
    class procedure Execute(APlaylist: tplaylist);
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

uses
  System.Messaging,
  ZicPlay.Config,
  fSelectConnector;

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
      TMessageManager.DefaultManager.SendMessage(Self,
        TPlaylistupdatedMessage.Create(fPlaylist));
  end;

  close;
end;

destructor TfrmPlaylist.Destroy;
begin
  fPlaylistParams.Free;
  inherited;
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

end.
