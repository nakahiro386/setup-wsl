netsh.exe interface portproxy delete v4tov4 listenport=22
netsh.exe interface portproxy add v4tov4 listenport=22 connectaddress=(wsl -d Ubuntu-18.04 exec hostname -I).trimend()
netsh.exe interface portproxy show v4tov4
Read-Host "‘±‚¯‚é‚É‚Í Enter ƒL[‚ğ‰Ÿ‚µ‚Ä‚­‚¾‚³‚¢..." 
