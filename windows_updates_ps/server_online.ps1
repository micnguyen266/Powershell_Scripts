$Logfile = "C:\windows_updates_script\LogUpdate.log"

# LogWrite Function converts output to a string and puts in LogUpdate File.
Function LogWrite {
   Param ([string]$Global:logstring)

   Add-content $Logfile -value $Global:logstring
}
   
$LogWrite1 = LogWrite "Server $env:Computername - $(get-date) has rebooted and is back up. Please RDP to ensure it's running or check if Puppet service has been restarted manually."
$LogWrite1

Function Sendgrid 
{
$Username ="apikey"

# To Manually Test
# $Password = ConvertTo-SecureString "<SENDGRID_API_KEY>" -AsPlainText -Force
$Password = $null
$Password = get-content .\secure_api.txt | ConvertTo-SecureString

$credential = New-Object System.Management.Automation.PSCredential $Username, $Password

$SMTPServer = "smtp.sendgrid.net"

$EmailFrom = "test@example.com"

# To add multiple emails, use comma separated values.
[string[]]$EmailTo = "test@example.com"
$Subject = "Server $env:Computername - $(get-date) has rebooted and is back up"

$Body = Write-Output $Global:logstring

Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -Port 587 -from $EmailFrom -to $EmailTo -subject $Subject -Body ($Body | Out-String) -Attachments C:\windows_updates_script\LogUpdate.log -BodyAsHtml
Write-Output "Email sent succesfully."
}
Sendgrid