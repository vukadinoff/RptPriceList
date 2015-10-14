unit FrameMostProductsUnit;

interface

uses
  Forms, SysUtils, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, dxSkinsCore, dxSkinsDefaultPainters, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, DB,
  cxDBData, cxCurrencyEdit, mySQLDbTables, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, Classes, Controls, cxGrid;

type
  TFrameMostProducts = class(TFrame)
    G1              : TcxGrid;
    G1V1            : TcxGridDBTableView;
    G1L1            : TcxGridLevel;
    dsProducts      : TDataSource;
    qryProducts     : TmySQLQuery;

    G1V1ProductID   : TcxGridDBColumn;
    G1V1ProductName : TcxGridDBColumn;
    G1V1Price1      : TcxGridDBColumn;
    G1V1Price1VAT   : TcxGridDBColumn;
    G1V1Price2      : TcxGridDBColumn;
    G1V1Price2VAT   : TcxGridDBColumn;
  private
    { Private declarations }
  public
    constructor Create(AOwner:TComponent); override;
    procedure RefreshProducts(const CategoryID: Integer;
                              const ReportCurrency: string;
                              const min_price: Double;
                              const max_price: Double);
end;

implementation

{$R *.dfm}

uses
  MainFUnit, DataModule, MLDMS_CommonExportsUnit;

constructor TFrameMostProducts.Create(AOwner: TComponent);
begin
  inherited;
  RefreshProducts(4, 'BGN', 0, 1000);
end;

procedure TFrameMostProducts.RefreshProducts(const CategoryID: Integer;
                                             const ReportCurrency: string;
                                             const min_price: Double;
                                             const max_price: Double);
const
  lcSQL=  'SELECT p.id AS ProductID,                                                                  ' +
	        '       p.name AS ProductName,                                                              ' +
          '       p.currency_code,                                                                    ' +
	        '       (p.price_1)*(SELECT cross_rate                                                      ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %s)) AS Price1,          ' +
	        '       (p.price_1)*(SELECT cross_rate                                                      ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %s))*(1.2) AS Price1VAT, ' +
	        '       (p.price_2)*(SELECT cross_rate                                                      ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %s)) AS Price2,          ' +
	        '       (p.price_2)*(SELECT cross_rate                                                      ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %s))*(1.2) AS Price2VAT  ' +
	        'FROM Products p                                                                            ' +
	        'INNER JOIN Category AS c                                                                   ' +
          '        ON (c.id = p.category_id)                                                          ' +
          'WHERE ((p.category_id = %d) AND                                                            ' +
          '      ((Price1 BETWEEN %f AND %f) OR (p.price_2 BETWEEN %f AND %f)));                   ';
var
  lvsReportCurrency: string;
begin
  if MainF.dbMostPriceList.Connected then
  begin
    Screen.Cursor := crSQLWait;
    if (Assigned(MainF.qryRates)) then DM.CalculateCrossRates;

    qryProducts.Active:=False;
    lvsReportCurrency:='''/' + ReportCurrency + '''';
    qryProducts.SQL.Text:= Format(lcSQL, [lvsReportCurrency, lvsReportCurrency,
                                          lvsReportCurrency, lvsReportCurrency,
                                          CategoryID, min_price, max_price,
                                          min_price, max_price]);
    try
      qryProducts.Open;
    finally end;
    qryProducts.Active:= True;
    Screen.Cursor := crDefault;
  end;
end;

end.
