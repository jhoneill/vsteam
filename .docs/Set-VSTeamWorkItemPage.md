<!-- #include "./common/header.md" -->

# Set-VSTeamWorkItemPage

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Both
```
Set-VSTeamWorkItemPage [-ProcessTemplate <Object>] [-WorkItemType] <Object> [-Label <Object>]
 -Newlabel <String> -Order <Int32> [-Sections <Object>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Label
```
Set-VSTeamWorkItemPage [-ProcessTemplate <Object>] [-WorkItemType] <Object> [-Label <Object>]
 -Newlabel <String> [-Sections <Object>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Order
```
Set-VSTeamWorkItemPage [-ProcessTemplate <Object>] [-WorkItemType] <Object> [-Label <Object>] -Order <Int32>
 [-Sections <Object>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

<!-- #include "./params/forcegroup.md" -->

### -Label
{{ Fill Label Description }}

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
{{ Fill Newlabel Description }}

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
{{ Fill Order Description }}

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
### -Sections
{{ Fill Sections Description }}

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
