Set-StrictMode -Version Latest

Describe 'VSTeamWorkItemPageGroup' {
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
      Mock _callApi { return ([pscustomobject]@{name='Dummy'}) }  -ParameterFilter {$method -in @('patch','put')}
   }

   Context 'Set-VSTeamWorkItemPageGroup' {

      It 'should call Get-WorkitemType, unlock the WIT, and call the Patch Rest API with the right body.' {
         ## Act
         $wipg =Set-VSTeamWorkItemPageGroup -ProcessTemplate Scrum5 -WorkItemType Changereq -PageLabel Customer -GroupLabel 'Customer Information' -Order 1 -NewLabel "Contact information" -Force

         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "Changereq" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq     'Patch' -and
               $url    -like   '*Changereq/layout/pages*' -and
               $url    -like   '*/sections/Section1/Groups*' -and
               $body    -match '"label":\s*"Contact Information"' -and
               $body    -match '"Order":\s*1'
         } -Times 1 -Exactly

         $wipg.count             | should -BeExactly  1
         $wipg.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemPageGroup'
         $wipg.WorkItemType      | should -BeExactly 'ChangeReq'
         $wipg.ProcessTemplate   | should -BeExactly 'Scrum5'
         $wipg.PageLabel         | should -BeExactly 'Customer'
         $wipg.SectionId         | should -beExactly 'Section1'
      }

         It 'should call the PUT Rest API with the right body and options to move a group between pages.' {
         ## Act
         $wipg = Set-VSTeamWorkItemPageGroup -ProcessTemplate Scrum5 -WorkItemType Changereq -PageLabel Customer -GroupLabel 'Customer Information' -Order 0 -NewPage Details -NewSectionID Section3 -Force

         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "Changereq" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq     'PUT' -and
               $url    -like   '*Changereq/layout/pages*' -and
               $url    -like   '*.details/sections/Section3/Groups*' -and
               $url    -like   '*removeFromPageId=*'                 -and
               $url    -like   '*&removefromSectionID=Section1&api-version=*' -and
               $body   -match '"label":\s*"Customer Information"' -and
               $body   -match '"Order":\s*0'
         } -Times 1 -Exactly

         $wipg.count             | should -BeExactly  1
         $wipg.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemPageGroup'
         $wipg.WorkItemType      | should -BeExactly 'ChangeReq'
         $wipg.ProcessTemplate   | should -BeExactly 'Scrum5'
         $wipg.PageLabel         | should -BeExactly 'Details'
         $wipg.SectionId         | should -beExactly 'Section3'
      }
   }
}