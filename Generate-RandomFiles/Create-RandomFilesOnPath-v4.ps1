[cmdletbinding()]

param(
    [Parameter(Mandatory=$True)]
    #[Alias('MinimumFileSize"(KB)"')]
    [int]$MinSizeinKB,

    [Parameter(Mandatory=$True)]
    #[Alias('MaximumFileSize"(KB)"')]
    [int]$MaxSizeinKB,

    [Parameter(Mandatory=$True)]
    #[Alias('Pause"(Sec)"')]
    [int]$Pause
    )

$MinSize = $MinSizeinKB * 1KB
$MaxSize = $MaxSizeinKB * 1KB

$paths = @()

while (1)
{
    $newpath = Read-Host "Enter Path"
    if ([string]::IsNullOrEmpty($newpath))
    {
        break
    }

    if (-not (Test-Path $newpath))
    {
        Write-host -ForegroundColor Red "$newpath does not exists, try again"
    }
    else
    {
        $paths += $newpath
        $paths
        $newpath = $null
    }
}

function childdirname
{
    -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
}

$dirlist = @()
foreach ($path in $paths)
{
    $childdir = Get-ChildItem -Path $path -Directory -Recurse | Select-Object Fullname
    $subdircount = (Get-ChildItem -Path $path -Directory | Measure-Object).count
    if($childdir -eq $null -or $subdircount -lt 10){
        while(((Get-ChildItem -Path $path -Directory | Measure-Object).count) -lt 10){
        $folder = childdirname
            New-Item -Path $path -Name $folder -ItemType Directory | Out-Null
        }
    $childdir = Get-ChildItem -Path $path -Directory -Recurse | Select-Object Fullname
    }

    $dirlist += $childdir
}

while (1)
{
    $dt = $null
    $dt = get-date -UFormat "%Y-%m-%d_%H%M%S"
    $size = get-random -Minimum $MinSize -Maximum $MaxSize #(1MB min, 10MB max)
    $rdir = Get-random($dirlist)
    $ext = Get-random(".txt", ".rar", ".zip", ".docx", ".pptx", ".xlsx", ".pdf", ".7z", ".tgz", ".tar", ".exe", ".iso", ".img")
    $createfile = $rdir.fullname + "\" + $(childdirname).substring(4) + "_" + $dt + $ext

    $out = new-object byte[] $size; (new-object Random).NextBytes($out); [IO.File]::WriteAllBytes($createfile, $out)
    $spacer = $Host.UI.RawUI.BufferSize.Width - ($createfile.Length)
    $createfile +" "+$('-'* ($spacer-20))+"> "+ [math]::round((Get-ChildItem $createfile | Select-Object length).length / 1KB, 2)+" KB"
    Start-Sleep $Pause
}
