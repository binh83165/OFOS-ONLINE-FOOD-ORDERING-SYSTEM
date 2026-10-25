CREATE DATABASE IF NOT EXISTS ofos_db;
USE ofos_db;

-- 1. Bảng Restaurant (Nhà hàng)
CREATE TABLE Restaurant (
    rest_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL
);

-- 2. Bảng Account (Tài khoản & Số dư)
CREATE TABLE Account (
    acc_no VARCHAR(20) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    balance DOUBLE DEFAULT 0.0
);

-- 3. Bảng Person (Gộp Customer và Worker: Manager, Chef, Waiter)
CREATE TABLE Person (
    person_id VARCHAR(20) PRIMARY KEY, -- tương ứng c_id hoặc manager_id
    acc_no VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    role ENUM('Customer', 'Manager', 'Chef', 'Waiter') NOT NULL,
    FOREIGN KEY (acc_no) REFERENCES Account(acc_no) ON DELETE CASCADE
);

-- 4. Bảng FoodItem (Món ăn)
CREATE TABLE FoodItem (
    item_id VARCHAR(20) PRIMARY KEY,
    rest_id INT DEFAULT 1,
    name VARCHAR(150) NOT NULL,
    price DOUBLE NOT NULL CHECK (price >= 0),
    status ENUM('Available', 'Out of Stock', 'Removed') DEFAULT 'Available',
    FOREIGN KEY (rest_id) REFERENCES Restaurant(rest_id)
);

-- 5. Bảng ItemDescription (Mô tả món ăn - Liên kết 1-1 với FoodItem)
CREATE TABLE ItemDescription (
    item_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (item_id) REFERENCES FoodItem(item_id) ON DELETE CASCADE
);

-- 6. Bảng Orders (Đơn hàng)
CREATE TABLE Orders (
    order_no VARCHAR(20) PRIMARY KEY,
    c_id VARCHAR(20) NOT NULL,
    manager_id VARCHAR(20) NULL,
    rest_id INT DEFAULT 1,
    status ENUM('Pending', 'Confirmed / Preparing', 'Ready for Delivery', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    delivery_address VARCHAR(255),
    FOREIGN KEY (c_id) REFERENCES Person(person_id),
    FOREIGN KEY (manager_id) REFERENCES Person(person_id),
    FOREIGN KEY (rest_id) REFERENCES Restaurant(rest_id)
);

-- 7. Bảng OrderLineItem (Dòng chi tiết đơn hàng)
CREATE TABLE OrderLineItem (
    line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_no VARCHAR(20) NOT NULL,
    item_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    sub_total DOUBLE NOT NULL,
    FOREIGN KEY (order_no) REFERENCES Orders(order_no) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES FoodItem(item_id)
);

-- 8. Bảng Transaction (Giao dịch)
CREATE TABLE Transaction_Log (
    trans_id VARCHAR(20) PRIMARY KEY,
    c_id VARCHAR(20) NOT NULL,
    order_no VARCHAR(20) NOT NULL,
    trans_date DATE NOT NULL,
    trans_time TIME NOT NULL,
    FOREIGN KEY (c_id) REFERENCES Person(person_id),
    FOREIGN KEY (order_no) REFERENCES Orders(order_no) ON DELETE CASCADE
);

-- 9. Bảng Payment (Thanh toán - Liên kết 1-1 với Transaction)
CREATE TABLE Payment (
    payment_id VARCHAR(20) PRIMARY KEY,
    trans_id VARCHAR(20) UNIQUE NOT NULL,
    amount DOUBLE NOT NULL,
    method ENUM('COD', 'E-Wallet', 'Account Balance') DEFAULT 'COD',
    FOREIGN KEY (trans_id) REFERENCES Transaction_Log(trans_id) ON DELETE CASCADE
);

-- 10. Bảng Receipt (Biên lai điện tử - Liên kết 1-1 với Order và Transaction)
CREATE TABLE Receipt (
    r_no VARCHAR(20) PRIMARY KEY,
    order_no VARCHAR(20) UNIQUE NOT NULL,
    trans_id VARCHAR(20) UNIQUE NOT NULL,
    total_amount DOUBLE NOT NULL,
    FOREIGN KEY (order_no) REFERENCES Orders(order_no) ON DELETE CASCADE,
    FOREIGN KEY (trans_id) REFERENCES Transaction_Log(trans_id) ON DELETE CASCADE
);

-- DỮ LIỆU MẪU (SEED DATA)
INSERT INTO Restaurant (name, address, city) VALUES ('OFOS Bistro', 'Số 1 Đại Cồ Việt', 'Hà Nội');

INSERT INTO Account VALUES 
('ACC01', 'khachhang@email.com', '123456', 500000),
('ACC02', 'quanly@email.com', '123456', 0),
('ACC03', 'daubep@email.com', '123456', 0),
('ACC04', 'giaohang@email.com', '123456', 0);

INSERT INTO Person VALUES 
('CUST01', 'ACC01', 'Nguyễn Văn A', '0901234567', 'Hai Bà Trưng, Hà Nội', 'Customer'),
('MGR01',  'ACC02', 'Trần Quản Lý', '0909999888', 'Hà Nội', 'Manager'),
('CHEF01', 'ACC03', 'Lê Đầu Bếp',   '0908888777', 'Hà Nội', 'Chef'),
('WAIT01', 'ACC04', 'Phạm Giao Hàng','0907777666', 'Hà Nội', 'Waiter');

INSERT INTO FoodItem (item_id, rest_id, name, price, status) VALUES 
('FD01', 1, 'Cơm gà xối mỡ', 45000, 'Available'),
('FD02', 1, 'Trà đào cam sả', 25000, 'Available'),
('FD03', 1, 'Mì Ý sốt bò bằm', 55000, 'Available');

INSERT INTO ItemDescription VALUES 
('FD01', 'Đồ ăn chính', 'Cơm gà da giòn kèm nước sốt và canh cải'),
('FD02', 'Đồ uống', 'Trà đào tươi mát lạnh kèm lát cam và sả'),
('FD03', 'Đồ ăn chính', 'Mì Ý sợi dai sốt cà chua với thịt bò bằm');
