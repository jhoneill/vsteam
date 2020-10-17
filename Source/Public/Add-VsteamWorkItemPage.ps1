function Add-VsteamWorkItemPage {
   [CmdletBinding()]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

      [parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, Position=0)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [parameter(Mandatory = $true, Position=1)]
      [Alias('Name','PageLabel')]
      $Label,

      [int]$Order,

      [ValidateSet('custom','attachments','history','links')]
      [String]$PageType = 'custom',

      $Sections
   )
   process {
      #This is designed to allow multiple pages to be added, and/or multiple WorkItemTypes to be modifed
      if ($Label.count -gt 1 -and ($order -or $Sections)) {throw "Can't process multiple pages when Order and/or sections are specified."  ; return}
         #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one first before adding the page.
         $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType  $WorkItemType
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
               $w = _callAPI -Url $url -method Post -body (ConvertTo-Json $body)
            }
            $url= $w.url + "/layout/pages?api-version=" + (_getApiVersion Processes)
            foreach ($l in $Label) {
               $body = @{
                        label        = $l
                        pageType     = $PageType
                        visible      = $true
               }
               if ($PSBoundParameters.ContainsKey('Order'))    {$body['order']=$Order}
               if ($PSBoundParameters.ContainsKey('Sections')) {$body['sections']=$Sections}

               $resp = _callAPI -method Post -Url $url -body (ConvertTo-Json $body)
               $resp.psobject.TypeNames.Insert(0,'vsteam_lib.Workitempage')
               Add-Member -InputObject $resp -MemberType NoteProperty  -Name PageLabel       -Value $l
               Add-Member -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $w.name
               Add-Member -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -Value $ProcessTemplate

               Write-Output $resp
            }
}   }
}

