function Hide-VsteamWorkItemPageGroup {
   [CmdletBinding()]
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
      $SectionID = 'Section1'
   )
   process {
      #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one before changing layout.
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType
      foreach ($w in $wit) {
         if ($w.customization -eq 'system') {
            $url  = ($w.url -replace '/workItemTypes/.*$', '/workItemTypes?api-version=') +  (_getApiVersion Processes)
            $body = @{
               color        = $w.color
               description  = $w.description
               icon         = $w.icon
               inheritsFrom = $w.referenceName
               isDisabled   = $w.isDisabled
               name         = $w.name
            }
            $w    = _callAPI -method Post -Url $url -body (ConvertTo-Json $body)
         }
         foreach ($l in $Label) {
            $page = Get-VsteamWorkItemPage -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Label $PageLabel
            $url  = $page.url + "/sections/$SectionID/Groups?api-version=" + (_getApiVersion Processes)
            $body = @{label=$l; visible=$true}
            $resp = _callAPI -Url $url -method Post -body (ConvertTo-Json $body)
            $resp.psobject.TypeNames.Insert(0,'Team.WorkitemPageGroup')
            Add-Member  -InputObject $resp -MemberType AliasProperty -Name GroupLabel      -Value Label
            Add-Member  -InputObject $resp -MemberType NoteProperty  -Name PageLabel       -Value $PageLabel
            Add-Member  -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $WorkItemType
            Add-Member  -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -Value $ProcessTemplate

            Write-Output $resp
         }
      }
   }
}
