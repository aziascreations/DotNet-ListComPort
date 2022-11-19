using System;
using System.Collections.Generic;
using System.Linq;
using NibblePoker.Library.Arguments;
using NibblePoker.Library.ComPortWatcher;

namespace NibblePoker.Application.ListComPort;

internal static class Program {
	private const string Version = "3.0.0";
	
	private static readonly Verb RootVerb = new Verb("");
	
	private static readonly Option OptionShowAll      = new('a', "show-all", "Display the complete port's name (Equal to '-dfn')");
	private static readonly Option OptionShowDevice   = new('d', "show-device", "Displays the port's device name");
	private static readonly Option OptionDivider      = new('D', "divider", "Uses the given string or char as a separator (Can be an empty string !)", OptionFlags.HasValue);
	private static readonly Option OptionShowFriendly = new('f', "show-friendly", "Displays the port's friendly name");
	private static readonly Option OptionHelp         = new('h', "help", "Display the help text", OptionFlags.StopsParsing);
	private static readonly Option OptionHelpShort    = new('H', "short-help", "Display the short help text", OptionFlags.StopsParsing);
	private static readonly Option OptionShowNameRaw  = new('n', "show-name-raw", "Displays the port's raw name (See remarks section)");
	private static readonly Option OptionNoPretty     = new('P', "no-pretty", "Disables the pretty printing format (Equal to -D \" \"");
	private static readonly Option OptionSort         = new('s', "sort", "Sorts the port based on their raw names in an ascending order");
	private static readonly Option OptionSortReverse  = new('S', "sort-reverse", "Sorts the port based on their raw names in a descending order");
	private static readonly Option OptionTabPadding   = new('t', "tab-padding", "Use tabs for padding between the types of names (Overrides '-D')");
	private static readonly Option OptionVersion      = new('v', "version", "Shows the utility's version number and other info");
	private static readonly Option OptionVersionOnly  = new('V', "version-only", "Shows the utility's version number only (Overrides '-v')");
	
	private static bool _shouldPrintRawNames = true;
	private static bool _shouldPrintDeviceNames = false;
	private static bool _shouldPrintFriendlyNames = false;
	
	private static string _paddingText = "";

	private static SortingOrder _sortingOrder = SortingOrder.None;
	
	private static int _exitCode = ErrorCodes.NoError;
	
	/// <summary>
	/// Checks if the program is the only owner of its console.
	/// This check is used to detect if the program was run from the exe/lnk or via a console.
	/// </summary>
	/// <returns><c>True</c> if the process is the console's sole owner, <c>False</c> otherwise</returns>
	private static bool IsProgramRunDirectly() {
		return GetConsoleProcessList(new int[2], 2) <= 1;
	}
	
	private static int Main(string[] args) {
		try {
			ArgumentsParser.ParseArguments(RootVerb.RegisterOption(OptionShowAll).RegisterOption(OptionShowDevice)
				.RegisterOption(OptionDivider).RegisterOption(OptionShowFriendly).RegisterOption(OptionHelp)
				.RegisterOption(OptionShowNameRaw).RegisterOption(OptionNoPretty).RegisterOption(OptionSort)
				.RegisterOption(OptionSortReverse).RegisterOption(OptionTabPadding).RegisterOption(OptionVersion)
				.RegisterOption(OptionVersionOnly), args);
		} catch(ArgumentException) {
			Console.Error.Write("Failed to parse the launch arguments, default options will be used.");
			_exitCode = ErrorCodes.ArgumentParsingFailure;
			RootVerb.Clear();
		}
		
		if(OptionHelp.WasUsed() || OptionHelpShort.WasUsed()) {
			Console.WriteLine(HelpText.GetFullHelpText(RootVerb, "lscom.exe", (uint)Console.BufferWidth - 1, 1, 2, false));
			
			if(OptionHelp.WasUsed()) {
				Console.WriteLine("\nRemarks:");
				Console.WriteLine(" * If '-d' or '-f' is used, the raw name will not be shown unless '-n' is used.");
				Console.WriteLine(" * If '-D', '-t' or '-p' are used, the special separator between the raw and friendly name and the square brackets are not shown.");
				Console.WriteLine(" * If the program is raw without going through a console, the options '-n' and '-f' will be used.");
				Console.WriteLine(" * By default, the ports are sorted in the order they are provided by the registry, which is often chronological.");
				Console.WriteLine(" * The 'raw name' refers to a port name. (e.g.: COM1, COM2, ...)");
				Console.WriteLine(" * The 'device name' refers to a port device path. (e.g.: \\Device\\Serial1, ...)");
				Console.WriteLine(" * The 'friendly name' refers to a port name as seen in the device manager. (e.g.: Communications Port, USB-SERIAL CH340, ...)");
				Console.WriteLine(" * Any result returned with an error code between 1-9 and 30-39 should be considered as invalid.");
				Console.WriteLine(" * Any result returned with another error code is valid but probably not formatted properly.");
			}
			
			return ErrorCodes.NoError;
		}
		
		if(OptionVersionOnly.WasUsed()) {
			Console.WriteLine(Version);
			return ErrorCodes.NoError;
		}
		
		if(OptionVersion.WasUsed()) {
			Console.WriteLine("NibblePoker.Application.ListComPort (lscom) v" + Version);
			Console.WriteLine("");
			Console.WriteLine("Dependencies:");
			Console.WriteLine("├─> NibblePoker.Library.Arguments v1.1.0");
			Console.WriteLine("├─> NibblePoker.Library.ComPortHelpers v" + Version);
			Console.WriteLine("└─> NibblePoker.Library.RegistryHelpers v0.0.1");
			Console.WriteLine("");
			Console.WriteLine("GitHub repositories:");
			Console.WriteLine("├─> https://github.com/aziascreations/DotNet-Arguments");
			Console.WriteLine("├─> https://github.com/aziascreations/DotNet-ListComPort");
			Console.WriteLine("└─> https://github.com/aziascreations/DotNet-RegistryHelpers");
			Console.WriteLine("");
			Console.WriteLine("This software and all its libraries are licensed under the MIT license.");
			return ErrorCodes.NoError;
		}
		
		if(OptionShowDevice.WasUsed()) {
			_shouldPrintRawNames = false;
			_shouldPrintDeviceNames = true;
		}
		
		if(OptionShowFriendly.WasUsed() || IsProgramRunDirectly()) {
			_shouldPrintRawNames = false;
			_shouldPrintFriendlyNames = true;
		}
		
		if(OptionShowNameRaw.WasUsed() || IsProgramRunDirectly()) {
			_shouldPrintRawNames = true;
		}
		
		if(OptionShowAll.WasUsed()) {
			_shouldPrintRawNames = true;
			_shouldPrintFriendlyNames = true;
			_shouldPrintDeviceNames = true;
		}
		
		if(OptionSort.WasUsed()) {
			_sortingOrder = SortingOrder.Ascending;
		}
		
		if(OptionSortReverse.WasUsed()) {
			_sortingOrder = SortingOrder.Descending;
		}
		
		if(OptionNoPretty.WasUsed()) {
			_paddingText = " ";
		}
		
		if(OptionDivider.WasUsed()) {
			_paddingText = OptionDivider.Arguments[0];
		}
		
		if(OptionTabPadding.WasUsed()) {
			_paddingText = "\t";
		}
		
		// Application's code
		
		string rawToFriendlySeparator = " - ";
		bool addDeviceBrackets = true;
		
		if(string.IsNullOrEmpty(_paddingText)) {
			_paddingText = " ";
		} else {
			rawToFriendlySeparator = _paddingText;
			addDeviceBrackets = false;
		}
		
		if(!_shouldPrintRawNames && !_shouldPrintFriendlyNames && _shouldPrintDeviceNames) {
			addDeviceBrackets = false;
		}
		
		List<ComPortInfo> comPortsInfo = ComPortHelper.GetComList(_shouldPrintFriendlyNames);
		
		if(comPortsInfo.Count > 0) {
			comPortsInfo = _sortingOrder switch {
				SortingOrder.Ascending => comPortsInfo.OrderBy(o => o.RawName).ToList(),
				SortingOrder.Descending => comPortsInfo.OrderByDescending(o => o.RawName).ToList(),
				_ => comPortsInfo
			};
			
			foreach(ComPortInfo comPortInfo in comPortsInfo) {
				if(_shouldPrintRawNames) {
					Console.Write(comPortInfo.RawName);

					if(_shouldPrintFriendlyNames) {
						Console.Write(rawToFriendlySeparator);
					}
				}
				
				if(_shouldPrintFriendlyNames) {
					Console.Write(comPortInfo.FriendlyName);
				}
				
				if((_shouldPrintRawNames || _shouldPrintFriendlyNames) && _shouldPrintDeviceNames) {
					Console.Write(_paddingText);
				}
				
				if(_shouldPrintDeviceNames) {
					Console.Write((addDeviceBrackets ? "[" : "") + comPortInfo.DeviceName + (addDeviceBrackets ? "]" : ""));
				}
				
				Console.WriteLine();
			}
		} else {
			Console.Error.Write("No COM port could be found.");
			_exitCode = ErrorCodes.NoComPorts;
		}
		
		// Allows the program to be ran from a shortcut without closing the console instantly.
		if(IsProgramRunDirectly()) {
			Console.Write("\nPress any key to continue...");
			Console.ReadKey();
		}
		
		return _exitCode;
	}
	
	// Imports "GetConsoleProcessList(...)" in order to know if the program was ran via a shortcut or CLI.
	// See: https://learn.microsoft.com/en-us/windows/console/getconsoleprocesslist
	[System.Runtime.InteropServices.DllImport("kernel32.dll")]
	private static extern int GetConsoleProcessList(int[] buffer, int size);
}
