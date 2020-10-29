function Set-VSTeamWorkItemPageGroup {
   [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName='LeaveAlone',ConfirmImpact='High')]
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

      [parameter(ValueFromPipelineByPropertyName=$true, Mandatory = $true, Position=1)]
      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [Alias('Name','GroupLabel')]
      [string]$Label,

      [int]$Order,

      [parameter(Mandatory = $true, Position=1,ParameterSetName='Rename')]
      [string]$NewLabel,

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Move')]
      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [string]$NewPage,

      [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Move')]
      [ValidateSet('Section1','Section2','Section3','Section4')]
      $NewSectionID,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one before changing layout.
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
               Where-object {$_.layout.pages.where({
                     $_.label -like $PageLabel -and -not $_.locked -and
                     $_.sections.groups.label -like $Label
               })}| Unlock-VSTeamWorkItemType -Expand layout -force:$Force
      if (-not $wit) {
         Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to update a PageGroup."
         return
      }
      foreach ($w in $wit) {
         $Pages = $w.layout.pages.where({
                  $_.label -like $PageLabel -and -not $_.locked -and
                  $_.sections.groups.label -like $Label})
         if ($NewPage -and $pages.Count -gt 1) {
            $msg =  "'{0}' matched on multiple pages of '{1}' in {2}, can't move multiple groups to one destination. " -f
                       $label, $w.name, $ProcessTemplate
            Write-Error -Activity Set-VSTeamWorkItemPageGroup  -Category InvalidData -Message $msg
            continue
         }
         foreach ($page in $pages) {
            # Label can be a wild card but it can only match once per page.
            $section = $page.sections.where({$_.groups.label -like $Label})
            $group  = $section.groups.where({$_.label -like $Label})
            if ($group.Count -gt 1) {
                  $Msg =  "'$GroupLabel' is not unique on Page '$($page.label)' for WorkItem type '$($w.name)'."
                  Write-Error -Activity Set-VSTeamWorkItemPageGroup  -Category InvalidData -Message $msg
                  continue
            }
            $body = @{id = $group.id}
            if ($NewLabel) {$body['label']   = $NewLabel}
            else           {$body['label']   = $group.label}
            if ($Hide)     {$body['visible'] = $false}
            if ($Show)     {$body['visible'] = $true}
            if ($PSBoundParameters.ContainsKey('Order')) {$body['order']   = $Order}
            if (-not $NewPage -and -not $NewSectionID) {
               if ($force -or $PSCmdlet.ShouldProcess("$($group.label)`" group on page `"$($page.label)", "Modify layout group.")){
                  $url = "{0}/layout/pages/{1}/sections/{2}/Groups/{3}?api-version={4}" -f
                           $w.url, $page.id, $section.id ,$group.id , (_getApiVersion Processes)
                  #Call the REST API
                  try {
                     $resp = _callAPI -Url $url -method PATCH -body (ConvertTo-Json $body)
                  }
                  catch {
                     $msg = "An error ocurred updating '{0}' on page '{1}' of Workitem type {2} in {3}" -f
                              $group.label, $page.label, $w.name, $ProcessTemplate
                     Write-Error -Activity Set-VSTeamWorkItemPageGroup  -Category InvalidResult -Message $msg
                     continue
                  }
                  $destination = $page
                  $NewSectionID = $section.id
               }
            }
            elseif ($NewPage) {
               $destination = $w.layout.pages.where({ $_.label -like $NewPage -and -not $_.locked })
               if (-not $destination)  {
                  $msg =  "WorkItem Type '{0}' in {1} does not have a pagematching '{2}'." -f
                              $w.name, $ProcessTemplate, $NewPage
                  Write-Error -Activity Set-VSTeamWorkItemPageGroup  -Category InvalidData -Message $msg
                  continue
               }
               if (-not $NewSectionID) {$NewSectionID = $section.id}
               if ($force -or $PSCmdlet.ShouldProcess("$($group.label)`" on Page `"$($page.label)", "Move layout group to new page.")) {
                  $url = '{0}/layout/pages/{1}/sections/{2}/groups/{3}?removeFromPageId={4}&removeFromSectionId={5}&api-version={6}' -f
                        $w.url, $destination.id , $NewSectionID, $group.id, $page.id, $Section.ID, (_getApiVersion Processes)
                  #Call the REST API
                  try {
                     $resp = _callAPI -Url $url -method PUT -body (ConvertTo-Json $body)
                  }
                  catch {
                     $msg = "An error ocurred moving '{0}' to page '{1}' of Workitem type {2} in {3}" -f
                              $group.label, $destination.label, $w.name, $ProcessTemplate
                     Write-Error -Activity Set-VSTeamWorkItemPageGroup  -Category InvalidResult -Message $msg
                     continue
                  }
               }
            }
            elseif ($NewSectionID) {
               if ($force -or $PSCmdlet.ShouldProcess("$($group.label)`"on Page `"$($page.label)", "Move layout group to new section.")){
                  $url = '{0}/layout/pages/{1}/sections/{2}/groups/{3}?removeFromSectionId={4}&api-version={5}' -f
                           $w.url, $page.id, $NewSectionID, $group.id,    $section.id, (_getApiVersion Processes)
                  #Call the REST API
                  try {
                     $resp = _callAPI -Url $url -method PUT -body (ConvertTo-Json $body)
                  }
                  catch {
                     $msg = "An error ocurred moving '{0}' to a new section on page '{1}' of Workitem type {2} in {3}" -f
                     $group.label, $page.label, $w.name, $ProcessTemplate
                     Write-Error -Activity Set-VSTeamWorkItemPageGroup  -Category InvalidResult -Message $msg
                     continue
                  }
                  $destination = $page
               }
            }
            if ($resp) {
               # Apply a Type Name so we can use custom format view and custom type extensions
               # and add members to make it easier if piped into something which takes values by property name
               $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemPageGroup')
               Add-Member  -InputObject $resp -MemberType AliasProperty -Name GroupLabel      -Value Label
               Add-Member  -InputObject $resp -MemberType NoteProperty  -Name SectionId       -Value $NewSectionID
               Add-Member  -InputObject $resp -MemberType NoteProperty  -Name PageLabel       -Value $Destination.label
               Add-Member  -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $w.name
               Add-Member  -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -value $w.processTemplate

               return $resp
            }
         }
      }
   }
}
