function Set-VSTeamWorkItemControl {
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

      [parameter(Mandatory = $true)]
      [ArgumentCompleter([vsteam_lib.FieldCompleter])]
      [string]$Label,

      [string]$NewLabel,

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ByGroup')]
      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [string]$GroupLabel,

      [int]$Order,

      [switch]$Hide,

      [switch]$Show,

      [switch]$Force
   )

   process {
      # WorkItem Type could be a wildcard. Find any type(s) which match &
      # have an unlocked layout.page with a matching page label name (also wildcard), and
      # have the right control (by reference name or label).
      # And ensure we can update the Work Item type.
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
               Where-Object {$_.layout.pages.where({
                  $_.label-like $PageLabel -and
                  -not $_.locked -and
                  ($_.sections.groups.controls.label -like $Label -or $_.sections.groups.controls.id -like $Label  )
                })} | Unlock-VSTeamWorkItemType -Expand layout -Force:$Force

      if (-not $wit) {
         Write-Warning "No suitable unlocked page matching '$pagelabel' for customizable WorkItem Type matching '$WorkItemType.'"
         return
      }

      foreach ($w in $wit) {
         #Select Page(s) - match must exsit for w.i.t to get here)
         $pages = $w.layout.pages.where({$_.label -like $PageLabel -and -not $_.locked -and
                  ($_.sections.groups.controls.label -like $Label -or $_.sections.groups.controls.id -like $Label  )})

         foreach ($page in $Pages) {
            $section = $page.sections.where({$_.groups.controls.label -like $Label -or $_.groups.controls.id -like $Label})
            $group  = $section.groups.where({$_.controls.label -like $Label -or $_.controls.id -like $Label})
            $control = $group.controls.where({$_.label -like $Label -or $_.id -like $Label})
            if ($control.count -gt 1) {
               Write-Warning "'$label' is not unique on Page '$($page.label)' for WorkItem type '$($w.name)'."
               continue
            }

            if ($control.controlType -eq "HtmlFieldControl" -and $PSBoundParameters['$GroupLabel']) {
              throw [System.Management.Automation.ValidationMetadataException]::new("To move an HTML field to a new , move its group")
            }

            $body    =  @{  controlType      = $control.ControlType
                            id               = $control.id
                            visible          = $control.visible
                            label            = $control.label
            }
            if ($PSBoundParameters.ContainsKey('Order')) {
                            $body['Order']= $Order
            }
            if ($NewLabel) {$body['label']   = $NewLabel}
            if     ($Hide) {$body['visible'] = $false}
            elseif ($Show) {$body['visible'] = $true}

            if (-not $GroupLabel) {
               $url  = '{0}/layout/groups/{1}/controls/{2}?api-version={3}' -f
               $w.url , $group.ID  , $control.id ,  (_getApiVersion Processes)
               if ($force -or $PSCmdlet.ShouldProcess("$($control.label)`" on page `"$($page.label)","On workitem type $($w.name) modify field.")) {
                  #Call the REST API
                  $resp = _callAPI  -method Patch -Url $url -body (ConvertTo-Json $body)
                  $newGroup = $group
               }
            }
            else {
               $newGroup = $page.sections.groups.where({$_.Label -like $GroupLabel -and $label -ne $group.label})
               if (-not $newGroup) {
                  Write-Warning "Can't find a group matching '$GroupLabel' on Page '$($page.label)' for WorkItem type '$($w.name)'."
                  continue
               }
               elseif ($newGroup.count -gt 1) {
                     Write-Warning "'$GroupLabel' is not unique on Page '$($page.label)' for WorkItem type '$($w.name)'."
                     continue
               }
               else {$section = $page.sections.where({$_.groups.label -eq $newGroup.label})}
               $url  = '{0}/layout/groups/{1}/controls/{2}?removeFromGroupId={3}&api-version={4}' -f
                        $w.url , $newgroup.ID  , $control.id , $group.id,  (_getApiVersion Processes)
               if ($force -or $PSCmdlet.ShouldProcess("$($control.label)`" on page `"$($page.label)","On workitem type $($w.name) change group of field.")) {
                  #Call the REST API
                  $resp = _callAPI  -method PUT -Url $url -body (ConvertTo-Json $body)
               }
            }
            # Apply a Type Name so we can use custom format view and/or custom type extensions
            # and add members to make it easier if piped into something which takes values by property name
            $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemControl')
            Add-Member -InputObject $resp -Name GroupLabel      -MemberType NoteProperty  -Value $newgroup.label
            Add-Member -InputObject $resp -Name SectionID       -MemberType NoteProperty  -Value $section.id
            Add-Member -InputObject $resp -Name ControlLabel    -MemberType AliasProperty -Value Label
            Add-Member    -InputObject $resp -Name PageLabel       -MemberType NoteProperty  -Value $page.label
            Add-Member    -InputObject $resp -Name WorkItemType    -MemberType NoteProperty  -Value $w.name
            Add-Member    -InputObject $resp -Name ProcessTemplate -MemberType NoteProperty  -Value $ProcessTemplate

            return $resp

         }
      }
   }
}
