unit UdtmSMSeEmail;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, System.MaskUtils, Vcl.Forms, Soap.XSBuiltIns,
  Vcl.ExtCtrls, Xml.XMLDoc, Xml.XMLIntf, Winapi.Windows, System.DateUtils;

Type
  TConfiguracoes = record
    FCredencial: String;
    FToken: String;
    FMensagem: String;
    FMeuNumero: String;

    FSMTP: String;
    FPorta: String;
    FUsuario: String;
    FSenha: String;
    FEmail: String;
    FAssunto: String;
    FImagem: String;
    FAutenticacao: String;
    FConexao: String;
    FMensagemEmail: String;
    FTempo: String;
  end;

type
  TCarregarCreditos = procedure of object;

  TdtmSMSeEmail = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FCarregarCreditos: TCarregarCreditos;
    { Private declarations }
    procedure EnviaEmail;
    procedure EnviaSMS;
  public
    { Public declarations }
    Configuracoes: TConfiguracoes;

    procedure CarregaConfiguracao;
    procedure SaveLog(Msg: String);
    function  EnviarTesteEmail: Boolean;
    function  EnviaSMSTeste: Boolean;
    function  SaldoCreditos: Double;

    property CarregarCreditos: TCarregarCreditos read FCarregarCreditos write FCarregarCreditos;
  end;

var
  dtmSMSeEmail: TdtmSMSeEmail;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  ULib,
  UEmail,
  UMobilePronto;

procedure TdtmSMSeEmail.EnviaEmail;
var
  vEmail: TEmail;
begin
  try
    try
      vEmail := TEmail.Create;

      vEmail.Host     := Configuracoes.FSMTP;
      vEMail.Port     := StrToIntDef(Configuracoes.FPorta,0);
      vEmail.UserName := Configuracoes.FUsuario;
      vEmail.Password := Configuracoes.FSenha;
      vEmail.FromAdd  := Configuracoes.FEmail;
      vEmail.FromName := '';

      {qryContato.First;
      while not qryContato.Eof do
      begin
        if vEmail.ValidarEMail(qryContatoEMAIL.AsString) then
          vEmail.RecAdd.Add(qryContatoEMAIL.AsString)
        else
          SaveLog('Email inválido: R.Social - ' + qryContatoRAZAO_SOCIAL.AsString +
                  ', E-mail - ' + qryContatoEMAIL.AsString);

        qryContato.Next;
      end;}

      vEmail.Attach.Add(Configuracoes.FImagem);

      vEmail.Subject        := Configuracoes.FAssunto;
      vEmail.BodyMessage    := Configuracoes.FMensagemEmail;
      vEmail.ReadTime       := 60000;
      vEmail.Authentication := Configuracoes.FAutenticacao = 'True';

      if Configuracoes.FConexao = 'Nenhum' then //Nenhum
        vEmail.TypeConect := -1
      else if Configuracoes.FConexao = 'SSL' then //SSL
        vEmail.TypeConect := 0
      else if Configuracoes.FConexao = 'TLS' then //TLS
        vEmail.TypeConect := 3;

      vEmail.ModeAuth         := 0;
      vEmail.FFirstAnexoInput := FileExists(Configuracoes.FImagem);

      vEmail.EnviarEmail;
      SaveLog('Email enviado com sucesso ao(s) endereço(s): ' + vEmail.listRecAdd);
    except
      on e: Exception do
      begin
        raise Exception.Create('Não foi possível enviar email. ' + #13 + e.Message);
      end;
    end;
  finally
    vEmail.Free;
  end;
end;

function TdtmSMSeEmail.EnviarTesteEmail: Boolean;
var
  vEmail: TEmail;
begin
  try
    try
      vEmail := TEmail.Create;

      vEmail.Host     := Configuracoes.FSMTP;
      vEMail.Port     := StrToInt(Configuracoes.FPorta);
      vEmail.UserName := Configuracoes.FUsuario;
      vEmail.Password := Configuracoes.FSenha;
      vEmail.FromAdd  := Configuracoes.FEmail;
      vEmail.FromName := '';

      vEmail.RecAdd.Add(Configuracoes.FEmail);
      vEmail.Attach.Add(Configuracoes.FImagem);

      vEmail.Subject        := Configuracoes.FAssunto;
      vEmail.BodyMessage    := Configuracoes.FMensagemEmail;
      vEmail.ReadTime       := 60000;
      vEmail.Authentication := Configuracoes.FAutenticacao = 'True';

      if Configuracoes.FConexao = 'Nenhum' then //Nenhum
        vEmail.TypeConect := -1
      else if Configuracoes.FConexao = 'SSL' then //SSL
        vEmail.TypeConect := 0
      else if Configuracoes.FConexao = 'TLS' then //TLS
        vEmail.TypeConect := 3;

      vEmail.ModeAuth         := 0;
      vEmail.FFirstAnexoInput := FileExists(Configuracoes.FImagem);

      Result := vEmail.EnviarEmail;
    except
      on e: Exception do
      begin
        raise Exception.Create('Não foi possível enviar email de teste' + #13 + e.Message);
      end;
    end;
  finally
    vEmail.Free;
  end;
end;

procedure TdtmSMSeEmail.EnviaSMS;
var
  vMobilePronto : MPGatewaySoap;
  vResultado    : Integer;
  vResultadoAux, vMensagem, vTipoRetorno: String;
begin
  if (Configuracoes.FCredencial = '') or (Configuracoes.FToken = '') then
    raise Exception.Create('Não foi possível enviar SMS. Credencial ou Token não informado.');

  try
    vMobilePronto := GetMPGatewaySoap(True);

    {qryContato.First;

    while not qryContato.Eof do
    begin
      vResultadoAux := vMobilePronto.MPG_Send_LMS(Configuracoes.FCredencial, Configuracoes.FToken, '',
        'Parabéns', FormatMaskText('+55\(00\)000000009;0;', qryContatoCELULAR.AsString), Configuracoes.FMensagem);

      vResultado := StrToIntDef(vResultadoAux,0);
      vMensagem  := StatusMobilePronto(vResultado, vTipoRetorno);

      if vTipoRetorno = 'Erro' then
      begin
        SaveLog('Não foi possível enviar SMS ao número: ' + qryContatoCELULAR.AsString + #13 + ', Motivo: ' + vMensagem);
        Inconsistencia := True;
      end
      else if vTipoRetorno = 'Sucesso' then
        SaveLog('SMS enviado com sucesso ao número: ' + qryContatoCELULAR.AsString);

      qryContato.Next;
    end;}
  except
    on e: Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TdtmSMSeEmail.EnviaSMSTeste: Boolean;
var
  vMobilePronto : MPGatewaySoap;
  vResultado    : Integer;
  vResultadoAux, vMensagem, vTipoRetorno: String;
begin
  Result := False;
  if (Configuracoes.FCredencial = '') or (Configuracoes.FToken = '') then
    raise Exception.Create('Não foi possível enviar SMS. Credencial ou Token não informado.');

  try
    vMobilePronto := GetMPGatewaySoap(True);
    vResultadoAux := vMobilePronto.MPG_Send_LMS(Configuracoes.FCredencial, Configuracoes.FToken, '',
        'Teste de SMS', FormatMaskText('+55\(00\)000000009;0;', Configuracoes.FMeuNumero), Configuracoes.FMensagem);

    vResultado := StrToIntDef(vResultadoAux,0);
    vMensagem  := StatusMobilePronto(vResultado, vTipoRetorno);

    if vTipoRetorno = 'Erro' then
      raise Exception.Create('Não foi possível enviar SMS ao número: ' + Configuracoes.FMeuNumero + #13 + ', Motivo: ' + vMensagem)
    else if vTipoRetorno = 'Sucesso' then
      Result := True;
  except
    on e: Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TdtmSMSeEmail.SaldoCreditos: Double;
var
  vMobilePronto: MPGatewaySoap;
  vResultado: Integer;
  vCreditos: TXSDecimal;
  vResultadoAux, vMensagem, vTipoRetorno: String;
begin
  Result := -1;

  try
    vMensagem     := '';
    vMobilePronto := GetMPGatewaySoap(True);
    vCreditos     := vMobilePronto.MPG_Credits(Configuracoes.FCredencial, Configuracoes.FToken, vResultadoAux);
    vResultado    := StrToIntDef(vResultadoAux,0);

    if vCreditos.DecimalString > '-1' then
      Result := StrToFloatDef(Trim(FormatMaskText('!99999999,99;1;', StringReplace(vCreditos.DecimalString,'.',',',[rfReplaceAll, rfIgnoreCase]))),0)
    else
    begin
      vMensagem := StatusMobilePronto(vResultado, vTipoRetorno);

      raise Exception.Create(vMensagem);
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('Não foi possível conectar no Servidor de SMS.' + #13 + E.Message);
    end;
  end;
end;

procedure TdtmSMSeEmail.SaveLog(Msg: String);
var
  loLista: TStringList;
begin
  loLista := TStringList.Create;
  try
    try
      if FileExists(ChangeFileExt(Application.ExeName,'.log')) then
      begin
        loLista.LoadFromFile(ChangeFileExt(Application.ExeName,'.log'));
      end;

      loLista.Add(DateToStr(Date) + ' ' + TimeToStr(now) + ' - ' + Msg);
    except
      on e: Exception do
      begin
        loLista.Add(DateToStr(Date) + ' ' + TimeToStr(now) + ' - Erro ' + E.Message);
      end;
    end;
  finally
    loLista.SaveToFile(ChangeFileExt(Application.ExeName,'.log'));
    loLista.Free;
  end;
end;

procedure TdtmSMSeEmail.CarregaConfiguracao;
begin
  Configuracoes.FCredencial := CarregaIni('SMS', 'Credencial');
  Configuracoes.FToken      := Crypt('D', CarregaIni('SMS', 'Token'));
  Configuracoes.FMensagem   := StringReplace(CarregaIni('SMS', 'Mensagem'),
                                             '|', Chr(13)+Chr(10), [rfReplaceAll]);
  Configuracoes.FMeuNumero  := CarregaIni('SMS', 'MeuNumero');

  Configuracoes.FSMTP          := CarregaIni('Email', 'SMTP');
  Configuracoes.FPorta         := CarregaIni('Email', 'Porta');
  Configuracoes.FUsuario       := CarregaIni('Email', 'Usuario');
  Configuracoes.FSenha         := Crypt('D', CarregaIni('Email', 'Senha'));
  Configuracoes.FEmail         := CarregaIni('Email', 'Email');
  Configuracoes.FAssunto       := CarregaIni('Email', 'Assunto');
  Configuracoes.FImagem        := CarregaIni('Email', 'Imagem');
  Configuracoes.FAutenticacao  := CarregaIni('Email', 'Autenticacao');
  Configuracoes.FConexao       := CarregaIni('Email', 'Conexao');
  Configuracoes.FMensagemEmail := StringReplace(CarregaIni('Email', 'Mensagem'),
                                                '|', Chr(13)+Chr(10), [rfReplaceAll]);
  Configuracoes.FTempo         := CarregaIni('Email', 'Tempo');
end;

procedure TdtmSMSeEmail.DataModuleCreate(Sender: TObject);
begin
  CarregaConfiguracao;
end;

end.
