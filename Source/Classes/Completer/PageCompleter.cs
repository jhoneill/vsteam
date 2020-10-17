using System.Collections;
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
         // use default project to test we are logged on (unit tests can set the value)
         //
         if (!string.IsNullOrEmpty(Versions.DefaultProject) &&
             fakeBoundParameters["Processtemplate"] != null &&
             fakeBoundParameters["WorkItemType"] != null)
         {
            base._powerShell.Commands.Clear();
            var pages = base._powerShell.AddCommand("Get-VsteamWorkItemPage")
                                         .AddParameter("ProcessTemplate", fakeBoundParameters["ProcessTemplate"])
                                         .AddParameter("WorkItemType", fakeBoundParameters["WorkItemType"])
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
