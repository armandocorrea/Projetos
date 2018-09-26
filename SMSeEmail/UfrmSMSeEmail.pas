unit UfrmSMSeEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, System.UITypes, FireDAC.Comp.Client,
  FireDAC.Comp.UI, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, Data.DB,
  System.ImageList, Vcl.Buttons, System.MaskUtils, Vcl.Menus, Vcl.AppEvnts, ShellApi;

type
  TfrmSMSeEmail = class(TForm)
    pnlDadosEmpresa: TPanel;
    Panel1: TPanel;
    edtCredencial: TEdit;
    edtToken: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    pnlBotoes: TPanel;
    btnGravar: TButton;
    btnFechar: TButton;
    img: TImageList;
    btnCancelar: TButton;
    Conexao: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    Label2: TLabel;
    mmMensagem: TMemo;
    Panel3: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel5: TPanel;
    edtSMTP: TEdit;
    edtEmail: TEdit;
    Label7: TLabel;
    edtPorta: TEdit;
    edtSenha: TEdit;
    Label8: TLabel;
    edtAssunto: TEdit;
    Label10: TLabel;
    edtImagem: TEdit;
    chkRequerAutenticacao: TCheckBox;
    cmbCriptografia: TComboBox;
    Label11: TLabel;
    btnTestarEmail: TButton;
    lblRestam: TLabel;
    btnCapturar: TSpeedButton;
    OpenDialog1: TOpenDialog;
    Label13: TLabel;
    edtUsuario: TEdit;
    Label14: TLabel;
    mmMensagemEmail: TMemo;
    lblCreditos: TLabel;
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    Log1: TMenuItem;
    Configuraes1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    ImgIcon: TImageList;
    Label17: TLabel;
    edtTempo: TEdit;
    Label18: TLabel;
    Button1: TButton;
    Label9: TLabel;
    edtMeuNumero: TEdit;
    procedure btnFecharClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure mmMensagemChange(Sender: TObject);
    procedure btnCapturarClick(Sender: TObject);
    procedure btnTestarEmailClick(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure Configuraes1Click(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TrayIconDblClick(Sender: TObject);
    procedure Log1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrayIconBalloonClick(Sender: TObject);
    procedure TrayIconMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
  private
    procedure PreencheCampos;
    procedure CalculaMensagem;
    procedure CarregaCreditos;
    procedure AbreAplicacao;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSMSeEmail: TfrmSMSeEmail;

implementation

{$R *.dfm}

uses
  ULib,
  UdtmSMSeEmail;

procedure TfrmSMSeEmail.ApplicationEventsMinimize(Sender: TObject);
begin
  Self.Hide;
  Self.WindowState := wsMinimized;
end;

procedure TfrmSMSeEmail.btnCancelarClick(Sender: TObject);
begin
  try
    Screen.Cursor:= crHourGlass;
    PreencheCampos;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfrmSMSeEmail.btnCapturarClick(Sender: TObject);
var
  vCaminho: String;
begin
  if OpenDialog1.Execute then
  begin
    vCaminho       := OpenDialog1.Files.Text;
    edtImagem.Text := vCaminho;
  end;
end;

procedure TfrmSMSeEmail.btnFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSMSeEmail.btnGravarClick(Sender: TObject);
begin
  try
    Screen.Cursor:= crHourGlass;

    if cmbCriptografia.ItemIndex = -1 then
    begin
      MessageDlg('Informe o Tipo de Conexão do Email.', mtWarning, [mbOk], 0);
      cmbCriptografia.SetFocus;
      Exit;
    end;

    dtmSMSeEmail.Configuracoes.FCredencial := edtCredencial.Text;
    dtmSMSeEmail.Configuracoes.FToken      := Crypt('C', edtToken.Text);
    dtmSMSeEmail.Configuracoes.FMensagem   := mmMensagem.Lines.Text;
    dtmSMSeEmail.Configuracoes.FMeuNumero  := edtMeuNumero.Text;

    dtmSMSeEmail.Configuracoes.FSMTP         := edtSMTP.Text;
    dtmSMSeEmail.Configuracoes.FPorta        := edtPorta.Text;
    dtmSMSeEmail.Configuracoes.FUsuario      := edtUsuario.Text;
    dtmSMSeEmail.Configuracoes.FSenha        := Crypt('C', edtSenha.Text);
    dtmSMSeEmail.Configuracoes.FEmail        := edtEmail.Text;
    dtmSMSeEmail.Configuracoes.FAssunto      := edtAssunto.Text;
    dtmSMSeEmail.Configuracoes.FImagem       := edtImagem.Text;
    dtmSMSeEmail.Configuracoes.FAutenticacao := 'False';

    if chkRequerAutenticacao.Checked then
      dtmSMSeEmail.Configuracoes.FAutenticacao := 'True';
    dtmSMSeEmail.Configuracoes.FConexao        := cmbCriptografia.Items[cmbCriptografia.ItemIndex];
    dtmSMSeEmail.Configuracoes.FMensagemEmail  := mmMensagemEmail.Lines.Text;
    dtmSMSeEmail.Configuracoes.FTempo          := edtTempo.Text;

    ConfiguraIni('SMS', 'Credencial', dtmSMSeEmail.Configuracoes.FCredencial);
    ConfiguraIni('SMS', 'Token', dtmSMSeEmail.Configuracoes.FToken);
    ConfiguraIni('SMS', 'Mensagem', StringReplace(dtmSMSeEmail.Configuracoes.FMensagem,
                                                  Chr(13)+Chr(10), '|', [rfReplaceAll]));
    ConfiguraIni('SMS', 'MeuNumero', dtmSMSeEmail.Configuracoes.FMeuNumero);

    ConfiguraIni('Email', 'SMTP', dtmSMSeEmail.Configuracoes.FSMTP);
    ConfiguraIni('Email', 'Porta', dtmSMSeEmail.Configuracoes.FPorta);
    ConfiguraIni('Email', 'Usuario', dtmSMSeEmail.Configuracoes.FUsuario);
    ConfiguraIni('Email', 'Senha', dtmSMSeEmail.Configuracoes.FSenha);
    ConfiguraIni('Email', 'Email', dtmSMSeEmail.Configuracoes.FEmail);
    ConfiguraIni('Email', 'Assunto', dtmSMSeEmail.Configuracoes.FAssunto);
    ConfiguraIni('Email', 'Imagem', dtmSMSeEmail.Configuracoes.FImagem);
    ConfiguraIni('Email', 'Autenticacao', dtmSMSeEmail.Configuracoes.FAutenticacao);
    ConfiguraIni('Email', 'Conexao', dtmSMSeEmail.Configuracoes.FConexao);
    ConfiguraIni('Email', 'Mensagem', StringReplace(dtmSMSeEmail.Configuracoes.FMensagemEmail,
                                                    Chr(13)+Chr(10), '|', [rfReplaceAll]));
    ConfiguraIni('Email', 'Tempo', dtmSMSeEmail.Configuracoes.FTempo);

    dtmSMSeEmail.CarregaConfiguracao;
    MessageDlg('Registro gravado com sucesso!', mtInformation, [mbOK], 0);

    CarregaCreditos;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfrmSMSeEmail.btnTestarEmailClick(Sender: TObject);
begin
  try
    Screen.Cursor:= crHourGlass;
    try
      if dtmSMSeEmail.EnviarTesteEmail then
        MessageDlg('Email de Teste Enviado com Sucesso!', mtInformation, [mbOk], 0);
    except
      on e: Exception do
      begin
        raise Exception.Create(e.Message);
      end;
    end;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfrmSMSeEmail.Button1Click(Sender: TObject);
begin
  if dtmSMSeEmail.EnviaSMSTeste then
    MessageDlg('SMS enviado com Sucesso!', mtInformation, [mbOk], 0);
end;

procedure TfrmSMSeEmail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dtmSMSeEmail.Free;
end;

procedure TfrmSMSeEmail.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if CanClose then
  begin
    ApplicationEvents.OnMinimize(Self);
    CanClose := False;
  end;
end;

procedure TfrmSMSeEmail.FormCreate(Sender: TObject);
begin
  dtmSMSeEmail := TdtmSMSeEmail.Create(Self);
  dtmSMSeEmail.CarregaConfiguracao;

  PreencheCampos;
  CalculaMensagem;
  CarregaCreditos;
  ApplicationEvents.OnMinimize(Self);

  dtmSMSeEmail.CarregarCreditos := CarregaCreditos;
end;

procedure TfrmSMSeEmail.Log1Click(Sender: TObject);
var
  vPath: String;
begin
  vPath := ChangeFileExt(Application.ExeName, '.log');

  if not FileExists(vPath) then
  begin
    MessageDlg('Arquivo não encontrado.', mtInformation, [mbOk], 0);
    Exit;
  end;

  ShellExecute(handle, 'Open', Pchar(vPath), '', '', SW_SHOWMAXIMIZED);
end;

procedure TfrmSMSeEmail.mmMensagemChange(Sender: TObject);
begin
  CalculaMensagem;
end;

procedure TfrmSMSeEmail.PreencheCampos;
begin
  edtCredencial.Text    := dtmSMSeEmail.Configuracoes.FCredencial;
  edtToken.Text         := dtmSMSeEmail.Configuracoes.FToken;
  mmMensagem.Lines.Text := StringReplace(dtmSMSeEmail.Configuracoes.FMensagem,
                                         '|', Chr(13)+Chr(10), [rfReplaceAll]);
  edtMeuNumero.Text     := dtmSMSeEmail.Configuracoes.FMeuNumero;

  edtSMTP.Text                  := dtmSMSeEmail.Configuracoes.FSMTP;
  edtPorta.Text                 := dtmSMSeEmail.Configuracoes.FPorta;
  edtUsuario.Text               := dtmSMSeEmail.Configuracoes.FUsuario;
  edtSenha.Text                 := dtmSMSeEmail.Configuracoes.FSenha;
  edtEmail.Text                 := dtmSMSeEmail.Configuracoes.FEmail;
  edtAssunto.Text               := dtmSMSeEmail.Configuracoes.FAssunto;
  edtImagem.Text                := dtmSMSeEmail.Configuracoes.FImagem;
  chkRequerAutenticacao.Checked := dtmSMSeEmail.Configuracoes.FAutenticacao = 'True';
  cmbCriptografia.ItemIndex     := cmbCriptografia.Items.IndexOf(dtmSMSeEmail.Configuracoes.FConexao);
  mmMensagemEmail.Lines.Text    := StringReplace(dtmSMSeEmail.Configuracoes.FMensagemEmail,
                                                 '|', Chr(13)+Chr(10), [rfReplaceAll]);
  edtTempo.Text                 := dtmSMSeEmail.Configuracoes.FTempo;
end;

procedure TfrmSMSeEmail.Sair1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmSMSeEmail.TrayIconBalloonClick(Sender: TObject);
begin
  Log1.Click;
end;

procedure TfrmSMSeEmail.TrayIconDblClick(Sender: TObject);
begin
  AbreAplicacao;
end;

procedure TfrmSMSeEmail.TrayIconMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  TrayIcon.Hint := 'SMSeEmail';
end;

procedure TfrmSMSeEmail.CalculaMensagem;
var
  vRestante: word;
begin
  vRestante := 150 - Length(mmMensagem.Lines.Text);
  lblRestam.Caption := 'Restam ' + IntToStr(vRestante) + ' letras.';
end;

procedure TfrmSMSeEmail.CarregaCreditos;
var
  vSaldo: Double;
begin
  try
    vSaldo := dtmSMSeEmail.SaldoCreditos;
    lblCreditos.Caption := 'Você possui ' + FloatToStr(vSaldo) + ' de créditos SMS.';
  except
    on e: Exception do
    begin
      lblCreditos.Caption := 'Não foi possível consultar os créditos de SMS.';
      dtmSMSeEmail.SaveLog(e.Message);
    end;
  end;
end;

procedure TfrmSMSeEmail.Configuraes1Click(Sender: TObject);
begin
  AbreAplicacao;
end;

procedure TfrmSMSeEmail.AbreAplicacao;
begin
  Self.Show;
  Self.WindowState := wsNormal;
  Application.BringToFront;
end;

end.
