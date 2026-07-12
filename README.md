# Ast

Ast is a PowerShell module for using the PowerShell abstract syntax tree (AST) to analyze PowerShell code. It provides
commands to extract functions, commands, aliases, comments, and script structure from a file, a string of script content,
or an existing AST object.

## Installation

Install the module from the PowerShell Gallery:

```powershell
Install-PSResource -Name Ast
Import-Module -Name Ast
```

## Usage

The commands accept a file path (`-Path`), inline script content (`-Script`), or an existing AST object (`-Ast`), and
default to matching everything so you can narrow the results with `-Name`.

### Example: List the functions defined in a script

```powershell
Get-AstFunction -Path ./MyScript.ps1
Get-AstFunctionName -Path ./MyScript.ps1
```

### Example: Find the commands invoked by a script

```powershell
Get-AstCommand -Path ./MyScript.ps1
Get-AstCommand -Script "Get-Process; Write-Host 'Hello'"
```

### Example: Inspect a single function by name

```powershell
Get-AstFunction -Path ./MyScript.ps1 -Name 'Test-Me'
```

## Documentation

Documentation is published at [psmodule.io/Ast](https://psmodule.io/Ast/).

Use PowerShell help and command discovery for module details:

```powershell
Get-Command -Module Ast
Get-Help -Name Get-AstFunction -Examples
```

## Related tools

- [lzybkr/ShowPSAst](https://github.com/lzybkr/ShowPSAst) — an interactive viewer for exploring the PowerShell AST.
