filter Remove-LineComment {
    <#
        .SYNOPSIS
        Removes inline comments from a single line of PowerShell code.

        .DESCRIPTION
        Parses a given line of PowerShell code and removes any inline comments.
        Returns the modified line without the comment while preserving the rest of the code.

        .EXAMPLE
        'Get-Process # This retrieves all processes' | Remove-LineComment

        Returns: 'Get-Process'

        This removes the comment from the input line and outputs only the valid PowerShell command.

        .EXAMPLE
        'Write-Host "Hello World"' | Remove-LineComment

        Returns: 'Write-Host "Hello World"'

        If no comment is present, the original line is returned unchanged.

        .LINK
        https://psmodule.io/AST/Functions/Lines/Remove-LineComment/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Does not change state'
    )]
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # Input line of PowerShell code to remove the comment from.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $Test
    )

    # Parse the single line using AST
    $tokens = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($Test, [ref]$tokens, [ref]$null)

    # Find comment tokens in the line
    $commentToken = $tokens | Where-Object { $_.Kind -eq 'Comment' }

    if ($commentToken) {
        $commentStart = $commentToken.Extent.StartColumnNumber - 1  # Convert to zero-based index

        # Remove the comment by trimming the line up to the comment start position
        return $Test.Substring(0, $commentStart)
    }

    # Return original line if no comment was found
    return $Test
}
