unit MainFUnit;

interface

uses
  SysUtils, StrUtils, Forms, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinsdxBarPainter, xmldom, XMLIntf, DB,
  mySQLDbTables, msxmldom, XMLDoc, Dialogs, ImgList, Controls, dxBar,
  cxClasses, Classes, ActnList, cxSplitter, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, StdCtrls, ExtCtrls, FrameMostCategoryUnit,
  FrameMostProductsUnit, ExchangeRatesFUnit;

type
  TMainF = class(TForm)
    dbMostPriceList: TmySQLDatabase;
    AL1            : TActionList;
    actExit        : TAction;
    actOpen        : TAction;
    actRates       : TAction;
    actRefresh     : TAction;
    actPrint       : TAction;
    actExport      : TAction;

    BM1            : TdxBarManager;
    BM1Bar1        : TdxBar;
    btnExit        : TdxBarLargeButton;
    btnOpen        : TdxBarLargeButton;
    btnRates       : TdxBarLargeButton;
    btnRefresh     : TdxBarLargeButton;
    btnPrint       : TdxBarLargeButton;
    ilImages       : TImageList;

    OpenDialog     : TOpenDialog;
    XMLDocument    : TXMLDocument;

    pnlG1Pad       : TPanel;
    pnlG1          : TPanel;
    pnlG1Filters   : TPanel;
    cxSplitter     : TcxSplitter;
    pnlG2Pad       : TPanel;
    pnlG2          : TPanel;
    pnlG2Filters   : TPanel;
    lblCbCurrency  : TLabel;
    cbCurrency     : TcxComboBox;
    dsRates        : TDataSource;
    qryRates       : TmySQLQuery;

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure actExitExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actRatesExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure cbCurrencyClick(Sender: TObject);
  private
    FrameMostProducts: TFrameMostProducts;
    FrameMostCategory: TFrameMostCategory;
    procedure CatRecChange(RecordID: Integer);
  private
    procedure InitializeDataBase;
    function OpenDatabase: Boolean;
    procedure InitializeCbRates;
  private
    procedure myQueryExecute(aSQL: string);
    procedure DropTablesFromDB;
    procedure CreateTablesInDB;
    procedure ParseXMLFile(fileName: TFileName);
    function IsCodeOnHand(sCode: string): Boolean;
    procedure AddNewCurrency(sCode: string);
  public
    function PriceParser(sPrice: string): string;
    function CurrencyParser(sPrice: string): string;

    procedure Notifier_RefreshAll;
    procedure Notifier_PrintReport;
    procedure Notifier_ExportReport(const aExportFmt:Integer);
end;

const
  gcDB_Name         = 'most_price_list';
  gcDB_Host         = 'devdb.maniapc.org';
  gcDB_Port         = 3307;
  gcDB_UserName     = 'kkroot';
  gcDB_UserPassword = 'k6415dl';

  gcDefaultXMLPath  = 'D:\MostPriceList';

var
  MainF: TMainF;

implementation

uses
  MLDMS_CommonConstants, LocalizeDevExpressUnit;

{$R *.dfm}

procedure TMainF.FormCreate(Sender: TObject);
begin
  if not (OpenDatabase) then
    Exit;
  InitializeCbRates;

  FrameMostCategory := TFrameMostCategory.Create(MainF);
  FrameMostCategory.Parent := pnlG1;
  FrameMostCategory.Align := alClient;

  FrameMostProducts := TFrameMostProducts.Create(MainF);
  FrameMostProducts.Parent := pnlG2;
  FrameMostProducts.Align := alClient;


end;

procedure TMainF.FormActivate(Sender: TObject);
begin
  FrameMostProducts.G1V1.DataController.FocusedRowIndex := 0;
  FrameMostCategory.G1V1.DataController.FocusedRowIndex := 0;
  FrameMostCategory.G1.SetFocus;
end;

procedure TMainF.FormDestroy;
begin
  if (Assigned(FrameMostProducts)) then
    FrameMostProducts.Free;
  if (Assigned(FrameMostCategory)) then
    FrameMostCategory.Free;
  if Assigned(dbMostPriceList)then
    dbMostPriceList.Free;
end;

procedure TMainF.CatRecChange(RecordID: Integer);
begin
  FrameMostProducts.RefreshProducts(RecordID, cbCurrency.Text, 0, 1000);
end;

procedure TMainF.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainF.actOpenExecute(Sender: TObject);
begin
  OpenDialog.InitialDir := gcDefaultXMLPath;
  If(OpenDialog.Execute)then
  begin
    DropTablesFromDB;
    CreateTablesInDB;
    ParseXMLFile(OpenDialog.FileName);
  end;
  Notifier_RefreshAll;
end;

procedure TMainF.actRatesExecute(Sender: TObject);
begin
  ExchangeRatesF.ShowModal;
end;

procedure TMainF.actRefreshExecute(Sender: TObject);
begin
  Notifier_RefreshAll;
end;

procedure TMainF.actPrintExecute(Sender: TObject);
begin
  Notifier_PrintReport;
end;

procedure TMainF.Notifier_PrintReport;
begin
  inherited;
end;

procedure TMainF.Notifier_RefreshAll;
var
  lvSelectedCategoryIndex: Integer;
  lvSelectedCategoryID   : Integer;
begin
  lvSelectedCategoryIndex:=FrameMostCategory.G1V1.Controller.FocusedRowIndex;
  lvSelectedCategoryID:=FrameMostCategory.G1V1.Controller.FocusedRecord.Values[FrameMostCategory.G1V1CategoryID.Index];
  FrameMostCategory.RefershCategory;
  FrameMostProducts.RefreshProducts(lvSelectedCategoryID, cbCurrency.Text, 0, 1000);
  FrameMostCategory.G1V1.DataController.FocusedRecordIndex:=lvSelectedCategoryIndex;
end;

procedure TMainF.Notifier_ExportReport(const aExportFmt: Integer);
begin
  inherited;
end;

procedure TMainF.InitializeDataBase;
begin
  dbMostPriceList.DatabaseName := gcDB_Name;
  dbMostPriceList.Host         := gcDB_Host;
  dbMostPriceList.Port         := gcDB_Port;
  dbMostPriceList.UserName     := gcDB_UserName;
  dbMostPriceList.UserPassword := gcDB_UserPassword;
end;

function TMainF.OpenDatabase: Boolean;
begin
  InitializeDataBase;
  try
    dbMostPriceList.Open;
    Result := dbMostPriceList.Connected;
  finally end;
end;

procedure TMainF.myQueryExecute(aSQL: string);
var
  myQuery: TmySQLQuery;
begin
  myQuery := TmySQLQuery.Create(Self);

  Screen.Cursor := crSQLWait;
  try
    myQuery.Database := dbMostPriceList;
    myQuery.SQL.Text := aSQL;
    myQuery.ExecSQL;
  finally
    FreeAndNil(myQuery);
  end;
  Screen.Cursor := crDefault;
end;

procedure TMainF.DropTablesFromDB;
const
  lcDropTableCategory = 'DROP TABLE IF EXISTS Category;';
  lcDropTableProducts = 'DROP TABLE IF EXISTS Products;';
begin
  myQueryExecute(lcDropTableCategory);
  myQueryExecute(lcDropTableProducts);
end;

procedure TMainF.CreateTablesInDB;
const
  lcCreateTableCategory = 'CREATE TABLE Category (                  ' +
                          '  id INT(10) UNSIGNED NOT NULL,          ' +
                          '  name VARCHAR(50) NOT NULL,             ' +
                          '  PRIMARY KEY (id)                       ' +
                          ');                                       ';

  lcCreateTableProducts = 'CREATE TABLE Products (                  ' +
                          '  id int(10) unsigned NOT NULL,          ' +
                          '  category_id int(10) unsigned NOT NULL, ' +
                          '  name VARCHAR(100) NOT NULL,            ' +
                          '  price_1 double NOT NULL,               ' +
                          '  price_2 double NOT NULL,               ' +
                          '  currency_code VARCHAR(3) NOT NULL,     ' +
                          '  PRIMARY KEY (id)                       ' +
                          ');                                       ';
begin
  myQueryExecute(lcCreateTableCategory);
  myQueryExecute(lcCreateTableProducts);
end;

procedure TMainF.AddNewCurrency(sCode: string);
begin
//
end;

function TMainF.IsCodeOnHand(sCode: string): Boolean;
begin
  Result := True;
end;

function TMainF.CurrencyParser(sPrice: string): string;
begin
  Result := RightStr(Trim(sPrice), 3);
  if not (IsCodeOnHand(Result)) then
    AddNewCurrency(Result);
end;

function TMainF.PriceParser(sPrice: string): string;
begin
  Result := LeftStr(sPrice, Pos(' ', sPrice));
end;

procedure TMainF.ParseXMLFile(fileName: TFileName);
var
  lvNode                : IXMLNode;
  lvsInsertCategoryData : WideString;
  lvsInsertProductData  : WideString;
  StringList            : TStringList;
  lvsCurrentCategoryName: WideString;
  lviCurrentCategoryID  : Integer;
begin
  XMLDocument.FileName := fileName;
  XMLDocument.Active := True;
  StringList := TStringList.Create;

  if not (XMLDocument.IsEmptyDoc) then
  begin
    Screen.Cursor := crHourGlass;
    try
      lvNode := XMLDocument.DocumentElement.ChildNodes.FindNode('item');
      if (lvNode <> nil) then
      begin
        lvsCurrentCategoryName := lvNode.ChildNodes['Category'].Text;
        StringList.Clear;
        StringList.Add(lvsCurrentCategoryName);
        lviCurrentCategoryID := 1;
        lvsInsertCategoryData := 'INSERT INTO Category VALUES ' + '(' + IntToStr(lviCurrentCategoryID) + ', ''' + lvsCurrentCategoryName + '''), ';
        lvsInsertProductData := 'INSERT INTO Products VALUES ';

        repeat
          lvsInsertProductData := lvsInsertProductData + '(' + lvNode.ChildNodes['ProductID'].Text + ', ';
          lvsCurrentCategoryName := lvNode.ChildNodes['Category'].Text;
          if (StringList.IndexOf(lvsCurrentCategoryName) = -1) then
          begin
            StringList.Add(lvsCurrentCategoryName);
            lviCurrentCategoryID := StringList.IndexOf(lvsCurrentCategoryName) + 1;

            lvsInsertCategoryData := lvsInsertCategoryData + ' (' + IntToStr(lviCurrentCategoryID) + ', ';
            lvsInsertCategoryData := lvsInsertCategoryData + '''' + lvsCurrentCategoryName + '''), ';
          end;
          lvsInsertProductData := lvsInsertProductData + IntToStr(lviCurrentCategoryID) + ', ';
          lvsInsertProductData := lvsInsertProductData + '''' + lvNode.ChildNodes['Name'].Text + ''', ';
          lvsInsertProductData := lvsInsertProductData + '''' + PriceParser(lvNode.ChildNodes['Price1'].Text) + ''', ';
          lvsInsertProductData := lvsInsertProductData + '''' + PriceParser(lvNode.ChildNodes['Price2'].Text) + ''', ';
          lvsInsertProductData := lvsInsertProductData + '''' + CurrencyParser(lvNode.ChildNodes['Price1'].Text) + '''), ';

          lvNode := lvNode.NextSibling;
        until (lvNode = nil);

        lvsInsertProductData := LeftStr(lvsInsertProductData, Length(lvsInsertProductData) - 2) + ';';
        lvsInsertCategoryData := LeftStr(lvsInsertCategoryData, Length(lvsInsertCategoryData) - 2) + ';';
      end;
    finally
      XMLDocument.Active := False;
      Screen.Cursor := crDefault;
    end;

    myQueryExecute(lvsInsertProductData);
    myQueryExecute(lvsInsertCategoryData);
  end;
end;

procedure TMainF.InitializeCbRates;
begin
  Screen.Cursor := crSQLWait;
  try
    qryRates.Open;
  finally end;
  Screen.Cursor := crDefault;

  qryRates.First;
  while not (qryRates.Eof) do
  begin
    cbCurrency.Properties.Items.Add(qryRates.FieldByName('code').AsString);
    qryRates.Next;
  end;

  cbCurrency.Properties.DropDownListStyle := lsFixedList;
  cbCurrency.ItemIndex := 0;
end;

procedure TMainF.cbCurrencyClick(Sender: TObject);
begin
  if (Assigned(FrameMostProducts)) then
  begin
    FrameMostProducts.G1V1.Columns[3].Visible := (cbCurrency.Text = 'BGN');
    FrameMostProducts.G1V1.Columns[5].Visible := (cbCurrency.Text = 'BGN');
    Notifier_RefreshAll;
  end;
end;

initialization
  Setup_QuantumGridsResources;
end.
