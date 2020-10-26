function Add-VSTeamWorkItemControl {
   [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName='ByGroup',ConfirmImpact='High')]
   param   (
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

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
      [ValidateSet('Section1','Section2','Section3')]
      $SectionID = 'Section1',

      [int]$Order,

      [switch]$Hide,

      [switch]$Force
   )
   begin   {
         if ($label -and $field.ReferenceName.count -gt 1) {
               throw [System.Management.Automation.ValidationMetadataException]::new("Label cannot be overriden when specifying multiple fields.")
         }
         #Allow for $field.ReferenceName being more than one name, a field object
#to do if everything is referencename has the right type name, don't get
         $fields = Get-VSTeamField -ReferenceName $ReferenceName
         $htmlField = $fields.type -eq "html"
         if ($fields.type -ne "html" -and $htmlField) {
              throw [System.Management.Automation.ValidationMetadataException]::new("Cannot mix HTML fields with field types.")
         }
         elseif ($PSBoundParameters['$GroupLabel'] -and    $htmlField ) {
              throw [System.Management.Automation.ValidationMetadataException]::new("HTML fields are assigned to a section, not a group")
         }
         elseif ($PSBoundParameters['$SectionID'] -and -not $htmlField) {
              throw [System.Management.Automation.ValidationMetadataException]::new("Only HTML fields are assigned to a section, other types are assigned to agroup")
         }
   }
   process {
      # WorkItem Type could be a wildcard. Find any type(s) which match &
      # have an unlocked layout.page with a matching page label name (also wildcard),
      # for non-html control filter to pages with the right group.
      # And ensure we can update the Work Item type.
      $wit = $null
      if ($WorkItemType.psobject.TypeNames.Contains('vsteam_lib.WorkItemType')  ) {
         if ($WorkItemType.count -eq 1 -and $WorkItemType.psobject.Properties['layout']){
            $wit = $WorkItemType
         }
         else {
            $WorkItemType = $workItemType.name
            $ProcessTemplate = $WorkItemType.ProcessTemplate
         }
      }
      if ($PageLabel.psobject.TypeNames.contains('vsteam_lib.WorkItemPage')) {
         $PageLabel = $PageLabel.label
      }
      if ($GroupLabel.psobject.TypeNames.contains('vsteam_lib.WorkItemPageGroup')) {
         $GroupLabel = $GroupLabel.label
      }
      if (-not $wit) {
         $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
               Where-Object {$_.layout.pages.where({$_.label-like $PageLabel -and -not $_.locked })}
      }
      if (-not $htmlfield) {
         #filter to types where the unlocked matching page has the right group name in one of its sections
         $wit = $wit.Where({$_.layout.pages.where({$_.label-like $PageLabel -and -not $_.locked }).sections.groups.label -like $GroupLabel})
         if (-not $wit ) {
            Write-Warning "WorkItem types matching '$WorkItemType' in $ProcessTemplate did not have the required group on a page matching '$PageLabel'."
            return
         }
      }
         $wit = $wit.where({$_.layout.pages.where({
            $_.label-like $PageLabel -and -not $_.locked -and
            $_.sections.groups.label -like $GroupLabel
         })}) | Unlock-VSTeamWorkItemType -Expand layout -force:$Force
      if (-not $wit) {
         Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to add a control."
         return
      }
      foreach ($w in $wit) {
         #We know $w can be modified and has required page (and group if not HTML)
         #Loop through the fields, adding if they're not already there, then through pages.
         $existingFields = $w | Get-VsteamWorkItemField
         foreach ($field in $fields) {
            if (-not ($existingFields.Where({$_.ReferenceName -eq $field.ReferenceName}))) {
               #Evaluate should process otherwise ALL doesn't work when we come back, or for repeat calls.
               if (-not ($Force -or $PSCmdlet.ShouldProcess($Wit.name, "Add field '$($field.name)' to WorkItem type" ))) {
                  continue
               }
               else {
                  try {
                     if (-not ($w | Add-VsteamWorkItemField -ReferenceName   $field.ReferenceName -Force)) {
                        "Could not add the field {0} to WorkItem type '{1}' in Process Template {2}."
                        $field.ReferenceName, $w.name, $ProcessTemplate
                        Write-error -Activity Add-VSTeamWorkItemControl -Category InvalidResult -Message $msg
                        continue
                     }
                  }
                  catch {
                     "An error occured trying to add the field {0} to WorkItem type '{1}' in Process Template {2}."
                        $field.ReferenceName, $w.name, $ProcessTemplate
                     Write-error -Activity Add-VSTeamWorkItemControl -Category InvalidResult -Message $msg
                     continue
                  }
               }
            }

            $pages = $w.layout.pages.where({$_.label -like $PageLabel -and -not $_.locked })
            if (-not $htmlField) {
               $pages = $pages.where({$_.sections.groups.label -like $GroupLabel})
            }
            foreach ($page in $Pages) {
               #build the control JSON (and group JSON for HTML controls) & URL
               if (-not $PSBoundParameters.ContainsKey('Label')) {$Label = $field.Name}
               $control =  @{
                  id       = $field.ReferenceName
                  label    = $Label
                  visible  = -not $Hide
               }
               if ($htmlField ) {
                  $body = @{
                     label    = "grp_$Label"
                     visible  = -not $Hide
                     controls =@($control)
                  }
                  $url = $w.url + "/layout/pages/" + $page.id + "/sections/$SectionID/Groups?api-version=" + (_getApiVersion Processes)
               }
               else  {
                  #Capture the sectionID to add as a property at the end.
                  $section   = $page.sections.where({$_.groups.label -like $GroupLabel})
                  $SectionID = $section.id
                  $group     = $section.groups.where({$_.label -like $GroupLabel})
                  if ($group.Count -gt 1) {
                     $msg = "'{0}' is not a unique group on Page '{1}' for WorkItem type '{2}' in {3}." -f
                              $GroupLabel, $page.label, $w.name, $ProcessTemplate
                     Write-Error -Activity Add-VSTeamWorkItemControl  -Category InvalidData -Message $msg
                     continue
                  }
                  $url     = $w.url + '/layout/groups/' + $group.ID + "/controls?api-version=" + (_getApiVersion Processes)
                  $body    = $control
               }
               # Zero is valid for Order.
               if ($PSBoundParameters.ContainsKey('Order'))  {$body['order'] = $Order}

               if ($force -or $PSCmdlet.ShouldProcess("$($page.label)`" page for WorkItem type`"$($w.name)","Add field `"$($field.Name)")) {
                  #Call the REST API.
                  try {
                     $resp = _callAPI -method Post -Url $url  -body (ConvertTo-Json $body)
                  }
                  catch {
                     #No terminating error to prevent a long list stopping part done.
                     $msg = "An error occured trying to add '{0}' to page '{1}' of workitem type '{2}' in ProcessTemplate {3}. " -f
                              $field.Name, $Page.label, $w.name, $ProcessTemplate
                     Write-Error -Activity Add-VSTeamWorkItemControl  -Category InvalidResult -Message $msg
                     continue
                  }

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
}
