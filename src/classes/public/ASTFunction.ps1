class ASTFunction {
    [string]$Name
    [string]$Alias
    [string]$Type
    [object]$Documentation
    [System.Collections.Generic.List[string]]$Attributes
    [System.Collections.Generic.List[object]]$Parameters
    [System.Collections.Generic.List[string]]$Variables
    [string]$ScriptBlock

    Function() {}
}
