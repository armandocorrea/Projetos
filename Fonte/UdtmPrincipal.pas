unit UdtmPrincipal;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Forms, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs;

type
  TdtmPrincipal = class(TDataModule)
    Conexao: TFDConnection;
    FDRodadas: TFDQuery;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    FDRodadasID: TFDAutoIncField;
    FDRodadasID_GRUPO: TIntegerField;
    FDRodadasID_SELECAO_A: TIntegerField;
    FDRodadasID_SELECAO_B: TIntegerField;
    FDRodadasNOME: TStringField;
    FDRodadasRESULTADO_A: TIntegerField;
    FDRodadasRESULTADO_B: TIntegerField;
    FDClassificacao: TFDQuery;
    FDClassificacaoID: TFDAutoIncField;
    FDClassificacaoID_GRUPO: TIntegerField;
    FDClassificacaoID_SELECAO: TIntegerField;
    FDClassificacaoPONTOS: TIntegerField;
    FDClassificacaoVITORIAS: TIntegerField;
    FDClassificacaoJOGOS: TIntegerField;
    FDClassificacaoDERROTAS: TIntegerField;
    FDClassificacaoEMPATES: TIntegerField;
    FDClassificacaoSALDO: TIntegerField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dtmPrincipal: TdtmPrincipal;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdtmPrincipal.DataModuleCreate(Sender: TObject);
begin
  Conexao.Connected := False;
  Conexao.Params.Database := ExtractFilePath(Application.exeName) + '\dados.db';
  Conexao.Connected := True;
end;

procedure TdtmPrincipal.DataModuleDestroy(Sender: TObject);
begin
  Conexao.Connected := False;
end;

end.

