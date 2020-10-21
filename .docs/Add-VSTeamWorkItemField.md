<!-- #include "./common/header.md" -->

# Add-VSTeamWorkItemField

## SYNOPSIS

<!-- #include "./synopsis/Add-VSTeamWorkItemField.md" -->

## SYNTAX

## DESCRIPTION
Every WorkItem has multiple data-fields. The definition of a Workitem type includes that type's fields, which are selected from a set of Fields shared across all Process Templates in the Organization. This command adds one of these Fields to the definition of a WorkItem type. Note that the WorkItem types in the built-in Process Templates cannot be modified, and changing the defintion of a WorkItem type in one Processs Template does not affect copies of the WorkItem type in other templates.

## EXAMPLES

### Example 1
```powershell
Add-VSTeamWorkItemField -ProcessTemplate Scrum5 -WorkItemType Change -ReferenceName Office

Confirm
Are you sure you want to perform this action?
Performing the operation "Add field 'Custom.Office' to WorkItem type" on target "Change".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

Name   Reference Name Required Type   customization
----   -------------- -------- ----   -------------
Office Custom.Office             string custom

```

In this example, a custom field named "Office" has been created, and is added to a custom WorkItem type named "Change"; no default value is given and the field is not requred. Note that the command is able to resolve "Office" to its reference-name of "custom.office". Because -Force is not used the command prompts for confirmation before adding the field.


### Example 2
```powershell
Get-VSTeamWorkItemType -ProcessTemplate Scrum5 -WorkItemType Test* | Add-VsteamWorkItemField -ReferenceName Custom.Office -DefaultValue London -Required -force

Name   Reference Name Required Type   customization
----   -------------- -------- ----   -------------
Office Custom.Office  True     string inherited
Office Custom.Office  True     string inherited
Office Custom.Office  True     string inherited

```

Here the first command in the pipeline gets the WorkItem types "Test Case", "Test Plan" and "Test Suite" and passes them to Add-VsteamWorkItemField. This time the command uses the full reference name "Custom.Office" sets a default value and marks the field as a required value. To avoid the confirmation prompt, -Force is used.

## PARAMETERS

### -AllowGroups
Allows an identity field to be set to a group identity. Does not apply to other field types.

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

<!-- #include "./params/forcegroup.md" -->

### -DefaultValue
Sets a default value for the field.

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

<!-- #include "./params/processTemplate.md" -->

### -ReadOnly
Specifies that the field cannot be edited.

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

### -ReferenceName
The reference name of the field. The command will attempt to resolve a partial name like "ClosedDate" to its full reference name, like "Microsoft.VSTS.Common.ClosedDate". Values for the field names should tab-complete.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Name, FieldName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Required
Unless -Required is specified adding a value for the field is optional.

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
[Add-VSTeamField](Add-VSTeamField.md)

[Get-VSTeamWorkItemField](Get-VSTeamWorkItemField.md)

[Get-VSTeamWorkItemType](Get-VSTeamWorkItemType.md)