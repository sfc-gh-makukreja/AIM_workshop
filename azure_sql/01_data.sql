/*******************************************************************************
 * TASTY BYTES — Sample Data
 * Insert statements for all tables in dependency order.
 ******************************************************************************/


-- ============================================================================
-- 1. Country
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.Country ON;

INSERT INTO TastyBytes.Country (CountryID, CountryName, CountryCode, CurrencyCode, TaxRate, IsActive)
VALUES
    (1,  N'United States',  'USA', 'USD', 8.50,  1),
    (2,  N'Canada',         'CAN', 'CAD', 13.00, 1),
    (3,  N'Mexico',         'MEX', 'MXN', 16.00, 1),
    (4,  N'United Kingdom', 'GBR', 'GBP', 20.00, 1),
    (5,  N'Germany',        'DEU', 'EUR', 19.00, 1),
    (6,  N'Japan',          'JPN', 'JPY', 10.00, 1),
    (7,  N'Brazil',         'BRA', 'BRL', 17.00, 1),
    (8,  N'Australia',      'AUS', 'AUD', 10.00, 1);

SET IDENTITY_INSERT TastyBytes.Country OFF;
GO

-- ============================================================================
-- 2. City
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.City ON;

INSERT INTO TastyBytes.City (CityID, CityName, CountryID, StateProvince, Latitude, Longitude, PopulationSize)
VALUES
    (1,  N'New York',       1, N'New York',        40.712776,  -74.005974, 8336817),
    (2,  N'Los Angeles',    1, N'California',       34.052235, -118.243683, 3979576),
    (3,  N'Chicago',        1, N'Illinois',         41.878113,  -87.629799, 2693976),
    (4,  N'Toronto',        2, N'Ontario',          43.653225,  -79.383186, 2731571),
    (5,  N'Vancouver',      2, N'British Columbia', 49.282729, -123.120738, 631486),
    (6,  N'Mexico City',    3, N'CDMX',             19.432608,  -99.133209, 9209944),
    (7,  N'London',         4, N'England',          51.507351,   -0.127758, 8982000),
    (8,  N'Berlin',         5, N'Berlin',           52.520007,   13.404954, 3644826),
    (9,  N'Tokyo',          6, N'Tokyo',            35.689487,  139.691711, 13960000),
    (10, N'Sao Paulo',      7, N'Sao Paulo',       -23.550520,  -46.633308, 12325232),
    (11, N'Sydney',         8, N'New South Wales',  -33.868820,  151.209296, 5312000),
    (12, N'San Francisco',  1, N'California',       37.774929, -122.419418, 873965);

SET IDENTITY_INSERT TastyBytes.City OFF;
GO

-- ============================================================================
-- 3. FoodTruck
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.FoodTruck ON;

INSERT INTO TastyBytes.FoodTruck (TruckID, TruckName, LicensePlate, CityID, TruckConfig, YearPurchased, MaxCapacity, IsOperational)
VALUES
    (1,  N'Smokin'' BBQ',          'BBQ-001',  1,  '{"Equipment":[{"Name":"Smoker","Type":"Grill","InstallDate":"2021-03-15","IsOperational":true},{"Name":"Fryer","Type":"Deep Fryer","InstallDate":"2021-03-15","IsOperational":true}]}', 2021, 600, 1),
    (2,  N'Taco Loco',            'TAC-002',  2,  '{"Equipment":[{"Name":"Flat Top Grill","Type":"Grill","InstallDate":"2022-01-10","IsOperational":true},{"Name":"Steam Table","Type":"Warmer","InstallDate":"2022-01-10","IsOperational":true}]}', 2022, 500, 1),
    (3,  N'Noodle Express',       'NOO-003',  9,  '{"Equipment":[{"Name":"Wok Station","Type":"Burner","InstallDate":"2020-06-01","IsOperational":true}]}', 2020, 450, 1),
    (4,  N'Burger Bliss',         'BUR-004',  1,  '{"Equipment":[{"Name":"Char Grill","Type":"Grill","InstallDate":"2023-02-20","IsOperational":true},{"Name":"Milkshake Machine","Type":"Beverage","InstallDate":"2023-02-20","IsOperational":true}]}', 2023, 550, 1),
    (5,  N'Pizza Wagon',          'PIZ-005',  7,  '{"Equipment":[{"Name":"Wood Fire Oven","Type":"Oven","InstallDate":"2021-09-01","IsOperational":true}]}', 2021, 400, 1),
    (6,  N'Curry in a Hurry',     'CUR-006',  4,  '{"Equipment":[{"Name":"Tandoor Oven","Type":"Oven","InstallDate":"2022-05-15","IsOperational":true},{"Name":"Rice Cooker","Type":"Cooker","InstallDate":"2022-05-15","IsOperational":true}]}', 2022, 500, 1),
    (7,  N'Le Crepe Mobile',      'CRE-007',  8,  '{"Equipment":[{"Name":"Crepe Maker","Type":"Griddle","InstallDate":"2023-04-01","IsOperational":true}]}', 2023, 350, 1),
    (8,  N'Seoul Food',           'SEO-008',  3,  '{"Equipment":[{"Name":"Korean BBQ Grill","Type":"Grill","InstallDate":"2022-11-10","IsOperational":true}]}', 2022, 500, 1),
    (9,  N'Poutine Palace',       'POU-009',  5,  '{"Equipment":[{"Name":"Fryer","Type":"Deep Fryer","InstallDate":"2021-07-20","IsOperational":true},{"Name":"Gravy Warmer","Type":"Warmer","InstallDate":"2021-07-20","IsOperational":false}]}', 2021, 400, 1),
    (10, N'Churros & More',       'CHU-010',  6,  '{"Equipment":[{"Name":"Churro Fryer","Type":"Deep Fryer","InstallDate":"2023-01-05","IsOperational":true}]}', 2023, 350, 1),
    (11, N'The Acai Bowl',        'ACA-011', 10,  NULL, 2022, 300, 1),
    (12, N'Fish & Chips Express',  'FIS-012', 11, NULL, 2020, 450, 0);

SET IDENTITY_INSERT TastyBytes.FoodTruck OFF;
GO

-- ============================================================================
-- 4. Menu
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.Menu ON;

INSERT INTO TastyBytes.Menu (MenuID, MenuName, TruckID, CuisineType, MenuDescription, BasePriceTier, IsSeasonalMenu, EffectiveFrom, EffectiveTo)
VALUES
    (1,  N'BBQ Classics',       1,  N'American BBQ',  N'Slow-smoked meats and classic sides',              15.00, 0, '2021-04-01', NULL),
    (2,  N'Taco Tuesday',       2,  N'Mexican',       N'Authentic street tacos with fresh salsas',          10.00, 0, '2022-02-01', NULL),
    (3,  N'Ramen & Udon',       3,  N'Japanese',      N'Traditional noodle soups and sides',                12.00, 0, '2020-07-01', NULL),
    (4,  N'Burger Board',       4,  N'American',      N'Hand-crafted burgers with gourmet toppings',        14.00, 0, '2023-03-01', NULL),
    (5,  N'Neapolitan Nights',  5,  N'Italian',       N'Wood-fired pizzas with imported ingredients',       16.00, 0, '2021-10-01', NULL),
    (6,  N'Spice Route',        6,  N'Indian',        N'Curries, biryanis, and tandoori specialties',       13.00, 0, '2022-06-01', NULL),
    (7,  N'Parisian Crepes',    7,  N'French',        N'Sweet and savory crepes made to order',             11.00, 0, '2023-05-01', NULL),
    (8,  N'K-BBQ Street',       8,  N'Korean',        N'Korean BBQ bowls and kimchi plates',                13.00, 0, '2022-12-01', NULL),
    (9,  N'Poutine Menu',       9,  N'Canadian',      N'Classic and loaded poutine variations',             12.00, 0, '2021-08-01', NULL),
    (10, N'Dulce Vida',        10,  N'Mexican Desserts', N'Churros, tres leches, and seasonal sweets',       8.00, 1, '2023-02-01', '2023-12-31'),
    (11, N'Acai Bowls',        11,  N'Brazilian',     N'Fresh acai bowls with tropical toppings',            10.00, 0, '2022-06-01', NULL),
    (12, N'Summer BBQ Special',  1,  N'American BBQ', N'Limited-time summer BBQ items',                     18.00, 1, '2024-06-01', '2024-09-30');

SET IDENTITY_INSERT TastyBytes.Menu OFF;
GO

-- ============================================================================
-- 5. MenuItem (skip PriceWithTax computed col, RowVer auto-generated)
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.MenuItem ON;

INSERT INTO TastyBytes.MenuItem (MenuItemID, MenuID, ItemName, ItemDescription, BasePrice, CalorieCount, IsVegetarian, IsGlutenFree, IsSpicy)
VALUES
    (1,  1,  N'Pulled Pork Sandwich',  N'12-hour smoked pulled pork on brioche bun',       12.99, 680,  0, 0, 0),
    (2,  1,  N'Brisket Plate',         N'Sliced brisket with coleslaw and cornbread',       16.99, 850,  0, 0, 0),
    (3,  1,  N'Smoked Wings',          N'Hickory smoked wings with house BBQ sauce',        10.99, 520,  0, 1, 1),
    (4,  2,  N'Carne Asada Taco',      N'Grilled steak with onions and cilantro',            4.50, 280,  0, 1, 0),
    (5,  2,  N'Al Pastor Taco',        N'Marinated pork with pineapple',                     4.50, 310,  0, 1, 1),
    (6,  2,  N'Veggie Taco',           N'Grilled peppers, onions, and black beans',           3.99, 220,  1, 1, 0),
    (7,  3,  N'Tonkotsu Ramen',        N'Rich pork bone broth with chashu and egg',         14.99, 720,  0, 0, 0),
    (8,  3,  N'Spicy Miso Ramen',      N'Miso broth with chili oil and ground pork',        14.99, 690,  0, 0, 1),
    (9,  3,  N'Vegetable Udon',        N'Thick udon noodles in dashi broth with veggies',   12.99, 480,  1, 0, 0),
    (10, 4,  N'Classic Smash Burger',   N'Double smashed patty with American cheese',        11.99, 750,  0, 0, 0),
    (11, 4,  N'Mushroom Swiss Burger',  N'Beef patty with sauteed mushrooms and Swiss',      13.99, 820,  0, 0, 0),
    (12, 4,  N'Crispy Chicken Burger',  N'Fried chicken breast with spicy mayo',             12.99, 700,  0, 0, 1),
    (13, 5,  N'Margherita Pizza',       N'San Marzano tomatoes, fresh mozzarella, basil',    13.99, 600,  1, 0, 0),
    (14, 5,  N'Pepperoni Pizza',        N'Classic pepperoni with mozzarella',                14.99, 720,  0, 0, 0),
    (15, 6,  N'Butter Chicken',         N'Creamy tomato curry with tender chicken',          13.99, 650,  0, 1, 0),
    (16, 6,  N'Lamb Biryani',           N'Aromatic basmati rice with spiced lamb',           15.99, 780,  0, 1, 1),
    (17, 6,  N'Paneer Tikka Masala',    N'Cottage cheese in spiced tomato gravy',            12.99, 550,  1, 1, 1),
    (18, 7,  N'Nutella Banana Crepe',   N'Sweet crepe with Nutella and fresh banana',         9.99, 480,  1, 0, 0),
    (19, 7,  N'Ham & Cheese Crepe',     N'Savory crepe with ham, Gruyere, and bechamel',     11.99, 520,  0, 0, 0),
    (20, 8,  N'Bulgogi Bowl',           N'Marinated beef with rice and pickled veggies',     14.99, 680,  0, 1, 0),
    (21, 8,  N'Kimchi Fried Rice',      N'Fried rice with aged kimchi and fried egg',        11.99, 590,  0, 1, 1),
    (22, 9,  N'Classic Poutine',        N'Fries, cheese curds, and brown gravy',             10.99, 740,  1, 0, 0),
    (23, 9,  N'Loaded Poutine',         N'Classic poutine with pulled pork and jalapenos',   13.99, 920,  0, 0, 1),
    (24, 10, N'Churros con Chocolate',  N'Fresh churros with warm chocolate dipping sauce',   7.99, 380,  1, 0, 0),
    (25, 11, N'Tropical Acai Bowl',     N'Acai blend with granola, banana, and coconut',     11.99, 420,  1, 1, 0),
    (26, 11, N'Berry Blast Acai Bowl',  N'Acai with mixed berries, honey, and chia seeds',   12.99, 390,  1, 1, 0);

SET IDENTITY_INSERT TastyBytes.MenuItem OFF;
GO

-- ============================================================================
-- 6. Customer
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.Customer ON;

INSERT INTO TastyBytes.Customer (CustomerID, FirstName, LastName, Email, PhoneNumber, PreferredCityID, LoyaltyPoints, MemberSince, IsActive)
VALUES
    (1,  N'Alice',    N'Johnson',    'alice.johnson@email.com',   '212-555-0101', 1,  350, '2022-01-15', 1),
    (2,  N'Bob',      N'Martinez',   'bob.martinez@email.com',    '310-555-0202', 2,  120, '2022-03-20', 1),
    (3,  N'Charlie',  N'Wong',       'charlie.wong@email.com',    '416-555-0303', 4,  580, '2021-11-10', 1),
    (4,  N'Diana',    N'Smith',      'diana.smith@email.com',     '312-555-0404', 3,  210, '2023-02-01', 1),
    (5,  N'Erik',     N'Tanaka',     'erik.tanaka@email.com',     '813-555-0505', 9,  890, '2021-06-15', 1),
    (6,  N'Fatima',   N'Al-Hassan',  'fatima.alhassan@email.com', '020-555-0606', 7,  440, '2022-08-22', 1),
    (7,  N'George',   N'Mueller',    'george.mueller@email.com',  '030-555-0707', 8,   75, '2023-09-01', 1),
    (8,  N'Hannah',   N'Costa',      'hannah.costa@email.com',    '011-555-0808', 10, 320, '2022-04-10', 1),
    (9,  N'Ivan',     N'Petrov',     'ivan.petrov@email.com',     '604-555-0909', 5,  150, '2023-01-05', 1),
    (10, N'Julia',    N'Dubois',     'julia.dubois@email.com',    '415-555-1010', 12,  60, '2024-01-20', 1),
    (11, N'Kevin',    N'O''Brien',   'kevin.obrien@email.com',    '212-555-1111', 1,  950, '2021-03-01', 1),
    (12, N'Laura',    N'Garcia',     'laura.garcia@email.com',    '555-555-1212', 6,  200, '2022-10-15', 1),
    (13, N'Marcus',   N'Lee',        'marcus.lee@email.com',      '213-555-1313', 2,    0, '2024-03-10', 1),
    (14, N'Nina',     N'Yamamoto',   'nina.yamamoto@email.com',   '813-555-1414', 9,  710, '2021-09-20', 1),
    (15, N'Oliver',   N'Brown',      'oliver.brown@email.com',    '061-555-1515', 11, 180, '2023-06-01', 0);

SET IDENTITY_INSERT TastyBytes.Customer OFF;
GO

-- ============================================================================
-- 7. OrderHeader (OrderDate is DATETIME)
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.OrderHeader ON;

INSERT INTO TastyBytes.OrderHeader (OrderID, CustomerID, TruckID, OrderDate, CompletedAt, OrderStatus, TotalAmount, TipAmount, PaymentMethod, OrderNotes)
VALUES
    (1,   1,  1,  '2024-07-10 12:15:00', '2024-07-10 12:15:00', 'Completed', 29.98,  5.00, 'Credit Card', NULL),
    (2,   1,  4,  '2024-07-12 13:30:00', '2024-07-12 13:30:00', 'Completed', 25.98,  4.00, 'Credit Card', N'Extra pickles on burger'),
    (3,   2,  2,  '2024-07-15 11:45:00', '2024-07-15 11:45:00', 'Completed', 12.99,  2.00, 'Cash',        NULL),
    (4,   3,  6,  '2024-07-18 12:00:00', '2024-07-18 12:00:00', 'Completed', 29.98,  5.00, 'Debit Card',  NULL),
    (5,   4,  8,  '2024-07-20 18:30:00', '2024-07-20 18:30:00', 'Completed', 26.98,  3.00, 'Credit Card', NULL),
    (6,   5,  3,  '2024-07-22 19:00:00', '2024-07-22 19:00:00', 'Completed', 42.97,  6.00, 'Mobile Pay',  N'No pork in udon please'),
    (7,   6,  5,  '2024-07-25 20:15:00', '2024-07-25 20:15:00', 'Completed', 28.98,  4.50, 'Credit Card', NULL),
    (8,   7,  7,  '2024-08-01 14:00:00', '2024-08-01 14:00:00', 'Completed', 21.98,  3.00, 'Cash',        NULL),
    (9,   8, 11,  '2024-08-05 10:30:00', '2024-08-05 10:30:00', 'Completed', 24.98,  4.00, 'Credit Card', NULL),
    (10,  9,  9,  '2024-08-10 12:45:00', '2024-08-10 12:45:00', 'Completed', 24.98,  3.50, 'Debit Card',  NULL),
    (11, 10,  1,  '2024-08-15 11:00:00', '2024-08-15 11:00:00', 'Completed', 16.99,  2.50, 'Mobile Pay',  NULL),
    (12, 11,  4,  '2024-08-18 12:30:00', '2024-08-18 12:30:00', 'Completed', 37.97,  6.00, 'Credit Card', N'Double everything'),
    (13, 12, 10,  '2024-08-20 15:00:00', '2024-08-20 15:00:00', 'Completed',  7.99,  1.00, 'Cash',        NULL),
    (14, 14,  3,  '2024-08-22 19:30:00', '2024-08-22 19:30:00', 'Completed', 29.98,  5.00, 'Mobile Pay',  NULL),
    (15,  5,  3,  '2024-08-25 18:00:00', NULL,                          'Pending',   14.99,  0.00, NULL,          NULL),
    (16,  1,  1,  '2024-09-01 12:00:00', '2024-09-01 12:00:00', 'Completed', 10.99,  2.00, 'Credit Card', NULL),
    (17,  3,  6,  '2024-09-05 13:15:00', '2024-09-05 13:15:00', 'Completed', 42.97,  7.00, 'Debit Card',  N'Extra spicy'),
    (18,  2,  2,  '2024-09-10 12:30:00', NULL,                          'Pending',    8.99,  0.00, NULL,          NULL),
    (19, 11,  1,  '2024-09-12 11:45:00', '2024-09-12 11:45:00', 'Completed', 27.98,  4.00, 'Credit Card', NULL),
    (20, 13,  2,  '2024-09-15 14:00:00', '2024-09-15 14:00:00', 'Completed',  4.50,  1.00, 'Cash',        NULL),
    (21,  4,  8,  '2024-09-18 17:30:00', NULL,                          'Cancelled',  0.00,  0.00, NULL,          N'Customer cancelled'),
    (22,  6,  5,  '2024-09-20 19:45:00', '2024-09-20 19:45:00', 'Completed', 13.99,  2.00, 'Credit Card', NULL),
    (23, 14,  3,  '2024-09-25 20:00:00', '2024-09-25 20:00:00', 'Completed', 14.99,  3.00, 'Mobile Pay',  NULL),
    (24,  7,  7,  '2024-10-01 13:30:00', '2024-10-01 13:30:00', 'Completed',  9.99,  1.50, 'Cash',        NULL),
    (25,  8, 11,  '2024-10-05 11:00:00', '2024-10-05 11:00:00', 'Completed', 12.99,  2.00, 'Credit Card', NULL);

SET IDENTITY_INSERT TastyBytes.OrderHeader OFF;
GO

-- ============================================================================
-- 8. OrderDetail (skip LineTotal computed col)
-- ============================================================================
INSERT INTO TastyBytes.OrderDetail (OrderID, LineNumber, MenuItemID, Quantity, UnitPrice, Discount, SpecialRequests)
VALUES
    -- Order 1: Smokin' BBQ
    (1,  1, 1,  1, 12.99, 0.00, NULL),
    (1,  2, 3,  1, 10.99, 0.00, N'Extra sauce'),
    -- Order 2: Burger Bliss
    (2,  1, 10, 1, 11.99, 0.00, NULL),
    (2,  2, 11, 1, 13.99, 0.00, NULL),
    -- Order 3: Taco Loco
    (3,  1, 4,  2,  4.50, 0.00, NULL),
    (3,  2, 6,  1,  3.99, 0.00, NULL),
    -- Order 4: Curry in a Hurry
    (4,  1, 15, 1, 13.99, 0.00, NULL),
    (4,  2, 16, 1, 15.99, 0.00, NULL),
    -- Order 5: Seoul Food
    (5,  1, 20, 1, 14.99, 0.00, NULL),
    (5,  2, 21, 1, 11.99, 0.00, NULL),
    -- Order 6: Noodle Express
    (6,  1, 7,  1, 14.99, 0.00, NULL),
    (6,  2, 8,  1, 14.99, 0.00, NULL),
    (6,  3, 9,  1, 12.99, 0.00, NULL),
    -- Order 7: Pizza Wagon
    (7,  1, 13, 1, 13.99, 0.00, NULL),
    (7,  2, 14, 1, 14.99, 0.00, NULL),
    -- Order 8: Le Crepe Mobile
    (8,  1, 18, 1,  9.99, 0.00, NULL),
    (8,  2, 19, 1, 11.99, 0.00, NULL),
    -- Order 9: The Acai Bowl
    (9,  1, 25, 1, 11.99, 0.00, NULL),
    (9,  2, 26, 1, 12.99, 0.00, NULL),
    -- Order 10: Poutine Palace
    (10, 1, 22, 1, 10.99, 0.00, NULL),
    (10, 2, 23, 1, 13.99, 0.00, NULL),
    -- Order 11: Smokin' BBQ
    (11, 1, 2,  1, 16.99, 0.00, NULL),
    -- Order 12: Burger Bliss
    (12, 1, 10, 2, 11.99, 0.00, N'No onions'),
    (12, 2, 12, 1, 12.99, 1.00, NULL),
    -- Order 13: Churros & More
    (13, 1, 24, 1,  7.99, 0.00, NULL),
    -- Order 14: Noodle Express
    (14, 1, 7,  2, 14.99, 0.00, N'Extra chashu'),
    -- Order 15: Noodle Express (pending)
    (15, 1, 8,  1, 14.99, 0.00, NULL),
    -- Order 16: Smokin' BBQ
    (16, 1, 3,  1, 10.99, 0.00, NULL),
    -- Order 17: Curry in a Hurry
    (17, 1, 15, 1, 13.99, 0.00, NULL),
    (17, 2, 16, 1, 15.99, 0.00, NULL),
    (17, 3, 17, 1, 12.99, 0.00, NULL),
    -- Order 18: Taco Loco (pending)
    (18, 1, 5,  2,  4.50, 0.00, NULL),
    -- Order 19: Smokin' BBQ
    (19, 1, 1,  1, 12.99, 0.00, NULL),
    (19, 2, 2,  1, 14.99, 0.00, NULL),
    -- Order 20: Taco Loco
    (20, 1, 4,  1,  4.50, 0.00, NULL),
    -- Order 22: Pizza Wagon
    (22, 1, 13, 1, 13.99, 0.00, NULL),
    -- Order 23: Noodle Express
    (23, 1, 7,  1, 14.99, 0.00, NULL),
    -- Order 24: Le Crepe Mobile
    (24, 1, 18, 1,  9.99, 0.00, NULL),
    -- Order 25: The Acai Bowl
    (25, 1, 26, 1, 12.99, 0.00, NULL);
GO

-- ============================================================================
-- 9. Inventory
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.Inventory ON;

INSERT INTO TastyBytes.Inventory (InventoryID, TruckID, IngredientName, QuantityOnHand, UnitOfMeasure, ReorderLevel, SupplierNotes)
VALUES
    (1,  1,  N'Pulled Pork',       25.00, 'lbs',    10.00, N'Supplier: Smoke Masters LLC'),
    (2,  1,  N'Brisket',           15.00, 'lbs',    10.00, NULL),
    (3,  1,  N'BBQ Sauce',         8.50,  'gallons', 5.00, N'House recipe'),
    (4,  2,  N'Corn Tortillas',    200.00,'count',   50.00,NULL),
    (5,  2,  N'Carne Asada',       18.00, 'lbs',    10.00, NULL),
    (6,  2,  N'Cilantro',          3.00,  'bunches', 5.00, NULL),
    (7,  3,  N'Ramen Noodles',     120.00,'portions',30.00,N'Imported from Japan'),
    (8,  3,  N'Pork Belly',        12.00, 'lbs',    10.00, NULL),
    (9,  4,  N'Beef Patties',      80.00, 'count',   20.00,NULL),
    (10, 4,  N'Burger Buns',       90.00, 'count',   25.00,NULL),
    (11, 5,  N'Pizza Dough',       30.00, 'balls',  10.00, N'Made fresh daily'),
    (12, 5,  N'Mozzarella',        10.00, 'lbs',     5.00, N'Buffalo mozzarella'),
    (13, 6,  N'Basmati Rice',      50.00, 'lbs',    15.00, NULL),
    (14, 6,  N'Chicken Breast',    20.00, 'lbs',    10.00, NULL),
    (15, 9,  N'Cheese Curds',      5.00,  'lbs',    10.00, N'Quebec supplier'),
    (16, 9,  N'Gravy Mix',         2.00,  'lbs',    10.00, NULL);

SET IDENTITY_INSERT TastyBytes.Inventory OFF;
GO

-- ============================================================================
-- 10. EmployeeShift (skip HoursWorked computed col)
-- ============================================================================
SET IDENTITY_INSERT TastyBytes.EmployeeShift ON;

INSERT INTO TastyBytes.EmployeeShift (ShiftID, EmployeeName, TruckID, ShiftDate, StartTime, EndTime, Role, HourlyRate)
VALUES
    (1,  N'Mike Thompson',    1,  '2024-07-10', '10:00', '18:00', 'Cook',     18.50),
    (2,  N'Sarah Chen',       1,  '2024-07-10', '10:00', '18:00', 'Cashier',  15.00),
    (3,  N'James Rodriguez',  2,  '2024-07-15', '09:00', '17:00', 'Cook',     17.00),
    (4,  N'James Rodriguez',  2,  '2024-07-15', '09:00', '17:00', 'Driver',   16.00),
    (5,  N'Yuki Sato',        3,  '2024-07-22', '16:00', '23:00', 'Cook',     20.00),
    (6,  N'Priya Patel',      6,  '2024-07-18', '10:00', '18:00', 'Cook',     18.00),
    (7,  N'Priya Patel',      6,  '2024-07-18', '10:00', '18:00', 'Manager',  22.00),
    (8,  N'Hans Weber',       7,  '2024-08-01', '11:00', '19:00', 'Cook',     19.00),
    (9,  N'Min-jun Park',     8,  '2024-07-20', '15:00', '22:00', 'Cook',     18.50),
    (10, N'Luca Bianchi',     5,  '2024-07-25', '17:00', '23:00', 'Cook',     19.50),
    (11, N'Mike Thompson',    1,  '2024-08-15', '10:00', '18:00', 'Cook',     18.50),
    (12, N'Mike Thompson',    1,  '2024-09-01', '10:00', '18:00', 'Cook',     18.50),
    (13, N'Mike Thompson',    1,  '2024-09-12', '10:00', '18:00', 'Cook',     18.50),
    (14, N'James Rodriguez',  2,  '2024-09-10', '09:00', '17:00', 'Cook',     17.00),
    (15, N'James Rodriguez',  2,  '2024-09-15', '09:00', '17:00', 'Cook',     17.00),
    (16, N'Yuki Sato',        3,  '2024-08-22', '16:00', '23:00', 'Cook',     20.00),
    (17, N'Yuki Sato',        3,  '2024-08-25', '16:00', '23:00', 'Cook',     20.00),
    (18, N'Yuki Sato',        3,  '2024-09-25', '16:00', '23:00', 'Cook',     20.00),
    (19, N'Priya Patel',      6,  '2024-09-05', '10:00', '18:00', 'Cook',     18.00),
    (20, N'Luca Bianchi',     5,  '2024-09-20', '17:00', '23:00', 'Cook',     19.50);

SET IDENTITY_INSERT TastyBytes.EmployeeShift OFF;
GO

PRINT '=== Tasty Bytes sample data loaded successfully ===';
GO
