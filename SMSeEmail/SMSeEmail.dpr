program SMSeEmail;

uses
  Vcl.Forms,
  UfrmSMSeEmail in 'UfrmSMSeEmail.pas' {frmSMSeEmail},
  UdtmSMSeEmail in 'UdtmSMSeEmail.pas' {dtmSMSeEmail: TDataModule},
  UMobilePronto in 'UMobilePronto.pas',
  ULib in 'ULib.pas',
  UEmail in 'UEmail.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSMSeEmail, frmSMSeEmail);
  Application.Run;
end.
