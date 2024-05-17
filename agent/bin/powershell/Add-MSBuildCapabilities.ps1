[CmdletBinding()]
param()

function Get-MSBuildCapabilities {
    param (
        [Parameter(Mandatory = $true)]
        [int]$MajorVersion,

        [switch]$Add_x64
    )

    $vs = Get-VisualStudio -MajorVersion $MajorVersion
    
    $capabilitySuffix = [string]::Empty
    if($Add_x64)
    {
        $msbuildInstallationPath = 'MSBuild\Current\Bin\amd64'
        $capabilitySuffix = "_x64"
    }
    else
    {
        $msbuildInstallationPath = 'MSBuild\Current\Bin'
    }

    if ($vs -and $vs.installationPath) {
        # Add MSBuild_$($MajorVersion).0.
        # End with "\" for consistency with old MSBuildToolsPath value.
        $msbuild = ([System.IO.Path]::Combine($vs.installationPath, $msbuildInstallationPath)) + '\'
        if ((Test-Leaf -LiteralPath "$($msbuild)MSBuild.exe")) {
            Write-Capability -Name "MSBuild_$($MajorVersion).0$($capabilitySuffix)" -Value $msbuild
            $latest = $msbuild
        }
    }
    if ($latest) {
        Write-Capability -Name "MSBuild$($capabilitySuffix)" -Value $latest
    }
}

# Define the key names.
$keyName20 = "Software\Microsoft\MSBuild\ToolsVersions\2.0"
$keyName35 = "Software\Microsoft\MSBuild\ToolsVersions\3.5"
$keyName40 = "Software\Microsoft\MSBuild\ToolsVersions\4.0"
$keyName12 = "Software\Microsoft\MSBuild\ToolsVersions\12.0"
$keyName14 = "Software\Microsoft\MSBuild\ToolsVersions\14.0"

# Add 32-bit.
$latest = $null
$null = Add-CapabilityFromRegistry -Name "MSBuild_2.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName20 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_3.5" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName35 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_4.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName40 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_12.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName12 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_14.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName14 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$vs15 = Get-VisualStudio -MajorVersion 15
if ($vs15 -and $vs15.installationPath) {
    # Add MSBuild_15.0.
    # End with "\" for consistency with old MSBuildToolsPath value.
    $msbuild15 = ([System.IO.Path]::Combine($vs15.installationPath, 'MSBuild\15.0\Bin')) + '\'
    if ((Test-Leaf -LiteralPath "$($msbuild15)MSBuild.exe")) {
        Write-Capability -Name 'MSBuild_15.0' -Value $msbuild15
        $latest = $msbuild15
    }
}

Get-MSBuildCapabilities -MajorVersion 16

Get-MSBuildCapabilities -MajorVersion 17

# Add 64-bit.
$latest = $null
$null = Add-CapabilityFromRegistry -Name "MSBuild_2.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName20 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_3.5_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName35 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_4.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName40 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_12.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName12 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_14.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName14 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
if ($vs15 -and $vs15.installationPath) {
    # Add MSBuild_15.0_x64.
    # End with "\" for consistency with old MSBuildToolsPath value.
    $msbuild15 = ([System.IO.Path]::Combine($vs15.installationPath, 'MSBuild\15.0\Bin\amd64')) + '\'
    if ((Test-Leaf -LiteralPath "$($msbuild15)MSBuild.exe")) {
        Write-Capability -Name 'MSBuild_15.0_x64' -Value $msbuild15
        $latest = $msbuild15
    }
}

Get-MSBuildCapabilities -MajorVersion 16 -Add_x64

Get-MSBuildCapabilities -MajorVersion 17 -Add_x64

# SIG # Begin signature block
# MIIn0QYJKoZIhvcNAQcCoIInwjCCJ74CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCRZ2UUwQ8J+9kB
# j7ybtyUkp7bnpQC9BHG83Zl9a2T4pqCCDYUwggYDMIID66ADAgECAhMzAAADri01
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGaIwghmeAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAOuLTVRyFOPVR0AAAAA
# A64wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEINl4
# b1gGgcX4yQMpIppwMuK5FaJgOIXHrPpCFW+P+eSdMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEADrrz6Ox8x1PHjxE8Gd+9HVSToEkAK7o779J2
# 1NgLacQhXqCi467Ig0L4vmrl6DgQyTRap6rz5g0PPX9Wx/5oX3hWuow/+KsCcJ15
# G+g2nzxm0DaEVsLabqNwzQS01H/1evJob4V6kl0B89BnNCJlg6VXH+U2lzjIZ/dF
# mYmFiDz4a+HgLf1HLiEVm6Q7x8hJwcWxDLu5FJYi1drRsN3NxeCNWTQmTtHizJ2k
# eUfHsbq6SiH+xQ9x4rV+keYA8UhqwKhVmbGbzSPZUcpeXVs00oghlyowzLQJa9FL
# D7MRMfUzexejnLHzXL8SXmv99DT1SJP37H+ogjkndkzeCbfxvqGCFywwghcoBgor
# BgEEAYI3AwMBMYIXGDCCFxQGCSqGSIb3DQEHAqCCFwUwghcBAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCBvEiVid68aYHPlPJ8Ba43yU2YIyU3YeN2U
# 35hp8dSbNAIGZiAhcbpQGBMyMDI0MDUwMTA5MzcyMS45MTFaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOkZDNDEtNEJENC1EMjIwMSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIRezCCBycwggUPoAMCAQICEzMAAAHimZmV
# 8dzjIOsAAQAAAeIwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjMxMDEyMTkwNzI1WhcNMjUwMTEwMTkwNzI1WjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjpGQzQxLTRCRDQtRDIyMDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALVj
# tZhV+kFmb8cKQpg2mzisDlRI978Gb2amGvbAmCd04JVGeTe/QGzM8KbQrMDol7DC
# 7jS03JkcrPsWi9WpVwsIckRQ8AkX1idBG9HhyCspAavfuvz55khl7brPQx7H99UJ
# bsE3wMmpmJasPWpgF05zZlvpWQDULDcIYyl5lXI4HVZ5N6MSxWO8zwWr4r9xkMmU
# Xs7ICxDJr5a39SSePAJRIyznaIc0WzZ6MFcTRzLLNyPBE4KrVv1LFd96FNxAzwne
# tSePg88EmRezr2T3HTFElneJXyQYd6YQ7eCIc7yllWoY03CEg9ghorp9qUKcBUfF
# cS4XElf3GSERnlzJsK7s/ZGPU4daHT2jWGoYha2QCOmkgjOmBFCqQFFwFmsPrZj4
# eQszYxq4c4HqPnUu4hT4aqpvUZ3qIOXbdyU42pNL93cn0rPTTleOUsOQbgvlRdth
# FCBepxfb6nbsp3fcZaPBfTbtXVa8nLQuMCBqyfsebuqnbwj+lHQfqKpivpyd7KCW
# ACoj78XUwYqy1HyYnStTme4T9vK6u2O/KThfROeJHiSg44ymFj+34IcFEhPogaKv
# NNsTVm4QbqphCyknrwByqorBCLH6bllRtJMJwmu7GRdTQsIx2HMKqphEtpSm1z3u
# fASdPrgPhsQIRFkHZGuihL1Jjj4Lu3CbAmha0lOrAgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQURIQOEdq+7QdslptJiCRNpXgJ2gUwHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBAORURDGrVRTbnulfsg2cTsyyh7YXvhVU7NZMkITAQYsFEPVgvSviCylr5ap3
# ka76Yz0t/6lxuczI6w7tXq8n4WxUUgcj5wAhnNorhnD8ljYqbck37fggYK3+wEwL
# hP1PGC5tvXK0xYomU1nU+lXOy9ZRnShI/HZdFrw2srgtsbWow9OMuADS5lg7okrX
# a2daCOGnxuaD1IO+65E7qv2O0W0sGj7AWdOjNdpexPrspL2KEcOMeJVmkk/O0gan
# hFzzHAnWjtNWneU11WQ6Bxv8OpN1fY9wzQoiycgvOOJM93od55EGeXxfF8bofLVl
# UE3zIikoSed+8s61NDP+x9RMya2mwK/Ys1xdvDlZTHndIKssfmu3vu/a+BFf2uIo
# ycVTvBQpv/drRJD68eo401mkCRFkmy/+BmQlRrx2rapqAu5k0Nev+iUdBUKmX/iO
# aKZ75vuQg7hCiBA5xIm5ZIXDSlX47wwFar3/BgTwntMq9ra6QRAeS/o/uYWkmvqv
# E8Aq38QmKgTiBnWSS/uVPcaHEyArnyFh5G+qeCGmL44MfEnFEhxc3saPmXhe6MhS
# gCIGJUZDA7336nQD8fn4y6534Lel+LuT5F5bFt0mLwd+H5GxGzObZmm/c3pEWtHv
# 1ug7dS/Dfrcd1sn2E4gk4W1L1jdRBbK9xwkMmwY+CHZeMSvBMIIHcTCCBVmgAwIB
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
# Y1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtcwggJAAgEBMIIBAKGB2KSB1TCB
# 0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
# TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjpGQzQxLTRCRDQtRDIyMDElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAFpuZafp0bnpJdIhf
# iB1d8pTohm+ggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOncavcwIhgPMjAyNDA1MDExNTE3MTFaGA8yMDI0MDUw
# MjE1MTcxMVowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA6dxq9wIBADAKAgEAAgIP
# JgIB/zAHAgEAAgIRSjAKAgUA6d28dwIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUA
# A4GBACZD0HyM/iyRFybuwW+BVpO2rCgdm83YS4WY8w2wSofJNQUGmxhajD86EOcc
# Lxv78rsdTcBxJtSRCRi/avi/mtzU9p1H4Rhe8cVBxCAPB+ktJa8Y0cUmSIQDIn0P
# 6b9SgLRnRLt68jKDH/gog5CgT41pcGNhyQtQLwMUiUd7eDiqMYIEDTCCBAkCAQEw
# gZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHimZmV8dzjIOsA
# AQAAAeIwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0B
# CRABBDAvBgkqhkiG9w0BCQQxIgQgSSL6GkgYYtgdzU1e7dxlU2iXo9+X3vtpS+je
# YBNgpM8wgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCAriSpKEP0muMbBUETO
# DoL4d5LU6I/bjucIZkOJCI9//zCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwAhMzAAAB4pmZlfHc4yDrAAEAAAHiMCIEIFb8g3r1HbtM6YgvScyO
# hHvoKs8ktotTygHMdOCSwhyIMA0GCSqGSIb3DQEBCwUABIICABKV38jGKcBogMpe
# 0RamRPr7R7v7zEvyV+Vqg26J55g3EF1n1avhU/tRnZXDyveuUUxS6rr5XOZwOQdN
# Fwb8DIb0b0gWHrwVinCcgB80i06k2RG20nG//Aypp2It6YLXuy13Fr6WWt6kXjQn
# 3MsVXDdqfFKB4gkgPOOpqvdSh9i1q3nSnxElNut4ULMqiDTM0sVnbXmerLyxovFr
# Ip7gYQjWSGH7yFucWiIhDXBEdfbepOHfmMB3xeV3kX2o5PO3UBNvLRXbAbviPnDl
# wFxPBjRi/kncPBKugr6st78JI8q0RdSCUOUg/xO+Yt0olmgBbfunP2UlwncrvKXu
# vTKIJwfpWWelzHH2YBBvHLqcPpxZRB95eXK9VO9kbY8i6Vasj2y4B01ohv9oBbul
# Fy2qmRemfFa6WgyRi+fRQWIvHDHjX5kbN/yFlcvwwhJYGDEghjqZT+70hYC0895o
# FJiaf1UL/L7OkPqmkjCfX1icv5rHLV79cr9ftetFLJopNJbVzatn2wbRCpqJe/hU
# ls67Zs0WaWVPuPcXJv8BT2pWJ+zLubobFtwJd0dstHmblwkcwexKg42fJmdxVPT1
# qi2At83Ont5K6+83O7H3RlrvJyku9Xhl7zbu/a7g0Ily+CaOhDZXbIYMKsqp5aQF
# hmo98xBjAzT4B2d8dWjS89zT5R83
# SIG # End signature block
