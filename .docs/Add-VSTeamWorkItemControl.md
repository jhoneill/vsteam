<!-- #include "./common/header.md" -->

# Add-VSTeamWorkItemControl

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ByGroup (Default)
```
Add-VSTeamWorkItemControl -ProcessTemplate <Object> -WorkItemType <Object> [-PageLabel <String>]
 -ReferenceName <Object> [-Label <String>] [-GroupLabel <String>] [-Order <Int32>] [-Hide] [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### BySection
```
Add-VSTeamWorkItemControl -ProcessTemplate <Object> -WorkItemType <Object> [-PageLabel <String>]
 -ReferenceName <Object> [-Label <String>] [-SectionID <Object>] [-Order <Int32>] [-Hide] [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
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

### -GroupLabel
{{ Fill GroupLabel Description }}

```yaml
Type: String
Parameter Sets: ByGroup
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Hide
{{ Fill Hide Description }}

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
{{ Fill Label Description }}

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

### -ReferenceName
{{ Fill ReferenceName Description }}

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
{{ Fill SectionID Description }}

```yaml
Type: Object
Parameter Sets: BySection
Aliases:
Accepted values: Section1, Section2, Section3, Section4

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
