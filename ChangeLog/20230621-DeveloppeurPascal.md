# 20230621 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* added code to sort songs list, sources list and connectors list
* added some methods to ISongSourceType interface
* added some comments to Zicplay.Types unit
* finished code for TSongSourceTypeList class

* added a combo to sort the displayed list of songs
* changed displayed properties for each song
* added a non filtered (= full) for the current list of songs
* added a filter song list by keyword feature
* replaced TObjectList<> from Zicplay.Types by TList<> only (freeing items must be added later)
* added a timer to check if current played song has finished
* play next song of the list if current song has finished

* added a "fparams" field in song source and procedures for showing the setup dialog and getting the songlist of a connector
* changed the TSongSourceList class into a singleton class instance
* added some methods to TSongSourceTypeList

* added a sample code for loading musics from a folder and its subdirectories (cf Mac / RELEASE)

* updated TODO list file and GitHub issues
