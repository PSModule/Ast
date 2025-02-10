$Path = 'C:\Repos\GitHub\PSModule\Module\AST\tests\src\Test-Function.ps1'

# Gets the AST of a script. Can be any type of PowerShell script file.
$scriptAst = Get-AstScript -Path $path

# Gets the AST of a function(s) in a script. Can be any type of PowerShell script file.
Get-AstFunction -Path $path -Recurse

# Gets the AST of a command(s) in a script. Can be any type of PowerShell script file.
$functionAst = $scriptAst | Get-AstFunction -Recurse
$functionAst.Ast.Extent

$functionAst.Ast | gm
$functionAst.Ast.GetType()

$functionAst.Ast


Get-AstCommand -Path $path -Recurse

# Gets the AST of a command(s) in a script. Can be any type of PowerShell script file.
$commandAst = $functionAst | Get-AstCommand -Recurse

# Gets the type of all functions in a script file. Function or filter.
Get-ASTFunctionType -Path $path

# Gets the name of all functions in a script file.
Get-ASTFunctionName -Path $path

# Gets the alias of a function in a script, that uses Alias attribute.
Get-ASTFunctionAlias -Path $path

'Get-ChildItem -Path . # This is a comment' | Get-ASTLineComment
