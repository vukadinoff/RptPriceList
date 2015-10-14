object ExchangeRatesF: TExchangeRatesF
  Left = 413
  Top = 244
  Width = 450
  Height = 275
  Caption = #1042#1072#1083#1091#1090#1085#1080' '#1082#1091#1088#1089#1086#1074#1077
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object G1: TcxGrid
    Left = 0
    Top = 0
    Width = 434
    Height = 237
    Align = alClient
    TabOrder = 0
    object G1V1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.First.Visible = False
      Navigator.Buttons.PriorPage.Visible = False
      Navigator.Buttons.Prior.Visible = False
      Navigator.Buttons.Next.Visible = False
      Navigator.Buttons.NextPage.Visible = False
      Navigator.Buttons.Last.Visible = False
      Navigator.Buttons.Insert.Visible = False
      Navigator.Buttons.Append.Visible = True
      Navigator.Buttons.Delete.Visible = True
      Navigator.Buttons.SaveBookmark.Visible = False
      Navigator.Buttons.GotoBookmark.Visible = False
      Navigator.Buttons.Filter.Visible = False
      Navigator.Visible = True
      DataController.DataSource = dsDataSource
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Appending = True
      OptionsView.ColumnAutoWidth = True
      object G1V1code: TcxGridDBColumn
        Caption = #1050#1086#1076' '#1085#1072' '#1074#1072#1083#1091#1090#1072
        DataBinding.FieldName = 'code'
        Width = 103
      end
      object G1V1currency: TcxGridDBColumn
        Caption = #1042#1072#1083#1091#1090#1072
        DataBinding.FieldName = 'currency'
        Width = 230
      end
      object G1V1rate: TcxGridDBColumn
        Caption = #1051#1077#1074#1072' '#1079#1072' '#1077#1076#1080#1085#1080#1094#1072
        DataBinding.FieldName = 'rate'
        Width = 99
      end
    end
    object G1Level1: TcxGridLevel
      GridView = G1V1
    end
  end
  object tblExchangeRates: TmySQLTable
    Database = MainF.dbMostPriceList
    Active = True
    FieldDefs = <
      item
        Name = 'code'
        Attributes = [faRequired]
        DataType = ftString
        Size = 3
      end
      item
        Name = 'currency'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'rate'
        DataType = ftFloat
      end>
    IndexDefs = <
      item
        Fields = 'code'
        Options = [ixPrimary, ixUnique]
      end>
    StoreDefs = True
    TableName = 'ExchangeRates'
    Left = 40
    Top = 152
  end
  object dsDataSource: TDataSource
    DataSet = tblExchangeRates
    Left = 136
    Top = 152
  end
end
