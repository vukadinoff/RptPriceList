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
      PopupMenu = G1Popup
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
  object qryProductsUpdate: TmySQLUpdateSQL
    Left = 40
    Top = 128
  end
  object Printer1: TdxComponentPrinter
    CurrentLink = Printer1G1
    Version = 0
    Left = 176
    Top = 72
    object Printer1G1: TdxGridReportLink
      Active = True
      Component = G1
      PrinterPage.DMPaper = 9
      PrinterPage.Footer = 6350
      PrinterPage.Header = 6350
      PrinterPage.Margins.Bottom = 12700
      PrinterPage.Margins.Left = 12700
      PrinterPage.Margins.Right = 12700
      PrinterPage.Margins.Top = 12700
      PrinterPage.PageSize.X = 210000
      PrinterPage.PageSize.Y = 297000
      PrinterPage._dxMeasurementUnits_ = 0
      PrinterPage._dxLastMU_ = 2
      ReportDocument.CreationDate = 42290.711193842600000000
      OptionsSize.AutoWidth = True
      OptionsView.Footers = False
      OptionsView.Caption = False
      OptionsView.FilterBar = False
      BuiltInReportLink = True
    end
  end
  object G1Popup: TPopupMenu
    Left = 244
    Top = 72
    object N3: TMenuItem
      Caption = '-'
    end
  end
end
