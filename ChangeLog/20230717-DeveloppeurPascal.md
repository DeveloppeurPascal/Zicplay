# 20230717 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* differ retrieving songs duration in the file system connector playlist refresh because TMediaPlayer don't works on Windows before the main form has been created
* differ and parallelize the playlists loading after program initialization
* fixed updating song's year or published date when ID3 retrieve encoded strings

* added hasChanged property to TPlayer to know if the list of songs or their properties has changed after loading the list
* added Save() method to TPlaylist to save its content cache and settings (not depending to program settings)
* added locks to all properties writers of TPlaylist for multithreading access security
* updated TSong class to inform its playlist in case of any change for the cache file
* save changed playlists in the program closing

* changed settings path in RELEASE mode
* force a refresh of the playlist if it has changed (from the playlist screen)

=> FileSystem connector

* changed the calling of playlist setup dialog to update the view and the list in case of changes
* updated the duration retrieving during a global playlist reload (in its controler)
* fixed the call of callback procedure at the end of a playlist reload
* fixed a potential memory leak or access violation at the end of a playlist reload
* changed the playlist/connector params changes detection to reload the playlist and its display if needed

=> ZicPlay Types unit

* added HasSong() methods to check if a song is in a playlist
* changed PlaylistSetupDialog() interface
* updated default value for duration (to force its refresh)
* changed implementation of GetDurationAsTime() method
* RefreshSongsList() method send message TPlaylistUpdatedMessage instead of having a callback procedure
* fixed a EOutOfRangeError exception during mirroring playlists

=> main form

* added a RefreshListItem() method to update the display of a song on screen
* changed RefreshListView() to use the new RefreshListItem() method
* changed the loading of playlists on startup
* added a thread to update durations of songs (to activate in future release, see #81)
* added a song's duration update after playing a song (it will update playlist cache files to)
* all changes to CurrentSongsListNotFiltered content are now done in RefreshSongsList and nowhere else
* update list items properties and display when they are played or stopped

* added a progressive loading for playlists (as a test) in the FileSystem connector
* added the number of songs selected for current list of songs in the main form status bar

* updated TODO list

* release v1.1 - 20230717 for Windows 64 bits and macOS Apple Silicon
