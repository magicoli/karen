<?php
//get raw POST data so we can extract the email address
$raw = file_get_contents("php://input");
preg_match("/\<EMailAddress\>(.*?)\<\/EMailAddress\>/", $raw, $matches);
if (empty($_REQUEST[emailaddress])) {
  $email=$matches[1];
} else {
  $email=urldecode($_REQUEST[emailaddress]);
}
$domain=preg_replace('/.*@/', '', $email);
if (empty($domain)) {
   $domain = 'kimbe.red';
}
//set Content-Type
header("Content-Type: application/xml");
?><?xml version="1.0" encoding="utf-8" ?>
<Autodiscover xmlns="http://schemas.microsoft.com/exchange/autodiscover/responseschema/2006">
	<Response xmlns="http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a">
		<Account>
			<AccountType>email</AccountType>
			<Action>settings</Action>
			<Protocol>
				<Type>POP3</Type>
				<Server>mail.<?php echo $domain; ?></Server>
				<Port>110</Port>
				<LoginName><?php echo $email; ?></LoginName>
				<DomainRequired>off</DomainRequired>
				<SPA>off</SPA>
				<SSL>on</SSL>
				<STARTSSL>on</STARTSSL>
				<AuthRequired>on</AuthRequired>
				<DomainRequired>off</DomainRequired>
			</Protocol>
			<Protocol>
				<Type>POP3</Type>
				<Server>mail.<?php echo $domain; ?></Server>
				<Port>110</Port>
				<LoginName><?php echo $email; ?></LoginName>
				<DomainRequired>off</DomainRequired>
				<SPA>off</SPA>
				<SSL>off</SSL>
				<STARTSSL>off</STARTSSL>
				<AuthRequired>on</AuthRequired>
				<DomainRequired>off</DomainRequired>
			</Protocol>
			<Protocol>
				<Type>IMAP</Type>
				<Server>mail.<?php echo $domain; ?></Server>
				<Port>143</Port>
				<DomainRequired>off</DomainRequired>
				<LoginName><?php echo $email; ?></LoginName>
				<SPA>off</SPA>
				<SSL>on</SSL>
				<STARTSSL>on</STARTSSL>
				<AuthRequired>on</AuthRequired>
			</Protocol>
			<Protocol>
				<Type>IMAP</Type>
				<Server>mail.<?php echo $domain; ?></Server>
				<Port>143</Port>
				<DomainRequired>off</DomainRequired>
				<LoginName><?php echo $email; ?></LoginName>
				<SPA>off</SPA>
				<SSL>off</SSL>
				<STARTSSL>off</STARTSSL>
				<AuthRequired>on</AuthRequired>
			</Protocol>
			<Protocol>
				<Type>SMTP</Type>
				<Server>mail.<?php echo $domain; ?></Server>
				<Port>587</Port>
				<DomainRequired>off</DomainRequired>
				<LoginName><?php echo $email; ?></LoginName>
				<SPA>off</SPA>
				<SSL>on</SSL>
				<STARTSSL>on</STARTSSL>
				<AuthRequired>on</AuthRequired>
				<UsePOPAuth>on</UsePOPAuth>
				<SMTPLast>on</SMTPLast>
			</Protocol>
		</Account>
	</Response>
</Autodiscover>
