Set-StrictMode -Version Latest

Describe 'VSTeamWorkItemControl' {
   BeforeAll {
      . "$PSScriptRoot\_testInitialize.ps1" $PSCommandPath
      . "$PSScriptRoot\..\..\..\Source\Public\Get-VSTeamWorkItemType.ps1"
      . "$PSScriptRoot\..\..\..\Source\Public\Unlock-VSTeamWorkItemType.ps1"

      ## Arrange
      # Set the account to use for testing.
      # A normal user would do this using the Set-VSTeamAccount function.
      [vsteam_lib.Versions]::Account = 'https://dev.azure.com/test'
      Mock _getApiVersion { return '1.0-unitTests' }

      # Prime the process cache with an empty list,
      # So any name will be validated without calling Get-VSTeamProcess
      [vsteam_lib.ProcessTemplateCache]::Update([string[]]@(), 120)

      Mock Get-VSTeamWorkItemType  {
         $wits = Open-SampleFile "BugAndChangeReqLayout.json"
            if ($WorkItemType) { return $wits.where( { $_.name -like $WorkItemType }) }
            else               { return $wits }
      }
      Mock Unlock-VSTeamWorkItemType { return $WorkItemType}
      Mock _callApi { return $null }  -ParameterFilter {$method -eq 'Delete'}
   }

   Context 'Remove-VSTeamWorkItemControl' {


      It 'should call Get-WorkitemType,  Rest API  to move a control.' {
         ## Act
         Remove-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType change* -PageLabel * -ReferenceName AccountMgr -force

         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "change*" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly

         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq   'Delete' -and
               $url    -like "*ChangeReq/layout/groups/*"    -and
               $url    -like "*controls/Custom.AccountMgr*"
         } -Times 1 -Exactly
      }
   }
}