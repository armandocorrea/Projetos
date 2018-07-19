unit SMRodadas;

interface

uses
  HandleContext, System.SysUtils, FireDAC.Comp.Client;

type
  TSMRodadas = class
  private
    { Private declarations }
    fContext : TServerContext;
  public
    { Public declarations }
    Constructor Create (aContext : TServerContext); OverLoad;
    Destructor Destroy; Override;

    property Context : TServerContext read fContext write fContext;

    // http://localhost:8080/SMRodadas.Consulta
    function Consulta : String;
  end;

implementation

uses
  JSON,
  UdtmPrincipal;

Constructor TSMRodadas.Create (aContext : TServerContext);
Begin
  inherited Create;
  fContext := aContext;
End;

Destructor TSMRodadas.Destroy;
begin
  inherited Destroy;
End;

function TSMRodadas.Consulta : String;
var
  JSONObject  : TJSONObject;
  LJson       : TJSONObject;
  JSONArray   : TJSONArray;
  vQryRodadas : TFDQuery;
  I: Integer;
Begin
  JSONObject   := TJSONObject.Create;
  vQryRodadas := dtmPrincipal.FDRodadas;
  try
    try
      Context.LogBusiness('TSMRodadas.Consulta');

      vQryRodadas.Close;
      vQryRodadas.Open;
      vQryRodadas.First;

      JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
      if vQryRodadas.IsEmpty then
        JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Nenhum registro encontrado.'));

      JSONArray := TJSONArray.Create;
      while not vQryRodadas.Eof do
      begin
        LJson := TJSONObject.Create;

        for I := 0 to vQryRodadas.FieldCount-1 do
        begin
          if not vQryRodadas.Fields[I].IsNull then
            LJson.AddPair(TJSONPair.Create(vQryRodadas.Fields[I].FieldName,
                                           vQryRodadas.Fields[I].AsVariant));
        end;

        JSONArray.Add(LJson);

        vQryRodadas.Next;
      end;

      JSONObject.AddPair(TJSONPair.Create('result', JSONArray));

      Result := JSONObject.ToString;
    except on e: Exception do
    begin
      Result := e.Message;
    end;
    end;
  finally
    vQryRodadas.Close;
    JSONObject.Free;
  end;
end;

end.
