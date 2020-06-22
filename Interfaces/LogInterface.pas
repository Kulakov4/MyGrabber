unit LogInterface;

interface

type
  ILog = interface(IInterface)
    procedure Add(const S: string);
    procedure Clear;
  end;

implementation

end.
