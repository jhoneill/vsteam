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
      Mock _callApi { return ([pscustomobject]@{name='Dummy'}) }  -ParameterFilter {$method -in @('patch','put')}
   }

   Context 'Set-VSTeamWorkItemControl' {

      It 'should call Get-WorkitemType, unlock the WIT, and call the PATCH Rest API with the right body to hide a control.' {
         ## Act
         $wic = Set-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType Bug -PageLabel * -GroupLabel Deployment -Label * -Hide -force
         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "Bug" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq    'patch' -and
               $url    -like "*Bug/layout/groups*" -and $url -like "*Deployment/controls/Deployments*" -and
               $body   -match '"visible":\s*false' -and
               $body   -match '"label":\s*""' -and
               $body   -match '"id":\s*"Deployments"'} -Times 1 -Exactly

         $wic.count             | should -BeExactly  1
         $wic.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemControl'
         $wic.WorkItemType      | should -BeExactly 'Bug'
         $wic.ProcessTemplate   | should -BeExactly 'Scrum5'
         $wic.PageLabel         | should -BeExactly 'Details'
         $wic.SectionID         | should -BeExactly 'Section3'
         $wic.GroupLabel        | should -BeExactly 'Deployment'
      }
      It 'should call Get-WorkitemType, unlock the WIT, and call the PUT Rest API to move a control.' {
         ## Act
         $wic = Set-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType change* -PageLabel Customer -ReferenceName Custom.AccountMgr -NewLabel "Account Manager" -NewGroup Details -force

         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "change*" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq   'put' -and
               $url    -like "*ChangeReq/layout/groups/*"    -and
               $url    -like "*controls/Custom.AccountMgr*"  -and
               $url    -like "*removeFromGroupId*"  -and
               $body   -match '"visible":\s*true' -and
               $body   -match '"label":\s*"Account Manager"' -and
               $body   -match '"id":\s*"Custom.AccountMgr"'} -Times 1 -Exactly

         $wic.count             | should -BeExactly  1
         $wic.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemControl'
         $wic.WorkItemType      | should -BeExactly 'ChangeReq'
         $wic.ProcessTemplate   | should -BeExactly 'Scrum5'
         $wic.PageLabel         | should -BeExactly 'Customer'
         $wic.SectionID         | should -BeExactly 'Section2'
         $wic.GroupLabel        | should -BeExactly 'Details'
      }
   }
}