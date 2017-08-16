Clear-Host;

"Starting RPE configuration..."

#Host PC name, Database name, Database instance name
$MachineName="ll-desktop.rsi";
$DatabaseName="testDB1234";
$DatabaseInstance="PDB";
$DatabaseUsername="sa";
$DatabasePassword="Rsi@123456";


#Developer username and password 
$Username="llopez@rsi";
$Password="1234567@rsi";

#Content Management Credentials
$contentManagementCredentials="admin"

Get-ChildItem C:\CODE\RevenuePremier *.config -recurse |
    Foreach-Object {
        $c = ($_ | Get-Content)
        $c = $c -replace 'add name="RSI_Connection" connectionString=".*?"',"add name=""RSI_Connection"" connectionString=""Data Source=$MachineName\$DatabaseInstance;Initial Catalog=$DatabaseName;User Id=$DatabaseUsername; Password=$DatabasePassword;""" `
		-replace 'localhost',"$MachineName" `
		-replace 'RPE_DATA', "$DatabaseName" `
		-replace '<log4net threshold="ERROR">','<log4net threshold="DEBUG">' `
		-replace '<level value="ERROR"/>','<level value="DEBUG"/>' `
		-replace '<level value="ERROR" />','<level value="DEBUG"/>' `
		-replace '<globalServerCredentialsSettings AppUsername="dep-svc-usr@rsi" AppPassword="Rsi#1234" >','<globalServerCredentialsSettings AppUsername="qauser@rsi" AppPassword="tester#1">' `
		-replace '<contentManagementCredentials Username="user@domain" Password="password"/>','<contentManagementCredentials Username="admin" Password="livelink"/>' `
		-replace '<add key="ServiceCertificateSerialNumber" value="" />','<add key="ServiceCertificateSerialNumber" value="7c993e4ab8a2bcbe44c045e6acfe5bef" />' `
		-replace '<add key="PaymentProcessingServiceUsername" value="paymentservice@rsi" />','<add key="PaymentProcessingServiceUsername" value="syamamoto@itsc.rsi" />' `
		-replace '<SSRSReportCredentials Username="user" Password="password" Domain="domain"/>','<SSRSReportCredentials Username="qauser" Password="tester#1" Domain="rsi"/>' `
		-replace 'rpe-demo-vt/ReportServer','DEV-REPORTING.RSI/ReportServer_PDB' `
		-replace ':58443/PaymentCardProcessingWebService/PaymentCardProcessingService.svc','/PaymentCardService/Services/PaymentCardProcessingService.svc'
		[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
    }

"`nConnection strings set to:`
Data Source=$MachineName\$DatabaseInstance;Initial Catalog=$DatabaseName;User Id=sa; Password=Rsi@123456;";

Get-ChildItem C:\Wildfly\standalone\configuration standalone.xml -recurse |
    Foreach-Object {
        $c = ($_ | Get-Content)
        $c = $c -replace '(<connection-url>jdbc:sqlserver:).*?(</connection-url>)', "<connection-url>jdbc:sqlserver://$MachineName:1433;databaseName=$DatabaseName;instance=$DatabaseInstance</connection-url>"
		[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
    }

"`nWildfly connection url set to:`
jdbc:sqlserver://ll-desktop.rsi:1433;databaseName=$DatabaseName;instance=$DatabaseInstance"

Get-ChildItem C:\Wildfly *.properties -recurse |
    Foreach-Object {
        $c = ($_ | Get-Content)
        $c = $c -replace 'RPE_DATA', "$DatabaseName"
		[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
    }

Get-ChildItem C:\RSI\RPRuleService *.config -recurse |
Foreach-Object {
	$c = ($_ | Get-Content)
	$c = $c -replace 'add name="RSI_Connection" connectionString=".*?"',"add name=""RSI_Connection"" connectionString=""Data Source=$MachineName\$DatabaseInstance;Initial Catalog=$DatabaseName;User Id=sa; Password=Rsi@123456;"""
	[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
}

"`nSetup complete.`n";

#"`a `a";
