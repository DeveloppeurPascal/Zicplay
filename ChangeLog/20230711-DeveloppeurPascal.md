# 20230711 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* removed default text for current song in the status bar on program startup
* update copyright, release and version infos in project options

* changed compiler option for universal binary (Android 64)
* changed compiler option for universal binary (macOS ARM + x64)
* renamed TForm1 in TfrmMain

* renamed some types to clarify their use
TSongList => TPlaylist
ISongSourceType => IConnector
TSongSource => TConnector
TSongSourceList => TConnectorsList

* in ZicPlay.Types.pas

renamed types, properties and methods
changed TConnector type interface and implemantation

* in fMain.pas
renamed fields, types and methods after changing ZicPlay.Types interface
fixed tools menu for connectors with a setup dialog

* added the new connector : File System (ZicPlay.Connector.FileSystem.pas)
* added the new connector : MyMusic (ZicPlay.Connector.MyMusic.pas)
* added a "current" property in TConnector to get current instance as singleton
* added a test button for "my music" connector playlist
