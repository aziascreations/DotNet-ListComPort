namespace NibblePoker.Application.ListComPort; 

public static class ErrorCodes {
	public const int NoError = 0;
	
	/* Fatal errors (1-9) */
	// Not needed in C#
	
	/* Internal argument parser errors (10-19) */
	public const int ArgumentParsingFailure = 10;
	// ArgumentDefinitionFailure = 11 => Cannot happen due to the way options are declared.  (Caught in development)
	// ArgumentInitFailure = 12 => Cannot happen with "NibblePoker.Library.Arguments".
	
	/* External argument errors (20-29) */
	public const int NoPaddingValue = 20;
	
	/* Application & System errors (30-39) */
	// NoFriendlyNames = 30 => Causes problems with broad-range exit code checks.
	public const int NoComPorts = 31;
}