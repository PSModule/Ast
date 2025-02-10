filter Get-ASTLineComment {
    <#

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
