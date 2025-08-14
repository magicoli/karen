<?php header("HTTP/1.1 418 I'm a teapot"); ?>
<!DOCTYPE HTML PUBLIC '-//IETF//DTD HTML 2.0//EN'>
<html>
<head>
	<meta charset="UTF-8" />
	<title>418 I’m a teapot</title>
</head>
<body>
	<center>
		<table height=100%>
			<tr valign=middle>
				<td align=center>
					<p><img src=zandoli-480x480.jpg style="max-width:100%;"></p>
					<p>
						You have reached the last page on the Internet.<br/>
						You can safely turn off your computer and go back to life.
					</p>
					<hr/>
					<address><?php
					echo preg_replace(":.*/:", "RealLife/",preg_replace(": .*:", "",getenv('SERVER_SOFTWARE')));
					?> Server at <?php echo preg_replace(":^www\.:", "", getenv('HTTP_HOST')) ?> Port <?php echo getenv('SERVER_PORT'); ?></address>
				</td>
			</tr>
		</table>
	</center>
</body>
</html>
