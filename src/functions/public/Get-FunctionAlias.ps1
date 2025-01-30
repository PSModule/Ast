function Get-FunctionAlias {
    param (
        # The name of the function to retrieve aliases for
        [string] $Name = '*',

        # The path to the script file to parse
        [string] $Path
    )

    # Parse the script file into an AST
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$null)

    # Extract function definitions
    $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

    # Process each function and extract aliases
    $functions | ForEach-Object {
        $funcName = $_.Name
        $attributes = $_.FindAll({ $args[0] -is [System.Management.Automation.Language.AttributeAst] }, $true)
        $aliasAttr = $attributes | Where-Object { $_ -is [System.Management.Automation.Language.AttributeAst] -and $_.TypeName.Name -eq 'Alias' }

        if ($aliasAttr) {
            $aliases = $aliasAttr.PositionalArguments | ForEach-Object { $_.ToString().Trim('"', "'") }
            [PSCustomObject]@{
                Name  = $funcName
                Alias = $aliases
            }
        }
    } | Where-Object { $_.Name -like $Name }
}
