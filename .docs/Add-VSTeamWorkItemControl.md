<!-- #include "./common/header.md" -->

# Add-VSTeamWorkItemControl

## SYNOPSIS
<!-- #include "./synopsis/Add-VSTeamWorkItemControl.md" -->


## DESCRIPTION
Each type of WorkItem specifies a multipage layout. Each page contains contain controls for working with the WorkItem's data fields. This command adds those controls which are oganized into groups, and the group are place in 3 sections.   
When adding an HTML field, it's control gets it's own group so a section, not a group, needs to be specified for these controls. 
If a field is specified which is not already part of the WorkItem type, it will be added. 
Note that the built-in Process templates (Scrum, Agile etc.) do not allow their work item types to be customized, this is only allowed for custom processes. 

## EXAMPLES

### Example 1
```powershell
Add-VsteamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType epic -Page Details  -ReferenceName Custom.Office -GroupLabel Details -order 0
Confirm
Are you sure you want to perform this action?
Performing the operation "Add field 'Office' to WorkItem type" on target "Epic".
[Y] Yes [A] Yes to All [N] No [L] No to All [S] Suspend [?] Help (default is "Yes"): 
Confirm
Are you sure you want to perform this action?
Performing the operation "Add field "Office" on target "Details" page of workitem "Epic".
[Y] Yes [A] Yes to All [N] No [L] No to All [S] Suspend [?] Help (default is "Yes"): y

WorkItemType PageLabel SectionID GroupLabel ControlLabel ID            ControlType   isContribution Visble 
------------ --------- --------- ---------- ------------ --            -----------   -------------- ------ 
Epic         Details   Section2  Details    Office       Custom.Office FieldControl   False          True
```

This command adds a single custom field "Office" to the Details group on the Details page for Epic workitems in the Scrum5 template.    
"Details" is the default page name and the default group name, so in the case the values did not need to given explicitly.  
Note that because there are two actions, adding the data-field to the WorkItem type, and then adding the control to the layout, there can be multiple confirmation prompts if -Force is not specified. 

### Example 2
```powershell
 Add-VsteamWorkItemControl -ProcessTemplate Scrum5 -WorkItemType epic  -ReferenceName 
 steps -Force

 WorkItemType PageLabel SectionID GroupLabel isContribution Visble Inherited Controls
------------ --------- --------- ---------- -------------- ------ --------- --------
Epic         Details   Section1  grp_Steps  False          True             Steps

```

In this case -Force has been used to supress the confirmation prompts and no group or section has been specified. Here the field name specified, "Steps", is an HTML fieldm so the command creates and returns a group name grp_Steps containing a control for the Steps field. This group has been placed in the default section, "Section1", of the default page "Details". 

### Example 3
```powershell
 $groups | Add-VSTeamWorkItemControl -Field $fields -force

WorkItemType PageLabel         SectionID GroupLabel  ControlLabel  ID              ControlType   Visble
------------ ---------         --------- ----------  ------------  --              -----------   ------
Bug          ReportInformation Section1  Environment Office        Custom.Office   FieldControl  True   
Bug          ReportInformation Section1  Environment Ready         Custom.Ready    FieldControl  True   
Bug          ReportInformation Section1  Environment Office        Custom.Office   FieldControl  True   
Bug          ReportInformation Section1  Environment Ready         Custom.Ready    FieldControl  True   
Bug          ReportInformation Section1  Environment Office        Custom.Office   FieldControl  True   
Bug          ReportInformation Section1  Environment Ready         Custom.Ready    FieldControl  True   
```

The examples for Add-VSTeamWorkItemPageGroup include a command to createdPageGroups on custom pages in the "Bug" workitem type in three process templates, and left the results in $Groups.     
Here $Groups is piped into Add-VSTeamWorkItemControl, which is passed multiple fields ("Custom.Office", and "Custom.Ready") as a parameter (using the alias "Field") and the -Force switch.    
This adds each of the fields to each of the groups; the six lines above are 3 pairs, one for each of the groups.  
The two steps could have been combined into a single pipeline:     
Get-VSTeamProcess scrum? |     
Add-VSTeamWorkItemPage -WorkItemType Bug -Label ReportInformation -Force |`     
Add-VSTeamWorkItemPageGroup -Label Environment -OutVariable groups -Force |     
Add-VSTeamWorkItemControl -Field $fields -force

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -GroupLabel
The Label of the group to contain non-HTML controls. If no group is specified the command will attempt to use the "Details" group. If a group is specified with HTML controls, the command will report an error. You can specify a wildcard for the group, provided that it only matches one group each selected page. 

```yaml
Type: String
Parameter Sets: ByGroup
Aliases:

Required: False
Position: Named
Default value: Details
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Hide
If specified, the control(s) will be set to not visible. By default newly added controls can be seen. 

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
A display label for the control. If no label is given, the field's name will be used. For example, "Microsoft.VSTS.CodeReview.AcceptedBy" would have get a label of "Accepted By" 

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
For a non HTML control this is the position of the control in its group. HTML controls are have their own groups, and this is position the group in its section. 

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
The page where the control(s) should be placed. If no page is specified the default "Details" page will be used. Wildcards can be used, and multiple pages match the contol(s) will be placed on each one, provided that there are suitable groups to place non-html controls.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Details
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

<!-- #include "./params/processTemplate.md" -->

### -ReferenceName
The reference name(s) of the field(s) to add. The command will attempt to resolve a partial name like "ClosedDate" to its full reference name, like "Microsoft.VSTS.Common.ClosedDate". Values for the field names should tab-complete.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: ID, Name, FieldName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SectionID
The section on the page where HTML controls should be added. If none is specified Section1 is used as a default. If SectionID is specified with non-HTML controls, the command will report an error. 

```yaml
Type: Object
Parameter Sets: BySection
Aliases:
Accepted values: Section1, Section2, Section3, Section4

Required: False
Position: Named
Default value: Section1
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

<!-- #include "./params/workItemType.md" -->

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
