param(
    # intermidate cert name
    [Parameter(Mandatory = $true)]
    [string]
    $name
)

if ($name.Trim().Length -eq 0) {
    Write-Output "Please input the name for intermidate certificate"
    return
}

$project_root_dir = "$PSScriptRoot/../.."

$root_config = "$project_root_dir/conf/openssl.root.cnf"
$intermediate_config_tpl = "$project_root_dir/conf/openssl.intermediate.cnf"

$root_cert = "root"
$root_cert_dir = "$project_root_dir/output/$root_cert"
$root_keyfile = "$root_cert_dir/private/root.key"
$root_certfile = "$root_cert_dir/certs/root.crt"

$outdir = "$project_root_dir/output/intermediate/$name"
$private_folder = "$outdir/private"
$certs_folder = "$outdir/certs"
$intermediate_config = "$outdir/openssl.cnf"

$csrfile = "$certs_folder/$name.csr"
$keyfile = "$private_folder/$name.key"
$certfile = "$certs_folder/$name.crt"

if (Test-Path $outdir) {
    Write-Output "intermediate certificate exists"
    return;
}
else
{
    powershell -Command "$PSScriptRoot\init.ps1 intermediate/$name"
}

$tpl = Get-Content $intermediate_config_tpl
$tpl -replace "__NAME__","$name" | Out-File -Encoding "UTF8" "$intermediate_config"

$subject = "/CN=$name/C=CN/ST=Shanghai/L=Shanghai/O=Nodew/OU=Nodew/emailAddress=wangqiao11@hotmail.com"

openssl genrsa -out "$keyfile" 2048

openssl req -config "$intermediate_config" -new -key "$keyfile" -out "$csrfile" -subj "$subject"

openssl ca -config "$root_config" -batch -notext `
    -extensions v3_intermediate_ca `
    -cert "$root_certfile" `
    -keyfile "$root_keyfile" `
    -in "$csrfile" `
    -out "$certfile"