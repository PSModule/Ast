function Read-AstScriptContent {
    param(
        [string]$ScriptContent
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptContent, [ref]$tokens, [ref]$errors)

    [pscustomobject]@{
        Ast    = $ast
        Tokens = $tokens
        Errors = $errors
    }
}
