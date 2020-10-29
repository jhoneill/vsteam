<!-- #include "./common/header.md" -->

# Remove-VSTeamWorkItemPageGroup

## SYNOPSIS
<!-- #include "./synopsis/Remove-VSTeamWorkItemPageGroup.md" -->

## DESCRIPTION
This command removes custom groups from page layouts of WorkItem types. If the group specified is an inherited group then the command will not attempt to process it, and may respond that there are no Workitem types suitable for processing. If the group contains controls, they will be deleted. 


## EXAMPLES

### Example 1
```powershell
Remove-VSTeamWorkItemPageGroup -ProcessTemplate Scrum4 -WorkItemType Bug -PageLabel * -Label Environment -Force
```

Removes a group named Environment from any page on the Bug WorkItemType in the Scrum4 process template 

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -Label
The name of the group to be removed. This may be a wildcard, but for safety it will only remove one wildcard match on any page. If the same label matches once on each of multiple pages, each one will be removed. 

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name, GroupLabel

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageLabel
The label for the page holding the group. This can be a wildcard, and if the group label is found on more than one page of the same WorkItem type it will be removed from each page. 

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
[Add-VSTeamWorkItemPageGroup](Add-VSTeamWorkItemPageGroup.md)

[Set-VSTeamWorkItemPageGroup](Set-VSTeamWorkItemPageGroup.md)