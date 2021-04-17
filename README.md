# A sample project to create and manage ssl certs with openssl

## Create root cert

powershell

```powershell
.\scripts\powershell\gen-root.ps1
```

## Create intermediate cert

powershell
```powershell
.\scripts\powershell\gen-intermidiate.ps1 test
```

## Create server cert based on intermediate cert

powershell
```powershell
.\scripts\powershell\gen-server.ps1 intermediate/test wangqiao.me
```


## Create client cert based on intermediate cert

powershell
```powershell
.\scripts\powershell\gen-client.ps1 intermediate/test admin wangqiao.me
```