Set-StrictMode -Version Latest

Describe 'VSTeamWorkItemPage' {
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


      Mock Get-VSTeamWorkItemType   {
         $wits = Open-SampleFile "BugAndChangeReqLayout.json"
            if ($WorkItemType) { return $wits.where( { $_.name -like $WorkItemType }) }
            else               { return $wits }
      }
      Mock Unlock-VSTeamWorkItemType { return $WorkItemType}
      Mock _callApi { return $null }  -ParameterFilter {$method -eq 'Delete'}
   }

   Context 'Remove-VSTeamWorkItemPage' {

      It 'should call Get-WorkitemType with -exapnd, and call the correct Delete REST API' {
         ## Act
         $wip = Remove-VSTeamWorkItemPage -ProcessTemplate Scrum5 -WorkItemType Change* -label "Customer"    -force
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "Change*" -and
            $processTemplate -eq "scrum5" -and
            $expand -eq "layout"
         } -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq     'Delete' -and
               $url    -like   '*changeReq/layout/pages*' -and
               $body    -eq $null
         } -Times 1 -Exactly
         ## Assert
         $wip   | should -BeNullOrEmpty

      }
   }
}