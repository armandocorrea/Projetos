unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, Winapi.Windows,
     JSON, Dialogs, ServerUtils, SysTypes, HandleContext;

type
{$METHODINFO ON}
  TServerMethods1 = class
  private
    { Private declarations }
    fContext : TServerContext;

  public
    { Public declarations }
    Constructor Create (aContext : TServerContext); OverLoad;
    Destructor Destroy; Override;
    property Context : TServerContext read fContext write fContext;

    // http://localhost:8080/InsereAluno/fulano
    function InsereAluno (NomeAluno : String) : String;

    // http://localhost:8080/ConsultaAluno/fulano
    {function ConsultaAluno (NomeAluno : String) : String;}

    // http://localhost:8080/GetListaAlunos
    function GetListaAlunos : String;

    // http://localhost:8080/AtualizaAluno/Fulano/cicrano
    function AtualizaAluno (OldNomeAluno, NewNome : String) : String;

    // http://localhost:8080/ExcluiAluno/NomeAluno
    function ExcluiAluno (NomeAluno : String) : String;
  end;
{$METHODINFO OFF}

implementation


uses System.StrUtils;


Constructor TServerMethods1.Create (aContext : TServerContext);
Begin
     inherited Create;
     fContext := aContext;
End;

Destructor TServerMethods1.Destroy;
begin
     inherited Destroy;
End;


// Aqui voce vai
// 1 - Conectar com o Banco
// 2 - Executar a query
// 3 - Fechar conexão com o banco
// 4 - Retornar o resultado em JSON

// Foi usado um Arquivo Texto para armazenar dados e um StringList
// o objetivo aqui é apenas mostrar como é um WebService REST + JSON
// e suas operações, o codigo de banco fica por sua conta.

function TServerMethods1.InsereAluno (NomeAluno : String) : String;
Var
     List : TStringList;
     JSONObject : TJSONObject;
Begin
     List       := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         Context.LogBusiness('InsereAluno : ' + NomeAluno);
         if Not FileExists (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt') then
            FileClose(FileCreate (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt'));

         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         List.Add (NomeAluno);
         List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');

         JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
         JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Inserido com sucesso'));
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
End;

{function TServerMethods1.ConsultaAluno (NomeAluno : String) : String;
Var
     List : TStringList;
     JSONObject : TJSONObject;
     ID : Integer;
Begin
     List := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         Context.LogBusiness('ConsultaAluno : ' + NomeAluno);
         if FileExists (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt') then Begin
            List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
            ID := List.IndexOf(NomeAluno);
            if ID > -1 then Begin
               JSONObject.AddPair(TJSONPair.Create('ID', IntToStr (ID)));
            end else begin
               JSONObject.AddPair(TJSONPair.Create('STATUS', 'NOK'));
               JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Não encontrado'));
            end;
         End Else begin
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'NOK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Não encontrado'));
         end;
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
end;}

function TServerMethods1.GetListaAlunos : String;
Var
     List        : TStringList;
     ID          : Integer;
     LJson       : TJSONObject;
     LJsonObject : TJSONObject;
     LArr        : TJSONArray;
Begin
     List        := TStringList.Create;
     LJsonObject := TJSONObject.Create;
     LArr        := TJSONArray.Create;
     try
         Context.LogBusiness('GetListaAlunos ');
         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         for Id := 0 to List.Count - 1 do Begin
             LJson := TJSONObject.Create;
             LJson.AddPair(TJSONPair.Create('NomeAluno', List [ID]));
             LArr.Add(LJson);
         End;
         LJsonObject.AddPair(TJSONPair.Create('Alunos', LArr));
         Result := LJsonObject.ToString;
     Finally
         List.Free;
         LJsonObject.Free;
     end;
end;

function TServerMethods1.AtualizaAluno (OldNomeAluno, NewNome : String) : String;
Var
     List       : TStringList;
     JSONObject : TJSONObject;
     ID         : Integer;
Begin
     List := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         Context.LogBusiness('AtualizaAluno : ' + OldNomeAluno + ' para ' + NewNome);
         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         ID := List.IndexOf(OldNomeAluno);
         if ID > -1 then Begin
            List[ID] := NewNome;
            List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Atualizado com sucesso'));
         End else begin
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'NOK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Aluno não encontrado'));
         end;
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
end;

function TServerMethods1.ExcluiAluno (NomeAluno : String) : String;
Var
     List       : TStringList;
     JSONObject : TJSONObject;
     ID         : Integer;
Begin
     List := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         Context.LogBusiness('ExcluiAluno : ' + NomeAluno);
         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         ID := List.IndexOf(NomeAluno);
         if ID > -1 then Begin
            List.Delete(ID);
            List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Deletado com sucesso'));
         End else begin
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'NOK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Aluno não encontrado'));
         end;
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
end;

end.





