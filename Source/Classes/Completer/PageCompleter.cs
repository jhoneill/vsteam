﻿using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using System.Management.Automation.Abstractions;
using System.Management.Automation.Language;
namespace vsteam_lib
{
   public class PageCompleter : BaseCompleter
   {
      /// <summary>
      /// This constructor is used when running in a PowerShell session. It cannot be
      /// loaded in a unit test.
      /// </summary>
      [ExcludeFromCodeCoverage]
      public PageCompleter() : base() { }

      /// <summary>
      /// This constructor is used during unit testings
      /// </summary>
      /// <param name="powerShell">fake instance of IPowerShell used for testing</param>
      public PageCompleter(IPowerShell powerShell) : base(powerShell) { }

      public override IEnumerable<CompletionResult> CompleteArgument(string commandName,
                                                                     string parameterName,
                                                                     string wordToComplete,
                                                                     CommandAst commandAst,
                                                                     IDictionary fakeBoundParameters)
      {
         var values = new List<CompletionResult>();
         // Test if we are logged on (unit tests can set the value),
         // we can only get the page if we have a work item type, if we don't have a ProcessTemplate, use the default.
         if (!string.IsNullOrEmpty(Versions.Account) && fakeBoundParameters["WorkItemType"] != null)
         {
            var process =  (fakeBoundParameters["Processtemplate"] != null) ? fakeBoundParameters["Processtemplate"] : Versions.DefaultProcess;

            //To make unit testing easier instead of calling Get-VSTeamWorkItemPage call Get-VsteamWorkItemType and expand it.
            base._powerShell.Commands.Clear();
            var pages = base._powerShell.AddCommand("Get-VsteamWorkItemType")
                                         .AddParameter("ProcessTemplate", process)
                                         .AddParameter("WorkItemType", fakeBoundParameters["WorkItemType"])
                                         .AddParameter("Expand", "layout")
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "layout")
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "pages")
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "label")
                                         .AddCommand("Sort-Object")
                                         .AddParameter("Unique")
                                         .Invoke();
            foreach (var p in pages)
            {
               string word = p.ToString();
               if (string.IsNullOrEmpty(wordToComplete) || word.ToLower().StartsWith(wordToComplete.ToLower()))
               {
                  // Only wrap in single quotes if they have a space
                  values.Add(new CompletionResult(word.Contains(" ") ? $"'{word}'" : word));
               }
            }
         }
         return values;
      }
   }
}
