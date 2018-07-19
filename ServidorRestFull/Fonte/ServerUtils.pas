unit ServerUtils;

interface

Uses
  System.Classes,
  SysTypes,
  System.SysUtils,
  RegularExpressions,
  IdURI,
  IdGlobal;

type
    (* rotinas diversas *)
    TServerUtils = class
      class function ParseRESTURL (const Cmd : string): TArguments;
      class function Result2JSON (wsResult : TResultErro) : String;
      class function ParseWebFormsParams (Params : TStrings; const URL : String): TArguments;
    end;

    (* Parametros do Servidor *)
    TServerParams = class
    private
      fUsername : string;
      fPassword : String;
      fHasAuthenticacion : Boolean;
      function GetUserName : String;
      function GetPassword : String;
      function GetHasAuthentication : Boolean;
    Public
      property HasAuthentication : Boolean read fHasAuthenticacion write fHasAuthenticacion;
      property UserName : string read GetUserName write fUsername;
      property Password : string read GetPassword write fPassword;

      constructor Create; overload;
    end;

implementation

// Retorna um array de strings com os parametros vindos da URL
// Ex de Cmd : 'GET /NomedoMetodo/Argumento1/Argumento2/ArgumentoN HTTP/1.1'
class function TServerUtils.ParseRESTURL (const Cmd : string): TArguments;
Var
     NewCmd       : String;
     iHttp        : Integer;
     ArraySize    : Integer;
     iBar1, IBar2 : Integer;
     Cont         : Integer;
begin
     NewCmd    := Cmd;
     ArraySize := TRegEx.Matches(NewCmd, '/').Count;
     SetLength(Result, ArraySize);
     NewCmd    := NewCmd + '/';

     iBar1 := Pos ('/', NewCmd);
     Delete (NewCmd, 1, iBar1);

     for Cont := 0 to ArraySize - 1 do begin
         iBar2 := Pos ('/', NewCmd);
         {$IFDEF VER230}   // XE2
           Result [Cont] := TIdURI.URLDecode (Copy (NewCmd, 1, iBar2 - 1), TEncoding.UTF8);
         {$ENDIF}

         {$IFDEF VER280}   // XE7
            Result [Cont] := TIdURI.URLDecode (Copy (NewCmd, 1, iBar2 - 1), IndyTextEncoding (encUTF8));
         {$ENDIF}

         {$IFDEF VER290}   // XE8
            Result [Cont] := TIdURI.URLDecode (Copy (NewCmd, 1, iBar2 - 1), IndyTextEncoding (encUTF8));
         {$ENDIF}

         Result [Cont] := TIdURI.URLDecode (Copy (NewCmd, 1, iBar2 - 1), IndyTextEncoding (encUTF8));

         Delete (NewCmd, 1, iBar2);
     end;
end;

class function TServerUtils.ParseWebFormsParams (Params : TStrings; const URL : String): TArguments;
var
  I   : Integer;
  Cmd : string;
Begin
  SetLength(Result, Params.Count + 1);

  // Extrai nome do ServerMethod
  Cmd := URL + '/';
  I   := Pos ('/', Cmd);
  Delete (Cmd, 1, I);
  I   := Pos ('/', Cmd);
  Result [0] := Copy (Cmd, 1, I - 1);

  // Extrai Parametros
  for I := 0 To Params.Count - 1 do
    Result [I+1] := Copy (Params [I], Pos ('=', Params [I]) + 1, 255);
End;

class function TServerUtils.Result2JSON (wsResult : TResultErro) : String;
var
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create();
  SB.Append('{');
  SB.Append('"STATUS":"' + IntToStr(wsResult.STATUS) + '"');
  SB.Append(',"MENSAGEM":"' + wsResult.MENSAGEM + '"');
  SB.Append('}');

  Result := SB.ToString;
  SB.Free;
end;


constructor TServerParams.Create;
begin
  HasAuthentication := False;
end;


function TServerParams.GetUserName : String;
begin
  Result := fUsername;
end;

function TServerParams.GetPassword : String;
begin
  Result := fPassword;
end;

function TServerParams.GetHasAuthentication : Boolean;
Begin
  Result := fHasAuthenticacion;
End;

end.
