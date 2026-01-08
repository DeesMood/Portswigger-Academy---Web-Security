📂 How to use it

Create a file in the same folder as the script, e.g. labs.txt:

https://portswigger.net/web-security/os-command-injection/lab-simple
https://portswigger.net/web-security/os-command-injection/lab-blind-time-delays
https://portswigger.net/web-security/os-command-injection/lab-blind-output-redirection
https://portswigger.net/web-security/os-command-injection/lab-blind-out-of-band
https://portswigger.net/web-security/os-command-injection/lab-blind-out-of-band-data-exfiltration


Save the script as lab-roulette.ps1 in the same folder.

Run it from PowerShell:

cd "C:\path\to\folder"
.\lab-roulette.ps1


Or with custom paths:

.\lab-roulette.ps1 -LabFile ".\my_labs.txt" -StateFile ".\my_labs_done.txt"


The script will:

Read URLs from labs.txt

Read finished ones from labs_done.txt (auto-created)

Only randomize over remaining labs

Append each completed lab to labs_done.txt

Next time you run it, it will remember what you’ve already done and only serve up fresh labs.