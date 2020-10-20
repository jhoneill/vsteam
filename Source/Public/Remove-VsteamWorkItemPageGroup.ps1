function Remove-VSTeamWorkItemPageGroup {
   [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true , Position=0)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [Parameter(ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [string]$PageLabel = 'Details',

      [parameter(Mandatory = $true, Position=1)]
      [Alias('Name','GroupLabel')]
      [string]$Label,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating. We can only remove a custom group so we don't need to worry about system w.i.ts
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
             Where-object {$_.layout.pages.where({
                  $_.label -like $PageLabel -and -not $_.locked -and
                  $_.sections.groups.label -like $Label})}
      if (-not $wit) {
         Write-Warning "Could not find an unlocked page matching '$pagelabel' with group matching '$Label' for WorkItemType '$WorkItemType'."
         return
      }
      foreach ($w in $wit) {
         foreach ($page in $w.layout.pages.where({
            $_.label -like $PageLabel -and -not $_.locked -and
            $_.sections.groups.label -like $Label}))
         {
            $section = $page.sections.where({$_.groups.label -like $Label})
            $group  = $section.groups.where({$_.label -like $Label})
            if ($group.Count -gt 1) {
               Write-Warning "'$Label' is not unique on Page '$($page.label)' for WorkItem type '$($w.name)'."
               continue
            }
            if ($group.psobject.properties['inherited']) {
               Write-Warning "'$($group.name)' is inherited and cannot be removed (but may be hidden)."
               continue
            }
            $url = '{0}/layout/pages/{1}/sections/{2}/Groups/{3}?api-version={4}' -f
                     $w.url,  $page.id, $section.id, $group.id, (_getApiVersion Processes)
            if ($force -or $PSCmdlet.ShouldProcess("$($group.label)`" group on Page `"$($page.label)" ,"Delete group from layout")){
               #Call the REST API
               $null = _callAPI -Url $url -method Delete
            }
         }
      }
   }
}
