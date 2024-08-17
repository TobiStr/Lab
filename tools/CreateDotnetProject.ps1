function Show-Menu {
    param (
        [string[]]$Options
    )

    $selectedIndex = 0

    while ($true) {
        Clear-Host

        for ($i = 0; $i -lt $Options.Length; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host ">> $($Options[$i])"
            } else {
                Write-Host "   $($Options[$i])"
            }
        }

        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { # Up arrow
                if ($selectedIndex -gt 0) { $selectedIndex-- }
            }
            40 { # Down arrow
                if ($selectedIndex -lt $Options.Length - 1) { $selectedIndex++ }
            }
            13 { # Enter
                return $Options[$selectedIndex]
            }
        }
    }
}

# Ask for user input
$inputName = Read-Host "Please enter the project name"

# Show the menu
$appType = Show-Menu -Options "Console", "WPF", "Worker", "Web", "BlazorWASM", "BlazorServer", "AzureFunction"

$testType = Show-Menu -Options "nunit", "xunit", "mstest"

# Define the base directories
$srcDir = "src"
$testDir = "test"
$docsDir = "docs"
$rootDir = Get-Location

# Create the folder structure
New-Item -ItemType Directory -Path $docsDir
New-Item -ItemType Directory -Path "$srcDir/$inputName.App"
New-Item -ItemType Directory -Path "$srcDir/$inputName.Logic"
New-Item -ItemType Directory -Path "$srcDir/$inputName.Core"
New-Item -ItemType Directory -Path "$srcDir/$inputName.Infrastructure"
New-Item -ItemType Directory -Path "$testDir/$inputName.Tests"

# Initialize the projects based on the user's choice
switch ($appType) {
    "AzureFunction" {
         # Ensure you're in the right directory to initialize the function app
        Set-Location -Path "$srcDir/$inputName.App"
        func init --worker-runtime dotnet-isolated --target-framework net8.0
	
	    # Rename the csproj file
 	    $csprojFile = Get-ChildItem -Path . -Filter "*.csproj"
        if ($csprojFile -ne $null) {
            $oldCsprojName = $csprojFile.Name
            $newCsprojName = "$inputName.App.csproj"
            Rename-Item -Path $oldCsprojName -NewName $newCsprojName
        } else {
            Write-Host "No .csproj file found in the directory."
        }

	    # Return to the script's original directory
        Set-Location -Path $rootDir
    }
    "Console" {
        dotnet new console -o "$srcDir/$inputName.App"
    }
    "WPF" {
        dotnet new wpf -o "$srcDir/$inputName.App"
    }
    "Web" {
        dotnet new web -o "$srcDir/$inputName.App"
    }
    "BlazorWASM" {
        dotnet new blazorwasm -o "$srcDir/$inputName.App"
    }
    "BlazorServer" {
        dotnet new blazorserver -o "$srcDir/$inputName.App"
    }
    "Worker" {
        dotnet new worker -o "$srcDir/$inputName.App"
    }
    default {
        Write-Host "Invalid app type selected. Please choose between AzureFunction, Console, or WPF."
        exit
    }
}

# Initialize the other projects
dotnet new classlib -o "$srcDir/$inputName.Logic"
dotnet new classlib -o "$srcDir/$inputName.Core"
dotnet new classlib -o "$srcDir/$inputName.Infrastructure"

switch ($appType) {
     "nunit" {
        dotnet new nunit -o "$testDir/$inputName.Tests"
    }
     "xunit" {
        dotnet new xunit -o "$testDir/$inputName.Tests"
    }
     "mstest" {
        dotnet new mstest -o "$testDir/$inputName.Tests"
    }
}

# Navigate to the root directory
Set-Location -Path $rootDir

# Create a new solution
dotnet new sln -n $inputName

# Add projects to the solution
dotnet sln add "$srcDir/$inputName.App/$inputName.App.csproj"
dotnet sln add "$srcDir/$inputName.Logic/$inputName.Logic.csproj"
dotnet sln add "$srcDir/$inputName.Core/$inputName.Core.csproj"
dotnet sln add "$srcDir/$inputName.Infrastructure/$inputName.Infrastructure.csproj"
dotnet sln add "$testDir/$inputName.Tests/$inputName.Tests.csproj"

Write-Host "Project structure and solution have been created successfully."
