function Get-VsteamWorkItemPage {
   [CmdletBinding()]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [Alias('Name','PageLabel')]
      [string]$Label = '*'
   )
   process {
      $wit = (Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout)
      foreach ($w in $wit) {
         foreach ($p in $w.layout.pages.where({$_.label -like $Label})) {
            # Apply Type Names to page and its child items so we can use custom format view and/or custom type extensions
            # and add members to make it easier if piped into something which takes values by property name
            $p.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemPage')
            $pageUrl = $w.url + "/layout/pages/" + $p.id
            Add-Member -InputObject $p -Name PageLabel       -MemberType AliasProperty  -Value Label
            Add-Member -InputObject $p -Name ProcessTemplate -MemberType NoteProperty   -Value $ProcessTemplate
            Add-Member -InputObject $p -Name WorkItemType    -MemberType NoteProperty   -Value $w.name
            Add-Member -InputObject $p -Name Customization   -MemberType NoteProperty   -Value $w.customization
            Add-Member -InputObject $p -Name URL             -MemberType NoteProperty   -Value $pageUrl
            Add-Member -InputObject $p -Name Groups          -MemberType ScriptProperty -Value {$this.sections.groups}
            foreach ($s in $p.sections) {
               foreach ($g in $s.groups)  {
                  $g.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemPageGroup');
                  Add-Member -InputObject $g -Name GroupLabel      -MemberType AliasProperty -Value Label
                  Add-Member -InputObject $g -Name SectionID       -MemberType NoteProperty  -Value $s.id
                  Add-Member -InputObject $g -Name PageLabel       -MemberType NoteProperty  -Value $p.label
                  Add-Member -InputObject $g -Name ProcessTemplate -MemberType NoteProperty  -Value $ProcessTemplate
                  Add-Member -InputObject $g -Name WorkItemType    -MemberType NoteProperty  -Value $w.name
                  foreach ($c in $g.controls)  {
                     $c.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemControl');
                     Add-Member -InputObject $c -Name ControlLabel    -MemberType AliasProperty -Value Label
                     Add-Member -InputObject $c -Name GroupLabel      -MemberType NoteProperty  -Value $g.Label
                     Add-Member -InputObject $c -Name SectionID       -MemberType NoteProperty  -Value $s.id
                     Add-Member -InputObject $c -Name PageLabel       -MemberType NoteProperty  -Value $p.label
                     Add-Member -InputObject $c -Name ProcessTemplate -MemberType NoteProperty  -Value $ProcessTemplate
                     Add-Member -InputObject $c -Name WorkItemType    -MemberType NoteProperty  -Value $w.name
                  }
               }
            }

            Write-Output $p
         }
      }
   }
}
