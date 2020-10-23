function Remove-VSTeamWorkItemPage {
   [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

      [parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, Position=0)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [Parameter(ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [Alias('Name','PageLabel')]

      $Label,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating.
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
             Where-object {$_.layout.pages.where({$_.label -like $Label -and -not $_.psobject.properties['inherited'] })}
      if (-not $wit) {
         Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to remove a page."
         return
      }

      foreach ($w in $wit) {
         foreach ($page in $w.layout.pages.where({$_.label -like $Label})) {
            $url= $w.url + "/layout/pages/" + $page.id +" ?api-version=" + (_getApiVersion Processes)
            if ($Force -or $PSCmdlet.ShouldProcess("$($page.Label)`" page of WorkItem type `"$($w.name)",'Delete Page')) {
               #Call the REST API
               try {
                  $null = _callAPI -method Delete -Url $url
               }
               catch {
                  $msg = "Failed to remove Page '{0}' from WorkItem type '{1}' in {2}." -f
                                 $page.label, $w.name , $ProcessTemplate
                  Write-error -Activity Remove-VSTeamWorkItemPage  -Category InvalidResult -Message $msg
                  continue
               }
            }
         }
      }
   }
}
