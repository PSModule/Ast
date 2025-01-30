function Test-Function {
    <#
        .SYNOPSIS
        Performs tests on a module.

        .EXAMPLE
        Test-Function -Name 'World'

        "Hello, World!"
    #>
    [Alias('Test')]
    [CmdletBinding()]
    param (
        # Name of the person to greet.
        [Parameter(Mandatory)]
        [string] $Name
    )
    Write-Output "Hello, $Name!"
}
