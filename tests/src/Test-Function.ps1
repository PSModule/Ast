﻿function Test-Function {
    <#
        .SYNOPSIS
        Performs tests on a module.

        .EXAMPLE
        Test-Function -Name 'World'

        "Hello, World!"
    #>
    [Alias('Test', 'TestFunc')]
    [Alias('Test-Func')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingCmdletAliases',
        Justification = 'Want to see that AstCommand actually can get aliases.'
    )]
    [CmdletBinding()]
    param (
        # Name of the person to greet.
        [Parameter(Mandatory)]
        [Alias('Person')]
        [string] $Name
    )
    Write-Output "Hello, $Name!"

    Get-Process | Select-Object -First 5

    $hash = @{
        'Key1' = 'Value1'
        'Key2' = 'Value2'
    }

    $hash.GetEnumerator() | ForEach-Object {
        Write-Output "Key: $($_.Key), Value: $($_.Value)"
    }

    . Get-Alias | ForEach-Object {
        Write-Output "Alias: $($_.Name), Definition: $($_.Definition)"
    }

    & {
        Write-Output 'Hello, World!'
    }

    ipmo Microsoft.PowerShell.Utility
}

Register-ArgumentCompleter -CommandName Test-Function -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    Get-Process | Where-Object { $_.Name -like "$wordToComplete*" } | Select-Object -ExpandProperty Name
}
