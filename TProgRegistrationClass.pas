unit TProgRegistrationClass;
{   TProgRegistrationClass
    Copyright (C) 2024 Baz Cuda
    https://github.com/BazzaCuda/TProgRegistrationClass

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
  system.win.registry, winApi.windows, system.sysUtils;

type
  TProgRegistration = class(TObject)
  strict private
    FReg: TRegistry;

    {property fields}
    FAppArgs:         string;
    FClientType:      string;
    FProgIDPrefix:    string; // a unique identifier
    FFriendlyAppName: string;
    FFullPathToExe:   string;
    FFullPathToIco:   string;
    FRegRoot:         HKEY;

  public
    constructor Create;
    destructor  Destroy; override;

    function exeFileName:                                           string;
    function getApplicationsKey:                                    string;
    function getCapabilitiesKey:                                    string;
    function getFileAssociationsKey:                                string;
    function getProgID(const aExtension: string):                   string;
    function getSupportedTypesKey:                                  string;
    function registerAppPath:                                       boolean;
    function registerApp:                                           boolean;
    function registerAppVerbs(const aKey: string):                  boolean;
    function registerClientCapabilities:                            boolean; // e.g. media
    function registerFileAssociation(const aExtension: string):     boolean;
    function registerSupportedType(const aExtension: string):       boolean;
    function registerSysFileType(const aSysFileType: string):       boolean; // e.g. audio, video

    function registerExtension(const aExtension: string; const aFriendlyName: string; const aMimeType: string; const aPerceivedType: string): boolean;

    property appArgs:         string read FAppArgs         write FAppArgs;
    property clientType:      string read FClientType      write FClientType; // e.g. media
    property friendlyAppName: string read FFriendlyAppName write FFriendlyAppName;
    property fullPathToExe:   string read FFullPathToExe   write FFullPathToExe;
    property fullPathToIco:   string read FFullPathToIco   write FFullPathToIco; // optional separate icon file
    property progIDPrefix:    string read FProgIDPrefix    write FProgIDPrefix;
    property regRoot:         HKEY   read FRegRoot         write FRegRoot;
  end;

implementation

const
  KEY_APP_PATHS        = 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\';
  KEY_SOFTWARE_CLASSES = 'SOFTWARE\Classes\';
  KEY_SOFTWARE_CLIENTS = 'SOFTWARE\Clients\';
  KEY_APPLICATIONS     = 'Applications\';
  KEY_SYSFILE_ASSOCS   = 'SystemFileAssociations\';

{ TProgRegistration }

constructor TProgRegistration.Create;
begin
  inherited;
  FReg := TRegistry.create(KEY_READ OR KEY_WRITE);
  FRegRoot := HKEY_LOCAL_MACHINE;
  FAppArgs := '"%1"';
end;

destructor TProgRegistration.Destroy;
begin
  case FReg <> NIL of TRUE: FReg.free; end;
  inherited;
end;

function TProgRegistration.exeFileName: string;
begin
  result := extractFileName(FFullPathToExe);
end;

function TProgRegistration.getApplicationsKey: string;
begin
  result := KEY_SOFTWARE_CLASSES + KEY_APPLICATIONS + exeFileName + '\';
end;

function TProgRegistration.getCapabilitiesKey: string;
begin
  result := KEY_SOFTWARE_CLIENTS + FClientType + '\' + FFriendlyAppName + '\' + 'Capabilities\';
end;

function TProgRegistration.getFileAssociationsKey: string;
begin
  result := getCapabilitiesKey + 'FileAssociations\';
end;

function TProgRegistration.getProgID(const aExtension: string): string;
begin
  result := FProgIDPrefix + aExtension;
end;

function TProgRegistration.getSupportedTypesKey: string;
begin
  result := KEY_SOFTWARE_CLASSES + KEY_APPLICATIONS + exeFileName + '\' + 'SupportedTypes\';
end;

function TProgRegistration.registerApp: boolean;
begin
  result := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(KEY_SOFTWARE_CLASSES + KEY_APPLICATIONS + exeFileName, TRUE) of FALSE: EXIT; end;

  FReg.writeString('FriendlyAppName', FFriendlyAppName);
  FReg.closeKey;

  result := TRUE;
end;

function TProgRegistration.registerAppPath: boolean;
begin
  result := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(KEY_APP_PATHS + exeFileName, TRUE) of FALSE: EXIT; end;

  FReg.writeString('', FFullPathToExe);
  FReg.writeInteger('UseUrl', 1);

  FReg.closeKey;
  result := TRUE;
end;

function TProgRegistration.registerAppVerbs(const aKey: string): boolean;
// registerAppVerbs(getApplicationsKey)
begin
  result := FALSE;
  FReg.rootKey := FRegRoot;

  case FReg.openKey(aKey + 'shell\', TRUE) of FALSE: EXIT;end;

  // set the default verb to Play
  FReg.writeString('', 'Play');
  FReg.closeKey;

  // add "open" verb
  case FReg.openKey(aKey + 'shell\open\', TRUE) of FALSE: EXIT; end;

  // Hide the "open" verb from the context menu, since it's the same as "play"
  FReg.writeString('LegacyDisable', '');
  FReg.closeKey;

  case FReg.openKey(aKey + 'shell\open\command\', TRUE) of FALSE: EXIT; end;

  // set open command = "fullpathtoexe" "%1" or "fullpathtoexe" followed by the caller-supplied args
  FReg.writeString('', '"' + FFullPathToExe + '"' + ' ' + FAppArgs);
  FReg.closeKey;

  // add "play" verb
  case FReg.openKey(aKey + 'shell\play\', TRUE) of FALSE: EXIT; end;
  FReg.writeString('', '&Play');
  FReg.closeKey;

  case FReg.openKey(aKey + 'shell\play\command\', TRUE) of FALSE: EXIT; end;

  // set play command = "fullpathtoexe" "%1" or "fullpathtoexe" followed by the caller-supplied args
  FReg.writeString('', '"' + FFullPathToExe + '"' + ' ' + FAppArgs);
  FReg.closeKey;

  result := TRUE;
end;

function TProgRegistration.registerClientCapabilities: boolean;
begin
  result := FALSE;

  case FReg.openKey(KEY_SOFTWARE_CLIENTS + FClientType + '\' + FFriendlyAppName + '\' + 'Capabilities\', TRUE) of FALSE: EXIT; end;

  FReg.writeString('ApplicationName', FFriendlyAppName);
  FReg.writeString('ApplicationDescription', FFriendlyAppName);
  FReg.closeKey;

  result := TRUE;
end;

function TProgRegistration.registerExtension(const aExtension, aFriendlyName, aMimeType, aPerceivedType: string): boolean;

  function getExtKey: string;
  begin
    result := KEY_SOFTWARE_CLASSES + aExtension + '\';
  end;

  function getProgIDExtKey: string;
  begin
    result := KEY_SOFTWARE_CLASSES + getProgID(aExtension) + '\';
  end;

begin
  result := FALSE;

  // create ProgID
  case FReg.openKey(getProgIDExtKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString('', aFriendlyName);
  FReg.writeInteger('EditFlags', 65536); // FTA_OpenIsSafe
  FReg.writeString('FriendlyTypeName', aFriendlyName);
  FReg.closeKey;

  case FReg.openKey(getProgIDExtKey + 'DefaultIcon\', TRUE) of FALSE: EXIT; end;

  case FFullPathToIco = '' of  TRUE: FReg.writeString('', FFullPathToExe + ',0');
                              FALSE: FReg.writeString('', FFullPathToIco); end;
  FReg.closeKey;

  registerAppVerbs(getProgIDExtKey);

  case FReg.openKey(getExtKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString('', getProgID(aExtension));

  case aMimeType      <> '' of TRUE: FReg.writeString('Content Type', aMimeType); end;
  case aPerceivedType <> '' of TRUE: FReg.writeString('PerceivedType', aPerceivedType); end;
  FReg.closeKey;

  case FReg.openKey(getExtKey + 'OpenWithProgIDs\', TRUE) of FALSE: EXIT; end;

  FReg.writeString(getProgID(aExtension), '');
  FReg.closeKey;

  result := TRUE;
end;

function TProgRegistration.registerFileAssociation(const aExtension: string): boolean;
begin
  // add extension to the Default Programs control panel
  case FReg.openKey(getFileAssociationsKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString(aExtension, getProgID(aExtension));
  FReg.closeKey;
end;

function TProgRegistration.registerSupportedType(const aExtension: string): boolean;
begin
  case FReg.openKey(getSupportedTypesKey, TRUE) of FALSE: EXIT; end;

  FReg.writeString(aExtension, '');
  FReg.closeKey;
end;

function TProgRegistration.registerSysFileType(const aSysFileType: string): boolean;
begin
  result := FALSE;

  case FReg.openKey(KEY_SOFTWARE_CLASSES + KEY_SYSFILE_ASSOCS + aSysFileType + '\' + 'OpenWithList\' + exeFileName, TRUE) of FALSE: EXIT; end;
  FReg.closeKey;

  result := TRUE;
end;

end.
