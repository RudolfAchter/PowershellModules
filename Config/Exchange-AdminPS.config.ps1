$Global:LdapConnection=@{
    server=$null
    port=636
    credential=$null
    connection=$null
}

$Global:Postfix=@{
    Host="tom.rz.uni-passau.de"
    Table=@{
		Virtual = "/etc/postfix/virtual"
		SenderCanonical = "/etc/postfix/sender_canonical"
	}
}

$Global:SSH=@{
    PrivateKeyFile="$env:USERPROFILE\Documents\ssh\ac.openssh.key"
}

$Global:Exchange=@{
    DefaultHost="msxpo1.ads.uni-passau.de"
}
