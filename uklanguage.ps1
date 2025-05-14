# This script sets the system language to English (United Kingdom) and configures the locale settings.
# It also copies the language settings to the default user profile.

# Ensure the temp directory exists
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
    Write-Output "Temp directory created at C:\temp."
}
Write-Host "Temp directory exists at C:\temp."

# Set the progress preference to 'SilentlyContinue' to suppress progress messages (improve performance)
$ProgressPreference = 'SilentlyContinue'

# Download language pack from Microsoft
Write-Output "Starting: Downloading the English (United Kingdom) language pack..."
Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/p/?linkid=2195333 -OutFile C:\temp\lang.iso
Write-Output "Completed: Language pack downloaded to C:\temp\lang.iso."

# Download the defaultuser.bat file and associated en-GB.xml file
Write-Output "Starting: Downloading defaultuser.bat and en-GB.xml..."
Invoke-WebRequest -Uri https://raw.githubusercontent.com/richsaunders-atech/WinServer-UKRegionalisation/refs/heads/main/defaultuser.bat -OutFile C:\temp\defaultuser.bat
Invoke-WebRequest -Uri https://raw.githubusercontent.com/richsaunders-atech/WinServer-UKRegionalisation/refs/heads/main/en-GB.xml -OutFile C:\temp\en-GB.xml
Write-Output "Completed: defaultuser.bat and en-GB.xml downloaded."

# Mount the ISO file and install the language pack
Write-Output "Starting: Mounting the ISO file..."
Mount-DiskImage -ImagePath "C:\temp\lang.iso"
Write-Output "Completed: ISO file mounted."

# Get the drive letter of the mounted ISO
Write-Output "Retrieving the drive letter of the mounted ISO..."
$MountedISO = Get-Volume -FilesystemLabel "SERVER_FOD_LP_X64FRE_MULTI_DV9"
$DriveLetter = $MountedISO.DriveLetter
Write-Output "Drive letter of mounted ISO: $DriveLetter."

# Install en-GB Language Pack
Write-Output "Starting: Installing the en-GB Language Pack..."
cmd /c lpksetup /i en-gb /p "${DriveLetter}:\LanguagesAndOptionalFeatures\"
Write-Output "Completed: en-GB Language Pack installed."

# Set the system language to English (United Kingdom)
Write-Output "Starting: Setting the system language to English (United Kingdom)..."
Set-WinUserLanguageList "en-GB" -Force
Set-WinUILanguageOverride -Language "en-GB"
Set-WinSystemLocale "en-GB"
Write-Output "Completed: System language set to English (United Kingdom)."

# Set the GeoID for the United Kingdom
Write-Output "Starting: Setting the GeoID to 242 (United Kingdom)..."
Set-WinHomeLocation -GeoId 242 
Set-Culture -CultureInfo "en-GB"
Write-Output "Completed: GeoID set to 242."

# Set the default input method to English (United Kingdom)
Write-Output "Starting: Setting the default input method to English (United Kingdom)..."
New-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'LocaleName' -Value 'en-GB' -Force
New-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'Locale' -Value '00000809' -Force
New-ItemProperty -Path 'HKCU:\Control Panel\International\User Profile' -Name 'Languages' -Value 'en-GB' -Force
Write-Output "Completed: Default input method set to English (United Kingdom)."

# Copy settings to the default user profile
Write-Output "Starting: Copying settings to the default user profile..."
C:\temp\defaultuser.bat
# Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
Write-Output "Completed: Settings copied to the default user profile."

# Set Time zone to GMT Standard Time
Write-Output "Starting: Setting the time zone to GMT Standard Time..."
Set-TimeZone -Id "GMT Standard Time"
Write-Output "Completed: Time zone set to GMT Standard Time."

# Look for any AppxPackages containing 'Microsoft.LanguageExperiencePacken-GB' and remove them
Write-Output "Starting: Removing any AppxPackages containing 'Microsoft.LanguageExperiencePacken-GB'..."
Get-AppxPackage -Name '*Microsoft.LanguageExperiencePacken-GB*' | ForEach-Object {
    Write-Output "Removing package: $($_.Name)"
    Remove-AppxPackage -Package $_.PackageFullName
}
Write-Output "Completed: AppxPackages removed."

# Unmount the ISO file using the drive letter obtained earlier
Write-Output "Starting: Unmounting the ISO file..."
try {
    Dismount-DiskImage -ImagePath "C:\temp\lang.iso" -ErrorAction Stop
    Write-Output "ISO file successfully unmounted."
} catch {
    Write-Output "Error: Failed to unmount the ISO file. $_"
    throw
}
Write-Output "Completed: ISO file unmounted."

# Remove the downloaded files
Write-Output "Starting: Removing downloaded files..."
Remove-Item -Path "C:\temp\*" -Force -ErrorAction SilentlyContinue
Write-Output "Completed: Downloaded files removed."

Write-Output "Script completed successfully."
# End of script
# Note: This script requires administrative privileges to run successfully.