#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

Describe 'Core' {
    Context "Function: 'Get-AstScript'" {
        It 'Get-AstScript gets the script Ast' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $script = Get-AstScript -Path $path
            $script | Should -Not -BeNullOrEmpty
            $script.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }
    }
    Context "Function: 'Get-AstFunction'" {
        It 'Get-AstFunction gets the function Ast' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $function = Get-AstFunction -Path $path
            $function | Should -Not -BeNullOrEmpty
            $function.Ast | Should -BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
        }
    }
    Context "Function: 'Get-AstCommand'" {
        It 'Get-AstCommand gets the command Ast' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $command = Get-AstCommand -Path $path
            $command | Should -Not -BeNullOrEmpty
            $command.Ast | Should -BeOfType [System.Management.Automation.Language.CommandAst]
        }
    }
}

Describe 'Functions' {
    Context "Function: 'Get-AstFunctionType'" {
        It 'Get-AstFunctionType gets the function type' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionType = Get-AstFunctionType -Path $path
            $functionType.Type | Should -Be 'Function'
        }
    }
    Context "Function: 'Get-AstFunctionName'" {
        It 'Get-AstFunctionName gets the function name' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionName = Get-AstFunctionName -Path $path
            $functionName | Should -Be 'Test-Function'
        }
    }
    Context "Function: 'Get-AstFunctionAlias'" {
        It 'Get-AstFunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionAlias = Get-AstFunctionAlias -Path $path
            $functionAlias.Alias | Should -Contain 'Test'
            $functionAlias.Alias | Should -Contain 'TestFunc'
            $functionAlias.Alias | Should -Contain 'Test-Func'
        }
    }
}

Describe 'Lines' {
    Context 'Function: Get-AstLineComment' {
        It 'Get-AstLineComment gets the line comment' {
            $line = '# This is a comment'
            $line = Get-AstLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-AstLineComment gets the line comment without leading whitespace' {
            $line = '    # This is a comment'
            $line = Get-AstLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-AstLineComment gets the line comment but not the command' {
            $line = '    Get-Command # This is a comment    '
            $line = Get-AstLineComment -Line $line
            $line | Should -Be '# This is a comment    '
        }
        It 'Get-AstLineComment returns nothing when no comment is present' {
            $line = 'Get-Command'
            $line | Get-AstLineComment | Should -BeNullOrEmpty
        }
    }
}

Describe 'Scripts' {
    Context "Function: 'Get-AstScriptCommands'" {
        It 'Get-AstScriptCommands gets the script commands' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Not -Contain 'ForEach-Object'
            $commands.Name | Should -Not -Contain 'Get-Process'
            $commands.Name | Should -Not -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-AstScriptCommands gets the script commands (recursive)' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path -Recurse
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Contain 'ForEach-Object'
            $commands.Name | Should -Contain 'Get-Process'
            $commands.Name | Should -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-AstScriptCommands gets the script commands with call operators' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path -IncludeCallOperators
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Not -Contain 'ForEach-Object'
            $commands.Name | Should -Not -Contain 'Get-Process'
            $commands.Name | Should -Not -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-AstScriptCommands gets the script commands with call operators (recursive)' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path -Recurse -IncludeCallOperators
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Contain 'ForEach-Object'
            $commands.Name | Should -Contain 'Get-Process'
            $commands.Name | Should -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Contain '.'
            $commands.Name | Should -Contain '&'
        }
    }
}
