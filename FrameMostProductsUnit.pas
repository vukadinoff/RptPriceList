unit FrameMostProductsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, DB, cxDBData, mySQLDbTables, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, Menus, cxGrid, dxPSGlbl, dxPSUtl, dxPSEngn, dxPrnPg,
  dxBkgnd, dxWrap, dxPrnDev, dxPSCompsProvider, dxPSFillPatterns,
  dxPSEdgePatterns, dxPSPDFExportCore, dxPSPDFExport, cxDrawTextUtils,
  dxPSPrVwStd, dxPSPrVwAdv, dxPSPrVwRibbon, dxPScxPageControlProducer,
  dxPScxGridLnk, dxPScxGridLayoutViewLnk, dxPScxEditorProducers,
  dxPScxExtEditorProducers, dxPSCore, dxPScxCommon,cxCurrencyEdit,
  dxSkinsDefaultPainters, dxSkinscxPCPainter;







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
    qryProductsUpdate: TmySQLUpdateSQL;
    Printer1: TdxComponentPrinter;
    Printer1G1: TdxGridReportLink;
    G1Popup: TPopupMenu;
    N3: TMenuItem;
  private
    { Private declarations }
    function RangeMaxValue(Value:double):Integer;
    function RangeMinValue(Value:double):Integer;
  public
    constructor Create(AOwner:TComponent); override;
    procedure RefreshProducts(const CategoryID:Integer;const CurrCode:string;const MinValue:Double; MaxValue:Double);
    procedure Print(CurrentCategory:string);
    function GetValueRange(const ValueType:Integer;CurrCode:string) : Integer;
end;

implementation

{$R *.dfm}
uses
  MainFUnit,DataModule, MLDMS_CommonExportsUnit ;

constructor TFrameMostProducts.Create(AOwner: TComponent);
begin
  inherited;
  qryProducts.Database := MainF.dbMostPriceList;
  dsProducts.DataSet:= qryProducts;
  G1V1.DataController.DataSource := dsProducts;
  G1V1.DataController.DetailKeyFieldNames:= 'ProductID';
  G1V1.OptionsView.ColumnAutoWidth:= True;
  TcxGridExportMenuGroup.CreateMenuGroup(G1Popup, N3);
end;

function TFrameMostProducts.GetValueRange(const ValueType:integer;CurrCode:string): Integer;
var
  qryRange : TmySQLQuery;
  lvMaxPrice1, lvMaxPrice2,lvMinPrice1,lvMinPrice2:Double;
  lvsReportCurrency: string;
const
  lcSQLMin = 'SELECT min((p.price_1)*(SELECT cross_rate FROM CrossRates              '+
             'WHERE currency_pair = CONCAT(p.currency_code, %0:s))) AS MinPrice1,    '+
             'min((p.price_2)*(SELECT cross_rate FROM CrossRates                     '+
             'WHERE currency_pair = CONCAT(p.currency_code, %0:s))) AS MinPrice2 from Products p;';

  lcSQLMax = 'SELECT max((p.price_1)*(SELECT cross_rate FROM CrossRates              '+
             'WHERE currency_pair = CONCAT(p.currency_code, %0:s))) AS MaxPrice1,    '+
             'max((p.price_2)*(SELECT cross_rate FROM CrossRates                     '+
             'WHERE currency_pair = CONCAT(p.currency_code, %0:s))) AS MaxPrice2 from Products p;';
begin
  Result:= 0;
  lvsReportCurrency:='''/' + CurrCode + '''';
  Try
    qryRange:= TmySQLQuery.Create(Self);
    qryRange.Database:= MainF.dbMostPriceList;
    if ValueType = MAX then
    begin
      qryRange.Close;
      qryRange.SQL.Text:= Format(lcSQLMax,[lvsReportCurrency]);
      qryRange.Open;
      qryRange.First;
      lvMaxPrice1:= qryRange.FieldByName('MaxPrice1').AsFloat;
      lvMaxPrice2:= qryRange.FieldByName('MaxPrice2').AsFloat;

      if lvMaxPrice1>=lvMaxPrice2 then
        Result:= RangeMaxValue(lvMaxPrice1)
      else
        Result:= RangeMaxValue(lvMaxPrice2);
    end
    else
      if ValueType = MIN then
      begin
        qryRange.Close;
        qryRange.SQL.Text:= Format(lcSQLMin,[lvsReportCurrency]);
        qryRange.Open;
        qryRange.First;
        lvMinPrice1:= qryRange.FieldByName('MinPrice1').AsFloat;
        lvMinPrice2:= qryRange.FieldByName('MinPrice2').AsFloat;

        if lvMinPrice1<=lvMinPrice2 then
          Result:= RangeMinValue(lvMinPrice1)
        else
          Result:= RangeMinValue(lvMinPrice2);
      end;
  Finally
    qryRange.Free;
  end;
end;

procedure TFrameMostProducts.Print(CurrentCategory: string);
var
 lvLabel:string;
begin
  lvLabel:= 'Категория: "'+CurrentCategory+'"';
  Printer1G1.ReportTitle.Font.Name:= 'Arial';
  Printer1G1.ReportTitle.Text:=lvLabel;
  Printer1G1.PrinterPage.PageFooter.Font.Style:= Printer1G1.PrinterPage.PageFooter.Font.Style+[fsItalic];
  Printer1G1.PrinterPage.PageFooter.LeftTitle.Text:= lvLabel;
  Printer1G1.Preview(True);
end;

function TFrameMostProducts.RangeMaxValue(Value: double): Integer;
var
  lvValueStr:string;
  lvValue:Double;
  DotPosition:Integer;
begin
  Result:= 5000;
  lvValue:= Value+1;
  lvValueStr:= FloatToStr(lvValue);
  DotPosition:= Pos('.',lvValueStr);
  if DotPosition>0 then
    TryStrToInt(Copy(lvValueStr,0,DotPosition-1),Result)
  else
    TryStrToInt(lvValueStr,Result);
end;

function TFrameMostProducts.RangeMinValue(Value: double): Integer;
var
  lvValueStr:string;
  lvValue:Double;
  DotPosition:Integer;
begin
  Result:=0;
  lvValue:= Value;
  lvValueStr:= FloatToStr(lvValue);
  if lvValueStr[1] = '0' then
    Result:=0
  else
  begin
    lvValue:= lvValue-1;
    lvValueStr:= FloatToStr(lvValue);
    DotPosition:= Pos('.',lvValueStr);
    if DotPosition>0 then
      TryStrToInt(Copy(lvValueStr,0,DotPosition-1),Result)
    else
      TryStrToInt(lvValueStr,Result);
  end;

end;

procedure TFrameMostProducts.RefreshProducts(const CategoryID:Integer;const CurrCode:string;const MinValue:Double; MaxValue:Double);
const
  lcSQL= 'SELECT p.id AS ProductID,                                                                  ' +
	        '       p.name AS ProductName,                                                              ' +
          '       p.currency_code,                                                                    ' +
	        '       (p.price_1)*(SELECT cross_rate                                                      ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %3:s)) AS Price1,          ' +
	        '       (p.price_1)*(SELECT cross_rate                                                      ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %3:s))*(1.2) AS Price1VAT, ' +
	        '       (p.price_2)*(SELECT cross_rate                                                       ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %3:s)) AS Price2,          ' +
	        '       (p.price_2)*(SELECT cross_rate                                                      ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %3:s))*(1.2) AS Price2VAT  ' +
	        'FROM Products p                                                                            ' +
	        'INNER JOIN Category c ON (c.id = p.category_id)					'+
  			  'WHERE c.id = %0:d AND (((p.price_1)*(SELECT cross_rate                                     ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %3:s)) BETWEEN %1:f AND %2:f) 			'+CRLF+
 	        'OR ((p.price_2)*(SELECT cross_rate                                                       ' +
          '                    FROM CrossRates                                                        ' +
          '                    WHERE currency_pair = CONCAT(p.currency_code, %3:s)) BETWEEN %1:f AND %2:f));';
var
  lvsReportCurrency: string;
begin
  if MainF.dbMostPriceList.Connected then
  begin
    Screen.Cursor := crSQLWait;
    qryProducts.Active:= False;
    lvsReportCurrency:='''/' + MainF.cbCurrency.Text + '''';
    qryProducts.SQL.Text:= Format(lcSQL,[CategoryID,MinValue,MaxValue,lvsReportCurrency]);
    try
      qryProducts.Open;
    finally end;
    qryProducts.Active:= True;
    Screen.Cursor := crDefault;
  end;
end;

end.
