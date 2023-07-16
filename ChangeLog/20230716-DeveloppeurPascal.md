# 20230716 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* updated dependencies
* added https://github.com/DeveloppeurPascal/Audio-Tools-Library repository as a submodule
* updated FR/EN dependencies doc
* added ID3v2 and ID3v2 units to the project
* getting ID3 tags from MP3 files in FileSystem connector
* changed getting the MP3 duration but it doesn't work as it
* added a ID3 tags string filter in FileSystem connector (because ID3v2 and ID3v1 classes have some problems with Unicode/non Unicode)
* fixed : the played song title is not shown on windows title bar
* current playing item button is now "Play/Stop" instead of "Play/Pause" (the button stop the music, it didn't "pause" it)
* fixed : the mvPlaylistsVisible parameter seems to be ignored by the multi view component (the value change wasn't coded and the show/hide wasn't the good way)
* changed the playlist (not filtered and filtered) behaviour, moved filter and sort operations to the refreshlistview() method
* update the view when the non filtered (aka "global") playlist is updated
* enable the global PLAY button if the current song list is not empty and play first one on click

* updated program settings file version to v4
* added the search text in settings
* added the sort type in settings
* persistent search text and sort type by storing them in the settings
* change song display in the list on screen (title, album, artist, genre and year)
* added the published year as a song's list filter

* added a timer to check the end of a song only 1 second after its start playing
* changed play operation : use each TMediaPlayer only once (changing the filename has side effects on macOS ARM)

* fixed : REPEAT ONE didn't restart the song (because of a bug in "play" which doesn't restart the song

* fixed : no finalization on macOS => the program settings were not saved

* changed finding next song in random mode due to a random error : sometimes the program stop searching next song

* released v1.0 - 20230716
