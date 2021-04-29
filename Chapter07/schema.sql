DROP TABLE customer;
CREATE TABLE customer 
(
	customer_id	INTEGER AUTO_INCREMENT PRIMARY KEY,
	firstname	VARCHAR(30) NOT NULL,
	middle		VARCHAR(30),
	lastname	VARCHAR(30) NOT NULL,
	username_email	VARCHAR(40) NOT NULL,
	password_pin	VARCHAR(20),
	date_joined	DATETIME,
	date_lastchg	TIMESTAMP, 

	INDEX idx_c_lname (lastname),
	INDEX idx_c_joined (date_joined),
	INDEX idx_c_username (username_email)
);
INSERT INTO customer (firstname, middle, lastname, username_email, password_pin, 
date_joined) VALUES ('John', 'Quincy', 'Public', 'jqp@foo.foo.com', 'bar', 
CURRENT_TIMESTAMP); 
INSERT INTO customer (firstname, middle, lastname, username_email, password_pin, 
date_joined) VALUES ('Jane', 'Anne', 'Doe', 'jane@anonymous.net', 'bigsecret', 
CURRENT_TIMESTAMP); 

DROP TABLE customer_billing_data; 
CREATE TABLE customer_billing_data
(
	customer_id	INTEGER REFERENCES customer.customer_id,
	cc_type		VARCHAR(20),
	cc_number	VARCHAR(17),
	cc_expire_mo	INTEGER,
	cc_expire_yr	INTEGER,

	UNIQUE INDEX idx_cbd_cid (customer_id, cc_number),
	INDEX idx_cbd_type (cc_type),
	INDEX idx_expire_mo_year (cc_expire_mo, cc_expire_yr)
);
INSERT INTO customer_billing_data VALUES (1, 'Green Card', '1234567890123456', 9, 2002); 
INSERT INTO customer_billing_data VALUES (2, 'Blue Card', '9876543210987654', 7, 2003); 


DROP TABLE customer_address_type; 
CREATE TABLE customer_address_type
(
	customer_address_type INTEGER PRIMARY KEY,
	description_of_type VARCHAR(50)
);
INSERT INTO customer_address_type VALUES (1, 'Ship To Address'); 
INSERT INTO customer_address_type VALUES (2, 'Billing Address'); 
INSERT INTO customer_address_type VALUES (3, 'Billing And Shipping Address'); 
INSERT INTO customer_address_type VALUES (4, 'Alternate E-Mail Address'); 


DROP TABLE customer_address; 
CREATE TABLE customer_address
(
	customer_id	INTEGER REFERENCES customer.customer_id, 
	customer_address_type	
			INTEGER REFERENCES 
			customer_address_type.customer_address_type,
	email		VARCHAR(40),
	phone		VARCHAR(15),
	address1	VARCHAR(50), 
	address2	VARCHAR(50),
	city		VARCHAR(50),
	state_or_prov	VARCHAR(10),
	postalcode	VARCHAR(12),

	UNIQUE INDEX idx_ca_customer_id (customer_id, customer_address_type), 
	INDEX idx_ca_email (email), 
	INDEX idx_ca_phone (phone),
	INDEX idx_ca_city (city),
	INDEX idx_ca_postalcode (postalcode)
);
INSERT INTO customer_address VALUES (1, 3, '', '8585551212', '123 Santa Barbara Place', 
'', 'San Diego', 'CA', '92109'); 
INSERT INTO customer_address VALUES (1, 1, '', '7605551212', '4321 La Place Ct', 
'Ste 306', 'Carlsbad', 'CA', '92008'); 
INSERT INTO customer_address VALUES (1, 4, 'john@his.office', '', '', 
'', '', '', ''); 
INSERT INTO customer_address VALUES (2, 1, '', '2155551212', '11 Main Street', 
'', 'Doylestown', 'PA', '18901'); 
INSERT INTO customer_address VALUES (2, 2, '', '6105551212', '1231 State Street', 
'Suite 14', 'Doylestown', 'PA', '18901'); 



DROP TABLE product; 
CREATE TABLE product 
(
	product_id	INTEGER AUTO_INCREMENT PRIMARY KEY,
	product_name	VARCHAR(50),
	product_desc	VARCHAR(80),
	price		FLOAT, 
	add_date	DATETIME,
	last_modified	TIMESTAMP, 

	INDEX idx_p_add_date (add_date)
);
INSERT INTO product (product_name, product_desc, price, add_date) VALUES ('MIXED1000', 
'Mixed Bag of 1000 Rubber Bands', 1.99, CURRENT_TIMESTAMP); 
INSERT INTO product (product_name, product_desc, price, add_date) VALUES ('MIXED5000', 
'Mixed Bag of 5000 Rubber Bands', 4.09, CURRENT_TIMESTAMP); 
INSERT INTO product (product_name, product_desc, price, add_date) VALUES ('RED1000', 
'Bag of 1000 Red Rubber Bands', 2.19, CURRENT_TIMESTAMP); 
INSERT INTO product (product_name, product_desc, price, add_date) VALUES ('RED10000', 
'Bag of 10000 Red Rubber Bands', 17.49, CURRENT_TIMESTAMP); 
INSERT INTO product (product_name, product_desc, price, add_date) VALUES ('BLUE1000', 
'Bag of 1000 Blue Rubber Bands', 0.99, CURRENT_TIMESTAMP); 
INSERT INTO product (product_name, product_desc, price, add_date) VALUES ('BLUE10000', 
'Bag of 10000 Blue Rubber Bands', 8.99, CURRENT_TIMESTAMP); 


DROP TABLE order_status_type; 
CREATE TABLE order_status_type
(
	order_status_type INTEGER PRIMARY KEY,
	description_of_type VARCHAR(50)
);
INSERT INTO order_status_type VALUES (1, 'Processing'); 
INSERT INTO order_status_type VALUES (2, 'Sent To Warehouse'); 
INSERT INTO order_status_type VALUES (3, 'Shipped'); 
INSERT INTO order_status_type VALUES (4, 'Finished');


DROP TABLE customer_order; 
CREATE TABLE customer_order 
(
	order_id		INTEGER AUTO_INCREMENT PRIMARY KEY,
	customer_id		INTEGER REFERENCES customer.customer_id,
	shipping_address 	INTEGER REFERENCES customer_address.address_type,	
	order_date		DATETIME,
	order_status_type	INTEGER REFERENCES order_status_type.order_status_type,
	tax			FLOAT, 
	shipping_charge		FLOAT,
	total_charge		FLOAT, 

	INDEX idx_co_cid (customer_id),	
	INDEX idx_co_date (order_date),
	INDEX idx_co_status (order_status_type) 
);
INSERT INTO customer_order (customer_id, shipping_address, order_date, 
order_status_type, tax, shipping_charge, total_charge) 
VALUES (1, 1, CURRENT_TIMESTAMP, 1, 0.09, 0.40, 2.48); 
INSERT INTO customer_order (customer_id, shipping_address, order_date, 
order_status_type, tax, shipping_charge, total_charge) 
VALUES (1, 3, CURRENT_TIMESTAMP, 1, 0.15, 0.78, 3.99); 


DROP TABLE customer_order_product;
CREATE TABLE customer_order_product
(
	order_id	INTEGER REFERENCES customer_order.order_id,
	product_id		INTEGER REFERENCES product.product_id, 
	quantity		INTEGER, 

	UNIQUE INDEX idx_cop_order (order_id, product_id),
	INDEX idx_cop_quantity (quantity)

);
INSERT INTO customer_order_product (order_id, product_id, quantity) 
VALUES (1,1,3); 
INSERT INTO customer_order_product (order_id, product_id, quantity) 
VALUES (1,3,1); 
INSERT INTO customer_order_product (order_id, product_id, quantity) 
VALUES (2,4,5); 
INSERT INTO customer_order_product (order_id, product_id, quantity) 
VALUES (2,2,1);

