Clear-Host;

"`nStarting RPE configuration...`n";

# Host PC name, Database name, Database instance name
$machineName="ll-desktop.rsi";
$databaseName="RPE_DATA";
$databaseInstance="PDB";
$databasePortNumber="1433";
$databaseUsername="sa";
$databasePassword="Rsi@123456";


# Developer username and password 
$username="llopez@rsi";
$password="1234567@rsi";

# Content Management Credentials
$contentManagementCredentials="admin"

Get-ChildItem C:\CODE\RevenuePremier *.config -recurse |
    Foreach-Object {
        $c = ($_ | Get-Content)
        $c = $c -replace 'add name="RSI_Connection" connectionString=".*?"', ('add name="RSI_Connection" connectionString="Data Source={0}\{1};Initial Catalog={2};User Id={3}; Password={4};"' -f $machineName, $databaseInstance, $databaseName, $databaseUsername, $databasePassword) `
		-replace 'localhost',"$machineName" `
		-replace 'RPE_DATA', "$databaseName" `
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

'Connection strings set to:
Data Source={0}\{1};Initial Catalog={2};User Id={3}; Password={4}' -f $machineName, $databaseInstance, $databaseName, $databaseUsername, $databasePassword
"`n"

Get-ChildItem C:\Wildfly\standalone\configuration standalone.xml -recurse |
    Foreach-Object {
        $c = ($_ | Get-Content)
        $c = $c -replace '(<connection-url>jdbc:sqlserver:).*?(</connection-url>)', ('<connection-url>jdbc:sqlserver://{0}:{1};databaseName={2};instance={3}</connection-url>' -f $machineName,$databasePortNumber,$databaseName,$databaseInstance)
		[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
    }

'Wildfly connection url set to:
jdbc:sqlserver://{0}:{1};databaseName={2};instance={3}' -f $machineName,$databasePortNumber,$databaseName,$databaseInstance

Get-ChildItem C:\Wildfly *.properties -recurse |
    Foreach-Object {
        $c = ($_ | Get-Content)
        $c = $c -replace 'RPE_DATA', '{0}' -f $databaseName
		[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
    }

Get-ChildItem C:\RSI\RPRuleService *.config -recurse |
Foreach-Object {
	$c = ($_ | Get-Content)
	$c = $c -replace 'add name="RSI_Connection" connectionString=".*?"', ('add name="RSI_Connection" connectionString="Data Source={0}\{1};Initial Catalog={2};User Id={3}; Password={4};"' -f $machineName, $databaseInstance, $databaseName, $databaseUsername, $databasePassword)
	[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
}

"`nConfiguration complete.`n";

#"`a `a";
