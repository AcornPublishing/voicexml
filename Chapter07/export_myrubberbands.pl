#!perl.exe
###################
# This script exports the myrubberbands.com database schema to an 
# XML format.  It will create on XML file for each registered user 
# in the system.  
###################
use strict; 
use DBI; 

my @months = ("NULL", 
		"January", "February", "March", "April", "May", "June", 
		"July", "August", "September", "October", "November", 
		"December"); 

my $xml_header = q(<?xml version="1.0"?>
<myrubberbands export_type="single">
   <customer_record>
); 


my $dbh = DBI->connect("dbi:mysql:voicexml"); 

#####
# Fetch all the data from the customer table.  This formats the 
# time stamps in ISO format to obey the XML schema.  

my $customer_sth = $dbh->prepare(q(
	SELECT customer_id, firstname, middle, lastname, 
	username_email, password_pin, 
	DATE_FORMAT(date_joined, '%Y-%m-%dT%T'),  
	DATE_FORMAT(date_lastchg, '%Y-%m-%dT%T')
	FROM customer)); 

my $customer_address_sth = $dbh->prepare(q(
	SELECT CAT.description_of_type, email, phone, address1, 
	address2, city, state_or_prov, postalcode 
	FROM customer_address CA, customer_address_type CAT 
	WHERE CA.customer_id = ? AND 
	CA.customer_address_type = CAT.customer_address_type 
)); 


#####
# This query generates all of the <order> data 
# except for the list of products.  

my $order_history_sth = $dbh->prepare(q(
	SELECT CO.order_id,  CAT.description_of_type, 
	DATE_FORMAT(order_date, '%Y-%m-%dT%T'), 
	CO.tax, CO.shipping_charge, CO.total_charge, 
	OST.description_of_type 

	FROM customer_order CO, customer_address CA, 
	customer_address_type CAT, order_status_type OST 

	WHERE CO.customer_id = ? AND 
	CO.customer_id = CA.customer_id AND 
	CO.shipping_address = CA.customer_address_type AND 
	CA.customer_address_type = CAT.customer_address_type AND 
	CO.order_status_type = OST.order_status_type 
)); 

######
# This query generates the list of products in an order.  

my $order_detail_sth = $dbh->prepare(q(
	SELECT product_id, quantity FROM customer_order_product WHERE 
	order_id = ?
)); 


######
# This query generates the complete list of products.  

my $product_list_sth = $dbh->prepare(q(
	SELECT product_id, product_name, product_desc, price 
	FROM product ORDER BY product_id 
)); 

#########################

########
# Outermost loop iterates over customer records. 

$customer_sth->execute; 
while (my ($customer_id, $fn, $mi, $ln, $username, $password, 
	   $date_joined, $date_lastchg) = $customer_sth->fetchrow_array)
{
	########
	# Log some output...

	print STDERR "Exporting $fn $ln ($customer_id) to customer_$customer_id.xml\n"; 

	########
	# Open a file for output. 

	open (XML, ">customer_$customer_id.xml") or die "can't open output file"; 

	########
	# Write out the customer profile. 

	print XML $xml_header; 
	print XML 
		"	<customer id=\"$customer_id\">\n" . 
		"	  <firstname>$fn</firstname>\n" . 
		"	  <middle>$mi</middle>\n" . 
		"	  <lastname>$ln</lastname>\n" . 
		"	  <username_or_email>$username</username_or_email>\n" . 
		"	  <password_or_pin>$password</password_or_pin>\n" . 	
		"	  <date_joined>$date_joined</date_joined>\n" . 
		"	  <date_lastchg>$date_lastchg</date_lastchg>\n" . 
		"	</customer>\n" 
		;

	##########
	# Fetch customer address records. 

	$customer_address_sth->execute($customer_id); 
 	while (my ($type, $email, $phone, $address1, $address2, 
		$city, $state, $postalcode) = 
		$customer_address_sth->fetchrow_array)
	{

		print XML 
			"	<customer_address 	address_type=\"$type\"  \n" .  
			"				customer_id=\"$customer_id\">  \n" . 
			"	  <address1>$address1</address1> \n" . 
			"	  <address2>$address2</address2> \n" . 
			"	  <city>$city</city> \n" . 
			"	  <state_or_prov>$state</state_or_prov> \n" . 
			"	  <postalcode>$postalcode</postalcode> \n" . 
			"	  <email>$email</email> \n" . 
			" 	  <phone>$phone</phone> \n" . 
			"	</customer_address> \n\n" 
			;
	}

	#########
	# Export the user's order history 

	print XML
		"	<order_history customer_id=\"$customer_id\">\n"
		;

	$order_history_sth->execute($customer_id); 
	while ( my ($order_id, $addr_desc, $order_date, $tax, $ship, $total, $order_status) = 
		$order_history_sth->fetchrow_array )

	{

		####
		# Since we know we're designing for a voice interface, it will be a lot 
		# easier in the long run to convert the order_state to a clean value for 
		# TTS rendering here.  

		my ($date, $time) = split(/T/, $order_date, 2); 
		my ($year, $month, $day) = split(/\-/, $date, 3); 
		my ($hours, $mins, $secs) = split(/\:/, $time, 3); 

		my $pretty_time = $months[$month] . " $day, $year at $hours $mins hours"; 

		print XML "	   <order id=\"$order_id\">\n" . 
			  "	     <customer_address address_type=\"$addr_desc\" customer_id=\"$customer_id\"/>\n" . 
			  "	     <order_date sayas=\"$pretty_time\">$order_date</order_date>\n" . 
			  "	     <order_status>$order_status</order_status>\n" . 
			  "	     <tax>$tax</tax>\n" . 
			  "	     <shipping_charge>$ship</shipping_charge>\n" . 
			  "	     <total_charge>$total</total_charge>\n" 
			  ;


		$order_detail_sth->execute($order_id); 
		while (my ($product_id, $quan) = $order_detail_sth->fetchrow_array) 
		{
			print XML 
				"	     <product id=\"$product_id\" quantity=\"$quan\"/>\n"
				;
		}

		print XML 
			  "	   </order>\n"
			  ;

	}	

	#########
	# Close out the customer record... 

	print XML
		"	</order_history>\n" . 
		"   </customer_record>\n" 
		;


	#########
	# To simplify schema, and avoid linking data across document, 
	# append a product list here.  Obviously, this is not practical for 
	# all applications.  

	print XML
		"   <product_list>\n"
		;

	$product_list_sth->execute; 
	while (my ($id, $name, $desc, $price) = $product_list_sth->fetchrow_array)
	{

		print XML
			"   <product id=\"$id\" name=\"$name\" price=\"$price\">$desc</product>\n"
			;

	}

	print XML
		"   </product_list>\n"
		;

	#########
	# Finish the document.  

	print XML 
		"</myrubberbands>\n"
		;


	close(XML); 

	#######
	# Generate VoiceXML, WML, and HTML.  

	open(SAXON, "saxon customer_$customer_id.xml myrubberbands2vxml.xsl |"); 
	open(VXML, ">customer_$customer_id.vxml"); 
	while (my $line = <SAXON>)
	{
		print VXML $line; 
	}
	close VXML; 
	close SAXON; 

	open(SAXON, "saxon customer_$customer_id.xml myrubberbands2wml.xsl |"); 
	open(WML, ">customer_$customer_id.wml"); 
	while (my $line = <SAXON>)
	{
		print WML $line; 
	}
	close WML; 
	close SAXON; 

	open(SAXON, "saxon customer_$customer_id.xml myrubberbands2html.xsl |"); 
	open(HTML, ">customer_$customer_id.html"); 
	while (my $line = <SAXON>)
	{
		print HTML $line; 
	}
	close HTML; 
	close SAXON; 
 
}

$customer_sth->finish; 
$customer_address_sth->finish; 
$order_history_sth->finish; 
$order_detail_sth->finish; 
$product_list_sth->finish; 

$dbh->disconnect; 
exit 0; 

