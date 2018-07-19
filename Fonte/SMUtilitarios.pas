unit SMUtilitarios;

interface

uses
  HandleContext, System.SysUtils, FireDAC.Comp.Client;

type
  TSMUtilitarios = class
  private
    { Private declarations }
    fContext : TServerContext;
  public
    { Public declarations }
    Constructor Create (aContext : TServerContext); OverLoad;
    Destructor Destroy; Override;

    property Context : TServerContext read fContext write fContext;

    // http://localhost:8080/SMUtilitarios.timezone
    function Timezone : String;
  end;

implementation

uses
  JSON,
  UdtmPrincipal;

Constructor TSMUtilitarios.Create (aContext : TServerContext);
Begin
  inherited Create;
  fContext := aContext;
End;

Destructor TSMUtilitarios.Destroy;
begin
  inherited Destroy;
End;

function TSMUtilitarios.Timezone : String;
var
  JSONObject : TJSONObject;
Begin
  JSONObject := TJSONObject.Create;

  try
    try
      Context.LogBusiness('TSMUtilitarios.Timezone');

      JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));

      JSONObject.AddPair(TJSONPair.Create('result', DateTimeToStr(Now)));

      Result := JSONObject.ToString;
    except on e: Exception do
    begin
      Result := e.Message;
    end;
  end;
  finally
    JSONObject.Free;
  end;
end;

end.
