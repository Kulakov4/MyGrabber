unit NotifyEvents;

interface

uses System.Contnrs, System.Classes;

type
  TNotifyEventRef = reference to procedure(ASender: TObject);

  TCustomNotifyEvent = class(TCollectionItem)
  private
    FOwnerObjectList: TObjectList;
  public
    constructor Create(Collection: TCollection; AOwnerObjectList: TObjectList);
      reintroduce;
    destructor Destroy; override;
  end;

  TNotifyEvents = class(TCollection)
  private
  protected
    FOwner: TObject;
  public
    constructor Create(AOwner: TObject);
    procedure CallEventHandlers; virtual;
    procedure Remove(ANotifyEvent: TNotifyEvent);
  end;

  TNotifyEventWrap = class(TCustomNotifyEvent)
  private
    FNotifyEvent: TNotifyEvent;
  public
    constructor Create(Collection: TCollection; ANotifyEvent: TNotifyEvent;
      AOwnerObjectList: TObjectList = nil); reintroduce; overload;
  end;

  TNotifyEventsEx = class(TNotifyEvents)
  private
  protected
  public
    procedure CallEventHandlers(Sender: TObject); reintroduce; virtual;
  end;

type
  TNotifyEventR = class(TCustomNotifyEvent)
  private
    FNotifyEventRef: TNotifyEventRef;
  public
    constructor Create(Collection: TCollection;
      ANotifyEventRef: TNotifyEventRef; AOwnerObjectList: TObjectList = nil);
      reintroduce; overload;
  end;

implementation

Uses System.Types;

constructor TNotifyEvents.Create(AOwner: TObject);
begin
  Assert(AOwner <> nil);
  FOwner := AOwner;
  inherited Create(TCustomNotifyEvent);
end;

procedure TNotifyEvents.CallEventHandlers;
Var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    (Items[i] as TNotifyEventWrap).FNotifyEvent(FOwner);
  end;
end;

procedure TNotifyEvents.Remove(ANotifyEvent: TNotifyEvent);
var
  i: Integer;
  ne: TNotifyEvent;
begin
  for i := Count - 1 downto 0 do
  begin
    ne := (Items[i] as TNotifyEventWrap).FNotifyEvent;
    if @ne = @ANotifyEvent then
    begin
      Delete(i);
    end;
  end;
end;

constructor TNotifyEventWrap.Create(Collection: TCollection;
  ANotifyEvent: TNotifyEvent; AOwnerObjectList: TObjectList = nil);
begin
  Assert(Assigned(ANotifyEvent));

  FNotifyEvent := ANotifyEvent;
  inherited Create(Collection, AOwnerObjectList);
  // Добавляем элемент коллекции в коллекцию
end;

procedure TNotifyEventsEx.CallEventHandlers(Sender: TObject);
Var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[i] is TNotifyEventWrap then
      (Items[i] as TNotifyEventWrap).FNotifyEvent(Sender);
    if Items[i] is TNotifyEventR then
      (Items[i] as TNotifyEventR).FNotifyEventRef(Sender);
  end;
end;

constructor TNotifyEventR.Create(Collection: TCollection;
  ANotifyEventRef: TNotifyEventRef; AOwnerObjectList: TObjectList = nil);
begin
  Assert(Assigned(ANotifyEventRef));

  FNotifyEventRef := ANotifyEventRef;
  inherited Create(Collection, AOwnerObjectList);
  // Добавляем элемент коллекции в коллекцию
end;

constructor TCustomNotifyEvent.Create(Collection: TCollection;
  AOwnerObjectList: TObjectList);
begin
  Assert(Collection <> nil);
  inherited Create(Collection); // Добавляем элемент коллекции в коллекцию
  FOwnerObjectList := AOwnerObjectList;
  if AOwnerObjectList <> nil then
    AOwnerObjectList.Add(Self);
  // Добавляем элемент коллекции в список-владелец элементов
end;

destructor TCustomNotifyEvent.Destroy;
begin
  if FOwnerObjectList <> nil then
    FOwnerObjectList.Extract(Self); // Удаляем ссылку на себя из списка объектов
  inherited;
end;

end.
