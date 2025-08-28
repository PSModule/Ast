function Read-AstDirectory {
    <#
        .SYNOPSIS
        Reads all PowerShell script files in a directory and processes them with Read-AstScriptFile.

        .DESCRIPTION
        This function retrieves all `.ps1` files in the specified directory and passes each file's path
        to the `Read-AstScriptFile` function. It supports recursion to include subdirectories.

        .EXAMPLE
        Read-AstDirectory -DirPath "C:\Scripts" -RecurseDir $true

        Output:
        ```powershell
        Processing: C:\Scripts\Script1.ps1
        Processing: C:\Scripts\Subfolder\Script2.ps1
        ```

        Reads all `.ps1` files from `C:\Scripts` and its subdirectories and processes them.

        .OUTPUTS
        PSCustomObject

        .NOTES
        An object containing the AST, tokens, and errors from parsing the script.

        .LINK
        https://psmodule.io/Ast/Functions/Read-AstDirectory
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # Specifies the directory path to search for `.ps1` script files.
        [Parameter(Mandatory)]
        [string] $DirPath,

        # Indicates whether to search subdirectories recursively.
        [Parameter()]
        [bool] $RecurseDir
    )

    $files = Get-ChildItem -Path $DirPath -Filter '*.ps1' -File -Recurse:$RecurseDir

    foreach ($file in $files) {
        Read-AstScriptFile -FilePath $file.FullName
    }
}
