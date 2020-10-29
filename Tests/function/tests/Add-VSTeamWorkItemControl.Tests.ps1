Set-StrictMode -Version Latest

Describe 'VSTeamWorkItemControl' {
   BeforeAll {
      . "$PSScriptRoot\_testInitialize.ps1" $PSCommandPath
      . "$PSScriptRoot\..\..\..\Source\Public\Get-VSTeamField.ps1"
      . "$PSScriptRoot\..\..\..\Source\Public\Add-VSTeamWorkItemField.ps1"
      . "$PSScriptRoot\..\..\..\Source\Public\Get-VSTeamWorkItemField.ps1"
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


      Mock Get-VSTeamField {
            $fields = @([PSCustomObject]@{Name = "Office";ReferenceName="Custom.Office";Type="String"}
                        [PSCustomObject]@{Name = "Notes"; ReferenceName="Custom.Notes";Type="Html"}
                        [PSCustomObject]@{Name = "Issue";ReferenceName= "Microsoft.VSTS.Common.Issue";Type="String"}
            )
            if ($ReferenceName) {return  $fields.where({$_.ReferenceName -like "*$ReferenceName"})}
            else                {return $fields}
      }
      Mock Get-VSTeamWorkItemField {
         return @([PSCustomObject]@{Name = "Office";ReferenceName="Custom.Office";Type="String"})
      }
      Mock Add-VSTeamWorkItemField { return $true}
      Mock Get-VSTeamWorkItemType  {
         $wits = Open-SampleFile "BugAndChangeReqLayout.json"
            if ($WorkItemType) { return $wits.where( { $_.name -like $WorkItemType }) }
            else               { return $wits }
      }
      Mock Unlock-VSTeamWorkItemType { return $WorkItemType}
      Mock _callApi { return ([pscustomobject]@{name='Dummy'}) }  -ParameterFilter {$method -eq 'Post'}
   }

   Context 'Add-VSTeamWorkItemControl' {


      It 'should call Get-WorkitemType, unlock the WIT, and call the POST Rest API with the right body for the default group.' {
         ## Act
         $wic = Add-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType Bug -ReferenceName office -Force
         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "Bug" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke Add-VSTeamWorkItemField  -Scope It -Times 0 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq    'post' -and
               $url    -like "*Bug/layout/groups*" -and $url -like "*Details/controls*" -and
               $body   -match '"visible":\s*true' -and
               $body   -match '"label":\s*"Office"' -and
               $body   -match '"id":\s*"Custom.Office"'} -Times 1 -Exactly

         $wic.count             | should -BeExactly  1
         $wic.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemControl'
         $wic.WorkItemType      | should -BeExactly 'Bug'
         $wic.ProcessTemplate   | should -BeExactly 'Scrum5'
         $wic.PageLabel         | should -BeExactly 'Details'
         $wic.SectionID         | should -BeExactly 'Section2'
         $wic.GroupLabel        | should -BeExactly 'Details'
      }
      It 'should call Get-WorkitemType, unlock the WIT, add the field and call the POST Rest API with the right body for a text control.' {
         ## Act
         $wic = Add-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType Bug -PageLabel Details -GroupLabel Details -ReferenceName issue -Force
         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "Bug" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke Add-VSTeamWorkItemField  -Scope It -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq    'post' -and
               $url    -like "*Bug/layout/groups*" -and $url -like "*Details/controls*" -and
               $body   -match '"visible":\s*true' -and
               $body   -match '"label":\s*"Issue"' -and
               $body   -match '"id":\s*"Microsoft.VSTS.Common.Issue"'} -Times 1 -Exactly

         $wic.count             | should -BeExactly  1
         $wic.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemControl'
         $wic.WorkItemType      | should -BeExactly 'Bug'
         $wic.ProcessTemplate   | should -BeExactly 'Scrum5'
         $wic.PageLabel         | should -BeExactly 'Details'
         $wic.SectionID         | should -BeExactly 'Section2'
         $wic.GroupLabel        | should -BeExactly 'Details'
      }

      It 'should call Get-WorkitemType, unlock the WIT, add the field and call the POST Rest API with the right body for an HTML control.' {
         ## Act
         $wic = Add-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType Bug -PageLabel Details -GroupLabel Details -ReferenceName Notes -Force
         ## Assert
         Should -Invoke Get-VSTeamWorkItemType -Scope It -ParameterFilter {
            $workitemtype -eq "Bug" -and
            $processTemplate -eq "scrum5"
         } -Times 1 -Exactly
         Should -Invoke unlock-VSTeamWorkItemType -Scope It -Times 1 -Exactly
         Should -Invoke Add-VSTeamWorkItemField  -Scope It -Times 1 -Exactly
         Should -Invoke _callapi -Scope It -parameterFilter {
               $method -eq    'post' -and
               $url    -like "*Bug/layout/pages*" -and $url -like "*Sections/Section1/groups*" -and
               $body   -match '"label":\s*"grp_Notes"' -and
               $body   -match '"controls":\s*\[' -and
               $body   -match '"visible":\s*true' -and
               $body   -match '"label":\s*"Notes"' -and
               $body   -match '"id":\s*"Custom.notes"'} -Times 1 -Exactly

         $wic.count             | should -BeExactly  1
         $wic.psobject.TypeNames| should -contain 'vsteam_lib.WorkItemPageGroup'
         $wic.WorkItemType      | should -BeExactly 'Bug'
         $wic.ProcessTemplate   | should -BeExactly 'Scrum5'
         $wic.PageLabel         | should -BeExactly 'Details'
         $wic.SectionID         | should -BeExactly 'Section1'
      }
   }
}