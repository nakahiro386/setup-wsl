var ws = new ActiveXObject("WScript.Shell");
ws.Run("wsl -u root -- service ssh start", 0, false);
