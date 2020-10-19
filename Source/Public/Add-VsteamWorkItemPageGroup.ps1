function Add-VsteamWorkItemPageGroup {
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
      [string]$PageLabel = 'Details',

      [parameter(Mandatory = $true, Position=1)]
      [Alias('Name','GroupLabel')]
      $Label,

      [Parameter(ValueFromPipelineByPropertyName=$true)]
      [ValidateSet('Section1','Section2','Section3','Section4')]
      $SectionID = 'Section1',

      [int]$Order,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one before changing layout.
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
             Where-object {$_.layout.pages.where({$_.label -like $PageLabel -and -not $_.locked })}
      if (-not $wit) {
         Write-Warning "Could not find an unlocked page matching '$pagelabel' for WorkItemType '$WorkItemType'."
         return
      }
      $wit = $wit | Unlock-VsteamWorkItemType -Force:$Force -Expand layout
      foreach ($w in $wit) {
         foreach ($page in $w.layout.pages.where({$_.label -like $PageLabel -and -not $_.locked})) {
            foreach ($l in $Label) {
               $body = @{
                  label  = $l
                  visible= $true
               }
               if ($Order) {$body['order'] = $Order}

               $url = $w.url + "/layout/pages/" + $page.id + "/sections/$SectionID/Groups?api-version=" + (_getApiVersion Processes)

               if ($force -or $PSCmdlet.ShouldProcess("$($page.label) page " ,"Modify workitem type '$($w.name)' in process template, '$ProcessTemplate' to add group to a page.")){
                  #Call the REST API
                  $resp = _callAPI -Url $url -method Post -body (ConvertTo-Json $body)

                  # Apply a Type Name so we can use custom format view and custom type extensions
                  # and add members to make it easier if piped into something which takes values by property name
                  $resp.psobject.TypeNames.Insert(0,'vsteam_lib.WorkItemPageGroup')
                  Add-Member  -InputObject $resp -MemberType AliasProperty -Name GroupLabel      -Value Label
                  Add-Member  -InputObject $resp -MemberType NoteProperty  -Name PageLabel       -Value $page.label
                  Add-Member  -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $w.name
                  Add-Member  -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -Value $ProcessTemplate

                  Write-Output $resp
               }
            }
         }
      }
   }
}
