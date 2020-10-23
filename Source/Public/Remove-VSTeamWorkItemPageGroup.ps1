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

      [Parameter(ValueFromPipelineByPropertyName=$true,  Position=1)]
      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [string]$PageLabel = 'Details',

      [parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, Position=2)]
      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [Alias('Name','GroupLabel')]
      [string]$Label,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating. We can only remove a custom group so we don't need to worry about system w.i.ts
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
             Where-object {$_.layout.pages.where({
                  $_.label -like $PageLabel -and -not $_.locked -and
                  $_.sections.groups.where({$_.label -like $Label -and -not $_.psobject.properties['inherited'] })})}
      if (-not $wit) {
         Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to remove a PageGroup."
         return
      }
      foreach ($w in $wit) {
         foreach ($page in $w.layout.pages.where({
                     $_.label -like $PageLabel -and -not $_.locked -and
                     $_.sections.groups.label -like $Label
                  })){
            $section = $page.sections.where({$_.groups.label -like $Label})
            $group  = $section.groups.where({$_.label -like $Label})
            if ($group.Count -gt 1) {
               $msg = "'{0}' is not a unique group on page '{1}' for WorkItem type '{2}' in {3}." -f
                         $label, $page.label, $w.name, $ProcessTemplate
               Write-Error -Activity Remove-VSTeamWorkItemPageGroup  -Category InvalidData -Message $msg
               continue
            }
            if ($group.psobject.properties['inherited']) {
               $msg = "'{0}' on page '{1}' for WorkItem type '{2}' in {3} is an inherited group and cannot be removed (but may be hidden)." -f
                         $group.label, $page.label, $w.name, $ProcessTemplate
               Write-Error -Activity Remove-VSTeamWorkItemPageGroup  -Category InvalidData -Message $msg
               continue
            }
            $url = '{0}/layout/pages/{1}/sections/{2}/Groups/{3}?api-version={4}' -f
                     $w.url,  $page.id, $section.id, $group.id, (_getApiVersion Processes)
            if ($force -or $PSCmdlet.ShouldProcess("$($group.label)`" group on Page `"$($page.label)" ,"Delete group from layout")){
               #Call the REST API
               try {
                  $null = _callAPI -Url $url -method Delete
               }
               catch {
                  $msg = "'Failed to remove group '{0}' from page '{1}' for WorkItem type '{2}' in {3}." -f
                           $group.label, $page.label, $w.name, $ProcessTemplate
                  Write-Error -Activity Remove-VSTeamWorkItemPageGroup  -Category InvalidResult -Message $msg
                  continue
               }
            }
         }
      }
   }
}
