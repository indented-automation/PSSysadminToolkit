#Requires -RunAsAdministrator
Function Remove-UserProfile{
    <#
        .SYNOPSIS
        Removes specified user profiles from a local or remote machine using CIM
        
        .PARAMETER Profile
        The name of the profile(s) you wish to remove from the computer(s)
        
        .PARAMETER Computername
        The computer(s) you wish to remove profiles from; by default, it will remove profiles from the local computer
        
        .EXAMPLE
        PS C:\Remove-UserProfile -Profile demouser1
        
        .EXAMPLE
        PS C:\Remove-UserProfile -Profile demouser1,demouser2
        
        .EXAMPLE
        PS C:\Remove-UserProfile -Computername wrkstn01 -Profile demouser1

        .EXAMPLE
        PS C:\Remove-UserProfile -Computername wrkstn01,wrkstn02 -Profile demouser1
    #>
    [cmdletBinding(SupportsShouldProcess)]
    Param(
         [parameter(Mandatory, Position = 0)]
         [Alias('SAMAccountName')]
         [string[]]$UserName,
 
         [parameter(Position = 1)]
         [string[]]$Computername = $env:COMPUTERNAME,

         [parameter(Position = 2)]
         [switch]$UseDCOM
    )
     
    Begin {
        if ($UseDCOM) {
            $CIMSessionOption = New-CimSessionOption -Protocol Dcom 
        }
        else {
            $CIMSessionOption = New-CimSessionOption -Protocol Wsman
        }
    }
 
    Process {
        Foreach($computer in $Computername)  {
            Foreach($User in $UserName) {
                Try {
                    if ($PSCmdlet.ShouldProcess(('Remove profile {0} from {1}' -f $user, $computer), '', '')) {
                        $SessionSplat = @{
                            ComputerName    = $computer
                            ClassName       = 'win32_userprofile'
                            Filter          = 'localpath LIKE "%\\{0}"' -f $UserName
                            ErrorAction     = 'Stop'
                            SessionOption   = $CIMSessionOption
                        }
                        Get-CimInstance @SessionSplat | 
                        Remove-CimInstance -ErrorAction Stop
                    }
                }
                Catch {
                    return $_.Exception.Message
                }     
            }   
        }
    }
    End {}
 }
