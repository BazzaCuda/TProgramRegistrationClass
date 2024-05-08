unit TProgramRegistrationClass;
{   TProgRegistrationClass
    Copyright (C) 2024 Baz Cuda
    https://github.com/BazzaCuda/TProgramRegistrationClass

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA
}

interface

uses
  system.win.registry, winApi.windows, system.sysUtils, winApi.ShlObj;

type
  TProgramRegistration = class(TObject)
  strict private
    FReg: TRegistry;

    {property fields}
    FAppArgs:         string;
    FClientType:      string;
    FProgIDPrefix:    string;
    FFriendlyAppName: string;
    FFullPathToExe:   string;
    FFullPathToIco:   string;
    FRegRoot:         HKEY;
    FSysFileType: string;
  private
    function getSysFileAssocsKey: string;

  public
    constructor Create;
    destructor  Destroy; override;

    function exeFileName:                                           string;
    function getApplicationsKey:                                    string;
    function getCapabilitiesKey:                                    string;
    function getFileAssociationsKey:                                string;
    function getProgID(const aExtension: string):                   string;
    function getRegisteredApplicationsKey:                          string;
    function getSupportedTypesKey:                                  string;
    function registerAppPath:                                       boolean;
    function registerAppName:                                       boolean;
    function registerAppVerbs(const aKey: string):                  boolean;
    function registerClientCapabilities:                            boolean; // e.g. media
    function registerFileAssociation(const aExtension: string):     boolean;
    function registerRegisteredApplication:                         boolean;
    function registerSupportedType(const aExtension: string):       boolean;
    function registerSysFileType:                                   boolean; // e.g. audio, video

    function registerExtension(const aExtension: string; const aFriendlyName: string; const aMimeType: string = ''; const aPerceivedType: string = ''): boolean;

    function refreshDesktop: boolean;

    property appArgs:         string read FAppArgs         write FAppArgs;
    property clientType:      string read FClientType      write FClientType; // e.g. media
    property friendlyAppName: string read FFriendlyAppName write FFriendlyAppName;
    property fullPathToExe:   string read FFullPathToExe   write FFullPathToExe;
    property fullPathToIco:   string read FFullPathToIco   write FFullPathToIco; // optional separate icon file
    property progIDPrefix:    string read FProgIDPrefix    write FProgIDPrefix;  // a unique identifier
    property regRoot:         HKEY   read FRegRoot         write FRegRoot;
    property sysFileType:     string read FSysFileType     write FSysFileType;
  end;

implementation

const
  KEY_APP_PATHS        = 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\';
  KEY_SOFTWARE_CLASSES = 'SOFTWARE\Classes\';
  KEY_SOFTWARE_CLIENTS = 'SOFTWARE\Clients\';
  KEY_APPLICATIONS     = 'Applications\';
  KEY_SYSFILE_ASSOCS   = 'SystemFileAssociations\';
  KEY_REGISTERED_APPS  = 'SOFTWARE\RegisteredApplications\';

{ TProgramRegistration }

constructor TProgramRegistration.Create;
begin
  inherited;
  FReg := TRegistry.create(KEY_READ OR KEY_WRITE);
  FRegRoot := HKEY_LOCAL_MACHINE;
  FAppArgs := '"%1"';
end;

destructor TProgramRegistration.Destroy;
begin
  case FReg <> NIL of TRUE: FReg.free; end;
  inherited;
end;

function TProgramRegistration.exeFileName: string;
begin
  result := extractFileName(FFullPathToExe);
end;

function TProgramRegistration.getApplicationsKey: string;
begin
  result := KEY_SOFTWARE_CLASSES + KEY_APPLICATIONS + exeFileName + '\';
end;

function TProgramRegistration.getCapabilitiesKey: string;
begin
  result := KEY_SOFTWARE_CLIENTS + FClientType + '\' + FFriendlyAppName + '\' + 'Capabilities\';
end;

function TProgramRegistration.getFileAssociationsKey: string;
begin
  result := getCapabilitiesKey + 'FileAssociations\';
end;

function TProgramRegistration.getProgID(const aExtension: string): string;
begin
  result := FProgIDPrefix + aExtension;
end;

function TProgramRegistration.getRegisteredApplicationsKey: string;
begin
  result := KEY_REGISTERED_APPS;
end;

function TProgramRegistration.getSupportedTypesKey: string;
begin
  result := KEY_SOFTWARE_CLASSES + KEY_APPLICATIONS + exeFileName + '\' + 'SupportedTypes\';
end;

function TProgramRegistration.getSysFileAssocsKey: string;
begin
  result := KEY_SOFTWARE_CLASSES + KEY_SYSFILE_ASSOCS + FSysFileType + '\' + 'OpenWithList\' + exeFileName + '\';
end;

function TProgramRegistration.refreshDesktop: boolean;
begin
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, 0, 0);
end;

function TProgramRegistration.registerAppName: boolean;
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  // HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Applications\your.exe\
  case FReg.openKey(KEY_SOFTWARE_CLASSES + KEY_APPLICATIONS + exeFileName, TRUE) of FALSE: EXIT; end;

  FReg.writeString('FriendlyAppName', FFriendlyAppName);
  FReg.closeKey;

  result := registerAppVerbs(KEY_SOFTWARE_CLASSES + KEY_APPLICATIONS + exeFileName + '\');
end;

function TProgramRegistration.registerAppPath: boolean;
// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\your.exe
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(KEY_APP_PATHS + exeFileName, TRUE) of FALSE: EXIT; end;

  FReg.writeString('', FFullPathToExe);
  FReg.writeInteger('UseUrl', 1);

  FReg.closeKey;
  result := TRUE;
end;

function TProgramRegistration.registerAppVerbs(const aKey: string): boolean;
// registerAppVerbs(getApplicationsKey)
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(aKey + 'shell\', TRUE) of FALSE: EXIT;end;

  // set the default verb to Play
  FReg.writeString('', 'Play');
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  // add "open" verb
  case FReg.openKey(aKey + 'shell\open\', TRUE) of FALSE: EXIT; end;

  // Hide the "open" verb from the context menu, since it's the same as "play"
  FReg.writeString('LegacyDisable', '');
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(aKey + 'shell\open\command\', TRUE) of FALSE: EXIT; end;

  // set open command = "fullpathtoexe" "%1" or "fullpathtoexe" followed by the caller-supplied args
  FReg.writeString('', '"' + FFullPathToExe + '"' + ' ' + FAppArgs);
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  // add "play" verb
  case FReg.openKey(aKey + 'shell\play\', TRUE) of FALSE: EXIT; end;
  FReg.writeString('', '&Play');
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(aKey + 'shell\play\command\', TRUE) of FALSE: EXIT; end;

  // set play command = "fullpathtoexe" "%1" or "fullpathtoexe" followed by the caller-supplied args
  FReg.writeString('', '"' + FFullPathToExe + '"' + ' ' + FAppArgs);
  FReg.closeKey;

  result := TRUE;
end;

function TProgramRegistration.registerClientCapabilities: boolean;
// HKEY_LOCAL_MACHINE\SOFTWARE\Clients\<ClientType>\<your app>\Capabilities\
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(getCapabilitiesKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString('ApplicationName', FFriendlyAppName);
  FReg.writeString('ApplicationDescription', FFriendlyAppName);
  FReg.rootKey := FRegRoot;
  FReg.closeKey;

  registerRegisteredApplication;

  result := TRUE;
end;

function TProgramRegistration.registerExtension(const aExtension: string; const aFriendlyName: string; const aMimeType: string = ''; const aPerceivedType: string = ''): boolean;

  function getExtKey: string;
  begin
    result := KEY_SOFTWARE_CLASSES + aExtension + '\';
  end;

  function getProgIDExtKey: string;
  begin
    result := KEY_SOFTWARE_CLASSES + getProgID(aExtension) + '\';
  end;

begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  // create ProgID - HKEY_CLASSES_ROOT\<yourPrefix>.ext
  case FReg.openKey(getProgIDExtKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString('', aFriendlyName);
  FReg.writeInteger('EditFlags', 65536); // FTA_OpenIsSafe
  FReg.writeString('FriendlyTypeName', aFriendlyName);
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(getProgIDExtKey + 'DefaultIcon\', TRUE) of FALSE: EXIT; end;

  case FFullPathToIco = '' of  TRUE: FReg.writeString('', FFullPathToExe + ',0');
                              FALSE: FReg.writeString('', FFullPathToIco); end;
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  registerAppVerbs(getProgIDExtKey);

  case FReg.openKey(getExtKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString('', getProgID(aExtension));

  case aMimeType      <> '' of TRUE: FReg.writeString('Content Type', aMimeType); end;
  case aPerceivedType <> '' of TRUE: FReg.writeString('PerceivedType', aPerceivedType); end;
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  // HKEY_CLASSES_ROOT\.ext\OpenWithProgIds
  case FReg.openKey(getExtKey + 'OpenWithProgIDs\', TRUE) of FALSE: EXIT; end;

  FReg.writeString(getProgID(aExtension), '');
  FReg.closeKey;
  FReg.rootKey := FRegRoot;

  registerSupportedType(aExtension);
  registerFileAssociation(aExtension);

  result := TRUE;
end;

function TProgramRegistration.registerFileAssociation(const aExtension: string): boolean;
// see HKEY_LOCAL_MACHINE\SOFTWARE\Clients\Capabilities\FileAssociations\
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  // add extension to the Default Programs control panel
  case FReg.openKey(getFileAssociationsKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString(aExtension, getProgID(aExtension));
  FReg.closeKey;

  result := TRUE;
end;

function TProgramRegistration.registerRegisteredApplication: boolean;
// see HKEY_LOCAL_MACHINE\SOFTWARE\RegisteredApplications\
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(getRegisteredApplicationsKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString(FFriendlyAppName, getCapabilitiesKey);
  FReg.closeKey;

  result := TRUE;
end;

function TProgramRegistration.registerSupportedType(const aExtension: string): boolean;
// see HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Applications\your.exe\SupportedTypes\
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(getSupportedTypesKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString(aExtension, '');
  FReg.closeKey;

  result := TRUE;
end;

function TProgramRegistration.registerSysFileType: boolean;
begin
  result       := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(getSysFileAssocsKey, TRUE) of FALSE: EXIT; end;
  FReg.closeKey;

  result := TRUE;
end;

end.
