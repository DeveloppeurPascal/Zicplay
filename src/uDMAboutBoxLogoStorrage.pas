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
  Signature : 2c973630668fca01fbc7780bf7e48ec0649f9345
  ***************************************************************************
*)

unit uDMAboutBoxLogoStorrage;

interface

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  FMX.ImgList;

type
  TdmAboutBoxLogo = class(TDataModule)
    imgLogo: TImageList;
  private
  public
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

end.
