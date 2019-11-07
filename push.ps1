param(
    [ValidateSet('rust', 'rust-ms', 'chars')]
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Package,
    [switch]$Confirm=$True
)

# choco apiKey -k YOURS-VERY-OWN-API-KEY -source https://chocolatey.org/

$here = (Split-Path -parent $MyInvocation.MyCommand.Definition)

if ($Package -eq 'chars' -and (test-path 'chars/chars')) {
  rm -recurse -force 'chars/chars'
}

pushd

try {

    cd $here/$Package

    rm *.nupkg
    choco pack

    gci *.nupkg | %{
        $PackagePath = $_
        if ($Confirm){
           $ConfirmText = @"
Confirm
Are you sure you want to push $PackagePath to chocolatey?
"@
            Write-Host $ConfirmText
            $answer = Read-Host @"
[Y] Yes [N] No [?] Help (default is "N")
"@
            switch ($Answer)
            {
                "Y" {
                    Write-Host Push $PackagePath
                    choco push $PackagePath
                    rm $PackagePath
                }
                "" { }
                "N" {  }
                "?" { Write-Host @"
Y - Continue with only the next step of the operation.
N - Skip this operation and proceed with the next operation.
"@
                }
            }
        }
    }
} finally {
    popd
}

git add -A
