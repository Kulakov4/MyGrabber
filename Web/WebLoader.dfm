object WebDM: TWebDM
  OldCreateOrder = False
  Height = 150
  Width = 255
  object IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 135
    Top = 16
  end
  object IdHTTP: TIdHTTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.CacheControl = 'max-age=0'
    Request.Connection = 'keep-alive'
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp' +
      ',*/*;q=0.8'
    Request.AcceptEncoding = 'gzip, deflate, br'
    Request.AcceptLanguage = 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3'
    Request.BasicAuthentication = False
    Request.UserAgent = 
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/2010010' +
      '1 Firefox/78.0'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    CookieManager = IdCookieManager1
    Left = 23
    Top = 16
  end
  object IdCookieManager1: TIdCookieManager
    OnNewCookie = IdCookieManager1NewCookie
    Left = 152
    Top = 80
  end
end
