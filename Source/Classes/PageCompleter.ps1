using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation

class PageCompleter : IArgumentCompleter {
   [IEnumerable[CompletionResult]] CompleteArgument(
      [string] $CommandName,
      [string] $ParameterName,
      [string] $WordToComplete,
      [Language.CommandAst] $CommandAst,
      [IDictionary] $FakeBoundParameters) {

      $results = [List[CompletionResult]]::new()

      $ProcessTemplate, $WorkItemType = $FakeBoundParameters['ProcessTemplate', 'WorkItemType']
      # If the user has not added the -ProcessTemplate and -WorkItemType parameters
      # we will not be able to get the pages and will return  and empty results
      if ($ProcessTemplate -and $WorkItemType) {
         foreach  (    $p in (Get-VsteamWorkItemPage -ProcessTemplate $ProcessTemplate -WorkItemType $WorkItemType ) ) {
            if     ($p.label_ -like "*$WordToComplete*" -and $p.label -notmatch '\W') { $results.Add([CompletionResult]::new(    $p.label))}
            elseif ($p.label_ -like "*$WordToComplete*")                               {$results.Add([CompletionResult]::new("'$($p.label.replace("'","''"))'", $p.label, 0, $p.label))}
         }
      }
      return $results
   }
}
