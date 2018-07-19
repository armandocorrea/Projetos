object dtmPrincipal: TdtmPrincipal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 252
  Width = 229
  object Conexao: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 24
    Top = 8
  end
  object FDRodadas: TFDQuery
    Connection = Conexao
    SQL.Strings = (
      'SELECT RODADAS.ID,'
      '       RODADAS.ID_GRUPO,'
      '       RODADAS.ID_SELECAO_A,'
      '       RODADAS.ID_SELECAO_B,'
      '       RODADAS.NOME,'
      '       RODADAS.RESULTADO_A,'
      '       RODADAS.RESULTADO_B'
      '  FROM RODADAS')
    Left = 24
    Top = 88
    object FDRodadasID: TFDAutoIncField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object FDRodadasID_GRUPO: TIntegerField
      FieldName = 'ID_GRUPO'
      Origin = 'ID_GRUPO'
    end
    object FDRodadasID_SELECAO_A: TIntegerField
      FieldName = 'ID_SELECAO_A'
      Origin = 'ID_SELECAO_A'
    end
    object FDRodadasID_SELECAO_B: TIntegerField
      FieldName = 'ID_SELECAO_B'
      Origin = 'ID_SELECAO_B'
    end
    object FDRodadasNOME: TStringField
      FieldName = 'NOME'
      Origin = 'NOME'
      Size = 50
    end
    object FDRodadasRESULTADO_A: TIntegerField
      FieldName = 'RESULTADO_A'
      Origin = 'RESULTADO_A'
    end
    object FDRodadasRESULTADO_B: TIntegerField
      FieldName = 'RESULTADO_B'
      Origin = 'RESULTADO_B'
    end
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 88
    Top = 8
  end
  object FDClassificacao: TFDQuery
    Connection = Conexao
    SQL.Strings = (
      'SELECT CLASSIFICACAO.ID,'
      '       CLASSIFICACAO.ID_GRUPO,'
      '       CLASSIFICACAO.ID_SELECAO,'
      '       CLASSIFICACAO.PONTOS,'
      '       CLASSIFICACAO.VITORIAS,'
      '       CLASSIFICACAO.JOGOS,'
      '       CLASSIFICACAO.DERROTAS,'
      '       CLASSIFICACAO.EMPATES,'
      '       CLASSIFICACAO.SALDO'
      '  FROM CLASSIFICACAO')
    Left = 80
    Top = 88
    object FDClassificacaoID: TFDAutoIncField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object FDClassificacaoID_GRUPO: TIntegerField
      FieldName = 'ID_GRUPO'
      Origin = 'ID_GRUPO'
    end
    object FDClassificacaoID_SELECAO: TIntegerField
      FieldName = 'ID_SELECAO'
      Origin = 'ID_SELECAO'
    end
    object FDClassificacaoPONTOS: TIntegerField
      FieldName = 'PONTOS'
      Origin = 'PONTOS'
    end
    object FDClassificacaoVITORIAS: TIntegerField
      FieldName = 'VITORIAS'
      Origin = 'VITORIAS'
    end
    object FDClassificacaoJOGOS: TIntegerField
      FieldName = 'JOGOS'
      Origin = 'JOGOS'
    end
    object FDClassificacaoDERROTAS: TIntegerField
      FieldName = 'DERROTAS'
      Origin = 'DERROTAS'
    end
    object FDClassificacaoEMPATES: TIntegerField
      FieldName = 'EMPATES'
      Origin = 'EMPATES'
    end
    object FDClassificacaoSALDO: TIntegerField
      FieldName = 'SALDO'
      Origin = 'SALDO'
    end
  end
end
