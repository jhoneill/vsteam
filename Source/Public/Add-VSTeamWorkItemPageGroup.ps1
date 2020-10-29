function Add-VSTeamWorkItemPageGroup {
   [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
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
      $PageLabel = 'Details',

      [parameter(Mandatory = $true, Position=1)]
      [Alias('Name','GroupLabel')]
      $Label,

      [Parameter(ValueFromPipelineByPropertyName=$true)]
      [ValidateSet('Section1','Section2','Section3')]
      $SectionID = 'Section1',

      [int]$Order,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one before changing layout.
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
      if (-not $wit) {
         $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
             Where-object {$_.layout.pages.where({$_.label -like $PageLabel -and -not $_.locked })}
      }
      $wit = $wit | Unlock-VSTeamWorkItemType -Expand layout -Force:$force

      if (-not $wit) {
          Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to add a PageGroup."
         return
      }
      foreach ($w in $wit) {
         foreach ($page in $w.layout.pages.where({$_.label -like $PageLabel -and -not $_.locked})) {
            foreach ($l in $Label) {
               $body = @{
                  label  = $l
                  visible= $true
               }
               #zero is a valid value for order
               if ($PSBoundParameters.ContainsKey('Order')) {$body['order'] = $Order}
               $url = $w.url + "/layout/pages/" + $page.id + "/sections/$SectionID/Groups?api-version=" + (_getApiVersion Processes)
               if ($force -or $PSCmdlet.ShouldProcess("$($page.label) page of workitem '$($w.name)'" ,"Add a layout group")){
                  #Call the REST API.
                  try {
                     $resp = _callAPI -Url $url -method Post -body (ConvertTo-Json $body)
                  }
                  catch {
                     #Make this a Non-terminating error, so a long list doesn't stop half way.
                     $msg = "An error occured trying to add group '{0}' to page '{1}' of workitem type '{2}' in ProcessTemplate {3}." -f
                                 $l, $Page.label, $w.name, $ProcessTemplate
                     Write-Error -Activity Add-VSTeamWorkItemPageGroup  -Category InvalidResult -Message $msg
                     continue
                  }
                  # Apply a Type Name so we can use custom format view and custom type extensions
                  # and add members to make it easier if piped into something which takes values by property name
                  $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemPageGroup')
                  Add-Member  -InputObject $resp -MemberType AliasProperty -Name GroupLabel      -Value Label
                  Add-Member  -InputObject $resp -MemberType NoteProperty  -Name SectionID       -Value $SectionID
                  Add-Member  -InputObject $resp -MemberType NoteProperty  -Name PageLabel       -Value $page.label
                  Add-Member  -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $w.name
                  Add-Member  -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -value $w.processTemplate

                  Write-Output $resp
               }
            }
         }
      }
   }
}
