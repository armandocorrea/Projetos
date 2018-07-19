unit SMClassificacao;

interface

uses
  HandleContext, System.SysUtils, FireDAC.Comp.Client;

type
  TSMClassificacao = class
  private
    { Private declarations }
    fContext : TServerContext;
  public
    { Public declarations }
    Constructor Create (aContext : TServerContext); OverLoad;
    Destructor Destroy; Override;

    property Context : TServerContext read fContext write fContext;

    // http://localhost:8080/SMClassificacao.Consulta
    function Consulta : String;
  end;

implementation

uses
  JSON,
  UdtmPrincipal;

Constructor TSMClassificacao.Create (aContext : TServerContext);
Begin
  inherited Create;
  fContext := aContext;
End;

Destructor TSMClassificacao.Destroy;
begin
  inherited Destroy;
End;

function TSMClassificacao.Consulta : String;
var
  JSONObject  : TJSONObject;
  LJson       : TJSONObject;
  JSONArray   : TJSONArray;
  vQryClassificacao : TFDQuery;
  I: Integer;
Begin
  JSONObject   := TJSONObject.Create;
  vQryClassificacao := dtmPrincipal.FDClassificacao;
  try
    try
      Context.LogBusiness('TSMClassificacao.Consulta');

      vQryClassificacao.Close;
      vQryClassificacao.Open;
      vQryClassificacao.First;

      JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
      if vQryClassificacao.IsEmpty then
        JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Nenhum registro encontrado.'));

      JSONArray := TJSONArray.Create;
      while not vQryClassificacao.Eof do
      begin
        LJson := TJSONObject.Create;

        for I := 0 to vQryClassificacao.FieldCount-1 do
        begin
          if not vQryClassificacao.Fields[I].IsNull then
            LJson.AddPair(TJSONPair.Create(vQryClassificacao.Fields[I].FieldName,
                                           vQryClassificacao.Fields[I].AsVariant));
        end;

        JSONArray.Add(LJson);

        vQryClassificacao.Next;
      end;

      JSONObject.AddPair(TJSONPair.Create('result', JSONArray));

      Result := JSONObject.ToString;
    except on e: Exception do
    begin
      Result := e.Message;
    end;
    end;
  finally
    vQryClassificacao.Close;
    JSONObject.Free;
  end;
end;

end.
