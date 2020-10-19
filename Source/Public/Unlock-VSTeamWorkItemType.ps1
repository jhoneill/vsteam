function Unlock-VSTeamWorkItemType {
   [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
   param(
      [Parameter(Position=0,ValueFromPipeline=$true,Mandatory=$true)]
      $WorkItemType,

      [ValidateSet('behaviors','layout','states')]
      [string[]]$Expand,

      [switch]$Force
   )
   process {
      if ($WorkItemType.customization -ne 'system') {
         return $WorkItemType
      }
      else {
         $url  = ($WorkItemType.url -replace '/workItemTypes/.*$', '/workItemTypes?api-version=') +  (_getApiVersion Processes)
         $body = @{
            color        = $WorkItemType.color
            description  = $WorkItemType.description
            icon         = $WorkItemType.icon
            inheritsFrom = $WorkItemType.referenceName
            isDisabled   = $WorkItemType.isDisabled
            name         = $WorkItemType.name
         }
         if ($force -or $PSCmdlet.ShouldProcess($WorkItemType.name,"Update WorkItemType")) {
            $null = _callAPI -Url $url -method Post -body (ConvertTo-Json $body)
            Get-VSTeamWorkItemType -ProcessTemplate $WorkItemType.ProcessTemplate -WorkItemType $WorkItemType.name -Expand:$Expand
         }
      }
   }
}

