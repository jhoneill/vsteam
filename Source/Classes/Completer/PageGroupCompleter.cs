using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using System.Management.Automation.Abstractions;
using System.Management.Automation.Language;
namespace vsteam_lib
{
   public class PageGroupCompleter : BaseCompleter
   {
      /// <summary>
      /// This constructor is used when running in a PowerShell session. It cannot be
      /// loaded in a unit test.
      /// </summary>
      [ExcludeFromCodeCoverage]
      public PageGroupCompleter() : base() { }

      /// <summary>
      /// This constructor is used during unit testings
      /// </summary>
      /// <param name="powerShell">fake instance of IPowerShell used for testing</param>
      public PageGroupCompleter(IPowerShell powerShell) : base(powerShell) { }

      public override IEnumerable<CompletionResult> CompleteArgument(string commandName,
                                                                     string parameterName,
                                                                     string wordToComplete,
                                                                     CommandAst commandAst,
                                                                     IDictionary fakeBoundParameters)
      {
         var values = new List<CompletionResult>();
         // Test if we are logged on (unit tests can set the value)
         // We can only get the page if we have a work item type, if we don't have a ProcessTemplate, use the default.
         if (!string.IsNullOrEmpty(Versions.Account) && fakeBoundParameters["WorkItemType"] != null)
         {
            var process =  (fakeBoundParameters["Processtemplate"] != null) ? fakeBoundParameters["Processtemplate"] : Versions.DefaultProcess;
            var page    =  (fakeBoundParameters["PageLabel"] != null) ? fakeBoundParameters["PageLabel"] : "Details";

            //To make unit testing easier instead of calling Get-VSTeamWorkItemPage call Get-VsteamWorkItemType and expand it.
            base._powerShell.Commands.Clear();
            var groups = base._powerShell.AddCommand("Get-VsteamWorkItemType")
                                         .AddParameter("ProcessTemplate", process)
                                         .AddParameter("WorkItemType", fakeBoundParameters["WorkItemType"])
                                         .AddParameter("Expand", "layout")
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "layout")
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "pages")
                                         .AddCommand("Where-Object")
                                         .AddParameter("Property", "label")
                                         .AddParameter("like", true)
                                         .AddParameter("Value", page)
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "sections")
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "groups")
                                         .AddCommand("Select-Object")
                                         .AddParameter("ExpandProperty", "Label")
                                         .AddCommand("Sort-Object")
                                         .AddParameter("Unique")
                                         .Invoke();
            foreach (var g in groups)
            {
               string word = g.ToString();
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
