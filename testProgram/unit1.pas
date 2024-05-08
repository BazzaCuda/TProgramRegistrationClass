unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    edtFullPathToExe: TLabeledEdit;
    Button1: TButton;
    lblResult: TLabel;
    edtFriendlyAppName: TLabeledEdit;
    Button2: TButton;
    edtSystemFileType: TLabeledEdit;
    Button3: TButton;
    edtCapabilitiesType: TLabeledEdit;
    Button4: TButton;
    edtExtension: TLabeledEdit;
    edtExtFriendlyName: TLabeledEdit;
    edtMimeType: TLabeledEdit;
    edtPerceivedType: TLabeledEdit;
    btnRegisterExtension: TButton;
    Bevel1: TBevel;
    edtProgIDPrefix: TLabeledEdit;
    btnOneStep: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnRegisterExtensionClick(Sender: TObject);
    procedure btnOneStepClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses TProgramRegistrationClass;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
// register app path
begin
  lblResult.caption := '';
  var pr := TProgramRegistration.create;
  try
    pr.fullPathToExe := edtFullPathToExe.text;
    case pr.registerAppPath of  TRUE: lblResult.caption := 'register app path = TRUE';
                               FALSE: lblResult.caption := 'register app path = FALSE'; end

  finally
    pr.free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
// register friendly app name for "Open with..."
begin
  lblResult.caption := '';
  var pr := TProgramRegistration.create;
  try
    pr.fullPathToExe   := edtFullPathToExe.text;
    pr.friendlyAppName := edtFriendlyAppName.text;
    case pr.registerAppName of  TRUE: lblResult.caption := 'register app name = TRUE';
                               FALSE: lblResult.caption := 'register app name = FALSE'; end

  finally
    pr.free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
// add to the "Open with" list for all <sysFileType> file types, e.g. Audio, Video
// see HKEY_LOCAL_MACHINE\SOFTWARE\Classes\SystemFileAssociations\
begin
  lblResult.caption := '';
  var pr := TProgramRegistration.create;
  try
    pr.fullPathToExe   := edtFullPathToExe.text;
    pr.sysFileType     := edtSystemFileType.text; // e.g. audio
    case pr.registerSysFileType of  TRUE: lblResult.caption := 'register sys file type = TRUE';
                                   FALSE: lblResult.caption := 'register sys file type = FALSE'; end

  finally
    pr.free;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
// set capabilities for Default Apps control panel
// see e.g. HKEY_LOCAL_MACHINE\SOFTWARE\Clients\Media\
begin
  lblResult.caption := '';
  var pr := TProgramRegistration.create;
  try
    pr.friendlyAppName := edtFriendlyAppName.text;
    pr.clientType      := edtCapabilitiesType.text; // e.g. Media
    case pr.registerClientCapabilities of  TRUE: lblResult.caption := 'register capabilities = TRUE';
                                          FALSE: lblResult.caption := 'register capabilities = FALSE'; end

  finally
    pr.free;
  end;
end;

procedure TForm1.btnRegisterExtensionClick(Sender: TObject);
begin
  lblResult.caption := '';
  var pr := TProgramRegistration.create;
  try
    pr.fullPathToExe   := edtFullPathToExe.text; // for the icon. Alternatively, set pr.fullPathToIco
    pr.progIDPrefix    := edtProgIDPrefix.text;  // creates e.g. HKEY_LOCAL_MACHINE\SOFTWARE\Classes\my.app.wav
    case pr.registerExtension(edtExtension.text, edtExtFriendlyName.text, edtMimeType.text, edtPerceivedType.text) of  TRUE: lblResult.caption := 'register extension = TRUE';
                                                                                                                      FALSE: lblResult.caption := 'register extension = FALSE'; end

  finally
    pr.free;
  end;
end;

procedure TForm1.btnOneStepClick(Sender: TObject);
// Register your app and associate your extension with it.
var result: boolean;
begin
  lblResult.caption := '';
  var pr := TProgramRegistration.create;
  try
    pr.fullPathToExe   := edtFullPathToExe.text; // In addition, you can also set pr.fullPathToIco to specify a separate .ico icon file or any valid icon registry entry, e.g. %ProgramFiles%\Internet Explorer\hmmapi.dll,1
    pr.friendlyAppName := edtFriendlyAppName.text;
    pr.sysFileType     := edtSystemFileType.text; // e.g. audio
    pr.clientType      := edtCapabilitiesType.text; // e.g. Media
    pr.progIDPrefix    := edtProgIDPrefix.text;  // creates e.g. HKEY_LOCAL_MACHINE\SOFTWARE\Classes\my.app.wav

    lblResult.caption := 'register app path = FALSE';
    case pr.registerAppPath            of FALSE: EXIT; end;

    lblResult.caption := 'register app name = FALSE';
    case pr.registerAppName            of FALSE: EXIT; end;

    lblResult.caption := 'register sys file type = FALSE';
    case pr.registerSysFileType        of FALSE: EXIT; end; // e.g. audio, optional

    lblResult.caption := 'register capabilities = FALSE';
    case pr.registerClientCapabilities of FALSE: EXIT; end; // e.g. Media, optional

    case pr.registerExtension(edtExtension.text, edtExtFriendlyName.text, edtMimeType.text, edtPerceivedType.text) of  TRUE: lblResult.caption := 'register extension = TRUE';
                                                                                                                      FALSE: lblResult.caption := 'register extension = FALSE'; end

  finally
    pr.free;
  end;
end;

end.
