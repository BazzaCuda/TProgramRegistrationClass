# TProgramRegistrationClass

A Delphi class for registering applications and for associating file extensions with your .exe

This class has been developed from the mmp-install.bat file which is distributed with my **Minimalist Media Player** (see https://github.com/BazzaCuda/MinimalistMediaPlayerX). 
The batch file registers my application with Windows as a media file handler, not only being associated as the default player for many audio and video file extensions, but also as an official client for media files in general, for the "Open with.." dialog, and the Default Apps facility in Windows Settings.

mmp-install.bat was adapted from the excellent mpv-install.bat that ships with MPV, the API of which is what **Minimalist Media Player** is built on.
I am very grateful to the MPV devs for superbly illuminating the knotty problem of Windows file registration as this is an area that has grown more involved with successive versions of Windows.

I was able to use their work as a blueprint for creating this TProgramRegistrationClass to simplify the process of registering an app and associating as many extensions (custom and standard) with the app as required.

I have provided a fully-tested test program to illustrate (I hope) how to use the class. The ultimate test was that I successfully used the enclosed test program to re-register my media player and associate .wav files with it.

As this class writes directly to the Windows Registry, I of course recommend that you set a restore point to take a backup of your registry before making significant changes, especially while developing your own code using this class. I have happily used this code on my own machine, however I shall not be held responsible for any errors or issues that using this code in your projects may or may not cause.

Example:
 
      pr := TProgramRegistration.create;
      try
        pr.fullPathToExe   := 'C:\myapp.exe'; // In addition, you can also set pr.fullPathToIco to specify a separate .ico icon file or any valid icon registry entry, e.g. %ProgramFiles%\Internet Explorer\hmmapi.dll,1
        pr.friendlyAppName := 'My Awesome App';
        pr.sysFileType     := 'audio'; // optional
        pr.clientType      := 'Media'; // optional
        pr.progIDPrefix    := 'my.awesomeApp'; // unique prefix, creates e.g. HKEY_LOCAL_MACHINE\SOFTWARE\Classes\my.awesomeApp.wav\

        pr.registerAppPath;
        pr.registerAppName;
        pr.registerSysFileType;        // e.g. audio, optional
        pr.registerClientCapabilities; // e.g. Media, optional

        case pr.registerExtension('.wav', 'Wave Audio', 'audio/wav', 'audio'); // extension, friendly name, mime type, perceived type
      finally
        pr.free;
      end;
