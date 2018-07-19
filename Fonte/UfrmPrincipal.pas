unit UfrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.AppEvnts, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext,
  ServerUtils, Vcl.Imaging.pngimage;

type
  TfrmPrincipal = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    mmRequisicoes: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    mmRespostas: TMemo;
    Label4: TLabel;
    mmAplicacao: TMemo;
    btnAtivar: TSpeedButton;
    btnParar: TSpeedButton;
    TrayIcon: TTrayIcon;
    ApplicationEvents: TApplicationEvents;
    IdHTTPServer: TIdHTTPServer;
    lblInfoLabel: TLabel;
    procedure TrayIconClick(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure btnAtivarClick(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IdHTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure IdHTTPServerCommandOther(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ServerParams : TServerParams;
    procedure AddCORSHeaders(aResponseInfo: TIdHttpResponseInfo);
    procedure LoglastRequest(ARequestInfo: TIdHTTPRequestInfo);
    procedure LogLastResponse(AResponseInfo: TIdHTTPResponseInfo);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;
  CriticalSection: TRTLCriticalSection;

implementation

{$R *.dfm}

uses
  SysTypes,
  ServerMethodsUnit1,
  HandleContext,
  UdtmPrincipal;

procedure TfrmPrincipal.ApplicationEventsMinimize(Sender: TObject);
begin
  // Quando minimizado mostra o Balloon
  Self.Hide();
  Self.WindowState := wsMinimized;
  TrayIcon.Visible := True;
  TrayIcon.Animate := True;
  TrayIcon.ShowBalloonHint;
end;

procedure TfrmPrincipal.btnAtivarClick(Sender: TObject);
begin
  btnParar.Enabled  := True;
  btnAtivar.Enabled := False;

  IdHTTPServer.ContextClass := TServerContext;
  IdHTTPServer.Active       := True;
  lblInfoLabel.Caption      := 'Aguardando requisições...';
  mmRequisicoes.Lines.Add('Servidor startado em : ' + DateTimeToStr(Now));
end;

procedure TfrmPrincipal.btnPararClick(Sender: TObject);
begin
  btnAtivar.Enabled := True;
  btnParar.Enabled  := False;

  IdHTTPServer.Active  := False;
  lblInfoLabel.Caption := 'WebService parado.';
  EnterCriticalSection(CriticalSection);
  mmRequisicoes.Lines.Add('Servidor finalizado em : ' + DateTimeToStr(Now));
  LeaveCriticalSection(CriticalSection);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  dtmPrincipal := TdtmPrincipal.Create(nil);

  btnAtivarClick(self);

  ServerParams := TServerParams.Create;
  ServerParams.HasAuthentication := True;
  ServerParams.UserName          := 'teste';
  ServerParams.Password          := '123';
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  dtmPrincipal.Free;
  ServerParams.Free;
end;

procedure TfrmPrincipal.IdHTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
Var
  Cmd           : String;
  ServerContext : TServerContext;
  Retorno       : string;
begin
  Cmd := ARequestInfo.RawHTTPCommand;

  If (ServerParams.HasAuthentication) then Begin
    if not ((ARequestInfo.AuthUsername = ServerParams.Username) and
            (ARequestInfo.AuthPassword = ServerParams.Password))
     then Begin
       AResponseInfo.AuthRealm := 'Forneça autenticação';
       AResponseInfo.WriteContent;
       Exit;
     end;
  end;
  if (UpperCase(Copy (Cmd, 1, 3)) = 'GET') OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'POST') OR
     (UpperCase(Copy (Cmd, 1, 3)) = 'HEAD')
  then begin
    if ARequestInfo.URI <> '/favicon.ico' then begin
      LoglastRequest (ARequestInfo);

      ServerContext := TServerContext (AContext);
      Retorno := ServerContext.HandleRequest(ARequestInfo, AResponseInfo, Cmd, mmAplicacao.Lines);

      // Contribuição do José Benedito (JB Soluções) para
      // permitir retornar respostas a requisições AJAX CrossDomain
      AddCORSHeaders (aResponseInfo);

      // Escreve conteudo no Response
      AResponseInfo.ContentText := Retorno;
      LoglastResponse (AResponseInfo);
      AResponseInfo.WriteContent;
    end;
  end;
end;

procedure TfrmPrincipal.IdHTTPServerCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Cmd           : String;
  ServerContext : TServerContext;
  Retorno       : string;
begin
  Cmd := ARequestInfo.RawHTTPCommand;
  if (ServerParams.HasAuthentication) then Begin
    if Not ((ARequestInfo.AuthUsername = ServerParams.Username) and
           (ARequestInfo.AuthPassword = ServerParams.Password))
    Then Begin
      AResponseInfo.AuthRealm := 'Forneça autenticação';
      AResponseInfo.WriteContent;
      Exit;
    end;
  end;
  if (UpperCase(Copy (Cmd, 1, 3)) = 'PUT') OR
     (UpperCase(Copy (Cmd, 1, 6)) = 'DELETE')
  then Begin
    LoglastRequest (ARequestInfo);
    ServerContext := TServerContext (AContext);
    Retorno := ServerContext.HandleRequest(ARequestInfo, AResponseInfo, Cmd, mmAplicacao.Lines);

    // Contribuição do José Benedito (JB Soluções) para
    // permitir retornar AJAX CrossDomain
    AddCORSHeaders (aResponseInfo);

    // Escreve conteudo no Response
    AResponseInfo.ContentText := Retorno;
    LoglastResponse (AResponseInfo);
    AResponseInfo.WriteContent;
  end;
end;

procedure TfrmPrincipal.TrayIconClick(Sender: TObject);
begin
  // Minimiza para o Tray
  TrayIcon.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

// Contribuição do José Benedito (JB Soluções) para
// permitir retornar respostas a requisiçõe AJAX CrossDomain
procedure TfrmPrincipal.AddCORSHeaders (aResponseInfo : TIdHttpResponseInfo);
begin
  aResponseInfo.CustomHeaders.Values['Access-Control-Allow-Origin']      := '*';
  aResponseInfo.CustomHeaders.Values['Access-Control-Allow-Credentials'] := 'true';
  aResponseInfo.CustomHeaders.Values['Access-Control-Allow-Methods']     := 'GET, POST, PUT, DELETE, OPTIONS';
end;

procedure TfrmPrincipal.LoglastRequest (ARequestInfo: TIdHTTPRequestInfo);
Begin
  EnterCriticalSection(CriticalSection);
  mmRequisicoes.Lines.Add(ARequestInfo.UserAgent + #13 + #10 +
                          ARequestInfo.RawHTTPCommand);
  LeaveCriticalSection(CriticalSection);
End;

procedure TfrmPrincipal.LogLastResponse (AResponseInfo: TIdHTTPResponseInfo);
Begin
  EnterCriticalSection(CriticalSection);
  mmRespostas.Lines.Add(AResponseInfo.ContentText);
  LeaveCriticalSection(CriticalSection);
End;

initialization
  InitializeCriticalSection(CriticalSection);

finalization
  DeleteCriticalSection(CriticalSection);

end.
