add-content -path C:/Users/Michael.Simpson/.ssh/config -value @'
Host ${hostname}
    Hostname ${hostname}
    User ${user}
    IdentityFile ${identity_file}
    '@