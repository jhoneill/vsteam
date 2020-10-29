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

      [Parameter(ValueFromPipelineByPropertyName=$true, Position=1)]
      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [Alias('Name','PageLabel')]
      $Label,

      [Parameter(ParameterSetName='Label',Mandatory=$true)]
      [Parameter(ParameterSetName='Both',Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
      [string]$Newlabel,

      [Parameter(ParameterSetName='Order',Mandatory=$true)]
      [Parameter(ParameterSetName='Both',Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
      [int]$Order,

      [switch]$Force
   )
   process {
      #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one first
      $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout |
             Where-object {$_.layout.pages.where({$_.label -like $Label -and -not $_.locked })}
      if (-not $wit) {
         Write-Warning "No WorkItem type matching '$WorkItemType' in $ProcessTemplate met the criteria to update a page."
         return
      }
      $wit = $wit | Unlock-VsteamWorkItemType -Force:$Force -Expand layout
      foreach ($w in $wit) {
         $url= $w.url + "/layout/pages?api-version=" + (_getApiVersion Processes)
         $page = $w.layout.pages.where({$_.label -like $Label})
         if ($page.count -gt 1) {
            $msg = "'{0}' is not a unique Page for WorkItem type '{1}' in {2}." -f
                     $label,  $w.name, $ProcessTemplate
            Write-Error -Activity Set-VSTeamWorkItemPage  -Category InvalidData -Message $msg
            continue
         }
         $body = @{id = $page.id}
         if ($PSBoundParameters.ContainsKey('Newlabel')) {$body['label']=$Newlabel}
         else {$body['label'] = $page.label}
         if ($PSBoundParameters.ContainsKey('Order'))    {$body['order']=$Order}
         if ($Force -or $PSCmdlet.ShouldProcess("'$($page.Label)' of '$($w.name)'",'Update Page')) {
               #Call the REST API
               try {
                  $resp = _callAPI -method Patch -Url $url -body (ConvertTo-Json $body)
               }
               catch {
                  $msg = "Failed to update '{0}' of WorkItem type '{1}' in {2}." -f
                     $page.label,  $w.name, $ProcessTemplate
                  Write-Error -Activity Set-VSTeamWorkItemPage  -Category InvalidResult -Message $msg
                  continue
               }
               # Apply a Type Name so we can use custom format view and custom type extensions
               # and add members to make it easier if piped into something which takes values by property name
               $resp.psobject.TypeNames.Insert(0,'vsteam_lib.Workitempage')
               Add-Member -InputObject $resp -MemberType AliasProperty -Name PageLabel       -Value 'label'
               Add-Member -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $w.name
               Add-Member -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -value $w.processTemplate

               Write-Output $resp
            }
}   }
}