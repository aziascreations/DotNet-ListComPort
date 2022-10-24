using Microsoft.Win32;
using static NibblePoker.Library.RegistryHelpers.RegistryHelpers;

namespace NibblePoker.Library.ComPortWatcher; 

public static class ComPortHelper {
    private const string RegistryKeySerial = "HARDWARE\\DEVICEMAP\\SERIALCOMM";
    private const string RegistryKeyDeviceEnum = "SYSTEM\\ControlSet001\\Enum";
    
    private static readonly string[] IgnoredRegistryDeviceEnums = {
        "ACPI", "ACPI_HAL", "HDAUDIO", "SCSI", "STORAGE", "SW", "SWD", "UEFI"
    };
    
    private const string RegistryNameFriendlyName = "FriendlyName";
    
    private static void AddFriendlyNamesToPortsInfo(List<ComPortInfo> comPortsInfo) {
        List<string> subKeys = GetSubKeys(Registry.LocalMachine, RegistryKeyDeviceEnum);
        List<string> intermediateSubKeys = new List<string>();
        List<string> finalSubKeys = new List<string>();
        List<string> friendlyNames = new List<string>();
        
        foreach(var subKey in subKeys.Where(subKey => !IgnoredRegistryDeviceEnums.Contains(subKey))) {
            intermediateSubKeys.AddRange(GetSubKeys(
                Registry.LocalMachine,
                RegistryKeyDeviceEnum + "\\" + subKey,
                true));
        }
        subKeys.Clear();
        
        foreach(string subSubKey in intermediateSubKeys) {
            finalSubKeys.AddRange(GetSubKeys(
                Registry.LocalMachine,
                subSubKey,
                true));
        }
        intermediateSubKeys.Clear();
        
        foreach(string finalSubKey in finalSubKeys) {
            Dictionary<string, string> mappedKeyValues = GetMappedKeyNameStringValue(Registry.LocalMachine, finalSubKey);
            
            if(mappedKeyValues.ContainsKey(RegistryNameFriendlyName)) {
                friendlyNames.Add(mappedKeyValues[RegistryNameFriendlyName]);
            }
        }
        finalSubKeys.Clear();
        
        foreach(ComPortInfo comPortInfo in comPortsInfo) {
            foreach(string friendlyName in friendlyNames) {
                if(!friendlyName.Contains("(" + comPortInfo.RawName + ")")) {
                    continue;
                }
                
                comPortInfo.FriendlyName = friendlyName;
                break;
            }
        }
        friendlyNames.Clear();
    }

    public static List<ComPortInfo> GetComList(bool addFriendlyNames = false) {
        List<ComPortInfo> portsInfo = new List<ComPortInfo>();
        
        foreach(KeyValuePair<string, string> rawPortInfo in GetMappedKeyNameStringValue(Registry.LocalMachine, RegistryKeySerial)) {
            portsInfo.Add(new ComPortInfo(rawPortInfo.Value, rawPortInfo.Key));
        }
        
        if(addFriendlyNames && portsInfo.Count > 0) {
            AddFriendlyNamesToPortsInfo(portsInfo);
        }
        
        return portsInfo;
    }
}
