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

#Add-VSTeamWorkItemControl uses process, field , workitem, page, and pagegroup completers
#so it is as good a place as any to test them and their associated transform and validate classes.
Describe 'CompletersTransformersAndValidators' {
   BeforeAll {
      ## Arrange

      . "$PSScriptRoot\_testInitialize.ps1" $PSCommandPath
      . "$PSScriptRoot\..\..\..\Source\Public\Get-VSTeamField.ps1"
      . "$PSScriptRoot\..\..\..\Source\Public\Get-VSTeamWorkItemType.ps1"
      . "$PSScriptRoot\..\..\..\Source\Public\Get-VSTeamProcess.ps1"
      . "$PSScriptRoot\..\..\..\Source\Public\unlock-VSTeamWorkItemType.ps1"


      # Set the account to use for testing.
      # A normal user would do this using the Set-VSTeamAccount function.
      [vsteam_lib.Versions]::Account = 'https://dev.azure.com/test'
      Mock _getApiVersion { return '1.0-unitTests' }

      mock Unlock-VSTeamWorkItemType {return $workitemType}

      Mock Get-VSTeamField {
            $fields = @([PSCustomObject]@{Name = "Office";ReferenceName="Custom.Office";Type="String"}
                        [PSCustomObject]@{Name = "Notes"; ReferenceName="Custom.Notes";Type="Html"}
                        [PSCustomObject]@{Name = "Issue";ReferenceName= "Microsoft.VSTS.Common.Issue";Type="String"}
            )
            if ($ReferenceName) {return  $fields.where({$_.ReferenceName -like "*$ReferenceName"})}
            else                {return $fields}
      }

      Mock Get-VSTeamWorkItemType  {
         $wits = Open-SampleFile "BugAndChangeReqLayout.json"
            if ($WorkItemType) { return $wits.where( { $_.name -like $WorkItemType }) }
            else               { return $wits }
      }

      Mock Get-VSTeamProcess {
         $processes = @(
            [PSCustomObject]@{Name = "Scrum";  url = 'http://bogus.none/1'; ID = "6b724908-ef14-45cf-84f8-768b5384da45" },
            [PSCustomObject]@{Name = "Basic";  url = 'http://bogus.none/2'; ID = "b8a3a935-7e91-48b8-a94c-606d37c3e9f2" },
            [PSCustomObject]@{Name = "CMMI";   url = 'http://bogus.none/3'; ID = "27450541-8e31-4150-9947-dc59f998fc01" },
            [PSCustomObject]@{Name = "Agile";  url = 'http://bogus.none/4'; ID = "adcc42ab-9882-485e-a3ed-7678f01f66bc" },
            [PSCustomObject]@{Name = "Scrum5"; url = 'http://bogus.none/5'; ID = "12345678-0000-0000-0000-000000000000" }
         )
         if ($name) { return $processes.where( { $_.name -like $name }) }
         else       { return $processes }
      }
   }
   context 'color' {
      it 'Provides a set of color names'{
         $cc = [vsteam_lib.ColorCompleter]::new()
         $a = $cc.CompleteArgument('','','',$null,@{})
         $a.count | should -BeGreaterThan 1
      }
      it 'transforms names a  color name to a hex value' {
         $cttha = [vsteam_lib.ColorTransformToHexAttribute]::new()
         $a = $cttha.Transform($null,'Red')
         $a | should -be 'ff0000'
         $a = $cttha.Transform($null,$a)
         $a | should -be 'ff0000'
         $a = $cttha.Transform($null,"#$a")
         $a | should -be 'ff0000'
         $a = $cttha.Transform($null,"notacolor")
         $a | should -be '000000'
      }
   }

   context 'field' {
      beforeall {
         [vsteam_lib.fieldCache]::Invalidate()
         [vsteam_lib.Versions]::Account = 'https://dev.azure.com/test'
      }
      it 'Populates the cache for FieldCompleter operations' {
         $fc = [vsteam_lib.FieldCompleter]::new()
         $a = $fc.CompleteArgument('','','',$null,@{})
         should -Invoke Get-vsteamfield -Scope it -Times 1  -Exactly
         $a.count | should -BeGreaterThan 1
      }
      it 'Uses the cache for repeat FieldCompleter operations' {
         $fc = [vsteam_lib.FieldCompleter]::new()
         $a = $fc.CompleteArgument('','','',$null,@{})
         should -Invoke Get-vsteamfield -Scope it -Times 0 -Exactly
         $a.count | should -BeGreaterThan 1
      }
      it 'Uses the cache for FieldTransformAttribute operations' {
         $fta = [vsteam_lib.FieldTransformAttribute]::new()
         $a = $Fta.Transform($null,"Office")
         should -Invoke Get-vsteamfield -Scope it -Times 0 -Exactly
         $a       | should -beExactly "Custom.Office"
         $b = $fta.Transform($null,@("Office","notes"))
         $b.count | should -beExactly 2
         $b[1]    | should -beExactly "Custom.Notes"
         {$fta.Transform($null,"Absent")}  | should -throw
      }
   }

   context 'Process' {
      BeforeAll {[vsteam_lib.ProcessTemplateCache]::Invalidate()}
      it 'Populates the cache for ProcessTemplateCompleter operations' {
      ##act
         $Ptc = [vsteam_lib.ProcessTemplateCompleter]::new()
         $a   = $ptc.CompleteArgument('','','',$null,@{})
         should -Invoke Get-vsteamProcess -Scope it -Times 1  -Exactly
         $a.count | should -BeGreaterThan 1
      }
      it 'Uses the cache for repeat ProcessTemplateCompleteroperations' {
         $Ptc = [vsteam_lib.ProcessTemplateCompleter]::new()
         $a   = $ptc.CompleteArgument('','','',$null,@{})
         should -Invoke Get-vsteamProcess -Scope it -Times 0  -Exactly
         $a.count | should -BeGreaterThan 1
      }
      it 'Validates ProcessTemplate (or not) as expected using the ProcessTemplate cache' {
         {Add-VSTeamWorkItemControl -ProcessTemplate scrum5 -WorkItemType ant  -ReferenceName office -WhatIf -warningAction silentlyContinue} |  should -not -Throw
         {Add-VSTeamWorkItemControl -ProcessTemplate agile,scrum5 -WorkItemType ant  -ReferenceName office -WhatIf -warningAction silentlyContinue} |  should -not -Throw

         {Add-VSTeamWorkItemControl -ProcessTemplate scrum32768 -WorkItemType bug  -ReferenceName office -WhatIf} |  should  -Throw
         should -Invoke Get-vsteamProcess -Scope it -Times 0  -Exactly
      }
   }
   context 'WorkItemType' {
      BeforeAll {
         # Prime the process cache with an empty list,
         # So any name will be validated without calling Get-VSTeamProcess
         [vsteam_lib.ProcessTemplateCache]::Update([string[]]@(), 120)
         [vsteam_lib.WorkItemTypeCache]::Invalidate()
         $Global:PSDefaultParameterValues["*-vsteam*:projectName"] = 'test'
      }
      it 'Populates the cache for WorkItemTypeCompleter operations' {
            $witc = [vsteam_lib.WorkItemTypeCompleter]::new()
            $a   = $witc.CompleteArgument('','','',$null,@{})
            should -Invoke Get-vsteamWorkItemType -Scope it -Times 1  -Exactly
            $a.count | should -BeGreaterThan 1
      }
      it 'Uses the cache for repeat WorkItemTypeCompleter operations' {
            $witc = [vsteam_lib.WorkItemTypeCompleter]::new()
            $a   = $witc.CompleteArgument('','','',$null,@{})
            should -Invoke Get-vsteamWorkItemType -Scope it -Times 0  -Exactly
            $a.count | should -BeGreaterThan 1
      }

      it "Doesn't use the cache for non-default process templates." {
            $witc = [vsteam_lib.WorkItemTypeCompleter]::new()
            $a   = $witc.CompleteArgument('','','',$null,@{ProcessTemplate='Scrum5'})
            should -Invoke Get-vsteamWorkItemType -Scope it -Times 1  -Exactly
            $a.count | should -BeGreaterThan 1
      }
   }

   context 'WorkItemPage' {
      BeforeAll {
         # Prime the process cache with an empty list,
         # So any name will be validated without calling Get-VSTeamProcess
         [vsteam_lib.ProcessTemplateCache]::Update([string[]]@(), 120)
         $Global:PSDefaultParameterValues["*-vsteam*:projectName"] = 'test'

      }
      it 'Gets WorkItem layout Pages' {
            $pc= [vsteam_lib.PageCompleter]::new()
            $a   = $pc.CompleteArgument('','','',$null,@{ProcessTemplate='Scrum5';WorkItemType='Bug'})
            should -Invoke Get-vsteamWorkItemType -Scope it -Times 1  -Exactly -ParameterFilter {
               $ProcessTemplate -eq 'Scrum5' -and $WorkItemType -eq 'Bug' -and $Expand -eq 'layout'
            }
            $a.count | should -BeGreaterThan 1
            $a.CompletionText | should -contain "details"
      }
   }
      context 'WorkItemPageGroup' {
      BeforeAll {
         # Prime the process cache with an empty list,
         # So any name will be validated without calling Get-VSTeamProcess
         [vsteam_lib.ProcessTemplateCache]::Update([string[]]@(), 120)
         $Global:PSDefaultParameterValues["*-vsteam*:projectName"] = 'test'

      }
      it 'Gets WorkItem layout Page groups' {
            $pgc= [vsteam_lib.PageGroupCompleter]::new()
            $a   = $pgc.CompleteArgument('','','',$null,@{ProcessTemplate='Scrum5';WorkItemType='Bug';pageLabel='Details'})
            should -Invoke Get-vsteamWorkItemType -Scope it -Times 1  -Exactly -ParameterFilter {
               $ProcessTemplate -eq 'Scrum5' -and $WorkItemType -eq 'Bug' -and $Expand -eq 'layout'
            }
            $a.count | should -BeGreaterThan 1
            $a.CompletionText | should -contain "Deployment"
      }
   }

}