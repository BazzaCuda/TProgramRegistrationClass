object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object lblResult: TLabel
    Left = 8
    Top = 408
    Width = 337
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'lblResult'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 232
    Width = 506
    Height = 129
  end
  object edtFullPathToExe: TLabeledEdit
    Left = 8
    Top = 39
    Width = 498
    Height = 23
    EditLabel.Width = 81
    EditLabel.Height = 15
    EditLabel.Caption = 'Full Path to Exe'
    TabOrder = 0
    Text = 
      'B:\Win64_Dev\TProgramRegistrationClass\testProgram\Win64\Release' +
      '\testProgram.exe'
  end
  object Button1: TButton
    Left = 512
    Top = 38
    Width = 113
    Height = 25
    Caption = 'Register App Path'
    TabOrder = 1
    OnClick = Button1Click
  end
  object edtFriendlyAppName: TLabeledEdit
    Left = 8
    Top = 87
    Width = 498
    Height = 23
    EditLabel.Width = 102
    EditLabel.Height = 15
    EditLabel.Caption = 'Friendly App Name'
    TabOrder = 2
    Text = 'My TestProgram'
  end
  object Button2: TButton
    Left = 512
    Top = 86
    Width = 113
    Height = 25
    Caption = 'Register Friendly'
    TabOrder = 3
    OnClick = Button2Click
  end
  object edtSystemFileType: TLabeledEdit
    Left = 8
    Top = 135
    Width = 498
    Height = 23
    EditLabel.Width = 86
    EditLabel.Height = 15
    EditLabel.Caption = 'System File Type'
    TabOrder = 4
    Text = 'audio'
  end
  object Button3: TButton
    Left = 512
    Top = 134
    Width = 113
    Height = 25
    Caption = 'Associate App'
    TabOrder = 5
    OnClick = Button3Click
  end
  object edtCapabilitiesType: TLabeledEdit
    Left = 8
    Top = 183
    Width = 498
    Height = 23
    EditLabel.Width = 88
    EditLabel.Height = 15
    EditLabel.Caption = 'Capabilities Type'
    TabOrder = 6
    Text = 'Media'
  end
  object Button4: TButton
    Left = 512
    Top = 182
    Width = 113
    Height = 25
    Caption = 'Associate App'
    TabOrder = 7
    OnClick = Button4Click
  end
  object edtExtension: TLabeledEdit
    Left = 8
    Top = 259
    Width = 121
    Height = 23
    EditLabel.Width = 51
    EditLabel.Height = 15
    EditLabel.Caption = 'Extension'
    TabOrder = 8
    Text = '.mywav'
  end
  object edtExtFriendlyName: TLabeledEdit
    Left = 145
    Top = 259
    Width = 121
    Height = 23
    EditLabel.Width = 77
    EditLabel.Height = 15
    EditLabel.Caption = 'Friendly Name'
    TabOrder = 9
    Text = 'Wave Audio'
  end
  object edtMimeType: TLabeledEdit
    Left = 8
    Top = 320
    Width = 121
    Height = 23
    EditLabel.Width = 113
    EditLabel.Height = 15
    EditLabel.Caption = 'Mime Type (optional)'
    TabOrder = 10
    Text = 'audio/wav'
  end
  object edtPerceivedType: TLabeledEdit
    Left = 145
    Top = 320
    Width = 121
    Height = 23
    EditLabel.Width = 133
    EditLabel.Height = 15
    EditLabel.Caption = 'Perceived Type (optional)'
    TabOrder = 11
    Text = 'audio'
  end
  object btnRegisterExtension: TButton
    Left = 321
    Top = 319
    Width = 161
    Height = 25
    Caption = 'Register Extension'
    TabOrder = 12
    OnClick = btnRegisterExtensionClick
  end
  object edtProgIDPrefix: TLabeledEdit
    Left = 321
    Top = 259
    Width = 121
    Height = 23
    EditLabel.Width = 69
    EditLabel.Height = 15
    EditLabel.Caption = 'ProgID Prefix'
    TabOrder = 13
    Text = 'my.testprogram'
  end
  object btnOneStep: TButton
    Left = 431
    Top = 404
    Width = 189
    Height = 25
    Caption = 'All in One Step'
    TabOrder = 14
    OnClick = btnOneStepClick
  end
end
