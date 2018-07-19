unit UBASS;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Dialogs;

type
  DWORD   = LongWord;
  BOOL    = LongBool;
  QWORD   = Int64;
  HRECORD = DWORD;   // Ponteiro da Gravaca
  HSTREAM = DWORD;   // Fluxo de Amostra

type
  WAVHDR = packed record
    riff           : array[0..3] of AnsiChar;
    len            : DWord;
    cWavFmt        : array[0..7] of AnsiChar;
    dwHdrLen       : DWord;
    wFormat        : Word;
    wNumChannels   : Word;
    dwSampleRate   : DWord;
    dwBytesPerSec  : DWord;
    wBlockAlign    : Word;
    wBitsPerSample : Word;
    cData          : array[0..3] of AnsiChar;
    dwDataLen      : DWord;
  end;

type
  RECORDPROC = function(handle: HRECORD; buffer: Pointer; length: DWORD; user: Pointer): BOOL; stdcall;

const
  BASSVERSION    = $204;    // API version
  BASS_INPUT_OFF = $10000;  // Desabilita Entrada
  BASS_INPUT_ON  = $20000;  // Habilita Entrada

  BASS_INPUT_TYPE_MASK    = $FF000000;
  BASS_INPUT_TYPE_UNDEF   = $00000000;
  BASS_INPUT_TYPE_DIGITAL = $01000000;
  BASS_INPUT_TYPE_LINE    = $02000000;
  BASS_INPUT_TYPE_MIC     = $03000000;
  BASS_INPUT_TYPE_SYNTH   = $04000000;
  BASS_INPUT_TYPE_CD      = $05000000;
  BASS_INPUT_TYPE_PHONE   = $06000000;
  BASS_INPUT_TYPE_SPEAKER = $07000000;
  BASS_INPUT_TYPE_WAVE    = $08000000;
  BASS_INPUT_TYPE_AUX     = $09000000;
  BASS_INPUT_TYPE_ANALOG  = $0A000000;

Type
  TBass = class
    class function PegaVersao: DWORD;
    class function IniciaDispositivo(Dispositivo: LongInt; Frequencia, Flag: DWORD; Handle: HWND; classe: PGUID): Boolean;
    class function IniciaGravacao(Dispositivo : LongInt) : Boolean;
    class function PegaNomeDispositivo(Dispositivo : LongInt) : PAnsiChar;
    class function PegaNomeEntrada(Dispositivo: LongInt; var Volume: Single) : DWORD;
    class function LiberarGravacao: Boolean;
    class function LiberarDispositivo: Boolean;
    class function EntradaGravacao(Entrada: LongInt; Flags: DWORD; Volume: Single): Boolean;
    class function PararGravacao: Boolean;
    class function CanalAtivado(Handle: DWORD): DWORD;
    class function PararCanal(Handle : DWORD): Boolean;
    class function CriarArquivoCorrente(Memoria: BOOL; Ponteiro: Pointer; offset, Tamanho: QWORD; Flags: DWORD): HSTREAM;
    class function LiberarArquivoCorrente(Handle: HSTREAM): Boolean;
    class function Gravar(Frequencia, Chans, Flags: DWORD; Processo: RECORDPROC; Usuario: Pointer): HRECORD;
  end;

  TBassPlus = class
      class procedure IniciarGravacao;
      class procedure PararGravacao(const pPath: String);
    private
      class procedure SalvarArquivo(const pPath: String);
  end;

var
  HandleDLL  : THandle;
  WaveStream : TMemoryStream;
  RChan      : HRECORD;	// Canal de Gravação
  Chan       : HSTREAM;	// Canal de Reprodução
  WaveHdr    : WAVHDR;  // WAV header

implementation


{ TBass }

//function BASS_GetVersion: DWORD; stdcall; external 'bass.dll';
class function TBass.PegaVersao: DWORD;
var
  Proc : function () : DWORD ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_GetVersion');
  if @Proc <> nil then
  begin
    try
      Result := Proc();
      if HIWORD(Result) <> BASSVERSION then
        raise Exception.Create('Versão Incorreta da DLL.');
    except
    end;
  end;
end;

//function BASS_Init(device: LongInt; freq, flags: DWORD; win: HWND; clsid: PGUID): BOOL; stdcall; external 'bass.dll';
class function TBass.IniciaDispositivo(Dispositivo: LongInt; Frequencia, Flag: DWORD; Handle: HWND; classe: PGUID): Boolean;
var
  Proc     : function (Dispositivo: LongInt; Frequencia, Flag: DWORD; Handle: HWND; classe: PGUID) : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_Init');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc(Dispositivo, Frequencia, Flag, Handle, classe);
      if not vRetorno then
        raise Exception.Create('Não foi possível iniciar o dispositivo de gravação padrão!');
    except on
      E: Exception do
        raise Exception.Create(e.Message);
    end;
  end;
end;

//function BASS_RecordInit(device: LongInt):BOOL; stdcall; external 'bass.dll';
class function TBass.IniciaGravacao(Dispositivo : LongInt) : Boolean;
var
  Proc     : function (Dispositivo: LongInt) : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_RecordInit');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc(Dispositivo);
      if not vRetorno then
        raise Exception.Create('Não foi possível iniciar o dispositivo de gravação padrão!');
    except on
      E: Exception do
        raise Exception.Create(e.Message);
    end;
  end;
end;

//function BASS_RecordGetInputName(input: LongInt): PAnsiChar; stdcall; external 'bass.dll';
class function TBass.PegaNomeDispositivo(Dispositivo : LongInt) : PAnsiChar;
var
  Proc : function (Dispositivo: LongInt) : PAnsiChar ; stdcall;
begin
  Result := '';

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_RecordGetInputName');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Dispositivo);
    except
    end;
  end;
end;

//function BASS_RecordGetInput(input: LongInt; var volume: Single): DWORD; stdcall; external 'bass.dll';
class function TBass.PegaNomeEntrada(Dispositivo: LongInt; var Volume: Single) : DWORD;
var
  Proc : function (Dispositivo: LongInt; var Volume: Single) : DWORD ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_RecordGetInput');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Dispositivo, Volume);
    except
    end;
  end;
end;

//function BASS_RecordFree: BOOL; stdcall; external 'bass.dll';
class function TBass.LiberarGravacao: Boolean;
var
  Proc     : function () : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_RecordFree');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc();
      if vRetorno then
        Result := True;
    except
    end;
  end;
end;

//function BASS_Free: BOOL; stdcall; external 'bass.dll';
class function TBass.LiberarDispositivo: Boolean;
var
  Proc     : function () : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_Free');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc();
      if vRetorno then
        Result := True;
    except
    end;
  end;
end;

//function BASS_RecordSetInput(input: LongInt; flags: DWORD; volume: Single): BOOL; stdcall; external 'bass.dll';
class function TBass.EntradaGravacao(Entrada: LongInt; Flags: DWORD; Volume: Single): Boolean;
var
  Proc     : function (Entrada: LongInt; Flags: DWORD; Volume: Single) : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_RecordSetInput');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc(Entrada, Flags, Volume);
      if vRetorno then
        Result := True;
    except
    end;
  end;
end;

//function BASS_Stop: BOOL; stdcall; external 'bass.dll';
class function TBass.PararGravacao: Boolean;
var
  Proc     : function () : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_Stop');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc();
      if vRetorno then
        Result := True;
    except
    end;
  end;
end;

//function BASS_ChannelIsActive(handle: DWORD): DWORD; stdcall ;external 'bass.dll';
class function TBass.CanalAtivado(Handle: DWORD): DWORD;
var
  Proc : function (Handle : DWORD) : DWORD ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_ChannelIsActive');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Handle);
    except
    end;
  end;
end;

//function BASS_ChannelStop(handle: DWORD): BOOL; stdcall; external 'bass.dll';
class function TBass.PararCanal(Handle : DWORD): Boolean;
var
  Proc     : function (Handle : DWORD) : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_ChannelStop');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc(Handle);
      if vRetorno then
        Result := True;
    except
    end;
  end;
end;

//function BASS_StreamCreateFile(mem: BOOL; f: Pointer; offset, length: QWORD; flags: DWORD): HSTREAM; stdcall; external 'bass.dll';
class function TBass.CriarArquivoCorrente(Memoria: BOOL; Ponteiro: Pointer; offset, Tamanho: QWORD; Flags: DWORD): HSTREAM;
var
  Proc : function (Memoria: BOOL; Ponteiro: Pointer; offset, Tamanho: QWORD; Flags: DWORD) : HSTREAM ; stdcall;
begin
  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_StreamCreateFile');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Memoria, Ponteiro, Offset, Tamanho, Flags);
    except
    end;
  end;
end;

//function BASS_StreamFree(handle: HSTREAM): BOOL; stdcall; external 'bass.dll';
class function TBass.LiberarArquivoCorrente(Handle: HSTREAM): Boolean;
var
  Proc     : function (Handle : HSTREAM) : BOOL ; stdcall;
  vRetorno : BOOL;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_StreamFree');
  if @Proc <> nil then
  begin
    try
      vRetorno := Proc(Handle);
      if vRetorno then
        Result := True;
    except
    end;
  end;
end;

//function BASS_RecordStart(freq, chans, flags: DWORD; proc: RECORDPROC; user: Pointer): HRECORD; stdcall; external 'bass.dll';
class function TBass.Gravar(Frequencia, Chans, Flags: DWORD; Processo: RECORDPROC; Usuario: Pointer): HRECORD;
var
  Proc : function (Frequencia, Chans, Flags: DWORD; Proc: RECORDPROC; Usuario: Pointer) : HRECORD ; stdcall;
begin
  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'BASS_RecordStart');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Frequencia, Chans, Flags, Processo, Usuario);
    except
    end;
  end;
end;

{ TBassPlus }

(* Chamado Enquanto estiver Gravando o Audio *)
function RecordingCallback(Handle: HRECORD; buffer: Pointer; length: DWORD; user: Pointer): boolean; stdcall;
begin
  // Copie o novo conteúdo do buffer para o buffer de memória
	WaveStream.Write(buffer^, length);
  // Permitir que a gravação continue
	Result := True;
end;

class procedure TBassPlus.IniciarGravacao;
begin
	if WaveStream.Size > 0 then // Libera Gravação Antiga
  begin
		TBass.LiberarArquivoCorrente(Chan);
		WaveStream.Clear;
	end;

	// Gera Cabeçalho do Arquivo Wav
	with WaveHdr do
  begin
		riff           := 'RIFF';
		len            := 36;
		cWavFmt        := 'WAVEfmt ';
		dwHdrLen       := 16;
		wFormat        := 1;
		wNumChannels   := 2;
		dwSampleRate   := 44100;
		wBlockAlign    := 4;
		dwBytesPerSec  := 176400;
		wBitsPerSample := 16;
		cData          := 'data';
		dwDataLen      := 0;
  end;

	WaveStream.Write(WaveHdr, SizeOf(WAVHDR));
	// Inicia Gravação @ 44100hz 16-bit stereo
	RChan := TBass.Gravar(44100, 2, 0, @RecordingCallback, nil);
	if RChan = 0 then
	begin
 		WaveStream.Clear;
    raise Exception.Create('Não foi possível gravar!');
	end;
end;

class procedure TBassPlus.PararGravacao(const pPath: String);
var
  I : Integer;
begin
  if TBass.CanalAtivado(RChan) <> 0 then
  begin
    TBass.PararCanal(RChan);

    // Completando o Cabeçalho do Arquivo Wave
    WaveStream.Position := 4;
    I := WaveStream.Size - 8;
    WaveStream.Write(I, 4);

    I := I - $24;
    WaveStream.Position := 40;
    WaveStream.Write(I, 4);

    WaveStream.Position := 0;

    // Criando o Stream para Gravação do Audio
    Chan := TBass.CriarArquivoCorrente(True, WaveStream.Memory, 0, WaveStream.Size, 0);
    if Chan = 0 then
      raise Exception.Create('Erro ao criar o Stream da Gravação do Audio!');

    Self.SalvarArquivo(pPath);
  end;
end;

class procedure TBassPlus.SalvarArquivo(const pPath: String);
begin
  try
    WaveStream.SaveToFile(pPath);
    Messagedlg('Gravação Salva em: ' + pPath, mtInformation, [mbOk], 0);
  except
  end;
end;


//ROTINAS ABAIXO PARA CARREGAR A DLL COMO PONTEIRO POR LOADLIBRARY

procedure Carregar;
begin
  HandleDLL := 0;
  HandleDLL := LoadLibrary('bass.dll');

  WaveStream := TMemoryStream.Create;
end;

procedure Liberar;
begin
  WaveStream.Free;
end;

Initialization
  Carregar;

Finalization
  Liberar;


end.
