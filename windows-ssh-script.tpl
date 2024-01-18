add-content -path C:/Users/Michael.Simpson/.ssh/config -value @' 
Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
'@