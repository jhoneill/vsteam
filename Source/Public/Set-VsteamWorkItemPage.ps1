function Set-VSTeamWorkItemPage {
   [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

      [parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, Position=0)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [Parameter(ValueFromPipelineByPropertyName=$true)]
      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [Alias('Name','PageLabel')]
      $Label,

      [Parameter(ParameterSetName='Label',Mandatory=$true)]
      [Parameter(ParameterSetName='Both',Mandatory=$true)]
      [string]$Newlabel,

      [Parameter(ParameterSetName='Order',Mandatory=$true)]
      [Parameter(ParameterSetName='Both',Mandatory=$true)]
      [int]$Order,

      $Sections,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one first
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
             Where-object {$_.layout.pages.where({$_.label -like $Label -and -not $_.locked })}
      if (-not $wit) {
         Write-Warning "Could not find an unlocked page matching '$Label' for WorkItemType '$WorkItemType'."
         return
      }
      $wit = $wit | Unlock-VsteamWorkItemType -Force:$Force -Expand layout
      foreach ($w in $wit) {
         $url= $w.url + "/layout/pages?api-version=" + (_getApiVersion Processes)
         $page = $w.layout.pages.where({$_.label -like $Label})
         if ($page.count -gt 1) {
            Write-Warning "'$label' Matches more than one page on $($w.name)."
            continue
         }
         $body = @{id = $page.id}
         if ($PSBoundParameters.ContainsKey('Newlabel')) {$body['label']=$Newlabel}
         else {$body['label'] = $page.label}
         if ($PSBoundParameters.ContainsKey('Order'))    {$body['order']=$Order}
         if ($PSBoundParameters.ContainsKey('Sections')) {$body['sections']=$Sections}
         if ($Force -or $PSCmdlet.ShouldProcess("'$($page.Label)' of '$($w.name)'",'Update Page')) {
               #Call the REST API
               $resp = _callAPI -method Patch -Url $url -body (ConvertTo-Json $body)

               # Apply a Type Name so we can use custom format view and custom type extensions
               # and add members to make it easier if piped into something which takes values by property name
               $resp.psobject.TypeNames.Insert(0,'vsteam_lib.Workitempage')
               Add-Member -InputObject $resp -MemberType AliasProperty -Name PageLabel       -Value 'label'
               Add-Member -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $w.name
               Add-Member -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -Value $ProcessTemplate

               Write-Output $resp
            }
}   }
}