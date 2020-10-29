<!-- #include "./common/header.md" -->

# Remove-VSTeamWorkItemControl

## SYNOPSIS
<!-- #include "./synopsis/Remove-VSTeamWorkItemControl.md" -->

## DESCRIPTION

Removes a control for a data-field from a WorkItem type's page-layout definition; inherited controls cannot be removed (although they can be hidden), and if the control selected is an inherited one the command may respond that there are no WorkItem types suitable for processing. Removing a control from the page does not delete that field as a database column for the WorkItem type. 

## EXAMPLES

### Example 1
```powershell
Remove-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType Epic -Page Details  -Label effort

WARNING: No WorkItem type matching 'Epic' in Scrum5 met the criteria to remove a control.
```

In this example, the command has tried to remove an inherited field but couldn't find a match for WorkItem type of "Epic", an unlocked page Named "Details", and a removable control labeled "effort" in any group. 

### Example 2
```powershell
Remove-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType Epic -Page Details  -Label Office
```

In this example the command has found a custom field by searching in all groups on the "Details" page for Epic WorkItems

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -GroupLabel
Specifies a group to search for the control. The group label can be a wildcard, and if no group is given all groups will be searched to find the control. 

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

### -Label
The display label for the control OR the reference name for the data-field. This can be a wild card, provided that only one control on a page matches the combination of specified group and control label. 

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageLabel
The page to search for the control. If not specified all pages will be searched. 

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

[Add-VSTeamWorkItemControl](Add-VSTeamWorkItemControl.md)

[Set-VSTeamWorkItemControl](Set-VSTeamWorkItemControl.md)

[Remove-VSTeamWorkItemPageGroup](Remove-VSTeamWorkItemPageGroup.md)