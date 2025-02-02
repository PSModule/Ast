filter Get-ASTLineComment {
    <#
        .SYNOPSIS
        Extracts the inline comment from a single line of PowerShell code.

        .DESCRIPTION
        Parses a given line of PowerShell code and extracts any inline comment.
        If an inline comment exists, the function returns the comment text; otherwise, it returns nothing.

        .EXAMPLE
        'Get-Process # This retrieves all processes' | Get-ASTLineComment

        Returns: '# This retrieves all processes'

        .EXAMPLE
        'Write-Host "Hello World"' | Get-ASTLineComment

        Returns: $null (no comment found)

        .LINK
        https://psmodule.io/AST/Functions/Lines/Get-ASTLineComment/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Does not change state'
    )]
    [OutputType([System.Management.Automation.Language.Token[]])]
    [CmdletBinding()]
    param (
        # Input line of PowerShell code from which to extract the comment.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $Line
    )

    # Parse the line using the PowerShell parser to obtain its tokens.
    $tokens = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($Line, [ref]$tokens, [ref]$null)

    # Find comment token(s) in the line.
    ($tokens | Where-Object { $_.Kind -eq 'Comment' })
}
