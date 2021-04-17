param (
    [Parameter(Mandatory=$true)]
    [string]
    $target,

    [Parameter(Mandatory=$true,ValueFromRemainingArguments=$true)]
    [string[]]
    $domains
)

$name = $domains[0]
$targetPath = $target.Split("/");
$caName = $targetPath[$targetPath.Count - 1]
$project_root_dir = "$PSScriptRoot/../.."

$baseDir = "$project_root_dir/output/$target"
$server = "$baseDir/server/$name"
$config = "$baseDir/openssl.cnf"

$ca_keyfile = "$baseDir/private/$caName.key"
$ca_certfile = "$baseDir/certs/$caName.crt"

$keyfile = "$server/$name.key"
$csrfile = "$server/$name.csr"
$certfile = "$server/$name.crt"
$configWithSAN = "$server/openssl.san.conf"

if ((Test-Path $baseDir) -ne $true) {
    Write-Output "Target $target is invalid"
    return;
}

if (Test-Path $server) {
    $answer = Read-Host "The domain $name already exists, continue to override it? (Yes/No)"
    if ($answer -contains "y") {
        Remove-Item $server -Recurse -Force
    }
    else
    {
        Write-Output "Exit"
        return
    }
}

$ignore = New-Item -Path $server -ItemType Directory -Force

$SAN=""

foreach($domain in $domains) {
    $SAN+="DNS:*.$domain,DNS:$domain,"
}

$SAN = $SAN.Remove($SAN.Length - 1)

$subject = "/CN=$name/C=CN/ST=Shanghai/L=Shanghai/O=Nodew/OU=Nodew/emailAddress=wangqiao11@hotmail.com"

openssl genrsa -out "$keyfile" 2048

$configContent = Get-Content $config
$configContent + @"

[SAN]
subjectAltName=$SAN
"@ | Out-File -Encoding "UTF8" $configWithSAN


openssl req -new -config $configWithSAN `
        -reqexts SAN `
        -key "$keyfile" `
        -out "$csrfile" `
        -subj "$subject"

openssl ca -config "$config" -batch -notext `
    -extensions server_cert `
    -cert "$ca_certfile" `
    -keyfile "$ca_keyfile" `
    -in "$csrfile" `
    -out "$certfile"

Remove-Item $configWithSAN