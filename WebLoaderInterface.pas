unit WebLoaderInterface;

interface

type
  IWebLoader = interface(IInterface)
    function Load(const AURL: WideString): WideString; stdcall;
  end;

implementation

end.
