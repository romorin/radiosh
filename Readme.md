# radiosh

**radiosh** handles playing radio streams using a mplayer backend, controlled on the command line.

## installing

1. Install dependencies :

Requires mplayer to function.

2. Copy repository :
```
git clone $location .
```
3. Install :

..* Using default locations :
```
make install
```
..* Using a different location :
```
make install PREFIX=???
```
..* Using a different location for the configuration file only :
```
make install ETC_PREFIX=???
```
..* Using bash autocompletion :
```
make install BASH_COMPLETION=???
```
(Completion can be `GLOBAL` or `LOCAL`)

..* Combining arguments :
```
make install PREFIX=??? ETC_PREFIX=??? BASH_COMPLETION=???
```

## uninstalling
```
make uninstall ?arguments?
```
Where ?arguments? is the same arguments you defined during the installation

## usage
```
radiosh *command* *[arguments]*
```

### commands

(Arguments to be filled are like ?this?)

####add
```
radiosh add ?channel? ?url?
```
Adds a channel at the defined path using the specified url

####add-category
```
radiosh add ?category?
```
Adds a category at the defined path

####kill
```
radiosh kill
```
Kills the mplayer backend and removes temporary files

####list or ls
```
radiosh list
```
Lists the available categories and channels

####mute
```
radiosh mute
```
Toggles the sound

####pause
```
radiosh pause
```
Pause playback of the channel

####play
```
radiosh play ?channel?
```
Plays the channel with the specified path

####rm
```
radiosh rm ?channel?
```
Removes the channel with the specified path

####rm-category
```
radiosh rm-category ?category?
```
Removes the specified category, only if it is empty

####start
```
radiosh start
```
Starts the mplayer backend

####stop
```
radiosh stop
```
Stops the currently playing channel

####volume
```
radiosh volume ?volume?
```
Sets the radio volume. Can be from 0 to 100.

## about the radio urls

One place you can get radio url is from shoutcast. Find the station on the website, click on the download icon, then right click on the .m3u link to copy the shoutcast url. After that, you enter on the shell :
```
curl ?url from last step?
```
And you will see one or a list of urls. You can choose any of them.

## license

Released under the GPL license.
