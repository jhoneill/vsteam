<!-- #include "./common/header.md" -->

# Get-VSTeamWorkItemPage

## SYNOPSIS
<!-- #include "./synopsis/Get-VSTeamWorkItemPage.md" -->


## DESCRIPTION
Each type of WorkItem specifies a multipage layout. Pages may be added and customized, although some of the built-in pages are fixed, and some controls cannot be removed (only hidden.) Each page divides into sections, the sections contain groups, and the groups contain controls for working with the WorkItem's data fields.

## EXAMPLES

### Example 1
```powershell
 Get-VSTeamWorkItemPage -WorkItemType Bug


WorkItemType PageLabel   Page Type   Locked Visble Inherited Groups
------------ ---------   ---------   ------ ------ --------- ------
Bug          Details     custom      False  True   True      Repro Steps, ...
Bug          History     history     True   True   True      History
Bug          Links       links       True   True   True      Links
Bug          Attachments attachments True   True   True      Attachments
```

This command gets the layout pages for the Bug work type, using the Process-Template for the current project.

### Example 2
```powershell
Get-VSTeamWorkItemPage  bug,feature

WorkItemType PageLabel   Page Type   Locked Visble Inherited Groups
------------ ---------   ---------   ------ ------ --------- ------
Bug          Details     custom      False  True   True      Repro Steps, System Info, Acceptance
                                                             Criteria, Details, Build, Deployment,
                                                             Development, Related Work
Bug          History     history     True   True   True      History
Bug          Links       links       True   True   True      Links
Bug          Attachments attachments True   True   True      Attachments
Feature      Details     custom      False  True   True      Description, Acceptance Criteria,
                                                             Status, Details, Deployment,
                                                             Development, Related Work
Feature      History     history     True   True   True      History
Feature      Links       links       True   True   True      Links
Feature      Attachments attachments True   True   True      Attachments
```

This command compares the pages displayed for Bugs and Features. Both have the same page names; Details is only unlocked page and has different groups for each WorkItem type.


### Example 3
```powershell
Get-VSTeamWorkItemPage -WorkItemType bug -Label Details | select -expand groups

WorkItemType PageLabel SectionID GroupLabel          isContribution Visble Inherited Controls
------------ --------- --------- ----------          -------------- ------ --------- --------
Bug          Details   Section1  Repro Steps         False          True   True      Repro Steps
Bug          Details   Section1  System Info         False          True   True      System Info
Bug          Details   Section1  Acceptance Criteria False          True   True      Acceptance Criteria
Bug          Details   Section2  Details             False          True   True      Priority,  ...
Bug          Details   Section2  Build               False          True   True      Found in Build, ...
Bug          Details   Section3  Deployment          False          True   True      Deployments
Bug          Details   Section3  Development         False          True   True      Development
Bug          Details   Section3  Related Work        False          True   True      Related Work
```

This command gets a single page for bugs and expands its groups to show which section they are in, and the controls they have

### Example 4
```powershell
Get-VSTeamProcess scr* | Get-VSTeamWorkItemPage -WorkItemType bug | ft ProcessTemplate,WorkItemType,PageLabel,Locked

ProcessTemplate WorkItemType PageLabel   locked
--------------- ------------ ---------   ------
Scrum           Bug          Details      False
Scrum           Bug          History       True
Scrum           Bug          Links         True
Scrum           Bug          Attachments   True
Scrum5          Bug          Custom Page
Scrum5          Bug          Details      False
Scrum5          Bug          History       True
Scrum5          Bug          Links         True
Scrum5          Bug          Attachments   True
```

Here the first command in the Pipeline gets a list of Process Templates, returning the built-in "Scrum" and a custom template named "Scrum5";
these are piped into Get-VSTeamWorkItemPage to get a list of pages for Bug WorkItems in each template, which are displayed using Format-Table.
Note that in custom template a custom page has been added, and some fields (including) "locked" are not given a value for custom pages.


## PARAMETERS

### -Label
The Page label to select one or more pages. If none is specified all pages are returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name, PageLabel

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessTemplate

The process template containing the work item(s) of interest. If not specified this defaults to the process for the current project.


```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WorkItemType
The name(s) of the WorkItem type(s) with pages of interest.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
[Add-VSTeamWorkItemPage](Add-VSTeamWorkItemPage.md)

[Set-VSTeamWorkItemType](Set-VSTeamWorkItemPage.md)

[Remove-VSTeamWorkItemPage](Remove-VSTeamWorkItemPage.md)