$Logfile = "C:\windows_updates_script\LogUpdate.log"

# LogWrite Function converts output to a string and puts in LogUpdate File.
Function LogWrite {
   Param ([string]$Global:logstring)

   Add-content $Logfile -value $Global:logstring
} 

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
$Subject = "LogCleanup Report for $env:Computername - $(get-date)"

$Body = Write-Output $Global:logstring

Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -Port 587 -from $EmailFrom -to $EmailTo -subject $Subject -Body ($Body | Out-String) -Attachments C:\windows_updates_script\LogUpdate.log -BodyAsHtml
Write-Output "Email sent succesfully."
}

<# Function LogCleanup {
# Delete all .log files in "C:\windows_updates_script" older than 90 day(s)
$maxDaystoKeep = -90
 
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($maxDaystoKeep)
$itemsToDelete = Get-ChildItem -Path $Logfile -Recurse -Include ('*.log') | Where-Object {($_.LastWriteTime -lt $DatetoDelete)}
    if ($itemsToDelete.Count -gt 0) {
        ForEach ($item in $itemsToDelete) {
        $LogWrite1 = LogWrite "LogUpdate file has been deleted on $DateToDelete"
        $LogWrite1
        Sendgrid
        Start-Sleep -s 5
        Get-item $item.PSPath | Remove-Item
        exit
        }      
    }
    else {
        $LogWrite2 = LogWrite "No logs to be deleted today $($(Get-Date).DateTime)"
        $LogWrite2
        Sendgrid
    }
}
LogCleanup #>

Function LogCleanup {
# Delete all .log files in "C:\windows_updates_script".

$itemsToDelete = Get-ChildItem -Path $Logfile -Recurse -Include ('*.log')
    if ($itemsToDelete.Count -gt 0) {
        ForEach ($item in $itemsToDelete) {
        $LogWrite1 = LogWrite "LogUpdate file has been deleted on $($(Get-Date).DateTime)"
        $LogWrite1
        Sendgrid
        Start-Sleep -s 5
        Get-item $item.PSPath | Remove-Item
        exit
        }      
    }
    else {
        $LogWrite2 = LogWrite "No logs to be deleted today $($(Get-Date).DateTime)"
        $LogWrite2
        Sendgrid
    }
}
LogCleanup