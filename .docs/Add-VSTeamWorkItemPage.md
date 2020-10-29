<!-- #include "./common/header.md" -->

# Add-VSTeamWorkItemPage

## SYNOPSIS
 <!-- #include "./synopsis/Add-VSTeamWorkItemPage.md" -->


## DESCRIPTION
Each type of WorkItem specifies a multipage layout. This command adds pages to layouts. Note that the built-in Process templates (Scrum, Agile etc.) do not allow their work item types to be customized, this is only allowed for custom processes. After a page has been added groups may be added to its different sections.


## EXAMPLES

### Example 1
```powershell
Add-VSTeamWorkItemPage -WorkItemType Task -Label Progress

Confirm
Are you sure you want to perform this action?
Performing the operation "Update WorkItemType" on target "Task".
[Y] Yes [A] Yes to All [N] No [L] No to All [S] Suspend [?] Help (default is "Yes"): y
WARNING: An error occurred: Response status code does not indicate success: 403 (Forbidden).
WARNING: VS402356: You do not have the permissions required to perform the attempted operation on this process.
```

The user was prompted for confirmation, because the -Force switch was not used, and an error occurred because the current project is using one of the built-in process templates which cannot be modified.


### Example 2
```powershell
Add-VSTeamWorkItemPage -WorkItemType Task -Label Progress -ProcessTemplate Scrum5 -Force


WorkItemType PageLabel Page Type Locked Visble Inherited Groups
------------ --------- --------- ------ ------ --------- ------
Task         Progress  custom           True
```

This time the command has been run with the -Force switch to remove the need for confirmation and has specified a template where modifications are allowed.

### Example 3
```powershell
Get-VSTeamProcess scrum? | Add-VSTeamWorkItemPage -WorkItemType Bug -Label ReportInformation -Force

WorkItemType PageLabel         Page Type Locked Visble Inherited Groups
------------ ---------         --------- ------ ------ --------- ------
Bug          ReportInformation custom           True
Bug          ReportInformation custom           True
Bug          ReportInformation custom           True

```

In this example, the Get-VSTeamProcess command gets the processes "Scrum3","Scrum4" and "Scrum5" (but not "Scrum"), and for each one adds page "ReportInformation" to their Bug WorkItem type.


### Example 3
```powershell
Add-VSTeamWorkItemPage -WorkItemType Epic,Feature -Label "Business Justification","Costings" -ProcessTemplate Scrum5 -Force

WorkItemType PageLabel              Page Type Locked Visble Inherited Groups
------------ ---------              --------- ------ ------ --------- ------
Feature      Business Justification custom           True
Feature      Costings               custom           True
Epic         Business Justification custom           True
Epic         Costings               custom           True

```

This example shows the command supporting multiple WorkItems, and multiple new pages.

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -Label
The name of new page. To be consistent with other commands, the aliases "Name" or "PageLabel" can be used. If the page already exists, an error will occur.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Name, PageLabel

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Order
Specifies the position of the page. 0 is before the first existing page, 1 after the first and so on.

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

### -PageType
A page of controls uses the type "custom" and this is the default. Page types are defined for Attachments, History and Links.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: custom, attachments, history, links

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

<!-- #include "./params/processTemplate.md" -->

### -Sections
Allows JSON to be specified for the sections which make up the page. For information about the format of the JSON, please see the link at the end of this help.

```yaml
Type: Object
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
[Get-VSTeamWorkItemPage](Get-VSTeamWorkItemPage.md)

[Set-VSTeamWorkItemType](Set-VSTeamWorkItemPage.md)

[Remove-VSTeamWorkItemPage](Remove-VSTeamWorkItemPage.md)

[Microsoft Docs page for custom JSON information](https://docs.microsoft.com/en-us/rest/api/azure/devops/processes/pages/add)