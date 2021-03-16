#!/bin/pwsh 

## Pushover message
$token = "xxxx"
$user = "xxxxx"
    
### List of created lineup json files in /guide2go
# sample with 3 yaml lineups, adjust to yours
$JsonList = "xxxx"

### to create your lineups do as follows and follow the instructions
#docker exec -it xteve_guide2go guide2go -configure /guide2go/mossflix.json

### xTeve ip, Port in case API is used to update XEPG
$xTeveIP = "172.18.0.8"
$xTevePORT = "34400"

### Plex ip, Port, Token, TV Section ID in case API is used to update EPG directly after guide2go
$plexIP = "192.168.1.254"
$plexPORT = "32400"
$plexToken = "xxxxxxxxxxxxxxxx"
$plexID = "8"

# run guide2go in loop
guide2go -config "/guide2go/$jsonname.json"

$updatexmltv = @"
{"cmd": "update.xmltv"}
"@

$updatxepg = @"
{"cmd": "update.xepg"}
"@

$xmltv_response = Invoke-RestMethod "$xTeveIP:$xTevePORT/api/" -Method Post -Body $updatexmltv

if ($xmltv_response.status -eq "True") {
    $message = "Updated XML TV"
    $messagedecoded = [system.Web.httpUtility]::UrlEncode($message)
    Invoke-RestMethod -uri "https://api.pushover.net/1/messages.json?token=$token&user=$user&title=$title&message=$messagedecoded" -Method POST
}

Start-Sleep -Seconds 5

$xepg_response = Invoke-RestMethod "$xTeveIP:$xTevePORT/api/" -Method Post -Body $updatxepg

if ($xepg_response -eq "True") {
    $message = "Updated XEPG"
    $messagedecoded = [system.Web.httpUtility]::UrlEncode($message)
    Invoke-RestMethod -uri "https://api.pushover.net/1/messages.json?token=$token&user=$user&title=$title&message=$messagedecoded" -Method POST
}

$plexsplat = @{
    URI    = "http://${plexIP}:${plexPORT}/livetv/dvrs/${plexID}/reloadGuide?X-Plex-Product=Plex%20Web&X-Plex-Version=4.8.4&X-Plex-Client-Identifier=${plexToken}&X-Plex-Platform=Firefox&X-Plex-Platform-Version=69.0&X-Plex-Sync-Version=2&X-Plex-Features=external-media&X-Plex-Model=bundled&X-Plex-Device=Linux&X-Plex-Device-Name=Firefox&X-Plex-Device-Screen-Resolution=1128x657%2C1128x752&X-Plex-Language=de"
    Method = "POST"
}

Invoke-RestMethod @plexsplat
