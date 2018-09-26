unit UEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP, IdMessage, IdAttachmentFile, IdSSLOpenSSL, IdText;

type
  TEmail = class
    FHost: String;
    FPort: Integer;
    FUserName: String;
    FPassword: String;
    FFromAdd: String;
    FFromName: String;
    FRecAdd: TStringList;
    FAttach: TStringList;
    FSubject: String;
    FBodyMessage: String;
    FReadTime : Integer;
    FAuthentication: Boolean;
    FTypeConect: Integer; //-1 nenhum, 0 sslvSSLv2, 1 sslvSSLv23, 2 sslvSSLv3, 3 sslvTLSv1, 4 sslvTLSv1_1, 5 sslvTLSv1_2
    FModeAuth: Word; //0 sslmUnassigned, 1 sslmClient, 2 sslmServer, 3 sslmBoth
    FFirstAnexoInput: Boolean;

    FIdSMTP: TIdSMTP;
    FIdMessage: TIdMessage;
    FIdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    FAnexo: TIdAttachmentFile;
    FIdText: TIdText;
    FIdHtml: TIdText;
  public
    constructor Create;
    destructor Destroy; override;

    function EnviarEmail: Boolean;
    function listRecAdd: String;
    function ValidarEMail(aStr: string): Boolean;
  published
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property FromAdd: String read FFromAdd write FFromAdd;
    property FromName: String read FFromName write FFromName;
    property RecAdd: TStringList read FRecAdd write FRecAdd;
    property Attach: TStringList read FAttach write FAttach;
    property Subject: String read FSubject write FSubject;
    property BodyMessage: String read FBodyMessage write FBodyMessage;
    property ReadTime: Integer read FReadTime write FReadTime;
    property Authentication: Boolean read FAuthentication write FAuthentication;
    property TypeConect: Integer read FTypeConect write FTypeConect;
    property ModeAuth: Word read FModeAuth write FModeAuth;
end;

implementation

{ TEmail }

{ TEmail }

constructor TEmail.create;
begin
  inherited;
  FIdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create;
  FIdSMTP               := TIdSMTP.Create;
  FIdMessage            := TIdMessage.Create;

  FAttach := TStringList.Create;
  FRecAdd := TStringList.Create;
end;

destructor TEmail.Destroy;
begin
  // desconecta do servidor
  FIdSMTP.Disconnect;
  // liberação da DLL
  UnLoadOpenSSLLibrary;
  // liberação dos objetos da memória
  FreeAndNil(FIdMessage);
  FreeAndNil(FIdSSLIOHandlerSocket);
  FreeAndNil(FIdSMTP);
  inherited;
end;

function TEmail.EnviarEmail: Boolean;
var
  I: Integer;
begin
  Result := False;

  // Configuração do protocolo SSL (TIdSSLIOHandlerSocketOpenSSL)
  if TypeConect > -1 then
  begin
    FIdSSLIOHandlerSocket.SSLOptions.Method := TIdSSLVersion(FTypeConect);
    FIdSSLIOHandlerSocket.SSLOptions.Mode   := TIdSSLMode(FModeAuth);
  end;

  // Configuração do servidor SMTP (TIdSMTP)
  FIdSMTP.IOHandler := FIdSSLIOHandlerSocket;
  FIdSMTP.UseTLS    := utUseExplicitTLS;

  //FIdSMTP.AuthType := satSASL;
  FIdSMTP.Port     := FPort;
  FIdSMTP.Host     := FHost;
  FIdSMTP.Username := FUserName;
  FIdSMTP.Password := FPassword;

  // Configuração da mensagem (TIdMessage)
  FIdMessage.From.Address := FFromAdd;
  FIdMessage.From.Name    := FFromName;
  //FIdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;

  for I := 0 to (FRecAdd.Count - 1) do
    FIdMessage.BccList.Add.Text := FRecAdd[I];

  if FRecAdd.Count < 1 then
    raise Exception.Create('Não foi encontrado nenhum endereço de e-mail.');

  FIdMessage.Subject  := FSubject;
  //IdMessage.CharSet := 'utf-8';
  FIdMessage.Encoding := meMIME;
  FIdMessage.ContentType := 'multipart/mixed';

  // Configuração do corpo do email (TIdText)
  if FFirstAnexoInput then
  begin
    FIdHtml := TIdText.Create(FIdMessage.MessageParts);

    FIdHtml.ContentType := 'text/html';
    FIdHtml.CharSet     := 'ISO-8859-1';

    FIdHtml.Body.Add('<HTML>');
    FIdHtml.Body.Add('<head>');
    FIdHtml.Body.Add('<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">');
    FIdHtml.Body.Add('</head>');
    FIdHtml.Body.Add('<BODY>');
    FIdHtml.Body.Add(StringReplace(FBodyMessage, Chr(13)+Chr(10), '<br>', [rfReplaceAll]));
    FIdHtml.Body.Add('<BR><BR>');
    FIdHtml.Body.Add('<IMG SRC="cid:AnexoInput">');
    FIdHtml.Body.Add('</BODY><HTML>');
  end
  else
  begin
    FIdText := TIdText.Create(FIdMessage.MessageParts);
    FIdText.Body.Add(FBodyMessage);
  end;

  //anexa as imagens que vai no email
  FIdText := TIdText.Create(FIdMessage.MessageParts);
  FIdText.ContentType := 'text/plain';

  for I := 0 to (FAttach.Count - 1) do
  begin
    if FileExists(FAttach[I]) then
    begin
      FAnexo := TIdAttachmentFile.Create(FIdMessage.MessageParts, FAttach[I]);
      if (FFirstAnexoInput) and (I = 0) then
        FAnexo.ExtraHeaders.Values['content-ID'] := 'AnexoInput';
    end;
  end;

  // Conexão e autenticação
  try
    FIdSMTP.ReadTimeout    := FReadTime;
    FIdSMTP.ConnectTimeout := FReadTime;
    FIdSMTP.Disconnect;
    FIdSMTP.Connect;
    if FAuthentication then
      FIdSMTP.Authenticate;
  except
    on E:Exception do
    begin
      raise Exception.Create('Erro na conexão ou autenticação: ' + E.Message);
    end;
  end;

  // Envio da mensagem
  try
    FIdSMTP.Send(FIdMessage);

    Result := True;
  except
    On E:Exception do
    begin
      raise Exception.Create('Erro ao enviar a mensagem: ' + E.Message);
    end;
  end;
end;

function TEmail.listRecAdd: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to RecAdd.Count-1 do
  begin
    Result := Result + RecAdd[I] + ', ';
  end;
  Result := Copy(Result, 0, Length(Result)-2);
end;

function TEmail.ValidarEMail(aStr: string): Boolean;
begin
  aStr := Trim(UpperCase(aStr));
  if Pos('@', aStr) > 1 then
  begin
    Delete(aStr, 1, pos('@', aStr));
    Result := (Length(aStr) > 0) and (Pos('.', aStr) > 2);
  end
  else
    Result := False;
end;

end.
