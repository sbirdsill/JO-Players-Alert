# Joint Operations Player Alert
# PowerShell script that will send an email alert if more than x players are connected to a server.
# 1/27/2024

# Alert when number of connected players is equal to or greater than $players (Default: 32)
$players = 32

# Grab the text file from the lobby template
$url = "https://www.edcint.co.nz/jo/lobby/lobby.cgi?mode=data&region=JO&template=text"

# Pass the contents of the page into a variable 
$response = Invoke-WebRequest -Uri $url

# Read the content of the text file
$fileContent = $response.Content -split "`n"

# Loop through each line in the file
foreach ($line in $fileContent) {
  # Check if the line begins with "SERVER"
  if ($line -like "SERVER*") {
    # Split the line by the '|' character
    $items = $line -split '\|'

    # Check if there are at least 22 items in the line
    if ($items.Count -ge 22) {
      # Check if the 17th item is numeric and higher than 32
      if ([int]::TryParse($items[16],[ref]$null) -and [int]$items[16] -ge $players) {
        # Assign the 22nd item to a variable
        $twentySecondItem = $items[21]

        # Conditions met, send an email alert. (You'll need to configure an SMTP server as explained below.)
        $EmailFrom = "SMTPemail@outlook.com" # Sender email goes here, I recommend creating a burner email.
        $SMTPPassword = "SMTPPasswordGoesHere" # SMTP email password goes here
        $EmailTo = "you@gmail.com" # Your email goes here, alerts will be sent here.
        $Subject = "$players or more players are connected to a JO server!"
        $Body = "The following server name has 32 or more players connected: $twentySecondItem"
        $SMTPServer = "smtp-mail.outlook.com" # Set the SMTP server based on your SMTP provider.
        $SMTPMessage = New-Object System.Net.Mail.MailMessage ($EmailFrom,$EmailTo,$Subject,$Body)
        $SMTPClient = New-Object Net.Mail.SmtpClient ($SmtpServer,587)
        $SMTPClient.EnableSsl = $true
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential ($EmailFrom,$SMTPPassword);
        $SMTPClient.Send($SMTPMessage)
        Write-Host "Alert sent to $EmailTo."
      }
    }
  }
}
