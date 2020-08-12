Function Invoke-PSGlass {
    #requires -version 2
    param([switch]$Disable)
     
    add-type -namespace Hacks -name Aero -memberdefinition @"
     
       [StructLayout(LayoutKind.Sequential)]
       public struct MARGINS
       {
          public int left;
          public int right;
          public int top;
          public int bottom;
       }
     
       [DllImport("dwmapi.dll", PreserveSig = false)]
       public static extern void DwmExtendFrameIntoClientArea(IntPtr hwnd, ref MARGINS margins);
     
       [DllImport("dwmapi.dll", PreserveSig = false)]
       public static extern bool DwmIsCompositionEnabled();
"@
     
     
    if (([Environment]::OSVersion.Version.Major -gt 5) -and
         [hacks.aero]::DwmIsCompositionEnabled()) {
     
       $hwnd = (get-process -id $pid).mainwindowhandle
     
       $margin = new-object 'hacks.aero+margins'
     
       $host.ui.RawUI.BackgroundColor = "black"
       $host.ui.rawui.foregroundcolor = "white"
     
       if ($Disable) {
     
           $margin.top = 0
           $margin.left = 0
     
     
       } else {
     
           $margin.top = -1
           $margin.left = -1
     
       }
     
       [hacks.aero]::DwmExtendFrameIntoClientArea($hwnd, [ref]$margin)
     
    } else {
     
       write-warning "Aero is either not available or not enabled on this workstation."
     
    }
}


Function Set-AeroGlass {
    <#
        .SYSNOPSIS
            Enables or Disable an Aero Glass effect on the PowerShell console.

        .DESCRIPTION
            Enables or Disable an Aero Glass effect on the PowerShell console.

        .PARAMETER Enable
            Enables the Aero Glass effect on the PowerShell console

        .PARAMETER Disable
            Disables the Aero Glass effect on the PowerShell console

        .NOTES
            Name: Set-AeroGlass
            Author: Boe Prox
            Version History: 
                1.0 -- Boe Prox 19 Sept 2014 
                    - Initial Creation

            View types of font colors with this; not all work well with the Aero Glass effect 
            FOREGROUND
            [System.ConsoleColor]|gm -static -Type Property | ForEach {
                $host.ui.RawUI.ForegroundColor = $_.Name;Write-Host "$($_.Name)"
            }
            $host.ui.rawui.ForegroundColor='White'

            BACKGROUND
            [System.ConsoleColor]|gm -static -Type Property | ForEach {
                $host.ui.rawui.BackgroundColor=$_.Name;Write-Host ("{0}" -f (" " * ($host.ui.rawui.WindowSize.Width-1)))
            }
            $host.ui.rawui.BackgroundColor='DarkMagenta'


        .LINK
            http://learn-powershell.net

        .INPUTS
            None

        .OUPUTS
            None

        .EXAMPLE
            Set-AeroGlass -Enabled

        .EXAMPLE
            Set-AeroGlass -Disabled
    #>
    #requires -version 2
    [cmdletbinding(
        DefaultParameterSetName = 'Enable'
    )]
    param(
        [parameter(ParameterSetName='Enable')]
        [switch]$Enable,        
        [parameter(ParameterSetName='Disable')]
        [switch]$Disable
    )

    #region Module Builder
    $Domain = [AppDomain]::CurrentDomain
    $DynAssembly = New-Object System.Reflection.AssemblyName('AeroAssembly')
    # Only run in memory
    $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run) 
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('AeroModule', $False)
    #endregion Module Builder

    #region STRUCTs

    #region Margins
    $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
    $TypeBuilder = $ModuleBuilder.DefineType('MARGINS', $Attributes, [System.ValueType], 1, 0x10)
    [void]$TypeBuilder.DefineField('left', [Int], 'Public')
    [void]$TypeBuilder.DefineField('right', [Int], 'Public')
    [void]$TypeBuilder.DefineField('top', [Int], 'Public')
    [void]$TypeBuilder.DefineField('bottom', [Int], 'Public')

    #Create STRUCT Type
    [void]$TypeBuilder.CreateType()
    #endregion Margins

    #endregion STRUCTs

    #region DllImport
    $TypeBuilder = $ModuleBuilder.DefineType('Aero', 'Public, Class')
    
    #region DwmExtendFrameIntoClientArea Method
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'DwmExtendFrameIntoClientArea', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [Void], #Method Return Type
        [Type[]] @([IntPtr],[Margins]) #Method Parameters
    )

    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('PreserveSig')
    )

    $FieldValueArray = [Object[]] @(
        'DwmExtendFrameIntoClientArea', #CASE SENSITIVE!!
        $False
    )

    $CustomAttributeBuilder = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('dwmapi.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($CustomAttributeBuilder)
    #endregion DwmExtendFrameIntoClientArea Method

    #region DwmIsCompositionEnabled Method
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'DwmIsCompositionEnabled', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [Bool], #Method Return Type
        $Null #Method Parameters
    )

    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('PreserveSig')
    )

    $FieldValueArray = [Object[]] @(
        'DwmIsCompositionEnabled', #CASE SENSITIVE!!
        $False
    )

    $CustomAttributeBuilder = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('dwmapi.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($CustomAttributeBuilder)
    #endregion DwmIsCompositionEnabled Method

    [void]$TypeBuilder.CreateType()
    #endregion DllImport

    # Desktop Window Manager (DWM) is always enabled in Windows 8
    # Calling DwmIsCompsitionEnabled() only applies if running Vista or Windows 7
    If ([Aero]::DwmIsCompositionEnabled()) {
        $hwnd = (Get-Process -Id $PID).mainwindowhandle
        $margin = New-Object 'MARGINS'
 
        Switch ($PSCmdlet.ParameterSetName) {
            'Enable' {
                # Negative values create the 'glass' effect
                $margin.top = -1
                $margin.left = -1     
                $margin.right = -1    
                $margin.bottom = -1    
                New-Variable -Name PreviousConsole -Value @{
                    BackgroundColor = $host.ui.RawUI.BackgroundColor
                    Foregroundcolor = $host.ui.RawUI.Foregroundcolor
                } -Scope Global
                $host.ui.RawUI.BackgroundColor = "black"
                $host.ui.rawui.Foregroundcolor = "white"   

                Clear-Host
            }
            'Disable' {
                # Revert back to original style
                $margin.top = 0
                $margin.left = 0  
                $margin.right = 0
                $margin.bottom = 0      
                $host.ui.RawUI.BackgroundColor = $PreviousConsole.BackgroundColor
                $host.ui.rawui.Foregroundcolor = $PreviousConsole.Foregroundcolor
                Remove-Variable PreviousConsole -ErrorAction SilentlyContinue -Scope Global
                Clear-Host
            }
        }
        [Aero]::DwmExtendFrameIntoClientArea($hwnd, $margin)
    } Else {
        Write-Warning "Aero is either not available or not enabled on this workstation."
    }
}