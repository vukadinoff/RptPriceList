object FrameMostProducts: TFrameMostProducts
  Left = 0
  Top = 0
  Width = 579
  Height = 560
  TabOrder = 0
  object G1: TcxGrid
    Left = 0
    Top = 0
    Width = 579
    Height = 560
    Align = alClient
    TabOrder = 0
    object G1V1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = dsProducts
      DataController.DetailKeyFieldNames = 'ProductID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.ColumnAutoWidth = True
      object G1V1ProductID: TcxGridDBColumn
        Caption = 'No:'
        DataBinding.FieldName = 'ProductID'
        Options.Editing = False
        Options.Focusing = False
        Width = 55
      end
      object G1V1ProductName: TcxGridDBColumn
        Caption = #1055#1088#1086#1076#1091#1082#1090
        DataBinding.FieldName = 'ProductName'
        Options.Editing = False
        Options.Focusing = False
        Width = 219
      end
      object G1V1Price1: TcxGridDBColumn
        Caption = #1062#1077#1085#1072' 1'
        DataBinding.FieldName = 'Price1'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 67
      end
      object G1V1Price1VAT: TcxGridDBColumn
        Caption = #1062#1077#1085#1072' 1 '#1089' '#1044#1044#1057
        DataBinding.FieldName = 'Price1VAT'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 150
      end
      object G1V1Price2: TcxGridDBColumn
        Caption = #1062#1077#1085#1072' 2'
        DataBinding.FieldName = 'Price2'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 69
      end
      object G1V1Price2VAT: TcxGridDBColumn
        Caption = #1062#1077#1085#1072' 2 '#1089' '#1044#1044#1057
        DataBinding.FieldName = 'Price2VAT'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 140
      end
    end
    object G1L1: TcxGridLevel
      GridView = G1V1
    end
  end
  object dsProducts: TDataSource
    DataSet = qryProducts
    Left = 120
    Top = 72
  end
  object qryProducts: TmySQLQuery
    Database = MainF.dbMostPriceList
    Left = 40
    Top = 72
  end
end
