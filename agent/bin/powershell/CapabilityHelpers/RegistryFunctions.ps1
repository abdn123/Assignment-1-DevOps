function Get-RegistrySubKeyNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$Hive,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Registry32', 'Registry64')]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [string]$KeyName)

    Write-Host "Checking: hive '$Hive', view '$View', key name '$KeyName'"
    if ($View -eq 'Registry64' -and !([System.Environment]::Is64BitOperatingSystem)) {
        Write-Host "Skipping."
        return
    }

    $baseKey = $null
    $subKey = $null
    try {
        # Open the base key.
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, $View)

        # Open the sub key as read-only.
        $subKey = $baseKey.OpenSubKey($KeyName, $false)

        # Check if the sub key was found.
        if (!$subKey) {
            Write-Host "Key not found."
            return
        }

        # Get the sub-key names.
        $subKeyNames = $subKey.GetSubKeyNames()
        Write-Host "Sub keys:"
        foreach ($subKeyName in $subKeyNames) {
            Write-Host "  '$subKeyName'"
        }

        return $subKeyNames
    } finally {
        # Dispose the sub key.
        if ($subKey) {
            $null = $subKey.Dispose()
        }

        # Dispose the base key.
        if ($baseKey) {
            $null = $baseKey.Dispose()
        }
    }
}

function Get-RegistryValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$Hive,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Registry32', 'Registry64')]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [string]$KeyName,

        [string]$ValueName)

    Write-Host "Checking: hive '$Hive', view '$View', key name '$KeyName', value name '$ValueName'"
    if ($View -eq 'Registry64' -and !([System.Environment]::Is64BitOperatingSystem)) {
        Write-Host "Skipping."
        return
    }

    $baseKey = $null
    $subKey = $null
    try {
        # Open the base key.
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, $View)

        # Open the sub key as read-only.
        $subKey = $baseKey.OpenSubKey($KeyName, $false)

        # Check if the sub key was found.
        if (!$subKey) {
            Write-Host "Key not found."
            return
        }

        # Get the value.
        $value = $subKey.GetValue($ValueName)

        # Check if the value was not found or is empty.
        if ([System.Object]::ReferenceEquals($value, $null) -or
            ($value -is [string] -and !$value)) {

            Write-Host "Value not found or is empty."
            return
        }

        # Return the value.
        Write-Host "Found $($value.GetType().Name) value: '$value'"
        return $value
    } finally {
        # Dispose the sub key.
        if ($subKey) {
            $null = $subKey.Dispose()
        }

        # Dispose the base key.
        if ($baseKey) {
            $null = $baseKey.Dispose()
        }
    }
}

function Get-RegistryValueNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$Hive,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Registry32', 'Registry64')]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [string]$KeyName)

    Write-Host "Checking: hive '$Hive', view '$View', key name '$KeyName', value name '$ValueName'"
    if ($View -eq 'Registry64' -and !([System.Environment]::Is64BitOperatingSystem)) {
        Write-Host "Skipping."
        return
    }

    $baseKey = $null
    $subKey = $null
    try {
        # Open the base key.
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, $View)

        # Open the sub key as read-only.
        $subKey = $baseKey.OpenSubKey($KeyName, $false)

        # Check if the sub key was found.
        if (!$subKey) {
            Write-Host "Key not found."
            return
        }

        # Get the value names.
        $valueNames = $subKey.GetValueNames()
        Write-Host "Value names:"
        foreach ($valueName in $valueNames) {
            Write-Host "  '$valueName'"
        }

        return $valueNames
    } finally {
        # Dispose the sub key.
        if ($subKey) {
            $null = $subKey.Dispose()
        }

        # Dispose the base key.
        if ($baseKey) {
            $null = $baseKey.Dispose()
        }
    }
}
# SIG # Begin signature block
# MIIn0QYJKoZIhvcNAQcCoIInwjCCJ74CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCALzKZaVB94WWyX
# acRdEp/wsucjy+r8tbSFoN6OI30gJqCCDYUwggYDMIID66ADAgECAhMzAAADri01
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIA84
# cjHR9N9Ep5TD2rqnXLPC6rVUi+YtpG96lwrtw7seMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEArm5YCsjN74GaL5G3GRyr3099G/X5TAkRqghU
# 8kpMqS6lgDek7+yEYEhfK3NlHEO8LCIrdy+l0JAiSd8ANTKolJSlUaqOmcOeLLIh
# y/UWWSXUgRVKsJ7nFXWfsVwAdCFeyBfqfatd8+B0ASqRzkTLLZK93gOVd0kj9KF2
# VJ8ggfou3InjH8jJMMEyzJm1j7zxCPDf4s0uBbpb1fTm438d4SQfsn+qW4wt/BQ8
# xyTHj3l47hUCMx1um2Yy/KZARK3CnSwEV5nE67VL7tcnJc4fRduSwYYSBaLdDDNu
# S5TOEhmzdy0+KONUTePDEgzyvBboV1lsTRFZvOG0pFRlBtttSaGCFywwghcoBgor
# BgEEAYI3AwMBMYIXGDCCFxQGCSqGSIb3DQEHAqCCFwUwghcBAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCAe0g6BSRYpYzeFA/aWenHwMKmVT7YeS6Um
# //4nsQ/tTwIGZh/H30LgGBMyMDI0MDUwMTA5MzcyMC4zOThaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOjhENDEtNEJGNy1CM0I3MSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIRezCCBycwggUPoAMCAQICEzMAAAHj372b
# mhxogyIAAQAAAeMwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjMxMDEyMTkwNzI5WhcNMjUwMTEwMTkwNzI5WjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo4RDQxLTRCRjctQjNCNzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL6k
# DWgeRp+fxSBUD6N/yuEJpXggzBeNG5KB8M9AbIWeEokJgOghlMg8JmqkNsB4Wl1N
# EXR7cL6vlPCsWGLMhyqmscQu36/8h2bx6TU4M8dVZEd6V4U+l9gpte+VF91kOI35
# fOqJ6eQDMwSBQ5c9ElPFUijTA7zV7Y5PRYrS4FL9p494TidCpBEH5N6AO5u8wNA/
# jKO94Zkfjgu7sLF8SUdrc1GRNEk2F91L3pxR+32FsuQTZi8hqtrFpEORxbySgiQB
# P3cH7fPleN1NynhMRf6T7XC1L0PRyKy9MZ6TBWru2HeWivkxIue1nLQb/O/n0j2Q
# Vd42Zf0ArXB/Vq54gQ8JIvUH0cbvyWM8PomhFi6q2F7he43jhrxyvn1Xi1pwHOVs
# bH26YxDKTWxl20hfQLdzz4RVTo8cFRMdQCxlKkSnocPWqfV/4H5APSPXk0r8Cc/c
# Mmva3g4EvupF4ErbSO0UNnCRv7UDxlSGiwiGkmny53mqtAZ7NLePhFtwfxp6ATIo
# jl8JXjr3+bnQWUCDCd5Oap54fGeGYU8KxOohmz604BgT14e3sRWABpW+oXYSCyFQ
# 3SZQ3/LNTVby9ENsuEh2UIQKWU7lv7chrBrHCDw0jM+WwOjYUS7YxMAhaSyOahpb
# udALvRUXpQhELFoO6tOx/66hzqgjSTOEY3pu46BFAgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQUsa4NZr41FbehZ8Y+ep2m2YiYqQMwHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBALe+my6p1NPMEW1t70a8Y2hGxj6siDSulGAs4UxmkfzxMAic4j0+GTPbHxk1
# 93mQ0FRPa9dtbRbaezV0GLkEsUWTGF2tP6WsDdl5/lD4wUQ76ArFOencCpK5svE0
# sO0FyhrJHZxMLCOclvd6vAIPOkZAYihBH/RXcxzbiliOCr//3w7REnsLuOp/7vlX
# JAsGzmJesBP/0ERqxjKudPWuBGz/qdRlJtOl5nv9NZkyLig4D5hy9p2Ec1zaotiL
# iHnJ9mlsJEcUDhYj8PnYnJjjsCxv+yJzao2aUHiIQzMbFq+M08c8uBEf+s37YbZQ
# 7XAFxwe2EVJAUwpWjmtJ3b3zSWTMmFWunFr2aLk6vVeS0u1MyEfEv+0bDk+N3jms
# CwbLkM9FaDi7q2HtUn3z6k7AnETc28dAvLf/ioqUrVYTwBrbRH4XVFEvaIQ+i7es
# DQicWW1dCDA/J3xOoCECV68611jriajfdVg8o0Wp+FCg5CAUtslgOFuiYULgcxnq
# zkmP2i58ZEa0rm4LZymHBzsIMU0yMmuVmAkYxbdEDi5XqlZIupPpqmD6/fLjD4ub
# 0SEEttOpg0np0ra/MNCfv/tVhJtz5wgiEIKX+s4akawLfY+16xDB64Nm0HoGs/Gy
# 823ulIm4GyrUcpNZxnXvE6OZMjI/V1AgSAg8U/heMWuZTWVUMIIHcTCCBVmgAwIB
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
# aGFsZXMgVFNTIEVTTjo4RDQxLTRCRjctQjNCNzElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAPYiXu8ORQ4hvKcuE
# 7GK0COgxWnqggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOncEK8wIhgPMjAyNDA1MDEwODUxNTlaGA8yMDI0MDUw
# MjA4NTE1OVowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA6dwQrwIBADAKAgEAAgIE
# mAIB/zAHAgEAAgISKDAKAgUA6d1iLwIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUA
# A4GBAMEtRk/RBmvvne65FNA2O3BOgqF6YqMyooplPxaiAdcWYGrW2yEMemmIP+YX
# 2m9bRvLuVjHy4UXEBl0qbt+ksDcGC9xux9UyQ2BM/PRA4WrIl9W9Y6tr3GjGUP1Z
# fxAHADMxanlhOIQveCa25UNs94LmJ3JmPJU92xa2DXIVJuvuMYIEDTCCBAkCAQEw
# gZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHj372bmhxogyIA
# AQAAAeMwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0B
# CRABBDAvBgkqhkiG9w0BCQQxIgQgq5W4az784eTsS6eOIZl9aBKfFPykz7gObr4v
# QVY0dT8wgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCAz1COr5bD+ZPdEgQjW
# vcIWuDJcQbdgq8Ndj0xyMuYmKjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwAhMzAAAB49+9m5ocaIMiAAEAAAHjMCIEIIau6o3JaNZaLmseJmzw
# rPhWqrJr8I28GwBOz523iQ9FMA0GCSqGSIb3DQEBCwUABIICALoMFQB+BBz185Gw
# ln1XXc3OvEM386clQjzb/ys99WsLaMGALPJLKVmzkumqiEt+JLZv3dD9FcBriWl2
# 11u91MOhu4UZQHF/3XjyOck/KuiWk9jc6tqipa/Fu7AQZF4z++piAT6C2CNBAMHL
# FZLnDt/3zg6Fluj9lqvWwMdtOkL/Fodfo2V03LykSrHaDK8LtOlgrIFsfS+kRvqA
# HrrCT+I6bjYj+5HnAYrskP9pCrtzDRcCfiiQtdUjxYzN+iJfRSDB6QAq3gPPA/Om
# FG6CHbsmyeOJidBOnzv5TZaH3fiiZkelkHAdesRWp3LpeqUnTiYaTySdboIQVKxl
# ERAjPtpulgguCu4WWp9LtDzFs/5LA81tXYrmU/vvaO8cKilMSjLEm+5ii5HbCzIH
# LhuG62c5tO/V0Jm5FsixDL3zcAGnQ/kju649e2ZCW5XadjnB1Q2VnrBnq4l3613h
# y2IqCHVYDpUZQ2I/Zs4Z57ot0WWhXqTqgOzn6yr6I6Qi7WeNPxWpPR43T67QlSL+
# E6DwRqblnutZymNm3zDM5nlDpVx8MV2k4Nam2SrViQfFpBQtXhGZ5NAOAmNypTbE
# zuBkMln9oFkZoQ21+O8f10Cz21yV0U2urXB+G+iENRSaKAS+JgkEM/MYnCVJhc0Q
# wz6wLuBupvTeiBS4ysJSmMuPEFeW
# SIG # End signature block
