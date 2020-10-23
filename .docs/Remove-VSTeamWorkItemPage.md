<!-- #include "./common/header.md" -->

# Remove-VSTeamWorkItemPage

## SYNOPSIS
<!-- #include "./synopsis/Remove-VSTeamWorkItemPage.md" -->


## DESCRIPTION
This command removes pages from the layouts of WorkItem types. Built-in (inherited) pages cannot be removed, and if one is specified the command may report that there are are no workitem types suitable to process. Any groups and controls contained on the page will be deleted; to keep groups Set-VSTeamWorkItemPageGroup can be used to move it to a different page before deleting the page it was on.  

## EXAMPLES

### Example 1
```powershell
Remove-VSTeamWorkItemPage -ProcessTemplate scrum5  -WorkItemType Feature -PageLabel Costings
```
Removes the "costings" page from features in the the Scrum5 Process template. This will prompt the user for confirmation


### Example 2
```powershell
 Get-VSTeamProcess scrum? | Remove-VSTeamWorkItemPage -WorkItemType Bug -Label ReportInformation -Force
```

In this example, the Get-VSTeamProcess command gets the processes "Scrum3","Scrum4" and "Scrum5" (but not "Scrum"), and for each one removes page "ReportInformation" from their Bug WorkItem type.



## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -Label
The name of the page to be removed.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Name, PageLabel

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

<!-- #include "./params/processTemplate.md" -->

<!-- #include "./params/workItemType.md" -->

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
