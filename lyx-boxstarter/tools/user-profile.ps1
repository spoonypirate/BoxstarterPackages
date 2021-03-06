#Set-Variable ProfileDir (Split-Path $MyInvocation.MyCommand.Path -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue
Write-Host "Loading Profile..."

. $profile
# Use this file to run your own startup commands
if((-not (Get-Module oh-my-posh)) -and (Get-Module -ListAvailable oh-my-posh)) {
    Import-Module oh-my-posh
}
if (Get-Module oh-my-posh) { 
    Set-Theme Fish 
} else {
    function global:prompt {
        Set-StrictMode -Off
        $history = Get-History
        $nextHistoryId = $history.Count + 1
        Write-Host "[" -ForegroundColor DarkGray -NoNewline
        Write-Host "$nextHistoryId" -ForegroundColor Red -NoNewline
        Write-Host "|" -ForegroundColor DarkGray -NoNewline
        Write-Host "$((Get-Date).ToShortTimeString())" -ForegroundColor Yellow -NoNewline
        if ($history) {
            $timing = $history[-1].EndExecutionTime - $history[-1].StartExecutionTime
            Write-Host "|" -ForegroundColor DarkGray -NoNewline
            $color = "Green"
            if ($timing.TotalSeconds -gt 1) {
                $color = "Red"
                }
            Write-Host "+" -ForegroundColor $color -NoNewline
            if ($timing.Hours) { Write-Host "$(($timing).Hours)h " -ForegroundColor $color -NoNewline }
            if ($timing.Minutes) { Write-Host "$(($timing).Minutes)m " -ForegroundColor $color -NoNewline }
            if ($timing.Seconds) { Write-Host "$(($timing).Seconds)s " -ForegroundColor $color -NoNewline }
            Write-Host "$(($timing).Milliseconds)ms" -ForegroundColor $color -NoNewline
            }
        Write-Host "] " -ForegroundColor DarkGray -NoNewline
        Write-Host "[" -ForegroundColor DarkGray -NoNewline
        [string]$path = $Pwd.Path
        if ($path -like "c:\users\$env:username*") {
            $path = "~home" + $path.Substring("c:\users\$env:username".Length)
            }
        $chunks = $path -split '\\'
        $short = $false
        if ($Pwd.Path.Length -gt 30 -and $chunks.Length -gt 2) {
            $chunks = $chunks | Select-Object -Last 2
            $short = $true
            }
        if ($short) { Write-Host "...\" -ForegroundColor DarkGray -NoNewline }
        $chunks | ForEach-Object { $i = 0 } {
            $i++
            $color = "Yellow"
            if ($_ -like "~home") { $color = "Green" }
            Write-Host "$_" -ForegroundColor $color -NoNewline
            if ($i -le $chunks.Count-1) {
                Write-Host "\" -ForegroundColor DarkGray -NoNewline
                }
            }
        Write-Host "]" -ForegroundColor DarkGray -NoNewline
        $g = Get-GitStatus
        if ($g) {
            Write-Host " [" -ForegroundColor DarkGray -NoNewline
            $branch = $g.Branch.Split("...") | Select-Object -first 1
            Write-Host $branch -ForegroundColor Red -NoNewline
            $add = $g.Working.Added.Count
            $cha = $g.Working.Modified.Count
            $del = $g.Working.Deleted.Count
            $ahead = $g.AheadBy
            $behind = $g.BehindBy
            if ($add) {
                Write-Host "|" -ForegroundColor DarkGray -NoNewline
                Write-Host "+$add" -ForegroundColor Yellow -NoNewline
                }
            if ($rem) {
                Write-Host "|" -ForegroundColor DarkGray -NoNewline
                Write-Host "-$rem" -ForegroundColor Yellow -NoNewline
                }
            if ($cha) {
                Write-Host "|" -ForegroundColor DarkGray -NoNewline
                Write-Host "~$cha" -ForegroundColor Yellow -NoNewline
                }
            if (!$g.Working) {
                Write-Host "|" -ForegroundColor DarkGray -NoNewline
                Write-Host "clean" -ForegroundColor Green -NoNewline
                }
            if ($ahead) {
                Write-Host "|" -ForegroundColor DarkGray -NoNewline
                Write-Host "▲$ahead" -ForegroundColor Green -NoNewline
                }
            if ($behind) {
                Write-Host "|" -ForegroundColor DarkGray -NoNewline
                Write-Host "▼$behind" -ForegroundColor Red -NoNewline
                }
            Write-Host "]" -ForegroundColor DarkGray -NoNewline
            }
        Write-Host "`nλ" -NoNewline -ForegroundColor "DarkGray"
        return " "
    }
}

if($Host.Name -eq "ConsoleHost") {
    if((-not (Get-Module PSReadLine)) -and (Get-Module -ListAvailable PSReadLine)) {
        Import-Module PSReadLine
    }
    if (Get-Module PSReadLine) {

        Set-PSReadlineKeyHandler -Key "Ctrl+Shift+R" -Function ForwardSearchHistory
        Set-PSReadlineKeyHandler -Key "Ctrl+R" -Function ReverseSearchHistory

        Set-PSReadlineKeyHandler Ctrl+M SetMark
        Set-PSReadlineKeyHandler Ctrl+Shift+M ExchangePointAndMark
        Set-PSReadlineKeyHandler -Function CaptureScreen -Key "Ctrl+["
        Set-PSReadlineKeyHandler Ctrl+K KillLine
        Set-PSReadlineKeyHandler Ctrl+I Yank
                Set-PSReadlineKeyHandler -Key '"',"'" `
                             -BriefDescription SmartInsertQuote `
                             -LongDescription "Insert paired quotes if not already on a quote" `
                             -ScriptBlock {
        param($key, $arg)
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        if ($line[$cursor] -eq $key.KeyChar) {        # Just move the cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            } else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)" * 2)
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
            }
        }
        Set-PSReadlineKeyHandler -Key '(','{','[' `
                                -BriefDescription InsertPairedBraces `
                                -LongDescription "Insert matching braces" `
                                -ScriptBlock {
            param($key, $arg)
            $closeChar = switch ($key.KeyChar) {
                <#case#> '(' { [char]')'; break }
                <#case#> '{' { [char]'}'; break }
                <#case#> '[' { [char]']'; break }
                }
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
            }
        Set-PSReadlineKeyHandler -Key ')',']','}' `
                                -BriefDescription SmartCloseBraces `
                                -LongDescription "Insert closing brace or skip" `
                                -ScriptBlock {
            param($key, $arg)
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            if ($line[$cursor] -eq $key.KeyChar) {
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
                }
            else {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
                }
            }
        Set-PSReadlineKeyHandler -Key Backspace `
                                -BriefDescription SmartBackspace `
                                -LongDescription "Delete previous character or matching quotes/parens/braces" `
                                -ScriptBlock {
            param($key, $arg)
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            if ($cursor -gt 0) {
                $toMatch = $null
                switch ($line[$cursor]) {
                    <#case#> '"' { $toMatch = '"'; break }
                    <#case#> "'" { $toMatch = "'"; break }
                    <#case#> ')' { $toMatch = '('; break }
                    <#case#> ']' { $toMatch = '['; break }
                    <#case#> '}' { $toMatch = '{'; break }
                    }
                if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
                    }
                else {
                    [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
                    }
                }
            }
        # Insert text from the clipboard as a here string
        Set-PSReadlineKeyHandler -Key Ctrl+Shift+v `
                                -BriefDescription PasteAsHereString `
                                -LongDescription "Paste the clipboard text as a here string" `
                                -ScriptBlock {
            param($key, $arg)
            Add-Type -Assembly PresentationCore
            if ([System.Windows.Clipboard]::ContainsText()) {
                # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
                $text = ([System.Windows.Clipboard]::GetText() -replace "\p{Zs}*`r?`n","`n").TrimEnd()
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("@'`n$text`n'@")
                }
            else {
                [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
                }
            }
        Set-PSReadlineKeyHandler -Key 'Alt+(' `
                                -BriefDescription ParenthesizeSelection `
                                -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
                                -ScriptBlock {
            param($key, $arg)
            $selectionStart = $null
            $selectionLength = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            if ($selectionStart -ne -1) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
                }
            else {
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
                [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
                }
            }

        Set-PSReadlineKeyHandler -Key 'Alt+"' `
                                -BriefDescription ParenthesizeSelection `
                                -LongDescription "Put quotes around the selection or entire line and move the cursor to after the closing parenthesis" `
                                -ScriptBlock {
            param($key, $arg)
            $selectionStart = $null
            $selectionLength = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            if ($selectionStart -ne -1) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '"' + $line.SubString($selectionStart, $selectionLength) + '"')
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
                }
            else {
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '"' + $line + '"')
                [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
                }
            }
        Set-PSReadlineKeyHandler -Key "Alt+%" `
                                -BriefDescription ExpandAliases `
                                -LongDescription "Replace all aliases with the full command" `
                                -ScriptBlock {
            param($key, $arg)
            $ast = $null
            $tokens = $null
            $errors = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
            $startAdjustment = 0
            foreach ($token in $tokens) {
                if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::CommandName) {
                    $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
                    if ($alias -ne $null) {
                        $resolvedCommand = $alias.ResolvedCommandName
                        if ($resolvedCommand -ne $null) {
                            $extent = $token.Extent
                            $length = $extent.EndOffset - $extent.StartOffset
                            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                                $extent.StartOffset + $startAdjustment,
                                $length,
                                $resolvedCommand)
                            # Our copy of the tokens won't have been updated, so we need to
                            # adjust by the difference in length
                            $startAdjustment += ($resolvedCommand.Length - $length)
                            }
                        }
                    }
                }
            }
        # F1 for help on the command line - naturally
        Set-PSReadlineKeyHandler -Key F1 `
                                -BriefDescription CommandHelp `
                                -LongDescription "Open the help window for the current command" `
                                -ScriptBlock {
            param($key, $arg)
            $ast = $null
            $tokens = $null
            $errors = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
            $commandAst = $ast.FindAll( {
                $node = $args[0]
                $node -is [System.Management.Automation.Language.CommandAst] -and
                    $node.Extent.StartOffset -le $cursor -and
                    $node.Extent.EndOffset -ge $cursor
                }, $true) | Select-Object -Last 1
            if ($commandAst -ne $null) {
                $commandName = $commandAst.GetCommandName()
                if ($commandName -ne $null) {
                    $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
                    if ($command -is [System.Management.Automation.AliasInfo]) {
                        $commandName = $command.ResolvedCommandName
                        }
                    if ($commandName -ne $null) {
                        Get-Help $commandName -ShowWindow
                        }
                    }
                }
            }
        Trace-Message "PSReadLine fixed"
        }
    
else {
    Remove-Module PSReadLine -ErrorAction SilentlyContinue
    Trace-Message "PSReadLine skipped!"
    }
}

## Fix em-dash screwing up our commands...
$ExecutionContext.SessionState.InvokeCommand.CommandNotFoundAction = {
    param( $CommandName, $CommandLookupEventArgs )
    if($CommandName.Contains([char]8211)) {
        $CommandLookupEventArgs.Command = Get-Command ( $CommandName -replace ([char]8211), ([char]45) ) -ErrorAction Ignore
    }
}

Clear-Host