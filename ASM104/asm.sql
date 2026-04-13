-- Xóa bảng nếu đã tồn tại (để chạy lại dễ dàng)
DROP TABLE IF EXISTS order_items, orders, products, customers, employees, suppliers, product_categories, promotions CASCADE;

-- Danh mục sản phẩm
CREATE TABLE product_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- Nhà cung cấp
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    contact_info TEXT
);

-- Sản phẩm
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    supplier_id INT,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Khách hàng
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    address TEXT
);

-- Nhân viên
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(255),
    position VARCHAR(100),
    hire_date DATE
);

-- Khuyến mãi
CREATE TABLE promotions (
    promotion_id SERIAL PRIMARY KEY,
    promotion_name VARCHAR(255),
    discount_percent INT,
    start_date DATE,
    end_date DATE
);

-- Đơn hàng
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date DATE,
    promotion_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id)
);

-- Chi tiết đơn hàng
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
--2
INSERT INTO product_categories (category_name) VALUES
('Đồ uống'),
('Thực phẩm khô'),
('Đồ gia dụng'),
('Bánh kẹo'),
('Đồ đông lạnh');
INSERT INTO suppliers (supplier_name) VALUES
('Công ty Thực phẩm Hảo Hạng'),
('Vinamilk'),
('PepsiCo'),
('Unilever'),
('Acecook');
INSERT INTO promotions (promotion_name, discount_percent, start_date, end_date) VALUES
('Giảm hè', 10, '2025-06-01', '2025-06-30'),
('Black Friday', 20, '2025-11-20', '2025-11-30'),
('Tết sale', 15, '2025-01-01', '2025-01-10');
INSERT INTO employees (employee_name, position, hire_date) VALUES
('An', 'Thu ngân', '2022-01-01'),
('Bình', 'Quản lý', '2021-03-02'),
('Cường', 'Thu ngân', '2023-05-01'),
('Dung', 'Kho', '2020-02-01'),
('Hà', 'Thu ngân', '2022-07-07'),
('Hùng', 'Kho', '2021-09-09'),
('Lan', 'Quản lý', '2019-04-04'),
('Mai', 'Thu ngân', '2023-01-01'),
('Nam', 'Kho', '2022-02-02'),
('Phúc', 'Thu ngân', '2023-03-03');
INSERT INTO customers (customer_name, email)
SELECT 
    'Khach ' || i,
    'khach' || i || '@gmail.com'
FROM generate_series(1,50) AS i;
INSERT INTO products (product_name, price, category_id, supplier_id)
SELECT 
    'San pham ' || i,
    (random()*100000)::int,
    (random()*4 + 1)::int,
    (random()*4 + 1)::int
FROM generate_series(1,30) AS i;
INSERT INTO orders (customer_id, employee_id, order_date, promotion_id)
SELECT 
    (random()*49 + 1)::int,
    (random()*9 + 1)::int,
    DATE '2025-10-01' + (random()*30)::int,
    (random()*2 + 1)::int
FROM generate_series(1,100);
INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT 
    (random()*99 + 1)::int,
    (random()*29 + 1)::int,
    (random()*5 + 1)::int,
    (random()*100000)::int
FROM generate_series(1,200);
--4
SELECT o.order_id, c.customer_name, e.employee_name, o.order_date,
       SUM(oi.quantity * oi.price) AS total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN employees e ON o.employee_id = e.employee_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.customer_name, e.employee_name, o.order_date
ORDER BY o.order_date DESC
LIMIT 10;
--5
SELECT pc.category_name, SUM(oi.quantity * oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_categories pc ON p.category_id = pc.category_id
GROUP BY pc.category_name
HAVING SUM(oi.quantity * oi.price) > 1000000
--6
SELECT p.product_name, p.price
FROM products p
JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_name = 'Công ty Thực phẩm Hảo Hạng';
--7
SELECT e.employee_name,
       SUM(oi.quantity * oi.price) AS total_sales,
       DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.price) DESC) AS rank
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(MONTH FROM o.order_date) = 10
GROUP BY e.employee_name;
--8
-- thêm 50k khách hàng
INSERT INTO customers (customer_name, email)
SELECT 'Test ' || i, 'test' || i || '@gmail.com'
FROM generate_series(1,50000) AS i;

EXPLAIN ANALYZE
SELECT * FROM customers WHERE email = 'test100@gmail.com';
--9
CREATE INDEX idx_email ON customers(email);

EXPLAIN ANALYZE
SELECT * FROM customers WHERE email = 'test100@gmail.com';
