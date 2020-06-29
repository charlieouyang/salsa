--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;

--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: salsa
--

-- INSERT INTO public.alembic_version (version_num) VALUES ('e3a1fba5d24c');



--
-- Data for Name: user_role; Type: TABLE DATA; Schema: public; Owner: salsa
--

INSERT INTO public.user_role (id, title, description) VALUES ('ad6382b5-50a7-40fa-91e8-c98f67005e40', 'Admin', 'Administrator');
INSERT INTO public.user_role (id, title, description) VALUES ('51484d2c-7a3d-4fe9-b10d-52d6e7408031', 'User', 'Regular user');


--
-- Data for Name: user_account; Type: TABLE DATA; Schema: public; Owner: salsa
--

--
-- password is abc
--
INSERT INTO public.user_account (id, name, email, password_hashed, extradata, created_at, updated_at, user_name, user_role_id) VALUES ('b3793c45-0b19-433d-a24d-9e9cd5952adf', 'Susanna Jiang', 'jiang.susanna@gmail.com', '$2b$12$JA6/fiuPQfJn3wzM0RJUeOvOOiT4p6fcmb7N1S0aFFWTKDRc6d8ii', '{}', NOW(), NOW(), 'susannajiang', '51484d2c-7a3d-4fe9-b10d-52d6e7408031');
--
-- password is abc
--
INSERT INTO public.user_account (id, name, email, password_hashed, extradata, created_at, updated_at, user_name, user_role_id) VALUES ('2ef9f33e-291a-4fb0-83db-d25031228986', 'Charlie Ou Yang', 'charlieouyang@gmail.com', '$2b$12$JA6/fiuPQfJn3wzM0RJUeOvOOiT4p6fcmb7N1S0aFFWTKDRc6d8ii', '{}', NOW(), NOW(), 'charlieouyang', '51484d2c-7a3d-4fe9-b10d-52d6e7408031');
--
-- password is abc
--
INSERT INTO public.user_account (id, name, email, password_hashed, extradata, created_at, updated_at, user_name, user_role_id) VALUES ('d6e517e1-75d7-48ca-9970-7e739d018eaa', 'Kevin Ou Yang', 'kevinouyang@gmail.com', '$2b$12$JA6/fiuPQfJn3wzM0RJUeOvOOiT4p6fcmb7N1S0aFFWTKDRc6d8ii', '{}', NOW(), NOW(), 'kevinouyang', '51484d2c-7a3d-4fe9-b10d-52d6e7408031');

--
-- password is 123
--
INSERT INTO public.user_account (id, name, email, password_hashed, extradata, created_at, updated_at, user_name, user_role_id) VALUES ('552b5eec-0fa2-4cd8-a78b-1b792b9bea92', 'God', 'god@email.com', '$2b$12$qB.WXaCRB1LG1MquzuAyw.ckwRYQPyKkzFDQhznTkealv4Zf//CCK', '{}', '2020-03-15 22:04:04.745385', '2020-03-15 22:04:04.745385', 'god', 'ad6382b5-50a7-40fa-91e8-c98f67005e40');

--
-- categories
--
INSERT INTO public.category (id, name, created_at, updated_at) VALUES ('88f0985c-a602-48c2-a15f-473492abfb1e', 'Food', NOW(), NOW());
INSERT INTO public.category (id, name, created_at, updated_at) VALUES ('ff2c3a9d-979a-43d4-a713-ac88ca8be9c3', 'Vegetable', NOW(), NOW());
INSERT INTO public.category (id, name, created_at, updated_at) VALUES ('bed8d549-c3c9-492b-b155-729ad151a9f9', 'Meat', NOW(), NOW());
INSERT INTO public.category (id, name, created_at, updated_at) VALUES ('8c982de6-bdb3-466e-90e2-afa8aa96262b', 'Stationary', NOW(), NOW());
INSERT INTO public.category (id, name, created_at, updated_at) VALUES ('c5043b26-fb8f-441d-83f9-86411309c95e', 'Electronics', NOW(), NOW());


--
-- PRODUCT beef short rib
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('c6a9ad8c-e208-4e41-9e1f-fcd87005df79', 't', 'Beef short ribs', 'Short ribs are a cut of beef taken from the brisket, chuck, plate, or rib areas of beef cattle. They consist of a short portion of the rib bone, which is overlain by meat which varies in thickness.', '{"https://thestayathomechef.com/wp-content/uploads/2014/10/Classic-Braised-Beef-Short-Ribs-3-small.jpg", "https://recipetineats.com/wp-content/uploads/2019/02/Slow-Cooked-Braised-Beef-Short-Ribs_3.jpg", "https://www.thespruceeats.com/thmb/XW_JuQ6Wk642VsnSQts9GIv-eLw=/2243x1682/smart/filters:no_upscale()/short-ribs-2500-56a20fc53df78cf772718708.jpg"}', 'b3793c45-0b19-433d-a24d-9e9cd5952adf', NOW(), NOW());

--
-- Product_category for beef short rib
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('b7dfee12-0c15-4240-b292-a51d5be118de', 'c6a9ad8c-e208-4e41-9e1f-fcd87005df79', '88f0985c-a602-48c2-a15f-473492abfb1e', NOW(), NOW());
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('c50fa9b7-9851-4694-ad2d-52bdab42d3ae', 'c6a9ad8c-e208-4e41-9e1f-fcd87005df79', 'bed8d549-c3c9-492b-b155-729ad151a9f9', NOW(), NOW());

--
-- LISTING beef short rib
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('5b9e48ef-70d6-4e2a-b701-fb96e25d9e09', 't', 'Delicious Beef Short Ribs', 'Selling very fresh beef short ribs. Come get them while they are still available', 99.99, 150.0, NOW(), NOW(), 'b3793c45-0b19-433d-a24d-9e9cd5952adf', 'c6a9ad8c-e208-4e41-9e1f-fcd87005df79');

--
-- PRODUCT beef steak
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('88eee8e2-d5e9-4d9b-bf62-7fc4b9483e45', 't', 'Beef steak', 'A steak is a meat generally sliced across the muscle fibers, potentially including a bone. Exceptions, in which the meat is sliced parallel to the fibers, include the skirt steak cut from the plate.', '{"https://www.jessicagavin.com/wp-content/uploads/2018/06/how-to-reverse-sear-a-steak-11.jpg", "https://www.recipetineats.com/wp-content/uploads/2016/07/Steak-Marinade_4.jpg?w=500&h=500&crop=1"}', 'b3793c45-0b19-433d-a24d-9e9cd5952adf', NOW(), NOW());
--
-- Product_category for beef steak
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('61eab18e-cfd9-4b0c-b91f-f8559c367c41', '88eee8e2-d5e9-4d9b-bf62-7fc4b9483e45', '88f0985c-a602-48c2-a15f-473492abfb1e', NOW(), NOW());
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('1ce49272-56a8-47b3-a882-e2cf9fb4bacf', '88eee8e2-d5e9-4d9b-bf62-7fc4b9483e45', 'bed8d549-c3c9-492b-b155-729ad151a9f9', NOW(), NOW());
--
-- LISTING beef steak
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('1e35025a-ae46-4f80-88ba-f2904730c190', 't', 'Delicious Beef Short Steak', 'Selling very fresh beef steaks. Includes rib eye, and new york strip. Very limited quantities available', 159.99, 50.0, NOW(), NOW(), 'b3793c45-0b19-433d-a24d-9e9cd5952adf', '88eee8e2-d5e9-4d9b-bf62-7fc4b9483e45');

--
-- PRODUCT bell peppers
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('c77eeeba-59f3-4a24-bf3d-9d0732a81550', 't', 'Bell peppers', 'The bell pepper is the fruit of plants in the Grossum cultivar group of the species Capsicum annuum. Cultivars of the plant produce fruits in different colours, including red, yellow, orange, green, white, and purple.', '{"https://www.chilipeppermadness.com/wp-content/uploads/2019/08/Bell-Peppers.jpg", "https://www.almanac.com/sites/default/files/image_nodes/bell-peppers-assorted-crop.jpg"}', 'b3793c45-0b19-433d-a24d-9e9cd5952adf', NOW(), NOW());
--
-- Product_category for bell peppers
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('59a93fcf-f5ce-46e9-9bad-03eb8c34496c', 'c77eeeba-59f3-4a24-bf3d-9d0732a81550', '88f0985c-a602-48c2-a15f-473492abfb1e', NOW(), NOW());
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('fb5cbf3b-1aa7-4abc-a1f3-ae5231abc237', 'c77eeeba-59f3-4a24-bf3d-9d0732a81550', 'ff2c3a9d-979a-43d4-a713-ac88ca8be9c3', NOW(), NOW());
--
-- LISTING bell peppers
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('e74e7ab4-150d-4039-8e8e-f78674c5f715', 't', 'Delicious Bell Peppers', 'Selling very fresh bell peppers. Come get them while they are still available. Very limited quantities', 4.99, 100, NOW(), NOW(), 'b3793c45-0b19-433d-a24d-9e9cd5952adf', 'c77eeeba-59f3-4a24-bf3d-9d0732a81550');

--
-- PRODUCT pens
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('04c77cf9-0659-4670-9d0e-fa5b603ece02', 't', 'Pens', 'A pen is a common writing instrument used to apply ink to a surface, usually paper, for writing or drawing. Historically, reed pens, quill pens, and dip pens were used, with a nib dipped in ink.', '{"https://pyxis.nymag.com/v1/imgs/3aa/964/849eb1e0f85e7a3301637636400259ad3e-sailor-pen.2x.rhorizontal.w600.jpg", "https://cdn.shopify.com/s/files/1/0036/4806/1509/products/s0146609_40463d18-eb8e-4a1a-affb-cab0462c85ff.jpg?v=1582722497"}', 'd6e517e1-75d7-48ca-9970-7e739d018eaa', NOW(), NOW());
--
-- Product_category for pens
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('f2d231d0-7403-43f9-a431-1b46cc728d23', '04c77cf9-0659-4670-9d0e-fa5b603ece02', '8c982de6-bdb3-466e-90e2-afa8aa96262b', NOW(), NOW());
--
-- LISTING pens
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('09565923-848b-4a2c-bae4-a06c8fd61487', 't', 'Very cool pens', 'Selling very cool pens. Come get them while they are still available. Very limited quantities', 1.99, 1000, NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', '04c77cf9-0659-4670-9d0e-fa5b603ece02');

--
-- PRODUCT pencils
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('475cb5fb-04c5-47ca-9e2a-a90678a22fad', 't', 'Pencils', 'A pencil is an implement for writing or drawing, constructed of a narrow, solid pigment core in a protective casing that prevents the core from being broken and/or marking the user''s hand.', '{"https://34t9wx3d3efh36333w49fxon-wpengine.netdna-ssl.com/wp-content/uploads/Single-Pencil-1-1030x488.jpg", "https://cdn.shopify.com/s/files/1/0036/4806/1509/products/s0265048_ddf70d6e-ed81-47bf-b3f4-3aeaaa79e18d_290x@2x.progressive.jpg?v=1582209376_290x@2x.progressive.jpg"}', 'd6e517e1-75d7-48ca-9970-7e739d018eaa', NOW(), NOW());
--
-- Product_category for pencils
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('b3161332-d625-437e-9312-143d2b1b324f', '475cb5fb-04c5-47ca-9e2a-a90678a22fad', '8c982de6-bdb3-466e-90e2-afa8aa96262b', NOW(), NOW());
--
-- LISTING pencils
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('3c790059-7f4e-4729-bb9b-ca96958e6e96', 't', 'Very cool pencils', 'Selling very cool pencils. Come get them while they are still available. Very limited quantities', 0.99, 9000, NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', '475cb5fb-04c5-47ca-9e2a-a90678a22fad');

--
-- PRODUCT erasers
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('c4732bb8-d768-4f22-9685-7b155a394f91', 't', 'Erasers', 'An eraser (also called a rubber outside the United States,[1] from the material first used) is an article of stationery that is used for removing marks from paper or skin (e.g. parchment or vellum). Erasers have a rubbery consistency and come in a variety of shapes, sizes and colours.', '{"https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Office-pink-erasers.jpg/600px-Office-pink-erasers.jpg", "https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Pencil_Eraser.jpg/440px-Pencil_Eraser.jpg"}', 'd6e517e1-75d7-48ca-9970-7e739d018eaa', NOW(), NOW());
--
-- Product_category for erasers
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('39a81c2c-b773-45c7-a10c-dbe50994d50e', 'c4732bb8-d768-4f22-9685-7b155a394f91', '8c982de6-bdb3-466e-90e2-afa8aa96262b', NOW(), NOW());
--
-- LISTING erasers
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('c899fc36-7439-45ed-a0dd-fe81ae63ac41', 't', 'Very cool erasers', 'Selling very cool erasers. Come get them while they are still available. Very limited quantities', 0.19, 100000, NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', 'c4732bb8-d768-4f22-9685-7b155a394f91');

--
-- PRODUCT rulers
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('3611a424-b332-43e1-9c06-80f73aeb3fec', 't', 'Rulers', 'A ruler, sometimes called a rule or line gauge, is a device used in geometry and technical drawing, as well as the engineering and construction industries, to measure distances or draw straight lines.', '{"https://cdn.shopify.com/s/files/1/0036/4806/1509/products/s0764277_e0dcee8a-79a8-44ee-a5c5-c67b088006b4_290x@2x.progressive.jpg?v=1582206155_290x@2x.progressive.jpg", "https://images.uline.com/is/image/content/dam/images/H/H7000/H-6560_1_CI.jpg?&qlt=80&wid=400&hei=300&op_usm=1,1,1&iccEmbed=1&icc=AdobeRGB"}', 'd6e517e1-75d7-48ca-9970-7e739d018eaa', NOW(), NOW());
--
-- Product_category for rulers
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('f1513412-d8b4-4f6c-807e-d735aaea7c39', '3611a424-b332-43e1-9c06-80f73aeb3fec', '8c982de6-bdb3-466e-90e2-afa8aa96262b', NOW(), NOW());
--
-- LISTING rulers
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('c02300e7-88e7-48ae-85be-a3fbc9a96aa3', 't', 'Very cool rulers', 'Selling very cool rulers. Come get them while they are still available. Very limited quantities', 2.99, 2000, NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', '3611a424-b332-43e1-9c06-80f73aeb3fec');

--
-- PRODUCT calculators
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('277ff02e-a601-4bcf-8e7a-4409a6a79d6d', 't', 'Calculators', 'An electronic calculator is typically a portable electronic device used to perform calculations, ranging from basic arithmetic to complex mathematics.', '{"https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Casio_calculator_JS-20WK_in_201901_002.jpg/340px-Casio_calculator_JS-20WK_in_201901_002.jpg", "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Casio-fx115ES-5564.jpg/340px-Casio-fx115ES-5564.jpg"}', 'd6e517e1-75d7-48ca-9970-7e739d018eaa', NOW(), NOW());
--
-- Product_category for calculators
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('e7c7f0c6-bc8d-40c7-9517-eed47c24530b', '277ff02e-a601-4bcf-8e7a-4409a6a79d6d', '8c982de6-bdb3-466e-90e2-afa8aa96262b', NOW(), NOW());
--
-- LISTING calculators
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('24ad7b6d-b44c-49e8-b100-46122f735731', 't', 'Very cool calculators', 'Selling very cool calculators. Come get them while they are still available. Very limited quantities', 20.99, 100, NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', '277ff02e-a601-4bcf-8e7a-4409a6a79d6d');

--
-- PRODUCT macbook
--
INSERT INTO public.product (id , active , name , description , image_urls , user_id , created_at , updated_at) VALUES ('1b8f5698-3905-4ed6-9b37-61487e660a3e', 't', 'Macbooks', 'The MacBook Pro (sometimes unofficially abbreviated as MBP[1]) is a line of Macintosh portable computers introduced in January 2006, by Apple Inc. It is the higher-end model of the MacBook family, sitting above the consumer-focused MacBook Air, and is available in 13-inch and 16-inch screen sizes. A 17-inch version was sold from April 2006 to June 2012.', '{"https://cnet4.cbsistatic.com/img/JKKeCYTf8W1a_PiR_WcNXz725ZU=/1200x675/2019/11/12/84e1159c-b8cb-4349-9e3b-3c37cc78945f/36-macbook-pro-16-inch.jpg", "https://i.pcmag.com/imagery/reviews/038Dr5TVEpwIv8rCljx6UcF-14..v_1588802180.jpg"}', '2ef9f33e-291a-4fb0-83db-d25031228986', NOW(), NOW());
--
-- Product_category for macbook
--
INSERT INTO public.product_category (id, product_id, category_id, created_at, updated_at) VALUES ('bbd69932-90e0-4d72-822a-7c7481813799', '1b8f5698-3905-4ed6-9b37-61487e660a3e', 'c5043b26-fb8f-441d-83f9-86411309c95e', NOW(), NOW());
--
-- LISTING macbook
--
INSERT INTO public.listing (id , active , name , description , price , amount_available , created_at , updated_at , user_id , product_id) VALUES ('43ed94d0-71a6-45a4-8dc7-effdbdb7aa45', 't', 'Very powerful macbooks', 'Selling very legit and powerful macbook pros. Come get them while they are still available. Very limited quantities', 1999.99, 100, NOW(), NOW(), '2ef9f33e-291a-4fb0-83db-d25031228986', '1b8f5698-3905-4ed6-9b37-61487e660a3e');


--
-- PURCHASE charlieouyang buy beef short rib from susannajiang
--
INSERT INTO public.purchase (id , amount , notes, created_at , updated_at , user_id , listing_id, buyer_complete, seller_complete) VALUES ('13c1e58b-7ee0-4d70-9fcb-e694cfe955b7', 10, 'Will pickup myself', NOW(), NOW(), '2ef9f33e-291a-4fb0-83db-d25031228986', '5b9e48ef-70d6-4e2a-b701-fb96e25d9e09', 'f', 'f');
--
-- REVIEW for purchase
--
INSERT INTO public.review (id , name , description , numstars , created_at , updated_at , user_id , product_id, purchase_id) VALUES ('e7f47cc2-7e64-4d0e-9ac8-d3c619f59c3e', 'Very delicious beef short ribs', 'Short ribs are very good. Very thick and juicy. Will by again', 5, NOW(), NOW(), '2ef9f33e-291a-4fb0-83db-d25031228986', 'c6a9ad8c-e208-4e41-9e1f-fcd87005df79', '13c1e58b-7ee0-4d70-9fcb-e694cfe955b7');

--
-- PURCHASE kevinouyang buy beef short rib from susannajiang
--
INSERT INTO public.purchase (id , amount , notes,  created_at , updated_at , user_id , listing_id, buyer_complete, seller_complete) VALUES ('deee3c83-637a-47dc-998e-9022268cff25', 20, 'I will call you to cooridinate the drop off', NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', '5b9e48ef-70d6-4e2a-b701-fb96e25d9e09', 'f', 'f');
--
-- REVIEW for purchase
--
INSERT INTO public.review (id , name , description , numstars , created_at , updated_at , user_id , product_id, purchase_id) VALUES ('36c6005a-05a0-4ffc-adc4-fa7250e1a9fb', 'Pretty good short ribs', 'Short ribs okay. Very thick, which is very good but it wasn''t as fresh as I liked.', 4, NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', 'c6a9ad8c-e208-4e41-9e1f-fcd87005df79', 'deee3c83-637a-47dc-998e-9022268cff25');

--
-- PURCHASE kevinouyang buy bell peppers from susannajiang
--
INSERT INTO public.purchase (id , amount , notes,  created_at , updated_at , user_id , listing_id, buyer_complete, seller_complete) VALUES ('9df2b070-c6be-4d8c-8880-4688dfc6acbc', 3, 'I will call you to cooridinate the drop off', NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', 'e74e7ab4-150d-4039-8e8e-f78674c5f715', 'f', 'f');
--
-- REVIEW for purchase
--
INSERT INTO public.review (id , name , description , numstars , created_at , updated_at , user_id , product_id, purchase_id) VALUES ('e1f85f1e-9c87-4ae2-bd66-8e59b483cde2', 'Pretty good bell peppers', 'Pretty fresh. Costco quality. Better than walmart', 4, NOW(), NOW(), 'd6e517e1-75d7-48ca-9970-7e739d018eaa', 'c77eeeba-59f3-4a24-bf3d-9d0732a81550', '9df2b070-c6be-4d8c-8880-4688dfc6acbc');

--
-- PURCHASE charlieouyang buy beef steak from susannajiang
--
INSERT INTO public.purchase (id , amount , notes,  created_at , updated_at , user_id , listing_id, buyer_complete, seller_complete) VALUES ('5c4d84ee-d757-4f03-b23d-f50ea17e17cd', 3, 'Will pickup myself', NOW(), NOW(), '2ef9f33e-291a-4fb0-83db-d25031228986', '1e35025a-ae46-4f80-88ba-f2904730c190', 'f', 'f');
--
-- REVIEW for purchase
--
INSERT INTO public.review (id , name , description , numstars , created_at , updated_at , user_id , product_id, purchase_id) VALUES ('f29fc176-76bc-4075-93ba-c2ba43a98b8a', 'Extremely disappointed', 'Steak was very thin. Quality of the meat was bad. Will not buy again', 1, NOW(), NOW(), '2ef9f33e-291a-4fb0-83db-d25031228986', '88eee8e2-d5e9-4d9b-bf62-7fc4b9483e45', '5c4d84ee-d757-4f03-b23d-f50ea17e17cd');

--
-- PURCHASE susannajiang buy macbook from charlieouyang
--
INSERT INTO public.purchase (id , amount , notes,  created_at , updated_at , user_id , listing_id, buyer_complete, seller_complete) VALUES ('d859b218-3509-4216-96a6-7844e6f00379', 1, 'I will come pick it up in 1 week', NOW(), NOW(), 'b3793c45-0b19-433d-a24d-9e9cd5952adf', '43ed94d0-71a6-45a4-8dc7-effdbdb7aa45', 'f', 'f');
--
-- REVIEW for purchase
--
INSERT INTO public.review (id , name , description , numstars , created_at , updated_at , user_id , product_id, purchase_id) VALUES ('122c0a46-57a9-467d-8265-48a7b5c80db6', 'Wow this macbook is amazing!', 'Brand new macbook pro! Very impressed. Definitely recommend to others!', 5, NOW(), NOW(), 'b3793c45-0b19-433d-a24d-9e9cd5952adf', '1b8f5698-3905-4ed6-9b37-61487e660a3e', 'd859b218-3509-4216-96a6-7844e6f00379');

--
-- PostgreSQL database dump complete
--

