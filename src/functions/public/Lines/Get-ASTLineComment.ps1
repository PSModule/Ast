filter Get-ASTLineComment {
    <#
        .SYNOPSIS
        Extracts comment tokens from a given line of PowerShell code.

        .DESCRIPTION
        This function parses a given line of PowerShell code and extracts comment tokens.
        It utilizes the PowerShell parser to analyze the input and return tokens that match
        the specified kind, defaulting to 'Comment'.

        .EXAMPLE
        "# This is a comment" | Get-ASTLineComment

        Output:
        ```powershell
        Kind    : Comment
        Text    : # This is a comment
        ```

        Extracts the comment token from the input PowerShell line.

        .OUTPUTS
        System.Management.Automation.Language.Token[]

        .NOTES
        An array of tokens representing comments extracted from the input line.

        .LINK
        https://psmodule.io/AST/Functions/Lines/Get-ASTLineComment/
    #>
    [OutputType([System.Management.Automation.Language.Token[]])]
    [CmdletBinding()]
    param (
        # Input line of PowerShell code from which to extract the comment.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $Line ,

        # The type of comment to extract.
        [Parameter()]
        [string] $Kind = 'Comment'
    )

    # Parse the line using the PowerShell parser to obtain its tokens.
    $tokens = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($Line, [ref]$tokens, [ref]$null)

    # Find comment token(s) in the line.
    ($tokens | Where-Object { $_.Kind -eq $Kind })
}
