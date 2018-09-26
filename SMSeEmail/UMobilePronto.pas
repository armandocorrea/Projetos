// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.mpgateway.com/v_3_00/sms/service.asmx?WSDL
//  >Import : http://www.mpgateway.com/v_3_00/sms/service.asmx?WSDL>0
// Encoding : utf-8
// Version  : 1.0
// (03/04/2017 21:24:41 - - $Rev: 86412 $)
// ************************************************************************ //

unit UMobilePronto;

interface

uses Soap.InvokeRegistry, Soap.SOAPHTTPClient, System.Types, Soap.XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_REF  = $0080;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:decimal         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]



  // ************************************************************************ //
  // Namespace : MobileProntoMPGateway
  // soapAction: MobileProntoMPGateway/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : MPGatewaySoap
  // service   : MPGateway
  // port      : MPGatewaySoap
  // URL       : http://www.mpgateway.com/v_3_00/sms/service.asmx
  // ************************************************************************ //
  MPGatewaySoap = interface(IInvokable)
  ['{D16F605F-F41E-1E4D-F1F1-FDD1A5E023E5}']
    function  MPG_Calculate_Message_Length_UTF8_or_UTF16(const Credencial: string; const Token: string; const Message_: string): Integer; stdcall;
    function  MPG_SendSimple_SMS(const Credencial: string; const Token: string; const Mobile: string; const Message_: string): string; stdcall;
    function  MPG_SendandFollowUp_SMS(const Credencial: string; const Token: string; const Principal_User: string; const Aux_User: string; const Mobile: string; const Send_Project: string; 
                                      const Message_: string): string; stdcall;
    function  MPG_Send_SMS(const Credencial: string; const Token: string; const Principal_User: string; const Aux_User: string; const Mobile: string; const Send_Project: string; 
                           const Message_: string): string; stdcall;
    function  MPG_Query01(const Credencial: string; const Token: string; const Start_Date: string; const End_Date: string; const Aux_User: string; const Mobile: string; 
                          const Status_Code: Integer; var Status: string): string; stdcall;
    function  MPG_Credits(const Credencial: string; const Token: string; var v_st_Status: string): TXSDecimal; stdcall;
    function  MPG_Send_LMS(const Credencial: string; const Token: string; const Principal_User: string; const Aux_User: string; const Mobile: string; const Message_: string
                           ): string; stdcall;
    function  MPG_Send_Long_SMS(const Credencial: string; const Token: string; const Principal_User: string; const Aux_User: string; const Mobile: string; const Message_: string
                                ): string; stdcall;
  end;

function GetMPGatewaySoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): MPGatewaySoap;
function StatusMobilePronto(const pResultado: Integer; var pTipo: String): String;


implementation
  uses System.SysUtils;

function GetMPGatewaySoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): MPGatewaySoap;
const
  defWSDL = 'http://www.mpgateway.com/v_3_00/sms/service.asmx?WSDL';
  defURL  = 'http://www.mpgateway.com/v_3_00/sms/service.asmx';
  defSvc  = 'MPGateway';
  defPrt  = 'MPGatewaySoap';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as MPGatewaySoap);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;

function StatusMobilePronto(const pResultado: Integer; var pTipo: String): String;
begin
  case pResultado of
    0:
    begin
      pTipo  := 'Sucesso';
      Result := 'Mensagem enviada com sucesso';
     end;
    1:
    begin
      pTipo  := 'Erro';
      Result := 'Credencial inválida';
    end;
    5:
    begin
      pTipo  := 'Erro';
      Result := 'MOBILE com formato inválido';
    end;
    8:
    begin
      pTipo  := 'Erro';
      Result := 'MESSAGE ou MESSAGE + NOME_PROJETO com mais de 160 posições ou SMS concatenado com mais de 1000 posições';
    end;
    9:
    begin
      pTipo  := 'Erro';
      Result := 'Créditos insuficientes em conta';
    end;
    10:
    begin
      pTipo  := 'Erro';
      Result := 'Gateway SMS da conta bloqueado';
    end;
    12:
    begin
      pTipo  := 'Erro';
      Result := 'MOBILE correto, porém com crítica';
    end;
    13:
    begin
      pTipo  := 'Erro';
      Result := 'Conteúdo da mensagem inválido ou vazio';
    end;
    15:
    begin
      pTipo  := 'Erro';
      Result := 'País sem cobertura ou não aceita mensagens concatenadas (SMS Longo)';
    end;
    16:
    begin
      pTipo  := 'Erro';
      Result := 'MOBILE com código de área inválido';
    end;
    17:
    begin
      pTipo  := 'Erro';
      Result := 'Operadora não autorizada para esta credencial';
    end;
    18:
    begin
      pTipo  := 'Erro';
      Result := 'MOBILE se encontra em lista negra';
    end;
    19:
    begin
      pTipo  := 'Erro';
      Result := 'Token inválido';
    end;
    22:
    begin
      pTipo  := 'Erro';
      Result := 'Conta atingiu o limite de envio do dia';
    end;
    800..899:
    begin
      pTipo  := 'Erro';
      Result := 'Falha no Gateway';
    end;
    900:
    begin
      pTipo  := 'Erro';
      Result := 'Erro de autenticação ou limite de segurança excedido';
    end;
    901..999:
    begin
      pTipo  := 'Erro';
      Result := 'Erro no acesso as operadoras';
    end;
  end;
end;

initialization
  { MPGatewaySoap }
  InvRegistry.RegisterInterface(TypeInfo(MPGatewaySoap), 'MobileProntoMPGateway', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(MPGatewaySoap), 'MobileProntoMPGateway/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(MPGatewaySoap), ioDocument);
  { MPGatewaySoap.MPG_Calculate_Message_Length_UTF8_or_UTF16 }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_Calculate_Message_Length_UTF8_or_UTF16', '',
                                 '[ReturnName="MPG_Calculate_Message_Length_UTF8_or_UTF16Result"]');
  InvRegistry.RegisterParamInfo(TypeInfo(MPGatewaySoap), 'MPG_Calculate_Message_Length_UTF8_or_UTF16', 'Message_', 'Message', '');
  { MPGatewaySoap.MPG_SendSimple_SMS }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_SendSimple_SMS', '',
                                 '[ReturnName="MPG_SendSimple_SMSResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(MPGatewaySoap), 'MPG_SendSimple_SMS', 'Message_', 'Message', '');
  { MPGatewaySoap.MPG_SendandFollowUp_SMS }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_SendandFollowUp_SMS', '',
                                 '[ReturnName="MPG_SendandFollowUp_SMSResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(MPGatewaySoap), 'MPG_SendandFollowUp_SMS', 'Message_', 'Message', '');
  { MPGatewaySoap.MPG_Send_SMS }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_Send_SMS', '',
                                 '[ReturnName="MPG_Send_SMSResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(MPGatewaySoap), 'MPG_Send_SMS', 'Message_', 'Message', '');
  { MPGatewaySoap.MPG_Query01 }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_Query01', '',
                                 '[ReturnName="MPG_Query01Result"]', IS_OPTN);
  { MPGatewaySoap.MPG_Credits }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_Credits', '',
                                 '[ReturnName="MPG_CreditsResult"]');
  { MPGatewaySoap.MPG_Send_LMS }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_Send_LMS', '',
                                 '[ReturnName="MPG_Send_LMSResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(MPGatewaySoap), 'MPG_Send_LMS', 'Message_', 'Message', '');
  { MPGatewaySoap.MPG_Send_Long_SMS }
  InvRegistry.RegisterMethodInfo(TypeInfo(MPGatewaySoap), 'MPG_Send_Long_SMS', '',
                                 '[ReturnName="MPG_Send_Long_SMSResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(MPGatewaySoap), 'MPG_Send_Long_SMS', 'Message_', 'Message', '');

end.