unit MainFUnit;

interface

uses
  ActnList, Classes, SysUtils, StrUtils, DateUtils, Controls, ExtCtrls, Forms, ImgList,
  dxSkinsdxBarPainter, dxSkinsDefaultPainters, Dialogs, dxBar,
  cxClasses, dxPSGlbl, dxPSUtl, dxPSEngn, dxPrnPg, dxBkgnd, dxWrap,
  dxPrnDev, dxPSCompsProvider, dxPSFillPatterns, dxPSEdgePatterns, dxPSPDFExportCore, dxPSPDFExport,
  cxDrawTextUtils, dxSkinscxPCPainter, dxPSPrVwStd, dxPSPrVwAdv,
  dxPSPrVwRibbon, dxPScxPageControlProducer, dxPScxGridLnk,
  dxPScxGridLayoutViewLnk, dxPScxEditorProducers, dxPScxExtEditorProducers,
  dxSkinsdxRibbonPainter, dxPSCore, dxPScxCommon, dxSkinsCore,
  DB, mySQLDbTables, xmldom, XMLIntf, StdCtrls, msxmldom, XMLDoc, FMTBcd, SqlExpr,
  MegalanMySQLConnectionUnit, MySQLBatch, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxSplitter, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxGrid, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxNavigator, cxDBData, cxGridLevel,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxButtonEdit, cxBarEditItem,
  FrameMostCategoryUnit, FrameMostProductsUnit,ExchangeRatesFUnit, cxTrackBar, cxLabel,
  cxSpinEdit, cxObjectSpinEdit;


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
    btnExport      : TdxBarLargeButton;
    ilImages       : TImageList;

    OpenDialog     : TOpenDialog;
    PrintDialog    : TPrintDialog;
    XMLDocument    : TXMLDocument;
    dxBarSubItem1: TdxBarSubItem;
    btnExp: TdxBarSubItem;
    dxBarSubItem3: TdxBarSubItem;
    dxBarSubItem4: TdxBarSubItem;
    btnExpToExcel: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarListItem1: TdxBarListItem;
    dxBarSeparator1: TdxBarSeparator;
    btnExpToHTML: TdxBarButton;
    btnExpToXML: TdxBarButton;
    btnExpToTXT: TdxBarButton;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarButton1: TdxBarButton;
    cxBarEditItem1: TcxBarEditItem;

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
    lbMinValue: TcxLabel;
    lbMaxValue: TcxLabel;
    edMinValue: TcxObjectSpinEdit;
    edMaxValue: TcxObjectSpinEdit;


    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure actExitExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actRatesExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure cbCurrencyClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    FrameMostProducts: TFrameMostProducts; //Frame instance variable end;
    FrameMostCategory: TFrameMostCategory; //Frame instance variable end;
    procedure CatRecChange(RecordID:integer);
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
    procedure InitPriceRangeEdits;
  public

end;

const
  gcDB_Name         = 'most_price_list';
  gcDB_Host         = 'devdb.maniapc.org';
  gcDB_Port         = 3307;
  gcDB_UserName     = 'kkroot';
  gcDB_UserPassword = 'k6415dl';

  gcDefaultXMLPath  = 'D:\MostPriceList';
  CRLF     = #13#10;
  MIN = 1;
  MAX = 2;

var
  MainF: TMainF;

implementation

uses
  MLDMS_CommonConstants, LocalizeDevExpressUnit, MLDMS_CommonExportsUnit;

{$R *.dfm}

procedure TMainF.FormCreate(Sender: TObject);
begin
  if not (OpenDatabase) then
    Exit;// If Open Database process fail then application terminate
  InitializeCbRates;

  FrameMostCategory := TFrameMostCategory.Create(MainF);
  FrameMostCategory.Parent := pnlG1;
  FrameMostCategory.Align := alClient;

  FrameMostProducts := TFrameMostProducts.Create(MainF);
  FrameMostProducts.Parent := pnlG2;
  FrameMostProducts.Align := alClient;

  InitPriceRangeEdits;
  FrameMostCategory.OnCatRecChange:= MainF.CatRecChange;
  btnRefresh.Click;
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
  FrameMostCategory.RefershCategory;
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
  FrameMostProducts.Print(FrameMostCategory.GetCurrentCategoryName);
end;

procedure TMainF.Notifier_RefreshAll;
begin
  FrameMostCategory.RefershCategory;
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

procedure TMainF.CatRecChange(RecordID: integer);
begin
  FrameMostProducts.RefreshProducts(RecordID,cbCurrency.Text,edMinValue.Value,edMaxValue.Value);
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
    InitPriceRangeEdits;
    btnRefresh.Click;
  end;
end;

procedure TMainF.btnExportClick(Sender: TObject);
begin
  if Sender is TComponent then
  begin
    case (Sender as TComponent).Tag of
      1: CommonExports.ExportGridTo(FrameMostProducts.G1);
      2: CommonExports.ExportGridTo(FrameMostProducts.G1, cesHTML);
      3: CommonExports.ExportGridTo(FrameMostProducts.G1, cesXML);
      4: CommonExports.ExportGridTo(FrameMostProducts.G1, cesTXT);
    end;
  end;
end;

procedure TMainF.InitPriceRangeEdits;
begin
  edMinValue.Value:= FrameMostProducts.GetValueRange(MIN,cbCurrency.Text);
  edMaxValue.Value:= FrameMostProducts.GetValueRange(MAX,cbCurrency.Text);
end;

initialization
  Setup_QuantumGridsResources;

end.
