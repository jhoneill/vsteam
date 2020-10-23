<!-- #include "./common/header.md" -->

# Set-VSTeamWorkItemPageGroup

## SYNOPSIS

<!-- #include "./synopsis/Set-VSTeamWorkItemPageGroup.md" -->

## DESCRIPTION
This command modifies groups on the pages of WorkItem layouts. It allows the groups to be renamed, repositioned within their sections, moved to another section or moved to another page. 

## EXAMPLES

### Example 1
```powershell
 Set-VSTeamWorkItemPageGroup -WorkItemType Task -ProcessTemplate Scrum5 -PageLabel Details -Label Followup-Order 0  -NewLabel "Follow-up" -Force


WorkItemType PageLabel SectionID GroupLabel isContribution Visble Inherited Controls
------------ --------- --------- ---------- -------------- ------ --------- --------
Task         Details   Section1  Follow-up   False          True
```
In the help for Add-VSTeamWorkItemPageGroup a group named "followup" was added to the details page of the Task WorkItem Type in the Scrum5 process template. Because no position was given it was placed as the last group in Section1. This moves it to be the first group in theat section, and inserts a "-" in the label


### Example 2
```powershell
Get-VSTeamProcess scrum? | Get-VSTeamWorkItemPage -Label ReportInformation | Set-VSTeamWorkItemPageGroup -Label Environment  -NewPage details -NewSectionID Section1 -Force


WorkItemType PageLabel SectionID GroupLabel  isContribution Visble Inherited Controls
------------ --------- --------- ----------  -------------- ------ --------- --------
Bug          Details   Section1  Environment False          True
Bug          Details   Section1  Environment False          True
Bug          Details   Section1  Environment False          True
```

In the help for Add-VSTeamWorkItemPageGroup a pipeline was shown finding pages labeled "ReportInformation" in any work item in the scrum templates. Here those items are modified moving them from their current place on the "ReportInformation" to the 

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -Label
The current name of the group. 

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name, GroupLabel

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NewLabel
The new label for the group 

```yaml
Type: String
Parameter Sets: Rename
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewPage
A new page to move the group to. 

```yaml
Type: String
Parameter Sets: Move
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NewSectionID
A new section to move the group to

```yaml
Type: Object
Parameter Sets: Move
Aliases:
Accepted values: Section1, Section2, Section3

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Order
A new position for new group; 0 is before the first existing group, 1 is between the first and second, and so on. If not specified a new group will be added as the last group in its section. 

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageLabel
The page where the group is currently found.

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

[Remove-VSTeamWorkItemPageGroup](Remove-VSTeamWorkItemPageGroup.md)