<?php
	require "tapir-sql.php";
	require "vxml-common.php";

	$conn=tapir_connect_ro();

	if (!isset($start)) {
		$start=0;
	};

	# make sure it's a number

	$start=1*$start;

	$where_clause="WHERE workflow_status>127 AND flag_visible_on_top=1";
	$r=$conn->query("SELECT sid,title FROM geeklog_stories $where_clause ORDER BY featured DESC,date DESC LIMIT $start,9");
	$stories=$r->fetch_objects();

	$r=$conn->query("SELECT COUNT(*) FROM geeklog_stories $where_clause");
	$count=$r->fetch_scalar();

	$older=(($start+9)<$count);
	$newer=($start>0);


?>