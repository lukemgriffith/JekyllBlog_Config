﻿<#

    .Notes
        ChangeLog:
            13/09/2016: Modified script to allow to run from TeamCity, added Jekyll build steps and pushed to verbose.


#>

Import-Module AWsPowerShell

$VerbosePreference = 'Continue'



Push-Location

Set-Location $PSScriptRoot

Write-Verbose "Starting Jekyll Build."
Write-Verbose ("--"*20)

bundle exec jekyll build | ForEach-Object {

    Write-Verbose $_

} 



$data = ConvertFrom-StringData (Get-Content -Path C:\Users\TC\config\rootkey.csv -Raw)

$cred = New-AWSCredentials -AccessKey $data.AWSAccessKeyId -SecretKey $data.AWSSecretKey

Write-Verbose "Cleaning bucket..."

Get-S3Object -BucketName lgjekyllblog -KeyPrefix "\" -Credential $cred | Remove-S3Object -BucketName lgjekyllblog -Force -Credential $cred

Write-Verbose "Starting Upload"

Write-S3Object -BucketName lgjekyllblog -Folder "$PSScriptRoot\_site" -Recurse -Credential $cred -KeyPrefix '\' -Verbose

