(* C2PP
  ***************************************************************************

  ZicPlay

  Copyright 2023-2025 Patrick Prémartin under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  ZicPlay is a MP3 player based on playlists from multiple sources.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://zicplay.olfsoftware.fr/

  Project site :
  https://github.com/DeveloppeurPascal/Zicplay

  ***************************************************************************
  File last update : 2025-10-16T10:43:26.219+02:00
  Signature : 797b38920c1d0f730819e795a4d0369cf83a1a8d
  ***************************************************************************
*)

unit fSelectConnector;

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
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  Zicplay.Types,
  System.Messaging;

type
  TonSelectedConnectorProc = reference to procedure(AConnector: IConnector);

  TfrmSelectConnector = class(TForm)
    ListView1: TListView;
    GridPanelLayout1: TGridPanelLayout;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FonSelectedConnectorProc: TonSelectedConnectorProc;
    procedure SetonSelectedConnectorProc(const Value: TonSelectedConnectorProc);
  protected
    procedure DoTranslateTexts(const Sender: TObject; const Msg: TMessage);
    procedure DoShow; override;
    procedure DoHide; override;
  public
    property onSelectedConnectorProc: TonSelectedConnectorProc
      read FonSelectedConnectorProc write SetonSelectedConnectorProc;
    class procedure Execute(ASelectedConnectorProc: TonSelectedConnectorProc);
    /// <summary>
    /// This method is called each time a global translation broadcast is sent
    /// with current language as argument.
    /// </summary>
    procedure TranslateTexts(const Language: string); virtual;
  end;

implementation

{$R *.fmx}

uses
  uTranslate,
  uConfig;

procedure TfrmSelectConnector.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmSelectConnector.btnOkClick(Sender: TObject);
begin
  if not assigned(ListView1.selected) then
    raise exception.create('Select a connector !');

  if assigned(FonSelectedConnectorProc) then
    FonSelectedConnectorProc(tconnectorslist.current.GetConnectorFromUID
      (ListView1.selected.tagstring));

  close;
end;

procedure TfrmSelectConnector.DoHide;
begin
  inherited;
  TMessageManager.DefaultManager.Unsubscribe(TTranslateTextsMessage,
    DoTranslateTexts, true);
end;

procedure TfrmSelectConnector.DoShow;
begin
  inherited;
  TranslateTexts(tconfig.current.Language);
  TMessageManager.DefaultManager.SubscribeToMessage(TTranslateTextsMessage,
    DoTranslateTexts);
end;

procedure TfrmSelectConnector.DoTranslateTexts(const Sender: TObject;
  const Msg: TMessage);
begin
  if not assigned(self) then
    exit;

  if assigned(Msg) and (Msg is TTranslateTextsMessage) then
    TranslateTexts((Msg as TTranslateTextsMessage).Language);
end;

class procedure TfrmSelectConnector.Execute(ASelectedConnectorProc
  : TonSelectedConnectorProc);
var
  f: TfrmSelectConnector;
begin
  if not assigned(ASelectedConnectorProc) then
    raise exception.create
      ('Selecting something without retrieving it is a nonsense !');

  f := TfrmSelectConnector.create(nil);
  f.onSelectedConnectorProc := ASelectedConnectorProc;
{$IF Defined(ANDROID) or Defined(IOS)}
  f.show;
{$ELSE}
  f.showmodal;
{$ENDIF}
end;

procedure TfrmSelectConnector.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  tthread.ForceQueue(nil,
    procedure
    begin
      self.Free;
    end);
end;

procedure TfrmSelectConnector.FormCreate(Sender: TObject);
var
  i: integer;
  Connector: IConnector;
  item: tlistviewitem;
begin
  FonSelectedConnectorProc := nil;

  for i := 0 to tconnectorslist.current.count - 1 do
  begin
    Connector := tconnectorslist.current.getConnectorat(i);
    item := ListView1.items.add;
    item.text := Connector.getname;
    item.tagstring := Connector.getUniqID;
  end;
end;

procedure TfrmSelectConnector.SetonSelectedConnectorProc
  (const Value: TonSelectedConnectorProc);
begin
  FonSelectedConnectorProc := Value;
end;

procedure TfrmSelectConnector.TranslateTexts(const Language: string);
begin
  // TODO : add texts translation here !
end;

end.
