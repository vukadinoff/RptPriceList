unit DataModule;

interface

uses
  Dialogs, SysUtils, Classes, DB, dxmdaset, mySQLDbTables;

type
  TDM = class(TDataModule)
    tblCrossRates : TmySQLTable;
    dsDataSource  : TDataSource;
  private
    function CalculateRate(const rate1: Double; const rate2: Double): Double;
  public
    procedure CalculateCrossRates;
  end;

var
  DM: TDM;

implementation

uses
  MainFUnit;

{$R *.dfm}

function TDM.CalculateRate(const rate1: Double; const rate2: Double): Double;
begin
  Result:=(rate1/rate2);
end;

procedure TDM.CalculateCrossRates;
var
  qryRatesCopy : TmySQLQuery;
  qryRatesCopy1: TmySQLQuery;
  qryRatesCopy2: TmySQLQuery;
begin
  qryRatesCopy:=TmySQLQuery.Create(Self);
  qryRatesCopy.Database:=MainF.dbMostPriceList;
  qryRatesCopy.SQL.Text:='TRUNCATE TABLE CrossRates;';
  qryRatesCopy.ExecSQL;

  qryRatesCopy1:=TmySQLQuery.Create(Self);
  qryRatesCopy1.Database:=MainF.dbMostPriceList;
  qryRatesCopy1.SQL.Text:='SELECT * FROM ExchangeRates;';
  qryRatesCopy1.Open;

  qryRatesCopy2:=TmySQLQuery.Create(Self);
  qryRatesCopy2.Database:=MainF.dbMostPriceList;
  qryRatesCopy2.SQL.Text:='SELECT * FROM ExchangeRates;';
  qryRatesCopy2.Open;

  if(Assigned(DM)) then
  begin
    with DM.tblCrossRates do
    begin
      while not (qryRatesCopy1.Eof) do
      begin
        qryRatesCopy2.First;
        while not (qryRatesCopy2.Eof) do
        begin
          Active:=True;
          Insert;
          FieldValues['currency_pair'] := MainF.CurrencyParser(qryRatesCopy1.FieldValues['code']) + '/' +
                                          MainF.CurrencyParser(qryRatesCopy2.FieldValues['code']);
          FieldValues['cross_rate'] := CalculateRate(qryRatesCopy1.FieldValues['rate'], qryRatesCopy2.FieldValues['rate']);
          qryRatesCopy2.Next;
        end;
        qryRatesCopy1.Next;
      end;
      Post;
    end;

  end;
  FreeAndNil(qryRatesCopy);
  FreeAndNil(qryRatesCopy1);
  FreeAndNil(qryRatesCopy2);
end;

end.
