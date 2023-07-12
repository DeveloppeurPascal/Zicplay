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
  Zicplay.Types;

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
    { Déclarations privées }
  public
    { Déclarations publiques }
    property onSelectedConnectorProc: TonSelectedConnectorProc
      read FonSelectedConnectorProc write SetonSelectedConnectorProc;
    class procedure Execute(ASelectedConnectorProc: TonSelectedConnectorProc);
  end;

implementation

{$R *.fmx}

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

end.
