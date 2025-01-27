# Function to search for cl.exe
function Find-CLCompiler {
    # Start searching from the root of the drive
    $rootDrive = "C:\"
    $compilerName = "cl.exe"

    # Use Get-ChildItem to search for the file
    $result = Get-ChildItem -Path $rootDrive -Recurse -ErrorAction SilentlyContinue -Filter $compilerName

    # Return the path if found
    if ($result) {
        return $result.DirectoryName
    } else {
        Write-Host "Visual Studio Compiler (cl.exe) not found!" -ForegroundColor Red
        return $null
    }
}

# Function to add a directory to the PATH
function Add-ToPath {
    param (
        [string]$PathToAdd
    )

    if (-not $PathToAdd) {
        Write-Host "No path to add to the PATH variable." -ForegroundColor Red
        return
    }

    # Get the current PATH environment variable
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    if ($currentPath -notlike "*$PathToAdd*") {
        # Add the new path to the PATH variable
        $newPath = "$currentPath;$PathToAdd"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Successfully added $PathToAdd to the PATH." -ForegroundColor Green
    } else {
        Write-Host "$PathToAdd is already in the PATH." -ForegroundColor Yellow
    }
}

# Main script execution
$compilerPath = Find-CLCompiler

if ($compilerPath) {
    Add-ToPath -PathToAdd $compilerPath
}