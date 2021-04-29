<?xml version = "1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" encoding="ISO-8859-1" indent="yes"/>

<xsl:template match="myrubberbands[@export_type = 'single']/customer_record">
<vxml version="1.0">

<meta name="author" content="Underpaid Myrubberbands Engineer"/>
<meta name="copyright" content="Copyright (C) 2001 Myrubberbands.com, Inc."/>
<xsl:element name="meta">
	<xsl:attribute name="name">description</xsl:attribute>
	<xsl:attribute name="content">Voice Interface for #<xsl:value-of select="customer/@id"/>
	</xsl:attribute>
</xsl:element>

<!-- Variables --> 
<var name="customer_ani" expr="session.telephone.ani"/>
<var name="customer_dnis" expr="session.telephone.dnis"/>
<var name="session_error_count" expr="0"/>
<var name="form_pointer" expr="'mainMenu'"/>
<var name="user_command" expr="''"/>

<!-- Help --> 
<help count="1">
	What seems to be the trouble? 
</help>
	
<help count="2">
	Isn't this easy enough to understand?
</help>	
		
<help count="3">
	<xsl:value-of select="customer/firstname"/>, are you stupid or something? 
</help>	

<!-- Goodbye Handler --> 
<catch event="telephone.disconnect">
	<!-- 
		A hangup handler goes here.  Perhaps this logs the user's 
		call somewhere. 
	--> 
</catch>

<!-- A Global Command Grammar --> 
<link next="#mainMenu">
	<grammar type="application/x-jsgf"> main menu </grammar>
</link>

<form id="welcomeMessage">
	<block>
		<prompt bargein="false" timeout="0.1s">
			Hello, <xsl:value-of select="customer/firstname"/>.  
			Welcome to the my rubber bands dot com voice order 
			status system.  
		</prompt>
		<goto next="#mainMenu"/>
	</block>
</form>

<form id="mainMenu">

	<nomatch>
		<goto next="#errorHandler"/>
	</nomatch>
		
	<noinput>
		<goto next="#mainMenu"/>
	</noinput>

	<block>
		<assign name="form_pointer" expr="'mainMenu'"/>	
	</block>
	
	<field name="userSaid">
		
		<prompt bargein="true" timeout="3s">
			This is the main menu.  
			<break msecs="500"/>
			You can say product list to hear a list of products.  
			<break msecs="500"/>	
			You can say order status to check your order status.   
			<break msecs="500"/>			
			You can say frequently asked questions to get more information. 
			<break msecs="500"/>
			You can always say main menu to return to this menu, or help 
			for additional help.  
		</prompt>		

		<grammar type="application/x-jsgf">
			list
			product list | 
			more information |
			frequently asked questions | 
			questions | 
			order status 
		</grammar>
	
		<filled>
			<assign name="user_command" expr="userSaid"/>
			<goto next="#navigator"/>
		</filled>
		
	</field>
</form>


<form id="orderStatus">
	<noinput>
		<assign name="user_command" expr="'main menu'"/>
		<goto next="#navigator"/>
	</noinput>
	
	<nomatch>
		<goto next="#errorHandler"/>
	</nomatch>
	
	<field name="userSaid">
	
		<prompt bargein="true" timeout="1s">
<xsl:if test="count(/myrubberbands/customer_record/order_history/order) != 0">
			This is a list of all your orders.  
</xsl:if>
<xsl:if test="count(/myrubberbands/customer_record/order_history/order) = 0">
			You have not placed any orders within the last thirty days.  
</xsl:if>
			<break msecs="500"/>
<xsl:for-each select="order_history/order">
			<sayas class="date">
			<xsl:value-of select="order_date/@sayas"/>,
			</sayas> 
			you placed an order.  Say order number 
			<xsl:value-of select="position()"/>
			to hear more about it.
			<break msecs="500"/>
</xsl:for-each> 
		</prompt>
		
		<grammar type="application/x-jsgf">
			list | 
			product list | 
			more information |
			frequently asked questions | 
			questions | 
			order status | 

<xsl:for-each select="order_history/order">
			order number <xsl:value-of select="position()"/> |
</xsl:for-each>
			buy me
		</grammar>
	
		<filled>
			<assign name="form_pointer" expr="'productList'"/>
			<assign name="user_command" expr="userSaid"/>
			<goto next="#navigator"/>
		</filled>
				
	</field>
</form>

<!-- Now create the order detail forms --> 

<xsl:for-each select="order_history/order">
<xsl:variable name="order_detail_counter" select="position()"/>
<form id="order_{$order_detail_counter}">
	<noinput>
		<!-- This falls through to order status top level --> 
		<assign name="user_command" expr="'order status'"/>
		<goto next="#navigator"/>
	</noinput>
	
	<nomatch>
		<goto next="#errorHandler"/>
	</nomatch>

	<block>
		<assign name="form_pointer" expr="'order_{$order_detail_counter}'"/>
	</block>
	
	<field name="userSaid">

		<prompt bargein="true" timeout="1s">
			This order was placed on <sayas class="date">
			<xsl:value-of select="order_date/@sayas"/></sayas>.  
			<break msecs="500"/>
			The order consisted of 
<xsl:for-each select="product">
			quantity <xsl:value-of select="./@quantity"/> of product 
			<xsl:value-of select="/myrubberbands/product_list/product[@id=current()/@id]"/>
			<break msecs="500"/>
</xsl:for-each>
			The total of the order was 
			<sayas class="currency">
			$<xsl:value-of select="total_charge"/></sayas>.  
			The status of this order is 
			<xsl:value-of select="order_status"/>.  
		</prompt>
		
		<grammar type="application/x-jsgf">
			list | 
			product list | 
			more information |
			frequently asked questions | 
			questions | 
			order status | 
<xsl:for-each select="/myrubberbands/customer_record/order_history/order">
			order number <xsl:value-of select="position()"/> | 
</xsl:for-each>
			buy me
		</grammar>

		<filled>
			<assign name="form_pointer" expr="'productList'"/>
			<assign name="user_command" expr="userSaid"/>
			<goto next="#navigator"/>
		</filled>
				
	</field>
</form>
</xsl:for-each>

<form id="productList">
	<noinput>
		<assign name="user_command" expr="'main menu'"/>
		<goto next="#navigator"/>
	</noinput>
	
	<nomatch>
		<goto next="#errorHandler"/>
	</nomatch>
	
	<field name="userSaid">
	
		<prompt bargein="true" timeout="1s">
			This is a list of products available from my 
			rubber bands dot com.  
			You can say buy me to place an order.  
<xsl:for-each select="/myrubberbands/product_list/product">
			Product <xsl:value-of select="."/>.  Your price is 
			<sayas class="currency"> 
			$<xsl:value-of select="./@price"/></sayas>.  
			<break msecs="500"/>
</xsl:for-each>
		</prompt>
		
		<grammar type="application/x-jsgf">
			list | 
			product list | 
			more information |
			frequently asked questions | 
			questions | 
			order status | 
			buy me 
		</grammar>
	
		<filled>
			<assign name="form_pointer" expr="'productList'"/>
			<assign name="user_command" expr="userSaid"/>
			<goto next="#navigator"/>
		</filled>
				
	</field>
</form>

<!-- 
	Place Order, transfer the user to an operator. 
--> 

<form id="placeOrder">
	<block>
		<prompt bargein="false" timeout="1s">
			Transferring your call to customer service. 
		</prompt>
	</block>
	<transfer name="callSales" dest="MYRUBBERBND" 
		connecttimeout="30s" bridge="true"/>
	<block>
		<!-- 
			After the call, if the customer returns, send them back to 
			the main menu. 
		-->
		<goto next="#mainMenu"/>
	</block>
</form>


<!-- 
	A frequently asked questions list.  This is a static prompt. 
--> 
<form id="FAQ">

	<noinput>
		<assign name="user_command" expr="'main menu'"/>
		<goto next="#navigator"/>
	</noinput>
	
	<nomatch>
		<goto next="#FAQ"/>
	</nomatch>
	
	<field name="userSaid">
			
		<prompt bargein="true" timeout="1s">
			This is the my rubber bands dot com frequently asked questions list. 
			Did you know that my rubber bands dot com offers over a hundred 
			different types of rubberbands? 
			<break msecs="500"/>
			First question.  I keep losing my rubber bands.  Where should I 
			keep them? 
			<break msecs="500"/>
			You can keep rubber bands on a door knob.  That way they are 
			always nearby when needed.  
			<break msecs="500"/>
			Second question.  I am trying to shoot rubber bands.  What should 
			I do?
			<break msecs="500"/>
			You'll shoot your eye out!
		</prompt>		

		<grammar type="application/x-jsgf">
			list | 
			product list | 
			more information |
			frequently asked questions | 
			questions | 
			order status 
		</grammar>
	
		<filled>
			<assign name="form_pointer" expr="'FAQ'"/>
			<assign name="user_command" expr="userSaid"/>
			<goto next="#navigator"/>
		</filled>

	</field>	
</form>


<!-- 
	The navigator puts the user into the appropriate form based 
	on the last input.  
--> 
	
<form id="navigator">
	<block>
		<if cond="user_command == 'product list' || user_command == 'list'">
			<goto next="#productList"/>
		<elseif cond="user_command  == 'questions' || 
					user_command == 'frequently asked questions' || 
					user_command == 'more information'"/>
			<goto next="#FAQ"/>
		<elseif cond="user_command == 'order status'"/>
			<goto next="#orderStatus"/>
		<elseif cond="user_command == 'buy me'"/>
			<goto next="#placeOrder"/>	
			
<!--
	This part of the navigator is driven by the style sheet. 
-->

<xsl:for-each select="order_history/order">	
<xsl:variable name="order_counter" select="position()"/>
		<elseif cond="user_command == 'order number {$order_counter}'"/>
			<goto next="#order_{$order_counter}"/>
</xsl:for-each>
<!-- --> 				
		<else/>
			<goto next="#mainMenu"/>
		</if>
	</block>
</form>
	
	
<!-- 
	The errorHandler plays an error message.  If there have been more 	
	than three errors, ask the user to call back and hang up. 
--> 
<form id="errorHandler">
	<block>
		<assign name="session_error_count" expr="session_error_count + 1"/>
		<if cond="session_error_count &lt; 4">
			<prompt bargein="false" timeout="0.1s">
				I'm sorry, but I'm unable to understand you.  
			</prompt>
			<if cond="session_error_count &gt; 2">
				<prompt bargein="false" timeout="0.1s">
					It seems I am having trouble.  
				</prompt> 			
			</if>
			
			<goto next="#navigator"/>
		<else/>
			<prompt bargein="false" timeout="0.1s">
				I'm sorry, but I'm having a lot of difficulty 
				understanding you.  If you are in a noisy environment, 
				please call back later.  
			</prompt>
			<exit/>
		</if>
	</block>
</form>

</vxml>


</xsl:template>
<xsl:template match="product_list"/>
</xsl:stylesheet>




