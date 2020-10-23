function Remove-VSTeamWorkItemControl {
   [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName='ByGroup',ConfirmImpact='High')]
   param   (
      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate,

      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [parameter(ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [string]$PageLabel = '*',

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ByGroup')]
      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [string]$GroupLabel = '*',

      [parameter(Mandatory = $true)]
      [ArgumentCompleter([vsteam_lib.FieldCompleter])]
      [alias('ReferenceName')]
      [string]$Label,

      [switch]$Force
   )

   process {
      # WorkItem Type could be a wildcard. Find any type(s) which match &
      # have an unlocked layout.page with a matching page label name (also wildcard), and
      # have the right control (by reference name or label).
      # We can only remove custom fields so don't have to unlock
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
               Where-Object {$_.layout.pages.where({
                  $_.label-like $PageLabel -and
                  -not $_.locked -and
                  $_.sections.groups.where({
                        $_.label -like $GroupLabel -and $_.controls.where({
                           -not $_.psobject.properties['inherited'] -and
                            ($_.label -like $Label -or $_.id -like $Label)
                           })
                  })
                })}

      if (-not $wit) {
         Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to remove a control."
         return
      }

      foreach ($w in $wit) {
         #Select Page(s) - match must exsit for w.i.t to get here)
         $pages = $w.layout.pages.where({
                  $_.label -like $PageLabel -and
                  -not $_.locked -and
                  $_.sections.groups.where({
                       $_.label -like $GroupLabel -and $_.controls.where({
                           -not $_.psobject.properties['inherited'] -and
                            ($_.label -like $Label -or $_.id -like $Label)
                        })
                  })
         })

         foreach ($page in $Pages) {
            $group   = $page.sections.groups.Where({
                  $_.label -like $GroupLabel -and $_.controls.where({
                     -not $_.psobject.properties['inherited'] -and
                     ($_.label -like $Label -or $_.id -like $Label)
                  })
            })
            $control = $group.controls.where({
               -not $_.psobject.properties['inherited'] -and
               ($_.label -like $Label -or $_.id -like $Label)
            })
            if ($control.count -gt 1) {
               $msg = "'{0}' is not a unique control on Page '{1}' for WorkItem type '{2}' in {3}." -f
                      $Label, $page.label, $w.name, $ProcessTemplate
               Write-Error -Activity Add-VSTeamWorkItemControl  -Category InvalidData -Message $msg
               continue
            }

            $url  = '{0}/layout/groups/{1}/controls/{2}?api-version={3}' -f
            $w.url , $group.ID  , $control.id ,  (_getApiVersion Processes)
            if ($force -or $PSCmdlet.ShouldProcess("$($control.label)`" on page `"$($page.label)","On workitem type $($w.name) Delete field.")) {
               #Call the REST API
               try {
                  $null = _callAPI  -method Delete -Url $url
               }
               catch {
                  $msg = "Failed to remove control {0} from Page '{1}' from WorkItem type '{2}' in {3}." -f
                          $control.label, $page.label, $w.name , $ProcessTemplate
                  Write-error -Activity Remove-VSTeamWorkItemControl  -Category InvalidResult -Message $msg
                  continue
               }
            }
         }
      }
   }
}
