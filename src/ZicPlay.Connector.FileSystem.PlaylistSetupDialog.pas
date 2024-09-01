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
/// File last update : 2024-09-01T16:13:18.000+02:00
/// Signature : 7715fbc8279562d41cd2fa4da4cbca5f4e286042
/// ***************************************************************************
/// </summary>

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
  System.Messaging,
  Olf.FMX.SelectDirectory;

type
  TPlaylistSetupDialogProc = reference to procedure(const AFolder: string;
    const AInSubFolders: Boolean);

  TfrmPlaylistSetupDialog = class(TForm)
    lblFolder: TLabel;
    edtSearchFolder: TEdit;
    lblInSubFolders: TLabel;
    VertScrollBox1: TVertScrollBox;
    swInSubFolders: TSwitch;
    GridPanelLayout1: TGridPanelLayout;
    btnOk: TButton;
    btnCancel: TButton;
    OlfSelectDirectoryDialog1: TOlfSelectDirectoryDialog;
    btnFolderChoice: TEditButton;
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
  if edtSearchFolder.Text.Trim.IsEmpty then
    OlfSelectDirectoryDialog1.Directory := tpath.GetDocumentsPath
  else
    OlfSelectDirectoryDialog1.Directory := edtSearchFolder.Text;
  if OlfSelectDirectoryDialog1.Execute and
    (not OlfSelectDirectoryDialog1.Directory.IsEmpty) and
    tdirectory.Exists(OlfSelectDirectoryDialog1.Directory) then
    edtSearchFolder.Text := OlfSelectDirectoryDialog1.Directory;
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
  if not tdirectory.Exists(path) then
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
  try
    f.onCloseProc := ACallback;
    f.SearchFolder := AFolder;
    f.SearchInSubFolders := AInSubFolders;
    f.tag := -1;
{$IF Defined(ANDROID) or Defined(IOS)}
    f.show;
{$ELSE}
    f.ShowModal;
{$ENDIF}
  finally
{$IF Defined(ANDROID) or Defined(IOS)}
{$ELSE}
    f.free;
{$ENDIF}
  end;
end;

procedure TfrmPlaylistSetupDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
{$IF Defined(ANDROID) or Defined(IOS)}
  if tag = -1 then
  begin
    tag := 0;
    tthread.ForceQueue(nil,
      procedure
      begin
        self.free;
      end);
  end
  else
    ShowMessage('2');
  // TODO : sur macOS le close était appelé 2 fois avec la fenêtre en ShowModal, qu'en est-il des mobiles ?
{$ENDIF}
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
