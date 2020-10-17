function Add-VsteamWorkItemControl {
   [CmdletBinding(SupportsShouldProcess=$true)]
   param(
      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [ProcessValidateAttribute()]
      [ArgumentCompleter([ProcessTemplateCompleter])]
      $ProcessTemplate,

      [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([WorkItemTypeCompleter])]
      $WorkItemType,

      [ArgumentCompleter([PageCompleter])]
      [string]$PageLabel = 'Details',

      [ArgumentCompleter([PageGroupCompleter])]
      [string]$Group = 'Details',

      [parameter(Mandatory = $true)]
      [ArgumentCompleter([FieldCompleter])]
      [Alias('ID','Name','FieldName')]
      $ReferenceName,

      [string]$Label,


      [switch]$Hidden,

      [switch]$Force
   )
   process {
      if (-not $Label) {$Label = ($ReferenceName -split '\.')[-1] }
      $page    = (Get-VsteamWorkItemPage -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType| Where-Object label -eq $PageLabel)
      if (-not $page)   { Write-Warning "Could not find a page '$PageLabel' for '$WorkItemType' items."; return
      }
      $groupID =  $page.sections.groups.where({$_.label -eq $Group}).id
      if (-not $groupID) {Write-Warning "Could not find a group '$Group' on Page '$PageLabel'."; return}
      if (-not  (Get-VsteamWorkItemField -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType | Where-Object ReferenceName -eq $ReferenceName)) {
         if (Get-VSTeamField | Where-Object referencename -like  $ReferenceName) {
           if (-not (Add-VsteamWorkItemField -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -ReferenceName $ReferenceName)) {
               Write-Warning "Could not add the field '$ReferenceName' to WorkItem type '$WorkItemType'."; return
           }
         }
         else {Write-Warning "Could not find a field with the reference name '$ReferenceName'."; return}
      }
      $url     = ($page.url -replace '/layout/pages.*$','/layout/groups/') + "$groupID/controls?api-version=" + (_getApiVersion Processes)
      $body    = @{id     = $ReferenceName
                  label   = $Label
                  visible = (-not $Hidden)
      }
      if ($PSCmdlet.ShouldProcess($WorkItemType,"Add control '$referencename' to $workItemType")) {
         $resp = _callAPI -Url $url -method Post -body (ConvertTo-Json $body) -ContentType "application/json"
         $resp.psobject.TypeNames.Insert(0,'Team.WorkitemControl')
         Add-Member           -InputObject $resp -MemberType NoteProperty -Name GroupLabel      -Value $Group
         Add-Member           -InputObject $resp -MemberType NoteProperty -Name PageLabel       -Value $PageLabel
         Add-Member           -InputObject $resp -MemberType NoteProperty -Name WorkItemType    -Value $WorkItemType
         Add-Member -PassThru -InputObject $resp -MemberType NoteProperty -Name ProcessTemplate -Value $ProcessTemplate
      }
   }
}
