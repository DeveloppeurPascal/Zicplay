unit uDMIcons;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList;

type
  TDMIcons = class(TDataModule)
    AboutBox: TImageList;
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  DMIcons: TDMIcons;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
