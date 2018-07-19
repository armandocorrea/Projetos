program Server;

uses
  Vcl.Forms,
  UfrmPrincipal in 'UfrmPrincipal.pas' {frmPrincipal},
  HandleContext in 'HandleContext.pas',
  ServerUtils in 'ServerUtils.pas',
  SysTypes in 'SysTypes.pas',
  UdtmPrincipal in 'UdtmPrincipal.pas' {dtmPrincipal: TDataModule},
  SMClassificacao in 'SMClassificacao.pas',
  SMUtilitarios in 'SMUtilitarios.pas',
  SMRodadas in 'SMRodadas.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
