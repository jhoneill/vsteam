function Add-VSTeamWorkItemPage {
   [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
   param(
      [parameter(ValueFromPipelineByPropertyName=$true)]
      [vsteam_lib.ProcessTemplateValidateAttribute()]
      [ArgumentCompleter([vsteam_lib.ProcessTemplateCompleter])]
      $ProcessTemplate = $env:TEAM_PROCESS,

      [parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, Position=0)]
      [ArgumentCompleter([vsteam_lib.WorkItemTypeCompleter])]
      $WorkItemType,

      [ArgumentCompleter([vsteam_lib.PageCompleter])]
      [parameter(Mandatory = $true, Position=1)]
      [Alias('Name','PageLabel')]
      $Label,

      [int]$Order,

      [ValidateSet('custom','attachments','history','links')]
      [String]$PageType = 'custom',

      $Sections,

      [switch]$Force
   )
   process {
      #This is designed to allow multiple pages to be added, and/or multiple WorkItemTypes to be modifed
      if ($Label.count -gt 1 -and ($Order -or $Sections)) {throw "Can't process multiple pages when Order and/or sections are specified."  ; return}
         #Get the workitem type(s) we are updating. If we get a system one, make it an inherited one first before adding the page.
         $wit = Get-VSTeamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType  $WorkItemType | Unlock-VSTeamWorkItemType -Force:$Force
         foreach ($w in $wit) {
            $url= $w.url + "/layout/pages?api-version=" + (_getApiVersion Processes)
            foreach ($l in $Label) {
               $body = @{
                  label        = $l
                  pageType     = $PageType
                  visible      = $true
               }
               if ($PSBoundParameters.ContainsKey('Order'))    {$body['order']=$Order}
               if ($PSBoundParameters.ContainsKey('Sections')) {$body['sections']=$Sections}

               if ($Force -or $PSCmdlet.ShouldProcess($w.name,"Modify process template '$ProcessTemplate'. Add page to work item")) {
                  #call the REST API
                  try {
                     $resp = _callAPI -method Post -Url $url -body (ConvertTo-Json $body)
                  }
                  catch {
                     $msg = "'Failed to add page '{0}' to WorkItem type '{1}' in {2}." -f
                           $l, $w.name, $ProcessTemplate
                     Write-Error -Activity Add-VSTeamWorkItemPage  -Category InvalidResult -Message $msg
                     continue
                  }
                  # Apply a Type Name so we can use custom format view and/or custom type extensions
                  # and add members to make it easier if piped into something which takes values by property name
                  $resp.psobject.TypeNames.Insert(0,'vsteam_lib.Workitempage')
                  Add-Member -InputObject $resp -MemberType NoteProperty  -Name PageLabel       -Value $l
                  Add-Member -InputObject $resp -MemberType NoteProperty  -Name WorkItemType    -Value $w.name
                  Add-Member -InputObject $resp -MemberType NoteProperty  -Name ProcessTemplate -Value $ProcessTemplate

                  Write-Output $resp
               }
            }
}   }
}

