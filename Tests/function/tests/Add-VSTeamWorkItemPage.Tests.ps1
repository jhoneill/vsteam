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
      Mock _callApi { return ([pscustomobject]@{name='Dummy'}) }  -ParameterFilter {$method -eq 'Post'}
   }

   Context 'Add-VSTeamWorkItemPage' {

      It 'should call  Get-WorkitemType, unlock the WIT, and call the POST Rest API with the right body.' {
         ## Act
         $wip = Add-VSTeamWorkItemPage -ProcessTemplate Scrum5 -WorkItemType Bug -label "Test page" -Force
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "bug" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq     'post' -and
               $url    -like   '*bug/layout/pages*' -and
               $body    -match '"label":\s*"Test page"' -and
               $body    -match '"Pagetype":\s*"custom"' -and
               $body    -match '"visible":\s*true'
         } -Times 1 -Exactly
         ## Assert
         $wip.count | should -BeExactly  1
         $wip.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemPage'
         $wip.WorkItemType      | should -BeExactly 'Bug'
         $wip.ProcessTemplate   | should -BeExactly 'Scrum5'
      }
   }
}