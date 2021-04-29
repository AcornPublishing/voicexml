<?php
	require "tapir-sql.php";
	require "vxml-common.php";

	$conn=tapir_connect_ro();
	$_sid=addslashes($sid);

	# if workflow_status<128,  the story isn't available for outside
	# readers

	$r=$conn->query("SELECT title,introtext,UNIX_TIMESTAMP(date) AS date,CONCAT(first_name,' ',last_name) AS name,bodytext FROM geeklog_stories,tapir_users WHERE sid='$_sid' AND workflow_status>127 AND tapir_users.user_id=geeklog_stories.uid");
	$story=$r->fetch_object();

	$_introtext=stripslashes(strip_tags($story->introtext));
	$_date=date("l F j",$story->date);
	$_name=$story->name;
	if(strlen($story->bodytext)>0) { 
		$_words=sizeof(explode(" ",$story->bodytext));
	} else
		$_words=0;

?>