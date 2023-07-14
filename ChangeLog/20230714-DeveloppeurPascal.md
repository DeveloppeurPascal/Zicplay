# 20230714 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* added a "enabled" property on the TPlaylist
* added a "UniqID" property on the TPlaylist
* updated TPlaylist data version level for load and save config
* force update of program config when a playlist property is changed

* updated config data version level
* updated load config from stream and save config to stream
* added the storrage of the visibility for multiview playlists on main screen

* added "enabled" property as a checkbox in the playlist config screen

* add a selection of the playlist whose tracks you want to listen to in the main form

* création de Olf.RTL.Streams.pas => pour DeveloppeurPascal/Libraries
* création de Olf.RTL.DateAndTime.pas => pour DeveloppeurPascal/Libraries
* added files from DeveloppeurPascal/Libraries to the project

* Changed TConfig.GetDefaultConfigFilePath() to get default program file setup or others (like playlist caches)

* added a playlist songs cache file to TPlaylist and TSong
* added load and save methods for TSong
* changed playlists from a TList to a TThreadList and updated its implementation

* implemented GetDurationAsTime() for TSong
* added a method SortByUniqID(), UpdateAsAMirrorOf(), Delete() in TPlaylist
* fixed TSong.SetFilename()

* update CurrentSongsListNotFiltered in main form with enabled/disabled playlists

* removed the buttons to load songs and playlists for UI/UX tests

