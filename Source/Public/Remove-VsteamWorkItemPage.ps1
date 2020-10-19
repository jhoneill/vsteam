function Remove-VsteamWorkItemPage {
   [CmdletBinding(SupportsShouldProcess=$true)]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

      [parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, Position=0)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [parameter(Mandatory = $true, Position=1)]
      [Alias('Name','PageLabel')]
      $Label,

      [switch]
      $Force
   )
   process {
      #This is designed to allow multiple pages to be added, and/or multiple WorkItemTypes to be modifed
      if ($Label.count -gt 1 -and ($order -or $Sections)) {throw "Can't process multiple pages when Order and/or sections are specified."  ; return}
         #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one first before adding the page.
         $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType  $WorkItemType
         foreach ($w in $wit) {
            if ($w.customization -eq 'system') {
## throw an error. You can't hide remove system pages
            }
            $url= $w.url + "/layout/pages?api-version=" + (_getApiVersion Processes)
            foreach ($l in $Label) {

##  DELETE https://dev.azure.com/{organization}/_apis/work/processes/{processId}/workItemTypes/{witRefName}/layout/pages/{pageId}?api-version=5.1-preview.1

            }
}   }
}

