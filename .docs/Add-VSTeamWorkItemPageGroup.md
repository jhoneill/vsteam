<!-- #include "./common/header.md" -->

# Add-VSTeamWorkItemPageGroup

## SYNOPSIS

<!-- #include "./synopsis/Add-VSTeamWorkItemPageGroup.md" -->

## DESCRIPTION
Each type of WorkItem specifies a multipage layout. Each page is divided into sections, a wide one on the left, and two narrower ones at the center and right of the screen. These sections may be empty or may contain groups which organize the controls which are used to interact with WorkItem's data-fields.
This command adds Groups. Note that the built-in Process templates (Scrum, Agile etc.) do not allow their work item types to be customized, this is only allowed for custom processes. After groups have been added controls can be placed in them.

## EXAMPLES

### Example 1
```powershell
Add-VSTeamWorkItemPageGroup -WorkItemType Task -PageLabel Details -Label Followup

Confirm
Are you sure you want to perform this action?
Performing the operation "Update WorkItemType" on target "Task".
[Y] Yes [A] Yes to All [N] No [L] No to All [S] Suspend [?] Help (default is "Yes"): y
WARNING: An error occurred: Response status code does not indicate success: 403 (Forbidden).
WARNING: VS402356: You do not have the permissions required to perform the attempted operation on this process.
```

The user was prompted for confirmation, because the -Force switch was not used, and an error occured because the current project is using one of the built-in process templates which cannnot be modified.

### Example 2
```powershell
Add-VSTeamWorkItemPageGroup -WorkItemType Task -ProcessTemplate Scrum5 -PageLabel Details -Label Followup -Force


WorkItemType PageLabel SectionID GroupLabel isContribution Visble Inherited Controls
------------ --------- --------- ---------- -------------- ------ --------- --------
Task         Details   Section1  Followup   False          True
```
This time the command has been run with the -Force switch to remove the need for confirmation, and has specified a template where modifications are allowed.

### Example 3
```powershell
Get-VSTeamProcess scrum? | Add-VSTeamWorkItemPage -WorkItemType Bug -Label ReportInformation -Force | Add-VSTeamWorkItemPageGroup -Label Environment -OutVariable groups -force

WorkItemType PageLabel         SectionID GroupLabel  isContribution Visble Inherited Controls
------------ ---------         --------- ----------  -------------- ------ --------- --------
Bug          ReportInformation Section1  Environment False          True
Bug          ReportInformation Section1  Environment False          True
Bug          ReportInformation Section1  Environment False          True
```

This shows items being piped into the command, and uses an example from the Add-VSTeamWorkItemPage help.    
First Get-VSTeamProcess finds the processes which match Scrum? ("Scrum3","Scrum4", and "Scrum5" but not "Scrum"), then the processes are piped into Add-VSTeamWorkItemPage, which cretes a new page on the layout of the "Bug" workitem type. Then pages a priped into Add-VSTeamWorkItemPageGroup which creates a group named environment on each one.    
Both the Add- commands have the -Force switch to prevent confirmation prompts and Add-VSTeamWorkItemPageGroup stores the result in $groups so that it can be used in other commands, like Add-VSTeamWorkItemControl.


## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -Label
Label for the new group 

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Name, GroupLabel

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Order
Position for the new group; 0 is before the first existing group, 1 is between the first and second, and so on. If not specified a new group will be added as the last group in its section. 

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
The page where the new group is to be created. 

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

### -SectionID
The section where the group is to be placed. Section1 is the wide group on the left, Section2 is in the middle of the screen and Section3 is on the right.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:
Accepted values: Section1, Section2, Section3

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

<!-- #include "./params/workItemType.md" -->

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
[Set-VSTeamWorkItemControl](Set-VSTeamWorkItemControl.md)

[Remove-VSTeamWorkItemControl](Remove-VSTeamWorkItemControl.md)

[Add-VSTeamWorkItemPage](Add-VSTeamWorkItemPage.md)

[Add-VSTeamWorkItemPageGroup](Add-VSTeamWorkItemPageGroup.md)