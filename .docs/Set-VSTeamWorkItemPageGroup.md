<!-- #include "./common/header.md" -->

# Set-VSTeamWorkItemPageGroup

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### LeaveAlone (Default)
```
Set-VSTeamWorkItemPageGroup [-ProcessTemplate <Object>] [-WorkItemType] <Object> [-PageLabel <String>]
 [-Label] <String> [-Order <Int32>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Rename
```
Set-VSTeamWorkItemPageGroup [-ProcessTemplate <Object>] [-WorkItemType] <Object> [-PageLabel <String>]
 [-Label] <String> [-Order <Int32>] [-NewLabel] <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Move
```
Set-VSTeamWorkItemPageGroup [-ProcessTemplate <Object>] [-WorkItemType] <Object> [-PageLabel <String>]
 [-Label] <String> [-Order <Int32>] [-NewPage <String>] [-NewSectionID <Object>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
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
{{ Fill NewLabel Description }}

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
{{ Fill NewPage Description }}

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
{{ Fill NewSectionID Description }}

```yaml
Type: Object
Parameter Sets: Move
Aliases:
Accepted values: Section1, Section2, Section3, Section4

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Order
{{ Fill Order Description }}

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
{{ Fill PageLabel Description }}

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
