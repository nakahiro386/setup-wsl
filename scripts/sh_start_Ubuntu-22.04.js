var ws = new ActiveXObject("WScript.Shell");
ws.Run("wsl -d Ubuntu-22.04 -u root -- ", 0, false);
