unit FrameMostCategoryUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  mySQLDbTables, dxSkinsCore, dxSkinsDefaultPainters, dxSkinscxPCPainter;

type
   TOnChangeEvent = procedure(RecordID: integer) of object;

type
  TFrameMostCategory = class(TFrame)
    G1              : TcxGrid;
    G1V1            : TcxGridDBTableView;
    G1L1            : TcxGridLevel;
    G1V1CategoryID  : TcxGridDBColumn;
    G1V1CategoryName: TcxGridDBColumn;

    dsCategory      : TDataSource;
    qryCategory     : TmySQLQuery;

    procedure G1V1FocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  private
    FOnCatRecChange: TOnChangeEvent;
  public
    constructor Create(AOwner:TComponent); override;
    function GetActiveRecordID: Integer;
    procedure RefershCategory;

    procedure TriggerCatRecEvent(const RecordID: integer);
  published
    property OnCatRecChange : TOnChangeEvent read FOnCatRecChange write FOnCatRecChange;
  end;

implementation

{$R *.dfm}
uses
  MainFUnit, FrameMostProductsUnit;

constructor TFrameMostCategory.Create(AOwner: TComponent);
begin
  inherited;
  RefershCategory;
end;

procedure TFrameMostCategory.RefershCategory;
const
  lcSQL = 'SELECT id AS CategoryID, name AS CategoryName FROM Category;';
begin
  if (MainF.dbMostPriceList.Connected) then
  begin
    try
      qryCategory.Active:= False;
      qryCategory.SQL.Text := lcSQL;
      qryCategory.Active:= True;
    finally end;
  end;
end;

function TFrameMostCategory.GetActiveRecordID: Integer;
begin
  Result:=0;
  If(qryCategory.Active)and(G1V1.Controller.FocusedRecord <> nil)and(G1V1.Controller.FocusedRecord is TcxGridDataRow)then
    Result:=(G1V1.Controller.FocusedRecord.Values[G1V1CategoryID.Index]);
end;

procedure TFrameMostCategory.G1V1FocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  TriggerCatRecEvent(GetActiveRecordID);
end;

procedure TFrameMostCategory.TriggerCatRecEvent(const RecordID: integer);
begin
    if Assigned(FOnCatRecChange) then
      FOnCatRecChange(RecordID);
end;

end.
