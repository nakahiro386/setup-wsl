var ws = new ActiveXObject("WScript.Shell");
ws.Run("wsl -u root -- service ssh stop", 0, false);
