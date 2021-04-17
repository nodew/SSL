param (
    [Parameter(Mandatory=$true)]
    [string]
    $target,

    [Parameter(Mandatory=$true)]
    [string]
    $client,

    [Parameter(Mandatory=$true,ValueFromRemainingArguments=$true)]
    [string[]]
    $domains
)

$targetPath = $target.Split("/");
$caName = $targetPath[$targetPath.Count - 1]
$project_root_dir = "$PSScriptRoot/../.."

$baseDir = "$project_root_dir/output/$target"
$clientDir = "$baseDir/client/$client"
$config = "$baseDir/openssl.cnf"

$ca_keyfile = "$baseDir/private/$caName.key"
$ca_certfile = "$baseDir/certs/$caName.crt"

$keyfile = "$clientDir/$client.key"
$csrfile = "$clientDir/$client.csr"
$certfile = "$clientDir/$client.crt"
$configWithSAN = "$clientDir/openssl.san.conf"

if ((Test-Path $baseDir) -ne $true) {
    Write-Output "Target $target is invalid"
    return;
}

if (Test-Path $clientDir) {
    $answer = Read-Host "The client $client already exists, continue to override it? (Yes/No)"
    if ($answer -contains "y") {
        Remove-Item $clientDir -Recurse -Force
    }
    else
    {
        Write-Output "Exit"
        return
    }
}

$ignore = New-Item -Path $clientDir -ItemType Directory -Force

$SAN=""

foreach($domain in $domains) {
    $SAN+="DNS:*.$domain,DNS:$domain,"
}

$SAN = $SAN.Remove($SAN.Length - 1)

$subject = "/CN=$client/C=CN/ST=Shanghai/L=Shanghai/O=Nodew/OU=Nodew/emailAddress=wangqiao11@hotmail.com"

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
    -extensions user_cert `
    -cert "$ca_certfile" `
    -keyfile "$ca_keyfile" `
    -in "$csrfile" `
    -out "$certfile"

Remove-Item $configWithSAN