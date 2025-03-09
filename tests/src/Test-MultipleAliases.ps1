<#
.SYNOPSIS
    A test function with multiple aliases.
.DESCRIPTION
    This function demonstrates how multiple aliases can be defined and extracted.
#>
function Test-MultipleAliases {
    [CmdletBinding()]
    [Alias('tma', 'testalias', 'malias', 'Test-MA')]
    param (
        [Parameter(ValueFromPipeline)]
        [string]$Name = 'Default'
    )

    process {
        Write-Output "Processing: $Name"
    }
}

# Register custom completer
Register-ArgumentCompleter -CommandName Test-MultipleAliases -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    @('Option1', 'Option2', 'Option3') | Where-Object { $_ -like "$wordToComplete*" }
}
