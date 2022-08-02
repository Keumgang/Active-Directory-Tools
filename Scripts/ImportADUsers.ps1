#############################
# New AD User Import Script #
#############################
#
# Revised 8/1/22
#

# Import AD module for running AD cmdlets
Import-Module ActiveDirectory

# Define UPN
$UPN = "your.domain"

# Store data from new user csv in $new_users variable
$new_users = Import-csv C:\Scripts\ADScripts\ADUsers_Import.csv

#Loop through each row of user details in new user csv
foreach ($user in $new_users) {
	#Read user data from each field and assign data to set variable
	$firstname = $user.firstname
	$lastname = $user.lastname
	$title = $user.title
	
	#Set user name on condition that last name is limited to 7 chars
        if ($user.lastname.length -gt 7) {
        	$username = $user.firstname.Substring(0,1)+$user.lastname.substring(0,7)
	}
        else {
		$username = $user.firstname.Substring(0,1)+$user.lastname
	}
	
        # Check to see if the user already exists in AD
	if (Get-ADUser -F { SamAccountName -eq $username }) {
	
		# If user does exist, give a warning
		Write-Warning "A user account with username $username already exists in Active Directory."
	}
	else {
	
		# User does not exist, proceed to create new user account
		New-ADUser `
			-SamAccountName $username `
			-Name "$firstname $lastname" `
			-Displayname "$firstname $lastname" `
			-Givenname $firstname `
			-Surname $lastname `
			-Enabled $True `
			-UserPrincipalname "$Logon@$UPN" `
			-Path "CN=users,DC=weirdstuff,DC=com" `
			-Title $title `
			-AccountPassword (convertto-securestring "password123" -AsPlainText -Force) -ChangePasswordAtLogon $true
        	
		# Report user creation to terminal
        	Write-Host "The user account $username has been created." -ForegroundColor Cyan
	}
}
