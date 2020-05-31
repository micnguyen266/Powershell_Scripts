### Instructions on Setting Up

1. Open Task Scheduler and Import the 3 .xml files "`windows_updates.xml`", "`server_online.xml`" and "`log_cleanup.xml`". 
This will create 3 separate tasks. Please note Windows Updates will run once a week and the time is based on the 
maintenance window of your Window Servers.

2. Follow directions below to securely convert the Sendgrid API Key as a hash.

3. Run this command in Powershell ISE as admin. This will open another PowerShell window as NT Authority/System

    `psexec -i -s Powershell.exe`

#### Copy Below Commands and Run one-by-one
This will convert the API key as a hash and save in a .txt file. Then the hash password will be called as a variable `$Password` in other scripts.
These commands need to run as System user due to secure string only works with the user which created the secure string. 
Since the task scheduler tasks are running as System user it can called the variable `$Password`.

    ConvertTo-SecureString "SENDGRID_API_KEY" -AsPlainText -force | ConvertFrom-SecureString | Out-File .\secure_api.txt
    $Password = Get-Content .\secure_api.txt | ConvertTo-SecureString

To test, run this variable. You should see "`System.Security.SecureString`"

    $Password

#### Testing
To test, run the main script `windows_updates.ps1` in task scheduler and if your computer has windows updates to download, it will download
them automatically and restart your machine even while the user is still logged in. At startup, it will run the main script again until there's
no more windows update. You should get email logs for each action it does, e.g. updating, restarting, no updates.

### LogCleanup
Please note there is also a LogCleanup script that will delete the LogUpdate.log file every 3 months. 
This task runs on the 1st of January, April, July and October at 12:00AM.

### Other Notes
The server_online.ps1 script is specific to a Puppet environment. If your Windows boxes don't run puppet you can disable this.
This script looks for a specific Windows event based on the .xml file. It looks for when the Puppet service restarts, after it restarts
the script will be invoked and the user will be sent an email that the Server has "restarted", this can be a false-positive if the 
service was manually restarted.

#### Troubleshooting:
If you're having issues running the "`psexec`" command. You can run these commands from PowerShell and it will open the psexec.exe file 
from the PSTools folder already in this repo. You will be prompted to accept an EULA agreement. 
If not, please manually open the `PsExec.exe` file.

    cd C:\windows_updates_script\pstools
    .\psexec.exe -i -s Powershell.exe

### Author
Michael Nguyen 

https://github.com/micnguyen266