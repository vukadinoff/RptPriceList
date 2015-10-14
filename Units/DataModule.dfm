object DM: TDM
  OldCreateOrder = False
  Left = 192
  Top = 124
  Height = 319
  Width = 423
  object tblCrossRates: TmySQLTable
    Database = MainF.dbMostPriceList
    TableName = 'CrossRates'
    Left = 24
    Top = 16
  end
  object dsDataSource: TDataSource
    DataSet = tblCrossRates
    Left = 96
    Top = 16
  end
end
