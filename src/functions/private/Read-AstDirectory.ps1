function Read-AstDirectory {
    param(
        [string]$DirPath,
        [bool]$RecurseDir
    )

    $files = Get-ChildItem -Path $DirPath -Filter '*.ps1' -File -Recurse:$RecurseDir

    foreach ($file in $files) {
        Read-AstScriptFile -FilePath $file.FullName
    }
}
