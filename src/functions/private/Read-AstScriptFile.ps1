function Read-AstScriptFile {
    param(
        [string]$FilePath
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$tokens, [ref]$errors)

    [pscustomobject]@{
        Path   = $FilePath
        Ast    = $ast
        Tokens = $tokens
        Errors = $errors
    }
}
