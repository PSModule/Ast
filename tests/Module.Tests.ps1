Describe 'Core' {
    Context "Function: 'Get-ScriptAST'" {
        It 'Get-ScriptAST gets the script AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $ast = Get-ScriptAST -Path $path
            $ast | Should -Not -BeNullOrEmpty
            $ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }
    }
    Context "Function: 'Get-FunctionAST'" {
        It 'Get-FunctionAST gets the function AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $ast = Get-FunctionAST -Path $path
            $ast | Should -Not -BeNullOrEmpty
            $ast | Should -BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
        }
    }
}

Describe 'Functions' {
    Context "Function: 'Get-FunctionType'" {
        It 'Get-FunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionType = Get-FunctionType -Path $path
            $functionType.Type | Should -Be 'Function'
        }
    }
    Context "Function: 'Get-FunctionName'" {
        It 'Get-FunctionName gets the function name' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionName = Get-FunctionName -Path $path
            $functionName | Should -Be 'Test-Function'
        }
    }
    Context "Function: 'Get-FunctionAlias'" {
        It 'Get-FunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionAlias = Get-FunctionAlias -Path $path
            $functionAlias.Alias | Should -Contain 'Test'
            $functionAlias.Alias | Should -Contain 'TestFunc'
            $functionAlias.Alias | Should -Contain 'Test-Func'
        }
    }
}

Describe 'Line' {
    Context 'Function: Get-LineComment' {
        It 'Get-LineComment gets the line comment' {
            $line = '# This is a comment'
            $line = Get-LineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-LineComment gets the line comment without leading whitespace' {
            $line = '    # This is a comment'
            $line = Get-LineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-LineComment gets the line comment but not the command' {
            $line = '    Get-Command # This is a comment    '
            $line = Get-LineComment -Line $line
            $line | Should -Be '# This is a comment    '
        }
        It 'Get-LineComment returns nothing when no comment is present' {
            $line = 'Get-Command'
            $line | Get-LineComment | Should -BeNullOrEmpty
        }
    }
}

Describe 'Scripts' {
    Context "Function: 'Get-ScriptCommands'" {
        It 'Get-ScriptCommands gets the script commands' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ScriptCommand -Path $path
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Contain 'ForEach-Object'
            $commands.Name | Should -Contain 'Get-Process'
            $commands.Name | Should -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-ScriptCommands gets the script commands with call operators' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ScriptCommand -Path $path -IncludeCallOperators
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
