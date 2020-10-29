<!-- #include "./common/header.md" -->

# Set-VSTeamWorkItemPage

## SYNOPSIS

<!-- #include "./synopsis/Set-VSTeamWorkItemType.md" -->

## DESCRIPTION
Each type of WorkItem specifies a multipage layout. This command moves and renames pages. Note that the built-in Process templates (Scrum, Agile etc.) do not allow their work item types to be customized, this is only allowed in custom processes.

## EXAMPLES

### Example 1
```powershell
 Set-VSTeamWorkItemPage -ProcessTemplate scrum5 -WorkItemType Task -PageLabel Progress -Order 0 -Force

WorkItemType PageLabel Page Type Locked Visble Inherited Groups
------------ --------- --------- ------ ------ --------- ------
Task         Progress  custom           True
```

This command moves the page named "progress" to be the leftmost page on the form for Tasks in the Scrum5 template.

### Example 2
```powershell
 Get-VsteamWorkItemPage -ProcessTemplate scrum5 -WorkItemType * -PageLabel "Business Justification" | Set-VSTeamWorkItemPage -Newlabel "Reason" -Force

WorkItemType PageLabel Page Type Locked Visble Inherited Groups
------------ --------- --------- ------ ------ --------- ------
Feature      Reason    custom           True
Epic         Reason    custom           True
```

"Business Justification" is a long label and it has been decided to shorten it to "Reason"
The first command in the pipeline finds all the pages with that label, in any WorkItem type in the Scrum 5 template, and sends them to Set-VSTeamWorkItemPage which assigns a new label, using -Force to avoid the confirmation message.
This example shows piped input, but the same goal could be acheived with the following:
Set-VSTeamWorkItemPage -ProcessTemplate scrum5  *  "Business Justification"  -Newlabel "Reason" -Force

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -Label
The current name of the page.

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

### -Newlabel
A replacement label for the page. If not specified, the name remains as it is. Note that either NewLabel or Order (or both) must be specified.

```yaml
Type: String
Parameter Sets: Both, Label
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Order
Repositions the page. 0 is before the first existing page, 1 after the first and so on. Note that either NewLabel or order (or both) must be specified.

```yaml
Type: Int32
Parameter Sets: Both, Order
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

<!-- #include "./params/processTemplate.md" -->

<!-- #include "./params/workItemType.md" -->

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
[Add-VSTeamWorkItemPage](Add-VSTeamWorkItemPage.md)

[Get-VSTeamWorkItemType](Get-VSTeamWorkItemPage.md)

[Remove-VSTeamWorkItemPage](Remove-VSTeamWorkItemPage.md)
