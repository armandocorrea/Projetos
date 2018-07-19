unit HandleContext;

interface

Uses
  System.SysUtils, System.Variants, System.Classes, Winapi.Windows,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdContext, ServerUtils, Systypes;

type
    TServerContext = class (TIdServerContext)
    Private
        fLogApp       : TStrings;
        fRequestInfo  : TIdHTTPRequestInfo;
        fResponseInfo : TIdHTTPResponseInfo;

        function GetArguments : TArguments;
        Function ReturnIncorrectArgs  : String;
        Function ReturnMethodNotFound : String;

        function CallGETServerMethod (Argumentos : TArguments) : string;
    public
        // Dispara (Dispatch) os vários ServerMethods
        Function HandleRequest (aRequestInfo : TIdHTTPRequestInfo;
                                aResponseInfo : TIdHTTPResponseInfo;
                                Const aCmd : String;
                                aLog : TStrings) : string;
        // Loga especialmente dados do negócio
        procedure LogBusiness (const s: String);

        property LogApp       : TStrings read fLogApp write fLogApp;
        property RequestInfo  : TIdHTTPRequestInfo read fRequestInfo write fRequestInfo;
        property ResponseInfo : TIdHTTPResponseInfo read fResponseInfo write fResponseInfo;
    end;

implementation

uses
    ServerMethodsUnit1, SMRodadas, SMClassificacao, SMUtilitarios;

Var
  ContextCriticalSection: TRTLCriticalSection;


{ TServerContext }

function TServerContext.GetArguments : TArguments;
Begin
     if fRequestInfo.Params.Count > 0 then begin
        Result := TServerUtils.ParseWebFormsParams (fRequestInfo.Params, fRequestInfo.URI);
     End Else
        Result := TServerUtils.ParseRESTURL (fRequestInfo.URI);
End;

procedure TServerContext.LogBusiness (const s: String);
Begin
     EnterCriticalSection(ContextCriticalSection);
     LogApp.Add('From IP : ' + Connection.Socket.Binding.PeerIP + ' - ' +
                               DateTimeToStr(Now) + ' - ' +  S);
     LeaveCriticalSection(ContextCriticalSection);
End;

Function TServerContext.HandleRequest(aRequestInfo: TIdHTTPRequestInfo;
                                      aResponseInfo: TIdHTTPResponseInfo;
                                      Const aCmd : String;
                                      aLog : TStrings) : String;
Var
     Argumentos    : TArguments;
begin
     fRequestInfo  := aRequestInfo;
     fResponseInfo := aResponseInfo;
     fLogApp       := aLog;
     Result        := '';

     Argumentos    := Self.GetArguments;
     If UpperCase(Copy (aCmd, 1, 3)) = 'GET' Then
        Result := CallGETServerMethod(Argumentos);
end;

Function TServerContext.ReturnIncorrectArgs : String;
Var
     WSResult : TResultErro;
begin
     WSResult.STATUS   := -1;
     WSResult.MENSAGEM := 'Total de argumentos menor que o esperado';
     Result := TServerUtils.Result2JSON(WSResult);
end;

Function TServerContext.ReturnMethodNotFound : String;
Var
     WSResult : TResultErro;
begin
     WSResult.STATUS   := -2;
     WSResult.MENSAGEM := 'Método não encontrado';
     Result := TServerUtils.Result2JSON(WSResult);
end;


function TServerContext.CallGETServerMethod (Argumentos : TArguments) : string;
var
  FoundMethod     : Boolean;
  SMRodadas       : TSMRodadas;
  SMClassificacao : TSMClassificacao;
  SMUtilitarios   : TSMUtilitarios;
begin
  FoundMethod     := False;
  SMRodadas       := TSMRodadas.Create(Self);
  SMClassificacao := TSMClassificacao.Create(Self);
  SMUtilitarios   := TSMUtilitarios.Create(Self);

  try
    if UpperCase(Argumentos[0]) = UpperCase('SMRodadas.Consulta') then
    begin
      FoundMethod := True;
      if Length (Argumentos) = 1 then
        Result := SMRodadas.Consulta
      else
        Result := ReturnIncorrectArgs;
    end
    else if UpperCase(Argumentos[0]) = UpperCase('SMClassificacao.Consulta') then
    begin
      FoundMethod := True;
      if Length (Argumentos) = 1 then
        Result := SMClassificacao.Consulta
      else
        Result := ReturnIncorrectArgs;
    end
    else if UpperCase(Argumentos[0]) = UpperCase('SMUtilitarios.Timezone') then
    begin
      FoundMethod := True;
      if Length (Argumentos) = 1 then
        Result := SMUtilitarios.Timezone
      else
        Result := ReturnIncorrectArgs;
    end;
  finally
    SMRodadas.Free;
    SMClassificacao.Free;

    if not FoundMethod then
      Result := ReturnMethodNotFound;
  end;
end;

initialization
  InitializeCriticalSection(ContextCriticalSection);

finalization
  DeleteCriticalSection(ContextCriticalSection);


end.
