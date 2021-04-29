<?xml version = "1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"/>

<xsl:template match="myrubberbands/customer_record">
<html>
  <head>
     <title>
	Customer Profile: <xsl:value-of select="customer/username_or_email"/>
    </title>
  </head>
  <body>
	<h2>	
	Customer Profile For: 
	<xsl:value-of select="customer/lastname"/>, 
	<xsl:value-of select="customer/firstname"/> 
	(<xsl:value-of select="customer/username_or_email"/>)
	</h2>
	<hr/>

	<!-- 
		Display all the user's registered addresses.  
		This section demonstrates how to embed the value of 
		an XML tag inside a result tag by using the 
		xsl:element construct. 
	-->
	
	<h2>Registered Addresses</h2>
	<table border="1">
	<tr valign="top">
	<xsl:for-each select="customer_address">

	  <td>
	  <h4><xsl:value-of select="@address_type"/></h4>
		<xsl:call-template name="formatAddressTemplate"/>
	   </td>
	</xsl:for-each>
	</tr>
	</table>
  	<hr/>

	<!-- 
		Display all the user's order history.  
	-->
	<xsl:for-each select="order_history">
	<table border="1">
	  <tr>
		<td>Date</td>
		<td>Status</td>
		<td>Summary</td>
		<td>Ship To</td>
		<td>Total</td>
	  </tr>
	  <xsl:for-each select="order">

	  <tr>
		<td><xsl:value-of select="order_date"/></td>
		<td><xsl:value-of select="order_status"/></td>
		<td><table>
		<xsl:for-each select="product">

		<!-- 
			These XPath expressions are analogous to a join or subquery in 
			SQL; they reference data contained elsewhere in the same 
			document.   
		-->

		  <tr>
		    <td>(<xsl:value-of select="@quantity"/>)&#160;<xsl:value-of 
			 select="//product_list/product[@id=current()/@id]"/></td>
		  </tr>
		</xsl:for-each>
		</table>
		<td>
		   <!-- 
			Get this ship to address, which is already contained elsewhere in the 
			document. 
		   -->
		   <xsl:for-each select="//customer_record/customer_address[
				@address_type=current()/customer_address/@address_type  
				and @customer_id=current()/customer_address/@customer_id]">
			<xsl:call-template name="formatAddressTemplate"/>
		   </xsl:for-each>	
		</td>
		</td>
		<td halign="right">$<xsl:value-of select="total_charge"/>
		</td>
	  </tr>
	  </xsl:for-each>
	</table>
	</xsl:for-each>

	<hr/>
	Copyright 2001, MyRubberbands.com, Inc. All Rights Reserved.  
  </body>
</html>
</xsl:template>

<!-- 
	Suppress the display of product list information 
--> 

<xsl:template match="product_list"/>


<!-- 
	This is a reusable named template for formatting 
	a billing or shipping address 
-->

<xsl:template name="formatAddressTemplate">

	<xsl:value-of select="address1"/><br/>
	<xsl:if test="address2 != ''">
		<xsl:value-of select="address2"/><br/>
	</xsl:if>

	<xsl:if test="city != '' and state_or_prov != ''">
		<xsl:value-of select="city"/>, 
		<xsl:value-of select="state_or_prov"/>&#160;
		<xsl:value-of select="postalcode"/><br/>
	</xsl:if>

	<!-- 
		The phone numbers are assumed to be 10-digit, unformatted 
		US numbers.
	-->

	<xsl:if test="phone != ''">
	    (<xsl:value-of select="substring(phone, 1, 3)"/>)
	    <xsl:value-of select="substring(phone, 4, 3)"/>-
	    <xsl:value-of select="substring(phone, 7, 4)"/><br/>
	</xsl:if>

	<xsl:if test="email != ''">		
	  <xsl:element name="a">
	   <xsl:attribute name="href">mailto:<xsl:value-of select="email"/>
	   </xsl:attribute>
	   <xsl:value-of select="email"/>
	  </xsl:element>
	  <br/>
	</xsl:if>

</xsl:template>

</xsl:stylesheet>




