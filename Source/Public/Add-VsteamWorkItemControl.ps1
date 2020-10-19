function Add-VsteamWorkItemControl {
   [CmdletBinding(SupportsShouldProcess=$true)]
   param   (
      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate,

      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [string]$PageLabel = 'Details',

      [ArgumentCompleter([vsteam_lib.PageGroupCompleter])]
      [string]$GroupLabel = 'Details',

      [parameter(Mandatory = $true)]
      [ArgumentCompleter([vsteam_lib.FieldCompleter])]

      [Alias('ID','Name','FieldName')]
      $ReferenceName,

      [string]$Label,

      [switch]$Hidden,

      [switch]$Force
   )
   begin   {
         if ($label -and $ReferenceName.count -gt 1) {
               throw [System.Management.Automation.ValidationMetadataException]::new("Label cannot be overriden when specifying multiple fields.")
         }
         elseif (-not $Label) {
            $Label = ($ReferenceName -split '\.')[-1]
         }
   }
   process {
      # WorkItem Type could be a wildcard. Find any type(s) which match &
      # have a layout.page with a matching page label name (also wildcard),
      # which isn't locked, and has a section.group with matching group label
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
               Where-Object {$_.layout.pages.where({
                     $_.label                 -like $PageLabel  -and
                     $_.sections.groups.label -like $GroupLabel -and
                     -not $_.locked
               })}
      if (-not $wit) {
         Write-Warning "Could not find an unlocked page matching '$pagelabel' with a group matching '$GroupLabel', for WorkItemType '$WorkItemType.'"
         return
      }

      foreach ($w in $wit) {
         # if the WorkItem type is a system one, Call the  REST API to make an inherited one from it.
         if ($w.customization -eq 'system') {
            $url  = ($w.url -replace '/workItemTypes/.*$', '/workItemTypes?api-version=') + (_getApiVersion Processes)
            $body = @{
               color        = $w.color
               description  = $w.description
               icon         = $w.icon
               inheritsFrom = $w.referenceName
               isDisabled   = $w.isDisabled
               name         = $w.name
            }
            if ($force -or $PSCmdlet.ShouldProcess($w.name,"Update WorkItemType")) {
               $null  = _callAPI -method Post -Url $url -body (ConvertTo-Json $body)
               $w     = Get-VSTeamWorkItemType -ProcessTemplate $w.ProcessTemplate -WorkItemType $w.name -Expand layout
            }
            # if ShouldPprocess said no, or the update failed, go to the next wit - if there is one
            if ($w.customization -eq 'system') {
               Write-Warning "Cannot process system WorkItem Type '$($w.name)'"
               continue
            }
         }

         #If the Field isn't already part of the WorkItem Type try to add it.
         if (      -not ($w | Get-VsteamWorkItemField | Where-Object ReferenceName -eq $ReferenceName)) {
               if (-not ($w | Add-VsteamWorkItemField  -ReferenceName $ReferenceName -Force:$Force)) {
                  Write-Warning "Could not add the field '$ReferenceName' to WorkItem type '$($p.WorkItemType)'."
                  continue
               }
         }

         #Find the page(s), containing a matching group, must exsit for w.i.t to get here)
         $pages = $w.layout.pages.where({
                     $_.label                 -like $PageLabel -and
                     $_.sections.groups.label -like $GroupLabel  -and
                     -not $_.locked
         })
         foreach ($page in $Pages) {
            #Capture the section to add as a property at the end.
            $section = $page.sections.where({$_.groups.label -like $GroupLabel})
            $group  = $Section.groups.where({$_.label -like $GroupLabel})
            if ($group.Count -gt 1) {
               Write-Warning "'$GroupLabel' is not unique on Page '$($page.label)' for WorkItem type '$($w.name)'."
               continue
            }

            $url     = ($page.url -replace '/layout/pages.*$','/layout/groups/') + $group.ID + "/controls?api-version=" + (_getApiVersion Processes)
            $body    = @{
               id      = $ReferenceName
               label   = $Label
               visible = (-not $Hidden)
            }
            if ($force -or $PSCmdlet.ShouldProcess("Page '$($page.label)', group '$($group.label)'","On workitem type $($p) add control '$referencename' to page group")) {
               #Call the REST API
               $resp = _callAPI -Url $url -method Post -body (ConvertTo-Json $body) -ContentType "application/json"

               # Apply a Type Name so we can use custom format view and/or custom type extensions
               # and add members to make it easier if piped into something which takes values by property name
               $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemControl')
               Add-Member -InputObject $resp -Name ControlLabel    -MemberType AliasProperty -Value Label
               Add-Member -InputObject $resp -Name GroupLabel      -MemberType NoteProperty  -Value $group.label
               Add-Member -InputObject $resp -Name SectionID       -MemberType NoteProperty  -Value $section.id
               Add-Member -InputObject $resp -Name PageLabel       -MemberType NoteProperty  -Value $p.label
               Add-Member -InputObject $resp -Name WorkItemType    -MemberType NoteProperty  -Value $w.name
               Add-Member -InputObject $resp -Name ProcessTemplate -MemberType NoteProperty  -Value $ProcessTemplate

               Write-Output $resp
            }
         }
      }
   }
}
