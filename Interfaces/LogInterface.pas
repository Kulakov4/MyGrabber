unit LogInterface;

interface

type
  ILog = interface(IInterface)
    procedure Add(const S: string);
  end;

implementation

end.
