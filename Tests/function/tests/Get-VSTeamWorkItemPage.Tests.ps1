Set-StrictMode -Version Latest

Describe 'VSTeamWorkItemPage' {
   BeforeAll {
      . "$PSScriptRoot\_testInitialize.ps1" $PSCommandPath
      . "$PSScriptRoot\..\..\..\Source\Public\Get-VSTeamWorkItemType.ps1"

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
     # Mock _callApi { return ([pscustomobject]@{Value=@([pscustomobject]@{name='History'},[pscustomobject]@{name='State'})})}
   }

   Context 'Get-VSTeamWorkItemPage' {

      It 'should call Get-WorkitemType with -exapnd, remove locked pages and add the correct properties to returned objects' {
         ## Act
        $wip = Get-VSTeamWorkItemPage -WorkItemType bug -ProcessTemplate Scrum5
         Should -Invoke Get-VSTeamWorkItemType -Exactly -Scope It -Times 1 -ParameterFilter {
            $workitemtype -eq "bug" -and
            $processTemplate -eq "scrum5" -and
            $expand -eq "layout"
         }
         ## Assert
         $wip.count | should -BeExactly  1
         $wip.WorkItemType       | should -BeExactly 'Bug'
         $wip.ProcessTemplate    | should -BeExactly 'Scrum5'
         $wip.PageLabel          | should -BeExactly $wip.label
         $wip.psobject.TypeNames | should -contain   'vsteam_lib.WorkItemPage'
         $wip.groups[0].ProcessTemplate    | should -BeExactly 'Scrum5'
         $wip.groups[0].WorkItemType       | should -BeExactly 'Bug'
         $wip.groups[0].PageLabel          | should -BeExactly $wip.label
         $wip.groups[0].GroupLabel         | should -BeExactly $wip.groups[0].Label
         $wip.groups[0].psobject.typenames | should -contain   'vsteam_lib.WorkItemPageGroup'
         $wip.groups[0].controls[0].ProcessTemplate    | should -BeExactly 'Scrum5'
         $wip.groups[0].controls[0].WorkItemType       | should -BeExactly 'Bug'
         $wip.groups[0].controls[0].PageLabel          | should -BeExactly $wip.label
         $wip.groups[0].controls[0].GroupLabel         | should -BeExactly $wip.groups[0].label
         $wip.groups[0].controls[0].GroupLabel         | should -BeExactly $wip.groups[0].Label
         $wip.groups[0].controls[0].ControlLabel       | should -BeExactly $wip.groups[0].controls[0].Label
         $wip.groups[0].controls[0].psobject.typenames | should -contain 'vsteam_lib.WorkItemControl'

      }
      It 'should call the Get-WorkitemType with -exapnd, remove locked pages and add the correct properties to returned objects' {
         ## Act
        $wip = Get-VSTeamWorkItemPage -WorkItemType bug -ProcessTemplate Scrum5 -IncludeLocked
         Should -Invoke Get-VSTeamWorkItemType -Exactly -Scope It -Times 1 -ParameterFilter {
            $workitemtype -eq "bug" -and
            $processTemplate -eq "scrum5" -and
            $expand -eq "layout"
         }
         ## Assert
         $wip.count | should -BeGreaterThan  1
         $wip[-1].psobject.TypeNames| should -contain 'vsteam_lib.WorkItemPage'
         $wip[-1].WorkItemType      | should -BeExactly 'Bug'
         $wip[-1].ProcessTemplate   | should -BeExactly 'Scrum5'
      }



   }
}