namespace NibblePoker.Library.ComPortWatcher; 

public class ComPortInfo {
	public string RawName;
	public string DeviceName;
	public string FriendlyName;
	
	public ComPortInfo(string rawName, string deviceName, string friendlyName = "") {
		RawName = rawName;
		DeviceName = deviceName;
		
		if(string.IsNullOrEmpty(friendlyName)) {
			FriendlyName = "No friendly name found (" + rawName + ")";
		} else {
			FriendlyName = friendlyName;
		}
	}
}