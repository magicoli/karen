<!DOCTYPE HTML PUBLIC '-//IETF//DTD HTML 2.0//EN'>
<html>
	<head>
		<title>404 Not Found</title>
	</head>
	<body>
		<center>
	    <table height=100%>
	      <tr valign=middle>
	        <td align=center>
	          <p><img src=zandoli-480x480.jpg style="max-width:100%;"></p>
						<p>
							You have reached the last page on the Internet.<br/>
							You can safely turn off your computer and come back to life.
						</p>
						<hr/>
						<address><? echo preg_replace(".*/", "RealWorld/", preg_replace(" .*", "", getenv('SERVER_SOFTWARE'))) ?> Server at <? echo ereg_replace("^www\.", "", getenv('HTTP_HOST')) ?> Port <? echo getenv('SERVER_PORT') ?></address>
	          </td>
	        </tr>
	      </table>
	    </center>
	</body>
</html>
