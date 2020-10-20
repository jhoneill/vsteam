function Add-VSTeamWorkItemControl {
   [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName='ByGroup')]
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
      [string]$PageLabel = 'Details',

      [parameter(Mandatory = $true)]
      [vsteam_lib.FieldTransformAttribute()]
      [ArgumentCompleter([vsteam_lib.FieldCompleter])]
      [Alias('ID','Name','FieldName')]
      $ReferenceName,

      [string]$Label,

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ByGroup')]
      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [string]$GroupLabel = 'Details',

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='BySection')]
      [ValidateSet('Section1','Section2','Section3','Section4')]
      $SectionID = 'Section1',

      [int]$Order,

      [switch]$Hide,

      [switch]$Force
   )
   begin   {
         if ($label -and $ReferenceName.count -gt 1) {
               throw [System.Management.Automation.ValidationMetadataException]::new("Label cannot be overriden when specifying multiple fields.")
         }

         $field = Get-VSTeamField -ReferenceName $ReferenceName
         if ($field.type -eq "html" -and $field.type -ne "html") {
              throw [System.Management.Automation.ValidationMetadataException]::new("Cannot mix HTML fields with field types.")
         }
         elseif ($field.type -eq "html" -and $PSBoundParameters['$GroupLabel']) {
              throw [System.Management.Automation.ValidationMetadataException]::new("HTML fields are assigned to a section, not a group")
         }
         elseif ($field.type -ne "html" -and $PSBoundParameters['$SectionID']) {
              throw [System.Management.Automation.ValidationMetadataException]::new("Only HTML fields are assigned to a section, other types are assigned to agroup")
         }
         else {$htmlField = $field.type -eq "html" }
   }
   process {
      # WorkItem Type could be a wildcard. Find any type(s) which match &
      # have an unlocked layout.page with a matching page label name (also wildcard),
      # for non-html control filter to pages with the right group.
      # And ensure we can update the Work Item type.
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
               Where-Object {$_.layout.pages.where({$_.label-like $PageLabel -and -not $_.locked })}
      if (-not $htmlfield) {
         $wit = $wit.Where({$_.layout.pages.sections.groups.label -like $GroupLabel})
         if (-not $wit ) {
            Write-Warning "Could not find a group matching '$GroupLabel.'"
            return
         }
      }
      $wit = $wit | Unlock-VSTeamWorkItemType -Expand layout -force:$Force
      if (-not $wit) {
         Write-Warning "No suitable unlocked page matching '$pagelabel' for customizable WorkItem Type matching '$WorkItemType.'"
         return
      }

      foreach ($w in $wit) {
         #If the Field isn't already part of the WorkItem Type try to add it.
         if (      -not ($w | Get-VsteamWorkItemField | Where-Object ReferenceName -eq $ReferenceName)) {
               if (-not ($w | Add-VsteamWorkItemField  -ReferenceName $ReferenceName -Force:$Force)) {
                  Write-Warning "Could not add the field '$ReferenceName' to WorkItem type '$($p.WorkItemType)'."
                  continue
               }
         }
         #Select Page(s) - match must exsit for w.i.t to get here)
         $pages = $w.layout.pages.where({$_.label -like $PageLabel -and -not $_.locked })
         if (-not $htmlField) {
            $pages = $pages.where({$_.sections.groups.label -like $GroupLabel})
         }

         foreach ($page in $Pages) {
            if (-not $Label) {
               $Label = ($ReferenceName -split '\.')[-1]
            }
            $control =  @{
                  id       = $ReferenceName
                  label    = $Label
                  visible  = -not $Hide
            }
            if ($htmlField ) {
               $body = @{
                  label    = $Label
                  visible  = -not $Hide
                  controls = $control
               }
               $url = $w.url + "/layout/pages/" + $page.id + "/sections/$SectionID/Groups?api-version=" + (_getApiVersion Processes)
            }
            else  {
               #Capture the sectionID to add as a property at the end.
               $section = $page.sections.where({$_.groups.label -like $GroupLabel})
               $SectionID = $section.id
               $group  = $section.groups.where({$_.label -like $GroupLabel})
               if ($group.Count -gt 1) {
                  Write-Warning "'$GroupLabel' is not unique on Page '$($page.label)' for WorkItem type '$($w.name)'."
                  continue
               }
               $url     = $w.url + '/layout/groups/' + $group.ID + "/controls?api-version=" + (_getApiVersion Processes)
               $body    = $control
            }
            # Zero appears to be valid for Order.
            if ($PSBoundParameters.ContainsKey('Order'))  {$body['order'] = $Order}
            if ($force -or $PSCmdlet.ShouldProcess("Page '$($page.label)', group '$($group.label)'","On workitem type $($w.name) add control '$referencename' to page group")) {
               #Call the REST API
               $resp = _callAPI -method Post -Url $url  -body (ConvertTo-Json $body)

               # Apply a Type Name so we can use custom format view and/or custom type extensions
               # and add members to make it easier if piped into something which takes values by property name
              if ($htmlField) {
                  $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemPageGroup')
                  Add-Member -InputObject $resp  -Name GroupLabel    -MemberType AliasProperty -Value Label
                  Add-Member -InputObject $resp  -Name SectionID     -MemberType NoteProperty -Value $SectionID
               }
               else {
                  $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemControl')
                  Add-Member -InputObject $resp -Name GroupLabel      -MemberType NoteProperty  -Value $group.label
                  Add-Member -InputObject $resp -Name SectionID       -MemberType NoteProperty  -Value $section.id
                  Add-Member -InputObject $resp -Name ControlLabel    -MemberType AliasProperty -Value Label
               }
               Add-Member    -InputObject $resp -Name PageLabel       -MemberType NoteProperty  -Value $page.label
               Add-Member    -InputObject $resp -Name WorkItemType    -MemberType NoteProperty  -Value $w.name
               Add-Member    -InputObject $resp -Name ProcessTemplate -MemberType NoteProperty  -Value $ProcessTemplate

               Write-Output $resp
            }
         }
      }
   }
}
