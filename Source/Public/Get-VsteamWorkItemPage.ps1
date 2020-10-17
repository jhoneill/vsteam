function Get-VsteamWorkItemPage {
   [CmdletBinding()]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROJECT,

      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [Alias('Name')]
      [string]$Label = '*'
   )
   process {
      $wit = (Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout)
      foreach ($w in $wit) {
         foreach ($p in $w.layout.pages.where({$_.label -like $Label})) {
            $p.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemPage')
            $pageUrl = $resp.url + "/layout/pages/" + $p.id
            #add members to make it easier if piped into something which takes values by property name
            Add-Member -InputObject $p -Name PageLabel       -MemberType AliasProperty -Value Label
            Add-Member -InputObject $p -Name ProcessTemplate -MemberType NoteProperty  -Value $ProcessTemplate
            Add-Member -InputObject $p -Name WorkItemType    -MemberType NoteProperty  -Value $w.name
            Add-Member -InputObject $p -Name URL             -MemberType NoteProperty  -Value $pageUrl

            Write-Output $p
         }
      }
   }
}
