unit WebLoaderInterface;

interface

type
  IWebLoader = interface(IInterface)
    function Load(const AURL: String): String; stdcall;
  end;

implementation

end.
