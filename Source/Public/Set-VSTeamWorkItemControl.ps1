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

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ByGroup')]
      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [string]$GroupLabel = '*',

      [parameter(Mandatory = $true)]
      [ArgumentCompleter([vsteam_lib.FieldCompleter])]
      [Alias('ReferenceName')]
      [string]$Label,

      [string]$NewLabel,

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ByGroup')]
      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [string]$NewGroup ,

      [int]$Order,

      [switch]$Hide,

      [switch]$Show,

      [switch]$Force
   )

   process {
      # WorkItem Type could be a wildcard. Find any type(s) which match & have
      # an unlocked layout.page with a matching page label(also wildcard), which has
      # the right group containing  the right control (by reference name or label).
      # Oh, and ensure we can update the WorkItem type.
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
               Where-Object {$_.layout.pages.where({
                  $_.label-like $PageLabel -and -not $_.locked -and
                  $_.sections.groups.where({
                     $_.label -like $GroupLabel -and
                     ($_.controls.label -like $Label -or $_.controls.id -like $Label )
                  })
               })} | Unlock-VSTeamWorkItemType -Expand layout -Force:$Force

      if (-not $wit) {
         Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to update a control."
         return
      }

      foreach ($w in $wit) {
         #Select Page(s) - match(es) must exsit for w.i.t to get here
         $pages = $w.layout.pages.where({
                  $_.label -like $PageLabel -and -not $_.locked -and
                  $_.sections.groups.where({
                     $_.label -like $GroupLabel -and
                     ($_.controls.label -like $Label -or $_.controls.id -like $Label )
                  })
         })
         foreach ($page in $Pages) {
            #Find the section (so we can report it at the end), the group and the one control.
            $section = $page.sections.where({
               $_.groups.label -like $GroupLabel -and
               ($_.groups.controls.label -like $Label -or $_.groups.controls.id -like $Label)
            })
            $group   = $section.groups.where({
               $_.label -like $GroupLabel -and
               ($_.controls.label -like $Label -or $_.controls.id -like $Label)
            })
            $control = $group.controls.where({$_.label -like $Label -or $_.id -like $Label})
            if ($control.count -gt 1) {
               $msg = "'{0}' is not a unique control on Page '{1}' for WorkItem type '{2}' in {3}." -f
                              $label, $page.label, $w.name, $ProcessTemplate
              Write-Error -Activity Set-VSTeamWorkItemControl  -Category InvalidData -Message $msg
               continue
            }
            if ($control.controlType -eq "HtmlFieldControl" -and $PSBoundParameters['NewGroup']) {
            $msg  = "HTML fields cannot be moved between groups. To move '{0}', move the group '{1}' to a new section." -f
                        $control.label, $group.label
              Write-Error -Activity Set-VSTeamWorkItemControl  -Category InvalidData -Message $msg
              Continue
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

            #Call different versions of the REST API depending on whether we are moving the control,
            #make errors non-terminating so a collection of changes doesn't stop with some done and some not.
            if (-not $NewGroup) {
               $url  = '{0}/layout/groups/{1}/controls/{2}?api-version={3}' -f
               $w.url , $group.ID  , $control.id ,  (_getApiVersion Processes)
               if ($force -or $PSCmdlet.ShouldProcess("$($control.label)`" on page `"$($page.label)","On workitem type $($w.name) modify field")) {
                  #Call the REST API
                  try {
                     $resp = _callAPI  -method Patch -Url $url -body (ConvertTo-Json $body)
                  }
                  catch {
                     $msg = "Failed to update '{0}' on Page '{1}' for WorkItem type '{2}' in {3}." -f
                                       $control.Label, $page.label, $w.name , $ProcessTemplate
                     Write-error -Activity Set-VSTeamWorkItemControl  -Category InvalidResult -Message $msg
                     continue
                  }
                  $Destination = $group
               }
            }
            else {
               $Destination = $page.sections.groups.where({$_.Label -like $NewGroup -and $label -ne $group.label})
               if (-not $Destination) {
                  $msg =  "Can't find a group matching '{0}' on Page '{1}' for WorkItem type '{2}' in {3}." -f
                                 $NewGroup, $page.label, $w.name, $ProcessTemplate
                  Write-Error -Activity Set-VSTeamWorkItemControl  -Category InvalidData -Message $msg
                  continue
               }
               elseif ($Destination.count -gt 1) {
                     $msg = "'{0}' is not a unique group on Page '{1}' for WorkItem type '{2}' in {3}." -f
                              $NewGroup, $($page.label), $w.name, $ProcessTemplate
                     Write-Error -Activity Set-VSTeamWorkItemControl  -Category InvalidData -Message $msg
                     continue
               }
               else {$section = $page.sections.where({$_.groups.label -eq $Destination.label})}
               $url  = '{0}/layout/groups/{1}/controls/{2}?removeFromGroupId={3}&api-version={4}' -f
                        $w.url , $Destination.ID  , $control.id , $group.id,  (_getApiVersion Processes)
               if ($force -or $PSCmdlet.ShouldProcess("$($control.label)`" on page `"$($page.label)","On workitem type $($w.name) change group of field.")) {
                  #Call the REST API
                  try {
                     $resp = _callAPI  -method PUT -Url $url -body (ConvertTo-Json $body)
                  }
                  catch{
                     $msg = "Failed to move control '{0}' on Page '{1}' for WorkItem type '{2}' in {3}." -f
                           $control.label, $page.label, $w.name, $ProcessTemplate
                     Write-error -Activity Set-VSTeamWorkItemControl  -Category InvalidResult -Message $msg
                     continue
                  }
               }
            }

            # Apply a Type Name so we can use custom format view and/or custom type extensions
            # and add members to make it easier if piped into something which takes values by property name
            $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemControl')
            Add-Member -InputObject $resp -Name GroupLabel      -MemberType NoteProperty  -Value $Destination.label
            Add-Member -InputObject $resp -Name SectionID       -MemberType NoteProperty  -Value $section.id
            Add-Member -InputObject $resp -Name ControlLabel    -MemberType AliasProperty -Value Label
            Add-Member -InputObject $resp -Name PageLabel       -MemberType NoteProperty  -Value $page.label
            Add-Member -InputObject $resp -Name WorkItemType    -MemberType NoteProperty  -Value $w.name
            Add-Member -InputObject $resp -Name ProcessTemplate -MemberType NoteProperty  -Value $ProcessTemplate

            return $resp

         }
      }
   }
}
