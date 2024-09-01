unit ZicPlay.Connector.FileSystem.PlaylistSetupDialog;

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
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Controls.Presentation,
  System.Messaging;

type
  TPlaylistSetupDialogProc = reference to procedure(AFolder: string;
    AInSubFolders: Boolean);

  TfrmPlaylistSetupDialog = class(TForm)
    lblFolder: TLabel;
    edtSearchFolder: TEdit;
    lblInSubFolders: TLabel;
    VertScrollBox1: TVertScrollBox;
    swInSubFolders: TSwitch;
    btnFolderChoice: TButton;
    GridPanelLayout1: TGridPanelLayout;
    btnOk: TButton;
    btnCancel: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnFolderChoiceClick(Sender: TObject);
  private
    FonCloseProc: TPlaylistSetupDialogProc;
    FSearchInSubFolders: Boolean;
    FSearchFolder: string;
    procedure SetonCloseProc(const Value: TPlaylistSetupDialogProc);
    procedure SetSearchFolder(const Value: string);
    procedure SetSearchInSubFolders(const Value: Boolean);
  protected
    procedure DoTranslateTexts(const Sender: TObject; const Msg: TMessage);
    procedure DoShow; override;
    procedure DoHide; override;
  public
    property onCloseProc: TPlaylistSetupDialogProc read FonCloseProc
      write SetonCloseProc;
    property SearchFolder: string read FSearchFolder write SetSearchFolder;
    property SearchInSubFolders: Boolean read FSearchInSubFolders
      write SetSearchInSubFolders;
    class procedure Execute(AFolder: string; AInSubFolders: Boolean;
      ACallback: TPlaylistSetupDialogProc);
    /// <summary>
    /// This method is called each time a global translation broadcast is sent
    /// with current language as argument.
    /// </summary>
    procedure TranslateTexts(const Language: string); virtual;
  end;

implementation

{$R *.fmx}

uses
  System.IOUtils,
  uTranslate,
  uConfig;

{ TfrmPlaylistSetupDialog }

procedure TfrmPlaylistSetupDialog.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPlaylistSetupDialog.btnFolderChoiceClick(Sender: TObject);
begin
  OpenDialog1.FileName := '';
  if edtSearchFolder.Text.Trim.IsEmpty then
    OpenDialog1.InitialDir := tpath.GetDocumentsPath
  else
    OpenDialog1.InitialDir := edtSearchFolder.Text;
  if OpenDialog1.Execute then
    edtSearchFolder.Text := tpath.GetDirectoryName(OpenDialog1.FileName);
end;

procedure TfrmPlaylistSetupDialog.btnOkClick(Sender: TObject);
var
  path: string;
begin
  path := edtSearchFolder.Text.Trim;
  if path.IsEmpty then
  begin
    edtSearchFolder.SetFocus;
    raise exception.Create('Please give a path.');
  end;
  if not TDirectory.Exists(path) then
  begin
    edtSearchFolder.SetFocus;
    raise exception.Create('This directory doesn''t exist !');
  end;
  FSearchFolder := path;
  FSearchInSubFolders := swInSubFolders.IsChecked;
  if assigned(onCloseProc) then
    onCloseProc(FSearchFolder, FSearchInSubFolders);
  Close;
end;

procedure TfrmPlaylistSetupDialog.DoHide;
begin
  inherited;
  TMessageManager.DefaultManager.Unsubscribe(TTranslateTextsMessage,
    DoTranslateTexts, true);
end;

procedure TfrmPlaylistSetupDialog.DoShow;
begin
  inherited;
  TranslateTexts(tconfig.Current.Language);
  TMessageManager.DefaultManager.SubscribeToMessage(TTranslateTextsMessage,
    DoTranslateTexts);
end;

procedure TfrmPlaylistSetupDialog.DoTranslateTexts(const Sender: TObject;
  const Msg: TMessage);
begin
  if not assigned(self) then
    exit;

  if assigned(Msg) and (Msg is TTranslateTextsMessage) then
    TranslateTexts((Msg as TTranslateTextsMessage).Language);
end;

class procedure TfrmPlaylistSetupDialog.Execute(AFolder: string;
  AInSubFolders: Boolean; ACallback: TPlaylistSetupDialogProc);
var
  f: TfrmPlaylistSetupDialog;
begin
  f := TfrmPlaylistSetupDialog.Create(nil);
  f.onCloseProc := ACallback;
  f.SearchFolder := AFolder;
  f.SearchInSubFolders := AInSubFolders;
{$IF Defined(ANDROID) or Defined(IOS)}
  f.show;
{$ELSE}
  f.showmodal;
{$ENDIF}
end;

procedure TfrmPlaylistSetupDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  tthread.ForceQueue(nil,
    procedure
    begin
      self.Free;
    end);
end;

procedure TfrmPlaylistSetupDialog.SetonCloseProc(const Value
  : TPlaylistSetupDialogProc);
begin
  FonCloseProc := Value;
end;

procedure TfrmPlaylistSetupDialog.SetSearchFolder(const Value: string);
begin
  FSearchFolder := Value;
  edtSearchFolder.Text := FSearchFolder;
end;

procedure TfrmPlaylistSetupDialog.SetSearchInSubFolders(const Value: Boolean);
begin
  FSearchInSubFolders := Value;
  swInSubFolders.IsChecked := FSearchInSubFolders;
end;

procedure TfrmPlaylistSetupDialog.TranslateTexts(const Language: string);
begin
  // TODO : add texts translation here !
end;

end.
