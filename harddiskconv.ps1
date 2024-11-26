Clear-Host

Write-Host @"
  ████████╗██████╗  █████╗  ██████╗██╗  ██╗    ████████╗██╗   ██╗ █████╗ ██╗  ██╗         
  ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝    ╚══██╔══╝██║   ██║██╔══██╗██║  ██║ 
     ██║   ██████╔╝███████║██║     █████╔╝        ██║   ██║   ██║███████║███████║ 
     ██║   ██╔══██╗██╔══██║██║     ██╔═██╗        ██║   ██║   ██║██╔══██║██╔══██║ 
     ██║   ██║  ██║██║  ██║╚██████╗██║  ██╗       ██║   ╚██████╔╝██║  ██║██║  ██║ 
     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝       ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ 
"@ -ForegroundColor Green
Write-Host ""
Write-Host "  HardDiskVolume Converter Made by Track Tuah - " -ForegroundColor Green -NoNewline
Write-Host -ForegroundColor Red "Fuckerleaks Misses You"

Write-Host ""
function Test-Admin {;$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);}
if (!(Test-Admin)) {
    Write-Warning "Please Run This Script as Admin."
    Start-Sleep 10
    Exit
}

$pathsFilePath = "paths.txt"
if(-Not(Test-Path -Path $pathsFilePath)){
    Write-Warning "The file $pathsFilePath does not exist."
    Start-Sleep 10
    Exit
}

Start-Sleep -s 3

Clear-Host

$DynAssembly = New-Object System.Reflection.AssemblyName('SysUtils')
$AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
$ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('SysUtils', $False)

$TypeBuilder = $ModuleBuilder.DefineType('Kernel32', 'Public, Class')
$PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('QueryDosDevice', 'kernel32.dll', ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static), [Reflection.CallingConventions]::Standard, [UInt32], [Type[]]@([String], [Text.StringBuilder], [UInt32]), [Runtime.InteropServices.CallingConvention]::Winapi, [Runtime.InteropServices.CharSet]::Auto)
$DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
$SetLastError = [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
$SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor, @('kernel32.dll'), [Reflection.FieldInfo[]]@($SetLastError), @($true))
$PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
$Kernel32 = $TypeBuilder.CreateType()

$Max = 65536
$StringBuilder = New-Object System.Text.StringBuilder($Max)

$filePath = "paths.txt"
$content = Get-Content $filePath

$driveMappings = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter } | ForEach-Object {
    $ReturnLength = $Kernel32::QueryDosDevice($_.DriveLetter, $StringBuilder, $Max)

    if ($ReturnLength)
    {
        @{
            DriveLetter = $_.DriveLetter
            DevicePath = $StringBuilder.ToString().ToLower()
        }
    }
}

$replacedContent = $content | ForEach-Object {
    $line = $_.ToLower()
    foreach ($driveMapping in $driveMappings){
        $line = $line.Replace($driveMapping.DevicePath, $driveMapping.DriveLetter)
    }
    $line
}

$newfilePath = "newpaths.txt"
$replacedContent | Out-File $newfilePath
