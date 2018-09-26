unit ULib;

interface

uses
  Vcl.Forms, system.SysUtils, System.IniFiles;

procedure ConfiguraIni(const pGrupo, pCampo, pValor: String; const pPath: String = '');
function  CarregaIni(const pGrupo, pCampo: String; const pPath: String = ''): String;
function  Crypt(Action, Src: String): String;

implementation

procedure ConfiguraIni(const pGrupo, pCampo, pValor: String; const pPath: String = '');
var
  vIni: TIniFile;
begin
  if Trim(pPath) = '' then
    vIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'))
  else
    vIni := TIniFile.Create(ChangeFileExt(pPath,'.ini'));

  try
    vIni.WriteString(pGrupo, pCampo, pValor);
  finally
    vIni.Free;
  end;
end;

function CarregaIni(const pGrupo, pCampo: String; const pPath: String = ''): String;
var
  vIni: TIniFile;
begin
  Result := '';
  if Trim(pPath) = '' then
    vIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'))
  else
    vIni := TIniFile.Create(ChangeFileExt(pPath,'.ini'));

  try
    Result := vIni.ReadString(pGrupo, pCampo, '');
  finally
    vIni.Free;
  end;
end;

function Crypt(Action, Src: String): String;
var
  KeyLen    : Integer;
  KeyPos    : Integer;
  OffSet    : Integer;
  Dest, Key : String;
  SrcPos    : Integer;
  SrcAsc    : Integer;
  TmpSrcAsc : Integer;
  Range     : Integer;
begin
  if (Src = '') Then
  begin
    Result:= '';
    Exit;
  end;
  Key    := 'YUQL23KL23DF90WI5E1JAS467NMCXXL6JAOAUWWMCL0AOMM4A4VZYW9KHJUI2347EJHJKDF3424SKL K3LAKDJSL9RTIKJ';
  Dest   := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  SrcPos := 0;
  SrcAsc := 0;
  Range := 256;

  if (Action = UpperCase('C')) then
  begin
    Randomize;
    OffSet := Random(Range);
    Dest   := Format('%1.2x',[OffSet]);

    for SrcPos := 1 to Length(Src) do
    begin
      Application.ProcessMessages;
      SrcAsc := (Ord(Src[SrcPos]) + OffSet) Mod 255;

      if KeyPos < KeyLen then
        KeyPos := KeyPos + 1 else KeyPos := 1;

      SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      Dest   := Dest + Format('%1.2x',[SrcAsc]);
      OffSet := SrcAsc;
    end;
  end
  Else if (Action = UpperCase('D')) then
  begin
    OffSet := StrToInt('$' + copy(Src,1,2));//<--------------- adiciona o $ entra as aspas simples
    SrcPos := 3;
    repeat
      SrcAsc := StrToInt('$' + copy(Src,SrcPos,2));//<--------------- adiciona o $ entra as aspas simples

      if (KeyPos < KeyLen) Then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;

      TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);

      if TmpSrcAsc <= OffSet then
        TmpSrcAsc := 255 + TmpSrcAsc - OffSet
      else
        TmpSrcAsc := TmpSrcAsc - OffSet;

      Dest   := Dest + Chr(TmpSrcAsc);
      OffSet := SrcAsc;
      SrcPos := SrcPos + 2;
    until (SrcPos >= Length(Src));
  end;
  Result:= Dest;
end;

end.

