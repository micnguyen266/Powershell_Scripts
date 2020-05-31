$Logfile = "C:\windows_updates_script\LogUpdate.log"

# LogWrite Function converts output to a string and puts in LogUpdate File.
Function LogWrite {
   Param ([string]$Global:logstring)

   Add-content $Logfile -value $Global:logstring
}

# This Function sends us email notifications via SendGrid API
Function Sendgrid {
    $Username ="apikey"

    # To Manually Test
    # $Password = ConvertTo-SecureString "<SENDGRID_API_KEY>" -AsPlainText -Force
    $Password = $null
    $Password = Get-Content .\secure_api.txt | ConvertTo-SecureString

    $credential = New-Object System.Management.Automation.PSCredential $Username, $Password

    $SMTPServer = "smtp.sendgrid.net"

    $EmailFrom = "test@example.com"

    # To add multiple emails, use comma separated values.
    [string[]]$EmailTo = "test@example.com"
    $Subject = "Windows Update Report for $env:Computername - $(get-date)"

    $Body =  Write-Output $Global:logstring

    Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -Port 587 -from $EmailFrom -to $EmailTo -subject $Subject -Body ($Body | Out-String) -Attachments C:\windows_updates_script\LogUpdate.log -BodyAsHtml
    Write-Output "Email sent succesfully."
}
# TODO: Find a better way to iterate LogWrite instead of doing LogWrite1, 2, 3 and 4.
# This function looks for Windows updates downloads and installs them, it will reboot automatically if necessary. User will be forced out.
Function WSUSUpdate {
    $Criteria = "IsInstalled=0 and Type='Software'"
    $Searcher = New-Object -ComObject Microsoft.Update.Searcher
    try {
        $SearchResult = $Searcher.Search($Criteria).Updates
        if ($SearchResult.Count -eq 0 -or $null) {
            $LogWrite1 = LogWrite "There are no applicable Windows Updates for $env:Computername $(get-date)."
            $LogWrite1
            Sendgrid
            exit
        } 
        else {
            $Session = New-Object -ComObject Microsoft.Update.Session
            $Downloader = $Session.CreateUpdateDownloader()
            $Downloader.Updates = $SearchResult
            $Downloader.Download()
            $Installer = New-Object -ComObject Microsoft.Update.Installer
            $Installer.Updates = $SearchResult
            $global:result = $Installer.Install()
            if ($global:result.rebootRequired) {
                $LogWrite2 = LogWrite "Windows Updates have been applied for $env:Computername $(get-date). Rebooting machine to finish installing updates..."
                $LogWrite2
                Sendgrid
                Restart-Computer -Force
                }
            if (!$global:result.rebootRequired) {
                $LogWrite3 = LogWrite "Windows Updates have been applied for $env:Computername $(get-date). Reboot not required."
                $LogWrite3
                Sendgrid
                }
        }
    }
    catch [System.Management.Automation.MethodInvocationException],[System.Runtime.InteropServices.COMException] {
        $ErrorMessage = $_.Exception.Message
        $LogWrite4 = LogWrite "An error occurred for $env:Computername $(get-date). $ErrorMessage. Please check if machine is in sync with WSUS Server."
        $LogWrite4
        Sendgrid
    }
}
WSUSUpdate