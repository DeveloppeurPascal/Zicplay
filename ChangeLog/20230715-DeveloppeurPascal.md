# 20230715 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* updated dependencies
* updated local TODO list

* changed "playlists" speed button to button
* added play/pause/stop/previous/next buttons
* changed the toolbar to adapt its height depending on the windows width

* implemented stop button
* implemented play button
* changed MusicLoop class to add a pause feature
* implemented pause button
* implemented previous button
* implemented next button

* added a volume trackbar
* new features : play only 5s (intro mode), play randomly, repeat current played song and repeat all

uConfig.pas :
* increased the program settings config file version
* added new UI parameters (volume, repeat all/1, intro, ...)

fMain.pas :
* store the UI state for checkbox and volume in the config file
* use new config parameters to initialize the user interface
* resized the StatusBarPanel to display the current playing song label (without truncating it)
