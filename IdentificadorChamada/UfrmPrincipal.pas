unit UfrmPrincipal;

{EXEMPLO
  Desenvolvedor: Armando Corrêa
  e-mail: kikobatery@hotmail.com
}

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Imaging.jpeg,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,

  UAD101,
  UBASS;

type
  TfrmPrincipal = class(TForm)
    Image1: TImage;
    GroupBox1: TGroupBox;
    radioCorLed: TRadioGroup;
    radioFrequenciaLed: TRadioGroup;
    GroupBox2: TGroupBox;
    btnIniciar: TButton;
    btnLiberar: TButton;
    ListView1: TListView;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    GroupBox3: TGroupBox;
    edtSalvar: TEdit;
    Label6: TLabel;
    btnCapturarCaminho: TButton;
    SaveDialog: TSaveDialog;
    Label7: TLabel;
    cmbAudio: TComboBox;
    btnCarregarAudio: TButton;
    lblTipoAudio: TLabel;
    procedure btnIniciarClick(Sender: TObject);
    procedure btnLiberarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure radioCorLedClick(Sender: TObject);
    Procedure OnDeviceMsg(var msg: TMessage); Message WM_USBLINEMSG;
    procedure radioFrequenciaLedClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCapturarCaminhoClick(Sender: TObject);
    procedure btnCarregarAudioClick(Sender: TObject);
    procedure cmbAudioChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FLine : Integer;

    procedure MudaStatusCorLed;
    procedure DispositivoDesativado;
    procedure DispositivoAtivado;
    procedure Estado(nLparam: Integer);
    procedure Identificador;
    procedure NumDiscado;
    procedure NumColateral;
    procedure CPUID;
    procedure ChamadaPerdida;
    procedure TempoLigacao(nLparam : Integer);
    procedure AtualizaInfoEntrada;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

procedure TfrmPrincipal.btnIniciarClick(Sender: TObject);
begin
  if not TAD101.IniciaDispositivo(Self.Handle) then
    raise Exception.Create('Não foi possível iniciar o dispositivo');

  TAD101.AbreDispositivo;
  radioCorLed.ItemIndex := 3;
end;

procedure TfrmPrincipal.btnLiberarClick(Sender: TObject);
begin
  radioCorLed.ItemIndex := 0;
  Sleep(1000);

  if not TAD101.LiberarDispositivo then
    Showmessage('Não foi possível liberar o dispositivo');
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TBass.LiberarGravacao;
  TBass.LiberarDispositivo;

  btnLiberarClick(Sender);
  Action := caFree;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  tempItem : Tlistitem;
  I        : Integer;
begin
  edtSalvar.Text := ExtractFilePath(Application.ExeName) + 'ligacao.wav';

  for I := 1 to 4 do
  begin
    tempItem         := listview1.Items.Add;
    tempItem.Caption := ('Linha '+ IntToStr(I));

    tempItem.SubItems.Add('Desativado');
    tempItem.SubItems.Add('');
    tempItem.SubItems.Add('');
    tempItem.SubItems.Add('');
    tempItem.SubItems.Add('');
    tempItem.SubItems.Add('');
    tempItem.SubItems.Add('');
  end;

  ListView1.ItemIndex := 0;
  btnCarregarAudioClick(Sender);
end;

procedure TfrmPrincipal.radioCorLedClick(Sender: TObject);
begin
  Self.MudaStatusCorLed;
end;

procedure TfrmPrincipal.radioFrequenciaLedClick(Sender: TObject);
begin
  Self.MudaStatusCorLed;
end;

procedure TfrmPrincipal.MudaStatusCorLed;
var
  vLinha : Integer;
begin
  vLinha := ListView1.ItemIndex;

  case radioFrequenciaLed.ItemIndex of
    0: //Fixa
      case radioCorLed.ItemIndex of
        0: //Desligada
          TAD101.Led(vLinha, LED_CLOSE);
        1: //Vermelho
          TAD101.Led(vLinha, LED_RED);
        2: //Amarelo
          TAD101.Led(vLinha, LED_YELLOW);
        3: //Verde
          TAD101.Led(vLinha, LED_GREEN);
      end;
    1: //Piscando Lentamente
      case radioCorLed.ItemIndex of
        0: //Desligada
          TAD101.Led(vLinha, LED_CLOSE);
        1: //Vermelho
          TAD101.Led(vLinha, LED_REDSLOW);
        2: //Amarelo
          TAD101.Led(vLinha, LED_YELLOWSLOW);
        3: //Verde
          TAD101.Led(vLinha, LED_GREENSLOW);
      end;
    2: //Piscando Rapidamente
      case radioCorLed.ItemIndex of
        0: //Desligada
          TAD101.Led(vLinha, LED_CLOSE);
        1: //Vermelho
          TAD101.Led(vLinha, LED_REDQUICK);
        2: //Amarelo
          TAD101.Led(vLinha, LED_YELLOWQUICK);
        3: //Verde
          TAD101.Led(vLinha, LED_GREENQUICK);
      end;
  end;
end;

procedure TfrmPrincipal.OnDeviceMsg (var msg: TMessage);
var
  nMsg     : integer;
  nWaparam : integer;
  nLparam  : integer;
begin
  nWaparam := msg.WParam;
  nLparam  := msg.LParam;
  nMsg     := nWaparam Mod 65536;
  FLine    := Trunc(nWaparam / 65536);

  case nMsg of
    MCU_BACKDISABLE :
      Self.DispositivoDesativado;
    MCU_BACKENABLE :
      Self.DispositivoAtivado;
    MCU_BACKSTATE:
      Self.Estado(nLparam);
    MCU_BACKCID:
      Self.Identificador;
    MCU_BACKDIGIT:
      Self.NumDiscado;
    MCU_BACKCOLLATERAL:
      Self.NumColateral;
    MCU_BACKCPUID:
      Self.CPUID;
    MCU_BACKMISSED:
      Self.ChamadaPerdida;
    MCU_BACKTALK:
      Self.TempoLigacao(nLparam);
  end;
end;

procedure TfrmPrincipal.DispositivoDesativado;
begin
  listview1.Items[FLine].SubItems[0] := 'Desativada';
  listview1.Items[FLine].SubItems[1] := '';
  listview1.Items[FLine].SubItems[2] := '';
  listview1.Items[FLine].SubItems[3] := '';
  listview1.Items[FLine].SubItems[4] := '';
  listview1.Items[FLine].SubItems[5] := '';
  listview1.Items[FLine].SubItems[6] := '';
end;

procedure TfrmPrincipal.DispositivoAtivado;
begin
  listview1.Items[FLine].SubItems[0] := 'Ativada';
end;

procedure TfrmPrincipal.Estado(nLparam: Integer);
var
  Buffer : PAnsiChar;
  Toque  : string[32];
begin
  GetMem(Buffer, 128);

  case nLparam of
    1://HKONSTATEPRA:
    begin
      listview1.Items[FLine].SubItems[1] := 'Gancho P+';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.PararGravacao(edtSalvar.Text);
    end;
    2://HKONSTATEPRB:
    begin
      listview1.Items[FLine].SubItems[1] := 'Gancho P-';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.PararGravacao(edtSalvar.Text);
    end;
    3://HKONSTATENOPR
    begin
      listview1.Items[FLine].SubItems[1] := 'Gancho SPR';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.PararGravacao(edtSalvar.Text);
    end;
    4://HKOFFSTATEPRA
    begin
      listview1.Items[FLine].SubItems[1] := 'Fora do Gancho PR+';

      if (TAD101.PegaIdenCham(FLine, Buffer, nil, nil) < 1) and
         (TAD101.PegaToques(FLine) < 1) then
        listview1.Items[FLine].SubItems[2] := '';

      listview1.Items[FLine].SubItems[3] := '';
      listview1.Items[FLine].SubItems[4] := '';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.IniciarGravacao;
    end;
    5:   //HKOFFSTATEPRB
    begin
      listview1.Items[FLine].SubItems[1] := 'Fora do Gancho PR-';

      if (TAD101.PegaIdenCham(FLine, Buffer, nil, nil) < 1) and
         (TAD101.PegaToques(FLine) < 1) then
        listview1.Items[FLine].SubItems[2] := '';

      listview1.Items[FLine].SubItems[3] := '';
      listview1.Items[FLine].SubItems[4] := '';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.IniciarGravacao;
    end;
    6: // NO_LINE
    begin
      listview1.Items[FLine].SubItems[1] := 'Sem Linha';

      if (TAD101.PegaIdenCham(FLine, Buffer, nil, nil) < 1) and
         (TAD101.PegaToques(FLine) < 1) then
        listview1.Items[FLine].SubItems[2] := '';

      listview1.Items[FLine].SubItems[3] := '';
      listview1.Items[FLine].SubItems[4] := '';
    end;
    7://RINGONSTATE
    begin
      Toque                              := FormatFloat('Toques:00', TAD101.PegaToques(FLine));
      listview1.Items[FLine].SubItems[1] := Toque;
    end;
    8://RINGOFFSTATE
      listview1.Items[FLine].SubItems[1] := 'Telefone Desligado';
    9://NOHKPRA
    begin
      listview1.Items[FLine].SubItems[1] := 'No Gancho PR+';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.PararGravacao(edtSalvar.Text);
    end;
    10://NOHKPRB
    begin
      listview1.Items[FLine].SubItems[1] := 'No Gancho PR-';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.PararGravacao(edtSalvar.Text);
    end;
    11://NOHKNOPR
    begin
      listview1.Items[FLine].SubItems[1] := 'No Gancho NOPR';

      if cmbAudio.ItemIndex <> -1 then
        TBassPlus.PararGravacao(edtSalvar.Text);
    end;
  end;

  FreeMem(Buffer);
end;

procedure TfrmPrincipal.Identificador;
var
  Buffer : pAnsiChar;
  Name   : pAnsiChar;
  Time   : pAnsiChar;
begin
  GetMem(Buffer, 128);
  GetMem(Name, 128);
  GetMem(Time, 128);

  TAD101.PegaIdenCham(FLine, Buffer, Name, Time);
  listview1.Items[FLine].SubItems[2] := Buffer;
  listview1.Items[FLine].SubItems[3] := '';
  listview1.Items[FLine].SubItems[4] := '';

  FreeMem(Buffer);
  FreeMem(Name);
  FreeMem(Time);
end;

procedure TfrmPrincipal.NumDiscado;
var
  Buffer : pAnsiChar;
begin
  GetMem(Buffer, 128);

  TAD101.PegaDigitosDiscados(FLine, Buffer);
  listview1.Items[FLine].SubItems[3] := Buffer;
  listview1.Items[FLine].SubItems[2] := '';
  listview1.Items[FLine].SubItems[4] := '';

  FreeMem(Buffer);
end;

procedure TfrmPrincipal.NumColateral;
var
  Buffer : pAnsiChar;
begin
  GetMem(Buffer,128);

  TAD101.PegaDigitosColaterais(FLine, Buffer);
  listview1.Items[FLine].SubItems[3] := Buffer;
  listview1.Items[FLine].SubItems[2] := '';
  listview1.Items[FLine].SubItems[4] := '';

  FreeMem(Buffer);
end;

procedure TfrmPrincipal.CPUID;
var
  Buffer : pAnsiChar;
begin
  GetMem(Buffer,128);

  TAD101.PegaIdenCPU(FLine, Buffer);
  listview1.Items[FLine].SubItems[5] := Buffer;

  FreeMem(Buffer);
end;

procedure TfrmPrincipal.ChamadaPerdida;
begin
  listview1.Items[FLine].SubItems[1] := 'Chamada Perdida';
end;

procedure TfrmPrincipal.TempoLigacao(nLparam : Integer);
var
  Tempo : string[32];
begin
  Tempo := FormatFloat('00', nLparam);
  listview1.Items[FLine].SubItems[4] := Tempo;
end;


//ROTINAS DA GRAVAÇÃO DO AUDIO


procedure TfrmPrincipal.cmbAudioChange(Sender: TObject);
var
  I : Integer;
  R : Boolean;
begin
  R := True;
  I := 0;

  // Desabilitar todas as Entradas
  while r do
  begin
    R := TBass.EntradaGravacao(I, BASS_INPUT_OFF, -1);
    Inc(I);
  end;

  //Habilita somente a Selecionada
  TBass.EntradaGravacao(cmbAudio.ItemIndex, BASS_INPUT_ON, -1);
  Self.AtualizaInfoEntrada;
end;

procedure TFrmPrincipal.AtualizaInfoEntrada;
var
  I     : DWord;
  Level : Single;
begin
  I := TBass.PegaNomeEntrada(cmbAudio.ItemIndex, Level);

  case (I and BASS_INPUT_TYPE_MASK) of
    BASS_INPUT_TYPE_DIGITAL:
      lblTipoAudio.Caption := 'digital';
    BASS_INPUT_TYPE_LINE:
      lblTipoAudio.Caption := 'line-in';
    BASS_INPUT_TYPE_MIC:
      lblTipoAudio.Caption := 'microphone';
    BASS_INPUT_TYPE_SYNTH:
      lblTipoAudio.Caption := 'midi synth';
    BASS_INPUT_TYPE_CD:
      lblTipoAudio.Caption := 'analog cd';
    BASS_INPUT_TYPE_PHONE:
      lblTipoAudio.Caption := 'telephone';
    BASS_INPUT_TYPE_SPEAKER:
      lblTipoAudio.Caption := 'pc speaker';
    BASS_INPUT_TYPE_WAVE:
      lblTipoAudio.Caption := 'wave/pcm';
    BASS_INPUT_TYPE_AUX:
      lblTipoAudio.Caption := 'aux';
    BASS_INPUT_TYPE_ANALOG:
      lblTipoAudio.Caption := 'analog';
    else
      lblTipoAudio.Caption := 'undefined';
    end;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  TBass.LiberarGravacao;
  TBass.LiberarDispositivo;
  TBass.PararGravacao;
end;

procedure TfrmPrincipal.btnCapturarCaminhoClick(Sender: TObject);
begin
  SaveDialog.FileName := 'ligacao.wav';
  SaveDialog.Execute;

  if SaveDialog.FileName <> '' then
    edtSalvar.Text := SaveDialog.FileName;
end;

procedure TfrmPrincipal.btnCarregarAudioClick(Sender: TObject);
var
  i     : Integer;
  dName : PAnsiChar;
  level : Single;
begin
  cmbAudio.Clear;

  TBass.LiberarGravacao;
  TBass.LiberarDispositivo;

  TBass.PegaVersao;
  TBass.IniciaGravacao(-1);
  TBass.IniciaDispositivo(-1, 44100, 0, Handle, nil);

  i     := 0;
  dName := TBass.PegaNomeDispositivo(i);

  while dName <> nil do
  begin
    cmbAudio.Items.Add(StrPas(dName));

    // Seleciona o Dispositivo Ativo
    if (TBass.PegaNomeEntrada(i, level) and BASS_INPUT_OFF) = 0 then
      cmbAudio.ItemIndex := i;

    Inc(i);
    dName := TBass.PegaNomeDispositivo(i);
  end;
  cmbAudioChange(Self);
end;

end.
