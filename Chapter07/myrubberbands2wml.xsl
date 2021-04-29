<?xml version = "1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml" encoding="ISO-8859-1"
 	    doctype-public="-//WAPFORUM//DTD WML 1.1//EN"
	    doctype-system="http://www.wapforum.com/DTD/wml_1.1.xml"
	    indent="yes"/>

<xsl:template match="myrubberbands/customer_record">
	
<xsl:variable name="firstname" select="customer/firstname"/> 

<wml> 

	<!-- Main Menu --> 

	<card id="main_menu" title="{$firstname}'s MyRubberBands"> 
		<p mode="wrap">
			<a href="#my_profile">My Profile</a><br/>
			<a href="#order_status">Order Status</a><br/>
			<a href="#product_list">Product List</a><br/>
			<a href="#faq">FAQ</a><br/>
			<!-- Link out of this XML-generated document --> 
		</p>
	</card> 

	<!-- Profile Summary --> 
	<card id="my_profile" title="{$firstname}'s Profile">
		<p mode="wrap">
			<xsl:value-of select="customer/firstname"/><br/> 
			<xsl:value-of select="customer/lastname"/><br/>
			<xsl:value-of select="customer/username_or_email"/><br/>
			<xsl:value-of select="count(customer_address)"/>&#160;
			<xsl:if test="count(customer_address) = 1">Address&#160;</xsl:if>
			<xsl:if test="count(customer_address) != 1">Addresses&#160;</xsl:if>
			On File<br/>
			<a href="#main_menu">Main Menu</a><br/>
		</p>
	</card>
	
	<!-- Order Status --> 
	<card id="order_status" title="{$firstname}'s Orders">
		<p mode="wrap">
		<xsl:if test="count(order_history/order) = 0">
		There are no orders on file.<br/>
		</xsl:if>
<xsl:for-each select="order_history/order">
			Order #<xsl:value-of select="position()"/><br/>
			<xsl:value-of select="order_date"/><br/>
			<xsl:value-of select="total_charge"/><br/>
			<xsl:value-of select="order_status"/><br/>
			=========
			<br/><br/>
</xsl:for-each>
			<a href="#main_menu">Main Menu</a><br/>
		</p>
	</card>

	<!-- Product List --> 
	<card id="product_list" title="Rubberbands!">
		<p mode="wrap">
<xsl:for-each select="/myrubberbands/product_list/product">
			<xsl:value-of select="."/><br/>
			<xsl:value-of select="./@price"/><br/>
			=========
			<br/><br/>
</xsl:for-each>
			<a href="#main_menu">Main Menu</a><br/>
		</p>
	</card>


	<!-- FAQ --> 
	<card id="faq" title="FAQ">
		<p mode="wrap">
			This is the my rubber bands dot com frequently asked questions list. 
			Did you know that my rubber bands dot com offers over a hundred 
			different types of rubberbands? <br/><br/>
			Q1.  I keep losing my rubber bands.  Where should I 
			keep them? <br/> 
			A1.  You can keep rubber bands on a door knob.  That way they are 
			always nearby when needed.  
			<br/><br/>
			Q2.  I am trying to shoot rubber bands.  What should 
			I do?<br/>
			A2.  You'll shoot your eye out!<br/><br/>
			<a href="#main_menu">Main Menu</a><br/>
		</p>
	</card>
</wml> 

</xsl:template>
<xsl:template match="/myrubberbands/product_list"/>
</xsl:stylesheet>

