# TProgramRegistrationClass

A Delphi class for registering applications and for associating file extensions with your .exe

This class has been developed from the mmp-install.bat file which is distributed with my **Minimalist Media Player** (see https://github.com/BazzaCuda/MinimalistMediaPlayerX). 
The batch file registers my application with Windows as a media file handler, not only being associated as the default player for many audio and video file extensions, but also as an official client for media files in general, for the "Open with.." dialog, and the Default Apps facility in Windows Settings.

mmp-install.bat was adapted from the excellent mpv-install.bat that ships with MPV, the API of which is what **Minimalist Media Player** is built on.
I am very grateful to the MPV devs for superbly illuminating the knotty problem of Windows file registration as this is an area that has grown more involved with successive versions of Windows.

I was able to use their work as a blueprint for creating this TProgramRegistrationClass to simplify the process of registering an app and associating as many extensions (custom and standard) with the app as required.

I have provided a fully-tested test program to illustrate (I hope) how to use the class. The ultimate test was that I successfully used the enclosed test program to re-register my media player and associate .wav files with it.




 
