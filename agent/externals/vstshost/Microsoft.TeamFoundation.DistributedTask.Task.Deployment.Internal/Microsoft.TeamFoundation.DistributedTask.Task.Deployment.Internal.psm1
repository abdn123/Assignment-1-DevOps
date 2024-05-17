<#
    Microsoft.TeamFoundation.DistributedTask.Task.Deployment.Internal.psm1
#>

# Constants #
$buildUriConstant = '/_build#_a=summary&buildId='

# TELEMETRY CODES
$telemetryCodes = 
@{
  "PREREQ_NoWinRMHTTP_Port" = "PREREQ001";
  "PREREQ_NoWinRMHTTPSPort" = "PREREQ002";
  "PREREQ_NoResources" = "PREREQ003";
  "PREREQ_NoOutputVariableForSelectActionInAzureRG" = "PREREQ004";
  "PREREQ_InvalidServiceConnectionType" = "PREREQ_InvalidServiceConnectionType";
  "PREREQ_AzureRMModuleNotFound" = "PREREQ_AzureRMModuleNotFound";
  "PREREQ_InvalidFilePath" = "PREREQ_InvalidFilePath";
  "PREREQ_StorageAccountNotFound" = "PREREQ_StorageAccountNotFound";
  "PREREQ_NoVMResources" = "PREREQ_NoVMResources";
  "PREREQ_UnsupportedAzurePSVerion" = "PREREQ_UnsupportedAzurePSVerion"; 
  "PREREQ_ClassicStorageAccountNotFound" = "PREREQ_ClassicStorageAccountNotFound";
  
  "PREREQ_RMStorageAccountNotFound" = "PREREQ_RMStorageAccountNotFound";
  
  "PREREQ_NoClassicVMResources" = "PREREQ_NoClassicVMResources";
  
  "PREREQ_NoRMVMResources" = "PREREQ_NoRMVMResources";
  
  "PREREQ_ResourceGroupNotFound" = "PREREQ_ResourceGroupNotFound";

  "AZUREPLATFORM_BlobUploadFailed" = "AZUREPLATFORM_BlobUploadFailed";
  "AZUREPLATFORM_UnknownGetRMVMError" = "AZUREPLATFORM_UnknownGetRMVMError";

  "UNKNOWNPREDEP_Error" = "UNKNOWNPREDEP001";
  "UNKNOWNDEP_Error" = "UNKNOWNDEP_Error";

  "DEPLOYMENT_Failed" = "DEP001";
  "DEPLOYMENT_FetchPropertyFromMap" = "DEPLOYMENT_FetchPropertyFromMap";
  "DEPLOYMENT_CSMDeploymentFailed" = "DEPLOYMENT_CSMDeploymentFailed";  
  "DEPLOYMENT_PerformActionFailed" = "DEPLOYMENT_PerformActionFailed";

  "FILTERING_IncorrectFormat" = "FILTERING_IncorrectFormat";
  "FILTERING_NoVMResources" = "FILTERING_NoVMResources";
  "FILTERING_MachinesNotPresentInRG" = "FILTERING_MachinesNotPresentInRG"
 }

### These constants are copied from 'Microsoft.VisualStudio.Services.DevTestLabs.Common.dll'
### [Microsoft.VisualStudio.Services.DevTestLabs.Common.DevTestLabsConstants]::WINRM_HttpTagKey - This code has been removed to remove the dependency of this psm1 with dll
$WINRM_HttpTagKey = "WinRM_Http";
$WINRM_HttpsTagKey = "WinRM_Https";
$FQDNTagKey = "Microsoft-Vslabs-MG-Resource-FQDN";
$SkipCACheckTagKey = "Microsoft-Vslabs-MG-SkipCACheck";

 # TELEMETRY FUNCTION
function Write-Telemetry
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$codeKey,

    [Parameter(Mandatory=$True,Position=2)]
    [string]$taskId
    )
  
  if($telemetrySet)
  {
    return
  }

  $code = $telemetryCodes[$codeKey]
  $telemetryString = "##vso[task.logissue type=error;code=" + $code + ";TaskId=" + $taskId + ";]"
  Write-Host $telemetryString
  $telemetrySet = $true
}

function Get-ResourceCredentials
{
    [CmdletBinding()]
    Param
    (
        [object]$resource
    )

    $machineUserName = $resource.Username
    if([string]::IsNullOrWhiteSpace($machineUserName))
    {
        throw (Get-LocalizedString -Key "Please specify valid username for resource {0}" -ArgumentList $resource.Name)
    }
    Write-Verbose "`t`t Resource Username - $machineUserName"
    
    $machinePassword = $resource.Password
    if([string]::IsNullOrWhiteSpace($machinePassword))
    {
        throw (Get-LocalizedString -Key "Please specify valid password for resource {0}" -ArgumentList $resource.Name)
    }

    $credential = New-Object 'System.Net.NetworkCredential' -ArgumentList $machineUserName, $machinePassword

    return $credential
}

function Get-ResourceOperationLogs
{
    [CmdletBinding()]
    Param
    (
        [object] [Parameter(Mandatory = $true)]
        $deploymentResponse
    )

    $log = "Copy Logs : " + $deploymentResponse.DeploymentLog + "`nService Logs : " + $deploymentResponse.ServiceLog;

    $logs = New-Object 'System.Collections.Generic.List[System.Object]'
    $resourceOperationLog = New-OperationLog -Content $log
    $logs.Add($resourceOperationLog)

    return $logs
}

function Write-ResponseLogs
{
    [CmdletBinding()]
    Param
    (
        [string] [Parameter(Mandatory = $true)]
        $operationName,

        [string] [Parameter(Mandatory = $true)]
        $fqdn,

        [object] [Parameter(Mandatory = $true)]
        $deploymentResponse
    )

    Write-Verbose "Finished $operationName operation on $fqdn"

    if ([string]::IsNullOrEmpty($deploymentResponse.DeploymentLog) -eq $false)
    {
        Write-Verbose "Deployment logs for $operationName operation on $fqdn " -Verbose
        Write-Verbose ($deploymentResponse.DeploymentLog | Format-List | Out-String) -Verbose
    }

    if ([string]::IsNullOrEmpty($deploymentResponse.ServiceLog) -eq $false)
    {
        Write-Verbose "Service logs for $operationName operation on $fqdn "
        Write-Verbose ($deploymentResponse.ServiceLog | Format-List | Out-String)
    }
}

function Get-ResourceHttpTagKey
{
    [CmdletBinding()]
    Param
    ()

    return $WINRM_HttpTagKey
}

function Get-ResourceHttpsTagKey
{
    [CmdletBinding()]
    Param
    ()

    return $WINRM_HttpsTagKey
}

function Get-ResourceFQDNTagKey
{
    [CmdletBinding()]
    Param
    ()

    return $FQDNTagKey
}

function Get-SkipCACheckTagKey
{
    [CmdletBinding()]
    Param
    ()

    return $SkipCACheckTagKey
}

function Get-OperationLogs
{
    [CmdletBinding()]
    param
    ()

    $teamFoundationCollectionUri = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
    $teamProject = $env:SYSTEM_TEAMPROJECT
    $buildId = $env:BUILD_BUILDID
    #TODO: Need to fix this URL for Release.
    $buildUri = $teamFoundationCollectionUri + $teamProject + $buildUriConstant + $buildId

    $logs = New-Object 'System.Collections.Generic.List[System.Object]'
    $resourceOperationLog = New-OperationLog -Content $buildUri
    $logs.Add($resourceOperationLog)
    return $logs
}

function Get-SqlPackageCommandArguments
{
    param (
    [string]$dacpacFile,
    [string]$targetMethod,
    [string]$serverName,
    [string]$databaseName,
    [string]$sqlUsername,
    [string]$sqlPassword,
    [string]$connectionString,
    [string]$publishProfile,
    [string]$additionalArguments
    )

    $ErrorActionPreference = 'Stop'
    $dacpacFileExtension = ".dacpac"
    $SqlPackageOptions =
    @{
        SourceFile = "/SourceFile:"; 
        Action = "/Action:"; 
        TargetServerName = "/TargetServerName:";
        TargetDatabaseName = "/TargetDatabaseName:";
        TargetUser = "/TargetUser:";
        TargetPassword = "/TargetPassword:";
        TargetConnectionString = "/TargetConnectionString:";
        Profile = "/Profile:";
    }

    # validate dacpac file
    if ([System.IO.Path]::GetExtension($dacpacFile) -ne $dacpacFileExtension)
    {
        Write-Error (Get-LocalizedString -Key "Invalid Dacpac file '{0}' provided" -ArgumentList $dacpacFile)
    }

    $sqlPackageArguments = @($SqlPackageOptions.SourceFile + "`'$dacpacFile`'")
    $sqlPackageArguments += @($SqlPackageOptions.Action + "Publish")

    if($targetMethod -eq "server")
    {
        $sqlPackageArguments += @($SqlPackageOptions.TargetServerName + "`'$serverName`'")

        if ($databaseName)
        {
            $sqlPackageArguments += @($SqlPackageOptions.TargetDatabaseName + "`'$databaseName`'")
        }

        if($sqlUsername)
        {
            $sqlPackageArguments += @($SqlPackageOptions.TargetUser + "`'$sqlUsername`'")

            if (-not($sqlPassword))
            {
                Write-Error (Get-LocalizedString -Key "No password specified for the SQL User: '{0}'" -ArgumentList $sqlUserName)
            }

            $sqlPackageArguments += @($SqlPackageOptions.TargetPassword + "`'$sqlPassword`'")
        }    
    }
    elseif($targetMethod -eq "connectionString")
    {
        $sqlPackageArguments += @($SqlPackageOptions.TargetConnectionString + "`'$connectionString`'")
    }    

    if( [string]::IsNullOrWhitespace($PublishProfile) -eq $false -and $PublishProfile -ne $env:SYSTEM_DEFAULTWORKINGDIRECTORY -and $PublishProfile -ne [String]::Concat($env:SYSTEM_DEFAULTWORKINGDIRECTORY, "\"))
    {
        # validate publish profile
        if ([System.IO.Path]::GetExtension($publishProfile) -ne ".xml")
        {
            Write-Error (Get-LocalizedString -Key "Invalid Publish Profile '{0}' provided" -ArgumentList $publishProfile)
        }
        $sqlPackageArguments += @($SqlPackageOptions.Profile + "`'$publishProfile`'")
    }

    $sqlPackageArguments += @("$additionalArguments")

    $scriptArgument = '"' + ($sqlPackageArguments -join " ") + '"'

    return $scriptArgument
}
# SIG # Begin signature block
# MIInzgYJKoZIhvcNAQcCoIInvzCCJ7sCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCFUQ6Jbzpjnr9R
# vlfQAohpN4cE8boJDoOT7D3DcoNzLaCCDYUwggYDMIID66ADAgECAhMzAAADri01
# UchTj1UdAAAAAAOuMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwODU5WhcNMjQxMTE0MTkwODU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQD0IPymNjfDEKg+YyE6SjDvJwKW1+pieqTjAY0CnOHZ1Nj5irGjNZPMlQ4HfxXG
# yAVCZcEWE4x2sZgam872R1s0+TAelOtbqFmoW4suJHAYoTHhkznNVKpscm5fZ899
# QnReZv5WtWwbD8HAFXbPPStW2JKCqPcZ54Y6wbuWV9bKtKPImqbkMcTejTgEAj82
# 6GQc6/Th66Koka8cUIvz59e/IP04DGrh9wkq2jIFvQ8EDegw1B4KyJTIs76+hmpV
# M5SwBZjRs3liOQrierkNVo11WuujB3kBf2CbPoP9MlOyyezqkMIbTRj4OHeKlamd
# WaSFhwHLJRIQpfc8sLwOSIBBAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhx/vdKmXhwc4WiWXbsf0I53h8T8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMTgzNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGrJYDUS7s8o0yNprGXRXuAnRcHKxSjFmW4wclcUTYsQZkhnbMwthWM6cAYb/h2W
# 5GNKtlmj/y/CThe3y/o0EH2h+jwfU/9eJ0fK1ZO/2WD0xi777qU+a7l8KjMPdwjY
# 0tk9bYEGEZfYPRHy1AGPQVuZlG4i5ymJDsMrcIcqV8pxzsw/yk/O4y/nlOjHz4oV
# APU0br5t9tgD8E08GSDi3I6H57Ftod9w26h0MlQiOr10Xqhr5iPLS7SlQwj8HW37
# ybqsmjQpKhmWul6xiXSNGGm36GarHy4Q1egYlxhlUnk3ZKSr3QtWIo1GGL03hT57
# xzjL25fKiZQX/q+II8nuG5M0Qmjvl6Egltr4hZ3e3FQRzRHfLoNPq3ELpxbWdH8t
# Nuj0j/x9Crnfwbki8n57mJKI5JVWRWTSLmbTcDDLkTZlJLg9V1BIJwXGY3i2kR9i
# 5HsADL8YlW0gMWVSlKB1eiSlK6LmFi0rVH16dde+j5T/EaQtFz6qngN7d1lvO7uk
# 6rtX+MLKG4LDRsQgBTi6sIYiKntMjoYFHMPvI/OMUip5ljtLitVbkFGfagSqmbxK
# 7rJMhC8wiTzHanBg1Rrbff1niBbnFbbV4UDmYumjs1FIpFCazk6AADXxoKCo5TsO
# zSHqr9gHgGYQC2hMyX9MGLIpowYCURx3L7kUiGbOiMwaMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGZ8wghmbAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAOuLTVRyFOPVR0AAAAA
# A64wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIH0T
# VyrC3RliUwZnqcNU8315LM35Npg1gjgvdjQWOln8MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAD/umn0t8TU4GKpR0X+fsHqJ2bjFX+Mh1wLYB
# v1uo7EMZNXCykGOd3tii0+423ccBs92yoIdHYps2yRCv7r6xrUYp2XUs1tOtSWkj
# ZdcnhXAxL44XJHpeTdCt3VaLcZ6KzzkbXpTcqkM5W/oMaMJRs/ZYlly4xuPrnOXI
# 3eFwGVdDYOAyL4hdNSj/fxUZufm1mmHlq2pXScaqGIWF13NmjS2G3YvCCRX2WZv+
# 8XDfwWmp7Kx7DgNgJh8jNc7UDWvVCRmUI8IETuxihb9AYqRXe41JhATaspJcyasC
# KBFOmYBTQd7MLEz/aNL2fcGiwfSJYFVDWbWBdwrJdbn3MYWl/aGCFykwghclBgor
# BgEEAYI3AwMBMYIXFTCCFxEGCSqGSIb3DQEHAqCCFwIwghb+AgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCCj7mklQYy0Ug+V35f2V6rHR5rL6TheDNTg
# xLhPKjSccwIGZh//gT7nGBMyMDI0MDUwMTA5MzcyMS45MDNaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOjg2REYtNEJCQy05MzM1MSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIReDCCBycwggUPoAMCAQICEzMAAAHdXVcd
# ldStqhsAAQAAAd0wDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjMxMDEyMTkwNzA5WhcNMjUwMTEwMTkwNzA5WjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo4NkRGLTRCQkMtOTMzNTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKhO
# A5RE6i53nHURH4lnfKLp+9JvipuTtctairCxMUSrPSy5CWK2DtriQP+T52HXbN2g
# 7AktQ1pQZbTDGFzK6d03vYYNrCPuJK+PRsP2FPVDjBXy5mrLRFzIHHLaiAaobE5v
# FJuoxZ0ZWdKMCs8acjhHUmfaY+79/CR7uN+B4+xjJqwvdpU/mp0mAq3earyH+AKm
# v6lkrQN8zgrcbCgHwsqvvqT6lEFqYpi7uKn7MAYbSeLe0pMdatV5EW6NVnXMYOTR
# KuGPfyfBKdShualLo88kG7qa2mbA5l77+X06JAesMkoyYr4/9CgDFjHUpcHSODuj
# lFBKMi168zRdLerdpW0bBX9EDux2zBMMaEK8NyxawCEuAq7++7ktFAbl3hUKtuzY
# C1FUZuUl2Bq6U17S4CKsqR3itLT9qNcb2pAJ4jrIDdll5Tgoqef5gpv+YcvBM834
# bXFNwytd3ujDD24P9Dd8xfVJvumjsBQQkK5T/qy3HrQJ8ud1nHSvtFVi5Sa/ubGu
# YEpS8gF6GDWN5/KbveFkdsoTVIPo8pkWhjPs0Q7nA5+uBxQB4zljEjKz5WW7BA4w
# pmFm24fhBmRjV4Nbp+n78cgAjvDSfTlA6DYBcv2kx1JH2dIhaRnSeOXePT6hMF0I
# l598LMu0rw35ViUWcAQkUNUTxRnqGFxz5w+ZusMDAgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQUbqL1toyPUdpFyyHSDKWj0I4lw/EwHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBAC5U2bINLgXIHWbMcqVuf9jkUT/K8zyLBvu5h8JrqYR2z/eaO2yo1Ooc9Shy
# vxbe9GZDu7kkUzxSyJ1IZksZZw6FDq6yZNT3PEjAEnREpRBL8S+mbXg+O4VLS0LS
# mb8XIZiLsaqZ0fDEcv3HeA+/y/qKnCQWkXghpaEMwGMQzRkhGwcGdXr1zGpQ7HTx
# vfu57xFxZX1MkKnWFENJ6urd+4teUgXj0ngIOx//l3XMK3Ht8T2+zvGJNAF+5/5q
# Bk7nr079zICbFXvxtidNN5eoXdW+9rAIkS+UGD19AZdBrtt6dZ+OdAquBiDkYQ5k
# VfUMKS31yHQOGgmFxuCOzTpWHalrqpdIllsy8KNsj5U9sONiWAd9PNlyEHHbQZDm
# i9/BNlOYyTt0YehLbDovmZUNazk79Od/A917mqCdTqrExwBGUPbMP+/vdYUqaJsp
# upBnUtjOf/76DAhVy8e/e6zR98PkplmliO2brL3Q3rD6+ZCVdrGM9Rm6hUDBBkvY
# h+YjmGdcQ5HB6WT9Rec8+qDHmbhLhX4Zdaard5/OXeLbgx2f7L4QQQj3KgqjqDOW
# InVhNE1gYtTWLHe4882d/k7Lui0K1g8EZrKD7maOrsJLKPKlegceJ9FCqY1sDUKU
# hRa0EHUW+ZkKLlohKrS7FwjdrINWkPBgbQznCjdE2m47QjTbMIIHcTCCBVmgAwIB
# AgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1
# WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O
# 1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
# hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t
# 1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxq
# D89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmP
# frVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSW
# rAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv
# 231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zb
# r17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYcten
# IPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQc
# xWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17a
# j54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
# n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEw
# QTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9E
# b2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3h
# LB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x
# 5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
# y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1A
# oL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbC
# HcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB
# 9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNt
# yo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3
# rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcV
# v7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A24
# 5oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lw
# Y1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtQwggI9AgEBMIIBAKGB2KSB1TCB
# 0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
# TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjo4NkRGLTRCQkMtOTMzNTElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUANiNHGWXbNaDPxnyi
# DbEOciSjFhCggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOncSQMwIhgPMjAyNDA1MDExMjUyMTlaGA8yMDI0MDUw
# MjEyNTIxOVowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA6dxJAwIBADAHAgEAAgII
# JjAHAgEAAgIRJzAKAgUA6d2agwIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEE
# AYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GB
# AN4SY+vcMjb757UfzgTePGOvdcBiWeyISichy+4tlmenj0J4KgSviK2CmOFLY0HM
# W+AB8HbvF772pKBnBAylQ8AyRimSmEzLUwg/8MjPHC9/TGQIyzfJNB6r4S09A+0F
# GPpCnt29Zb/pLSbHOk73xmBvUYQVSdT1o68mfAbMJCMaMYIEDTCCBAkCAQEwgZMw
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHdXVcdldStqhsAAQAA
# Ad0wDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRAB
# BDAvBgkqhkiG9w0BCQQxIgQgYrsO1U80jIUoKCt9hg5GG8LDt0V9EI+y7y4O7+3c
# 3jgwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCBh/w4tmmWsT3iZnHtH0Vk3
# 7UCN02lRxY+RiON6wDFjZjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAAB3V1XHZXUraobAAEAAAHdMCIEIEncT4AKLZaPW5EmUb3sG7Q7
# 23+0jGb1PxDmz1zD6ZzhMA0GCSqGSIb3DQEBCwUABIICAKadOyJPPmcA9+ZonilB
# pNhFravs8QHiog7saks0XFkmT2UrMTimTb1bdyTO2X3G7zGVIgnRy7LidaPIV/S/
# jhqu6R/o0B0SA3L+/ID+ISyUC40yAcVp3FA3EjRfolVvfdDb5aJyiXR7m3vkX5c4
# j309cW0jUfboA7igsRJ2AVRLH0we93SZ2JRLrLnoDZYPJOXq7/Tfxtmfs/a+Ed2c
# oh4KD2k/zh3v/PDPeERDOlm7m0V4qc6+UYGoN/vQ+Qm0W/hwNbceMuJyqOZTzTlv
# xYLOmVDgIzg5siKLgbMPUeP8vJEnzeYtXAT7WNosOFvTVsB4AhAEvIvHMaHILxBV
# Pd/bKQR4Und32yDR3QeykVmfbX3TwJWcIIRZXgxw/qpZbuOo44tw6E4FK9mGYTJw
# Lz0oet1qqGyuNDeNoQfxkYdUnRkUY9yeLJU1sIOIK9c0i3rHGLQiT50rRUu7A6rq
# i4XgcxZsrItGMavnNE2UjicGaQZLjvfYn1c31N+xBcZDoXB3BdN1J3k81OmtatnK
# JJuqa55S7Zcgm+L5LRytu6/7qrVP5g+Mlez3hAA1TFlOHz+VLtT6hh52fICjPg4q
# fHwqDk9Jtrz6j+eLBXU9Ph3EPqG4QbmzcFGqfO+jN6CzTA/EBhN/bAq2yZxt37RJ
# BaqI1kwCv3K9q1dwMjGEQ/DP
# SIG # End signature block
