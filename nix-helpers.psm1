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
    
    $templateSetupSh = Get-Content -Path $templatePath -Raw
    $setupSh = $templateSetupSh -f $majorVersion, $minorVersion, $buildVersion, $ToolCachePath
    
    $setupSh | Out-File -FilePath $shPath -Encoding utf8
}

Function Archive-Zip {
    param(
        [String]$PathToArchive,
        [String]$ToolZipFile
    )

    Push-Location -Path $pathToArchive
    zip -q -r $toolZipFile * | Out-Null
    Pop-Location
}

Function Download-Source {
    param(
        [Uri]$Uri,
        [String]$OutFile
    )

    # Download source
    try {
        Invoke-WebRequest -Uri $uri -OutFile $outFile
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

    # Unpack archive.tgz
    tar -C $expandArchivePath -$TarCommands $outFile | Out-Null
}

Function Append-EnvironmentVariable {
    param(
        [string] $variableName, 
        [string] $value
    )
    Write-Debug "Set ${variableName} to ${value}"
    if (Test-Path env:$variableName) {
        $previousValue = (Get-Item env:$variableName).Value
        Set-Item env:$variableName "${value} ${previousValue}"
    } else {
        Set-Item env:$variableName "${value}"
    }
}

Function Execute-Command {
    param(
        [string] $command
    )

    Write-Debug "Execute $command"

    try {
        Invoke-Expression $command | ForEach-Object { Write-Host $_ }
    }
    catch {
        Write-Host "Error happened during command execution: $command"
        Write-Host "##vso[task.logissue type=error;] $_"
    }
}
