<!-- #include "./common/header.md" -->

# Set-VSTeamWorkItemControl

## SYNOPSIS
<!-- #include "./synopsis/Add-VSTeamWorkItemPageGroup.md" -->

## DESCRIPTION
Each type of WorkItem specifies a layout, containing controls for working with the WorkItem's data-fields. This command modifies those controls. In the web UI editing the control on the page is also linked to modifying the field which underlies it, this command only changes the control. 

## EXAMPLES

### Example 1
```powershell
Set-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType epic -Page Details  -GroupLabel 'Acceptance Criteria' -Label * -Hide -Force

WorkItemType PageLabel SectionID GroupLabel          ControlLabel         ControlType      Visble 
------------ --------- --------- ----------          ------------         -----------       ------ 
Epic         Details   Section1  Acceptance Criteria Acceptance Criteria  HtmlFieldControl False
```

This command hides the built-in HTML Field for "Acceptance Criteria" in the Epic WorkItem type. Because this is an inherited field it can't be removed, but it can be hidden, as an HTML field it is the only field in its group so * can be used for the field label to hide any control in the group. 

### Example 2
```powershell
Set-VSTeamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType epic -Label Microsoft.VSTS.Common.BusinessValue  -NewLabel "Value" -Force

WorkItemType PageLabel SectionID GroupLabel ControlLabel ControlType   Visble
------------ --------- --------- ---------- ------------ -----------    ------
Epic         Details   Section2  Details    Value        FieldControl     True
```

This command renames the built-in HTML field for "Business Value" to "Value" in the Epic WorkItem type. The field only appears in one group so the group label does not need to be provided, and because the Page is not specified the command will look in all groups on all pages to find and rename the control. 

### Example 3
```powershell
Set-VSteamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType epic -Label Custom.Office -NewGroup 'details' -Order 0 -Force

WorkItemType PageLabel SectionID GroupLabel ControlLabel ID            ControlType  ReadOnly isContribution Visble Inherited
------------ --------- --------- ---------- ------------ --            -----------  -------- -------------- ------ ---------
Epic         Details   Section2  Details    Office       Custom.Office FieldControl          False          True
```

This command moves the custom field "Office" from a custom group to the top of the Built-in Details group. Custom controls can be located before, after or between the built-in ones in a built-in group. Built-in controls cannot be moved within a group but attempting to do so does not cause an error. Attempting to move a built-in control between groups creates a copy in the new group, without removing the old one (or reporting an error), and the control needs to be hidden as a separate operation. 

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -GroupLabel
The name of the layout group where the control is currently located. If not specified all groups will be searched to try to find the control, and it will be changed provided that only one matching control is found on the page. 

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

### -Hide
Hides the control. Intended for built-in controls which cannot be moved to different groups or removed from the page.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Label
The current label for the control. The label or field ReferenceName can be specified. The command will tab complete ReferenceNames. 

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

### -NewLabel
A replacement label for the control. 

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Order
Specifies a new position for the control within its group; 0 is before the first control, 1 is between the first and second, and so on. 

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
The page where the control is found. If not specified, all pages will be searched to try to find the group containing the control. 

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

### -Show
Reveals a control which was previously hidden.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

<!-- #include "./params/workItemType.md" -->

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
[Add-VSTeamWorkItemControl](Add-VSTeamWorkItemControl.md)

[Remove-VSTeamWorkItemControl](Remove-VSTeamWorkItemControl.md)

[Set-VSTeamWorkItemPageGroup](Set-VSTeamWorkItemPageGroup.md)