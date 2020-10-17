using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation

class PageGroupCompleter : IArgumentCompleter {
   [IEnumerable[CompletionResult]] CompleteArgument(
      [string] $CommandName,
      [string] $ParameterName,
      [string] $WordToComplete,
      [Language.CommandAst] $CommandAst,
      [IDictionary] $FakeBoundParameters) {

      $results = [List[CompletionResult]]::new()

      $ProcessTemplate, $WorkItemType, $PageLabel = $FakeBoundParameters['ProcessTemplate', 'WorkItemType','PageLabel']
      # If the user has not added the -ProcessTemplate -WorkItemType and pagelabel parameters
      # we will not be able to get the pages so will return  an empty result list
      if ($ProcessTemplate -and $WorkItemType -and $PageLabel) {
         $layout = (Get-VsteamWorkItemType -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType -Expand layout).layout
         $groups = $layout.pages.where({$_.label -eq $PageLabel}).sections.groups.label | Sort-Object
         foreach  ($g in $groups.where({$_ -like "*$WordToComplete*"}) ) {
            if    ($g -notmatch '\W') { $results.Add([CompletionResult]::new(  $g))}
            else                      { $results.Add([CompletionResult]::new("'$($g.replace("'","''"))'", $g, 0, $g))}
         }
      }

      return $results
   }
}
