#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

Describe 'Core' {
    Context "Function: 'Get-ASTScript'" {
        It 'Get-ASTScript gets the script AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $ast = Get-ASTScript -Path $path
            $ast | Should -Not -BeNullOrEmpty
            $ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }
    }
    Context "Function: 'Get-ASTFunction'" {
        It 'Get-ASTFunction gets the function AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $ast = Get-ASTFunction -Path $path
            $ast | Should -Not -BeNullOrEmpty
            $ast | Should -BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
        }
    }
    Context "Function: 'Get-ASTCommand'" {
        It 'Get-ASTCommand gets the command AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $ast = Get-ASTCommand -Path $path
            $ast | Should -Not -BeNullOrEmpty
            $ast | Should -BeOfType [System.Management.Automation.Language.CommandAst]
        }
    }
}

Describe 'Functions' {
    Context "Function: 'Get-ASTFunctionType'" {
        It 'Get-ASTFunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionType = Get-ASTFunctionType -Path $path
            $functionType.Type | Should -Be 'Function'
        }
    }
    Context "Function: 'Get-ASTFunctionName'" {
        It 'Get-ASTFunctionName gets the function name' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionName = Get-ASTFunctionName -Path $path
            $functionName | Should -Be 'Test-Function'
        }
    }
    Context "Function: 'Get-ASTFunctionAlias'" {
        It 'Get-ASTFunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionAlias = Get-ASTFunctionAlias -Path $path
            $functionAlias.Alias | Should -Contain 'Test'
            $functionAlias.Alias | Should -Contain 'TestFunc'
            $functionAlias.Alias | Should -Contain 'Test-Func'
        }
    }
}

Describe 'Line' {
    Context 'Function: Get-ASTLineComment' {
        It 'Get-ASTLineComment gets the line comment' {
            $line = '# This is a comment'
            $line = Get-ASTLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-ASTLineComment gets the line comment without leading whitespace' {
            $line = '    # This is a comment'
            $line = Get-ASTLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-ASTLineComment gets the line comment but not the command' {
            $line = '    Get-Command # This is a comment    '
            $line = Get-ASTLineComment -Line $line
            $line | Should -Be '# This is a comment    '
        }
        It 'Get-ASTLineComment returns nothing when no comment is present' {
            $line = 'Get-Command'
            $line | Get-ASTLineComment | Should -BeNullOrEmpty
        }
    }
}

Describe 'Scripts' {
    Context "Function: 'Get-ASTScriptCommands'" {
        It 'Get-ASTScriptCommands gets the script commands' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ASTScriptCommand -Path $path
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Contain 'ForEach-Object'
            $commands.Name | Should -Contain 'Get-Process'
            $commands.Name | Should -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-ASTScriptCommands gets the script commands with call operators' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ASTScriptCommand -Path $path -IncludeCallOperators
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
