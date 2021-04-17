$project_root_dir = "$PSScriptRoot/../.."
$name = "root"
$output_folder_name = "root"
$root_config_tpl = "$project_root_dir/conf/openssl.root.cnf"
$outdir = "$project_root_dir/output/${output_folder_name}"
$private_folder = "$outdir/private"
$certs_folder = "$outdir/certs"
$csr_folder = "$outdir/csr"
$root_config = "$outdir/openssl.cnf"

$keyfile = "$private_folder/$name.key"
$csrfile = "$csr_folder/$name.csr"
$certfile = "$certs_folder/$name.crt"

if (Test-Path $outdir) {
    Write-Output "Root certificate exists"
    return;
}
else
{
    $exn = powershell -Command "$PSScriptRoot\init.ps1 $output_folder_name"
}

Copy-Item -Path $root_config_tpl -Destination $root_config

$commonName = "ROOT"
$subject = "/CN=$commonName/C=CN/ST=Shanghai/L=Shanghai/O=Nodew/OU=Nodew"

openssl genrsa -out "$keyfile" 2048

openssl req -config "$root_config" -nodes -new -key "$keyfile" -out "$csrfile" -subj "$subject"

openssl x509 -req -in "$csrfile" -signkey "$keyfile" -out "$certfile"