Function New-SetupFile {
    param(
        [String]$ShPath,
        [String]$TemplatePath,
        [Version]$Version,
        [String]$ToolCachePath
    )

    $majorVersion = $Version.Major
    $minorVersion = $Version.Minor
    $buildVersion = $Version.Build
    
    $templateSetupSh = Get-Content -Path $TemplatePath -Raw
    $setupSh = $TemplateSetupSh -f $majorVersion, $minorVersion, $buildVersion, $ToolCachePath
    
    $setupSh | Out-File -FilePath $ShPath -Encoding utf8
}

Function Archive-Zip {
    param(
        [String]$PathToArchive,
        [String]$ToolZipFile
    )

    Push-Location -Path $PathToArchive
    zip -q -r $ToolZipFile * | Out-Null
    Pop-Location
}

Function Download-Source {
    param(
        [Uri]$Uri,
        [String]$OutFile
    )

    Write-Debug "Download source from $Uri to $OutFile"
    try {
        (New-Object System.Net.WebClient).DownloadFile($Uri, $OutFile)
    } catch {
        "$_"
        break
    }    
}

Function Unpack-TarArchive {
    param(
        [String]$OutFile,
        [String]$ExpandArchivePath = $env:BUILD_STAGINGDIRECTORY,
        [String]$TarCommands = "xvzf"
    )

    Write-Debug "Unpack $ExpandArchivePath to $OutFile"
    tar -C $ExpandArchivePath -$TarCommands $OutFile | Out-Null
}

Function Append-EnvironmentVariable {
    param(
        [string] $VariableName, 
        [string] $Value
    )
    Write-Debug "Set ${VariableName} to ${Value}"
    if (Test-Path env:$VariableName) {
        $PreviousValue = (Get-Item env:$VariableName).Value
        Set-Item env:$VariableName "${Value} ${PreviousValue}"
    } else {
        Set-Item env:$variableName "${Value}"
    }
}

Function Execute-Command {
    [CmdletBinding()]
    param(
        [string] $Command
    )

    Write-Debug "Execute $Command"

    try {
        Invoke-Expression $Command | ForEach-Object { Write-Host $_ }
    }
    catch {
        Write-Host "Error happened during command execution: $Command"
        Write-Host "##vso[task.logissue type=error;] $_"
    }
}
