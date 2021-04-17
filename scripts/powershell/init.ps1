param(
    # Folder name
    [Parameter()]
    [string]
    $certFolder = "ca"
)

$project_root_dir = "$PSScriptRoot/../.."
$outdir = "$project_root_dir/output/$certFolder"
$db_folder = "$outdir/db"
$certs_folder = "$outdir/certs"
$csr_folder = "$outdir/csr"
$private_folder = "$outdir/private"
$newcerts_folder = "$outdir/newcerts"
$crl_folder = "$outdir/crl"
$server_folder = "$outdir/server"
$client_folder = "$outdir/client"

$serialFile = "$db_folder/serial"
$indexFile = "$db_folder/index.txt"
$crlNumberFile = "$db_folder/crlnumber"
$randFile = "$private_folder/.rand"

if (Test-Path $outdir) {
    $answer = Read-Host "The output folder already exists, continue to override it? (Yes/No)"
    if ($answer -contains "y") {
        Remove-Item $outdir -Recurse -Force
    }
    else
    {
        Write-Output "Exit"
        return 1
    }
}

$ignore = New-Item -Path $outdir -ItemType Directory -Force
$ignore = New-Item -Path $private_folder -ItemType Directory
$ignore = New-Item -Path $certs_folder -ItemType Directory
$ignore = New-Item -Path $csr_folder -ItemType Directory
$ignore = New-Item -Path $newcerts_folder -ItemType Directory
$ignore = New-Item -Path $crl_folder -ItemType Directory
$ignore = New-Item -Path $db_folder -ItemType Directory
$ignore = New-Item -Path $server_folder -ItemType Directory
$ignore = New-Item -Path $client_folder -ItemType Directory

$ignore = New-Item -Path $serialFile -ItemType File -Value "1000"
$ignore = New-Item -Path $crlNumberFile -ItemType File -Value "1000"
$ignore = New-Item -Path $indexFile -ItemType File
$ignore = New-Item -Path $randFile -ItemType File

Write-Output "Inited certificate folder!"
return 0