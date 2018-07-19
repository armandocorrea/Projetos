unit UAD101;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils;

const
  WM_USBLINEMSG      = WM_USER + 180; //API do Windows para Escutar a Porta USB
  MCU_BACKID	       = $07; //Retorna ID do dispositivo
  MCU_BACKSTATE      = $08; //Retorna estado do dispositivo
  MCU_BACKCID	       = $09; //Retorna número do telefone
  MCU_BACKDIGIT	     = $0A; //Retorna dígito discado
  MCU_BACKDEVICE     = $0B; //Retorna Device Back Device ID
  //MCU_BACKPARAM	     = $0C; //Retorna Device Paramter
  MCU_BACKCPUID	     = $0D; //Retorna Device CPU ID
  MCU_BACKCOLLATERAL = $0E; //Retorna Collateral phone dialed
  MCU_BACKDISABLE    = $FF; //Retorna Finalização do Dispositivo
  MCU_BACKENABLE	   = $EE; //Retorna Inicialização do Dispositivo
  MCU_BACKMISSED	   = $AA; //Ligação não atendida
  MCU_BACKTALK	     = $BB; //Início da Chamada

type
  TLEDTYPE = (LED_CLOSE=1,   LED_RED,        LED_GREEN,    LED_YELLOW,     LED_REDSLOW,
              LED_GREENSLOW, LED_YELLOWSLOW, LED_REDQUICK, LED_GREENQUICK, LED_YELLOWQUICK);

Type
  TAD101 = class
    public
      class function  IniciaDispositivo(pHandle: THandle) : Boolean;
      class function  LiberarDispositivo : Boolean;
      class procedure Led(Linha: Integer; Status: TLEDTYPE);
      class function  PegaIdenCham(Linha: Integer; Buffer, Nome, Tempo : PAnsiChar) : Integer;
      class function  PegaToques(Linha: Integer) : Integer;
      class function  PegaDigitosDiscados(Linha: Integer; Buffer: PAnsiChar) : Integer;
      class function  PegaDigitosColaterais(Linha: Integer; Buffer: PAnsiChar) : Integer;
      class function  PegaIdenCPU(Linha: Integer; Buffer: PAnsiChar) : Integer;
      class function  AbreDispositivo : Integer;
  end;

var
  HandleDLL: THandle;

implementation

{ TAD101 }

//function AD101_InitDevice(APP:THandle) : Integer; stdcall; external 'AD101Device.dll';
class function TAD101.IniciaDispositivo(pHandle: THandle): Boolean;
var
  Proc     : function (Handle: THandle) : Integer; stdcall;
  vRetorno : Integer;
begin
  Result  := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_InitDevice');
  if @Proc <> nil then
  begin
    vRetorno := Proc(pHandle);
    if vRetorno = 1 then
    begin
      Beep;
      Result := True;
    end;
  end;
end;

//procedure AD101_SetLED(nLine:integer;enumLed :TLEDTYPE);stdcall;external 'AD101Device.DLL';
class procedure TAD101.Led(Linha: Integer; Status: TLEDTYPE);
var
  Proc : procedure (Linha: Integer; Status: TLEDTYPE) ; stdcall;
begin
  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_SetLED');
  if @Proc <> nil then
  begin
    try
      Proc(Linha, Status);
    except
    end;
  end;
end;

//procedure AD101_FreeDevice();stdcall;external 'AD101Device.dll';
class function TAD101.LiberarDispositivo: Boolean;
var
  Proc : procedure ; stdcall;
begin
  Result := False;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_FreeDevice');
  if @Proc <> nil then
  begin
    try
      Proc;
      Result := True;
    except
    end;
  end;
end;

//function AD101_GetCallerID(nLine:integer;szCallerIDBuffer:PChar;szName:Pchar;szTime:pchar):integer;stdcall;external 'AD101Device.DLL' ;
class function TAD101.PegaIdenCham(Linha: Integer; Buffer, Nome, Tempo : PAnsiChar) : Integer;
var
  Proc     : function (Linha: Integer; Buffer, Nome, Tempo : PAnsiChar) : Integer ; stdcall;
  vRetorno : Integer;
begin
  Result   := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_GetCallerID');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Linha, Buffer, Nome, Tempo);
    except
    end;
  end;
end;

//function AD101_GetRingIndex(nLine:integer):integer;stdcall;external 'AD101Device.DLL';
class function TAD101.PegaToques(Linha: Integer) : Integer;
var
  Proc : function (Linha: Integer) : Integer ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_GetRingIndex');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Linha);
    except
    end;
  end;
end;

//function AD101_GetDialDigit(nLine:integer;szDialDigitBuffer:PChar):integer;stdcall;external 'AD101Device.DLL' ;
class function TAD101.PegaDigitosDiscados(Linha: Integer; Buffer: PAnsiChar) : Integer;
var
  Proc : function (Linha: Integer; Buffer: PAnsiChar) : Integer ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_GetDialDigit');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Linha, Buffer);
    except
    end;
  end;
end;

//function AD101_GetCollateralDialDigit(nLine:integer;szDialDigitBuffer:PChar):integer;stdcall;external 'AD101Device.DLL' ;
class function TAD101.PegaDigitosColaterais(Linha: Integer; Buffer: PAnsiChar) : Integer;
var
  Proc : function (Linha: Integer; Buffer: PAnsiChar) : Integer ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_GetCollateralDialDigit');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Linha, Buffer);
    except
    end;
  end;
end;

//function AD101_GetCPUID(nLine:integer;szCPUID:PChar):integer;stdcall;external 'AD101Device.DLL' ;
class function TAD101.PegaIdenCPU(Linha: Integer; Buffer: PAnsiChar) : Integer;
var
  Proc : function (Linha: Integer; Buffer: PAnsiChar) : Integer ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_GetCPUID');
  if @Proc <> nil then
  begin
    try
      Result := Proc(Linha, Buffer);
    except
    end;
  end;
end;

//function AD101_GetDevice():integer;stdcall;external 'AD101Device.dll';
class function TAD101.AbreDispositivo : Integer;
var
  Proc : function () : Integer ; stdcall;
begin
  Result := 0;

  if HandleDLL = 0 then
    raise Exception.Create('DLL não foi carregada.' + #13 + 'Verifique se a mesma se encontra na pasta do Executável.');

  @Proc := GetProcAddress(HandleDLL, 'AD101_GetDevice');
  if @Proc <> nil then
  begin
    try
      Result := Proc();
    except
    end;
  end;
end;


//ROTINAS ABAIXO PARA CARREGAR A DLL COMO PONTEIRO POR LOADLIBRARY

procedure CarregarDLL;
begin
  HandleDLL := 0;
  HandleDLL := LoadLibrary('AD101Device.dll');
end;

{procedure LiberarDLL;
begin
  FreeLibrary(HandleDLL);
end;}

Initialization
  CarregarDLL;

Finalization
  //LiberarDLL;

end.
