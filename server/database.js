const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// 数据库文件路径
const dbPath = path.join(__dirname, 'diancan.db');

// 连接数据库
const db = new sqlite3.Database(dbPath);

// 创建表结构
function createTables() {
  // 菜品表
  db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS foods (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      image TEXT,
      rating REAL DEFAULT 4.0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // 订单表
    db.run(`CREATE TABLE IF NOT EXISTS orders (
      id TEXT PRIMARY KEY,
      total REAL NOT NULL,
      status TEXT DEFAULT 'pending',
      customer_name TEXT,
      customer_phone TEXT,
      delivery_address TEXT,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // 订单详情表
    db.run(`CREATE TABLE IF NOT EXISTS order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id TEXT NOT NULL,
      food_id TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      FOREIGN KEY (order_id) REFERENCES orders (id),
      FOREIGN KEY (food_id) REFERENCES foods (id)
    )`);

    // 收藏表
    db.run(`CREATE TABLE IF NOT EXISTS favorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      food_id TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (food_id) REFERENCES foods (id)
    )`);
  });
}

// 插入初始数据
function insertInitialData() {
  const initialFoods = [
    {
      id: '1',
      name: '宫保鸡丁',
      price: 28,
      category: '中式',
      description: '经典川菜，鸡肉嫩滑，花生香脆',
      image: 'https://images.unsplash.com/photo-1603133872878-684f208fb90a?w=300&h=200&fit=crop',
      rating: 4.8
    },
    {
      id: '2',
      name: '麻婆豆腐',
      price: 22,
      category: '中式',
      description: '四川名菜，麻辣鲜香，嫩滑可口',
      image: 'https://images.unsplash.com/photo-1596797038530-2c107229f92b?w=300&h=200&fit=crop',
      rating: 4.7
    },
    {
      id: '3',
      name: '红烧肉',
      price: 35,
      category: '中式',
      description: '传统家常菜，肥瘦相间，入口即化',
      image: 'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=300&h=200&fit=crop',
      rating: 4.9
    },
    {
      id: '4',
      name: '黑椒牛排',
      price: 68,
      category: '西式',
      description: '进口牛排配黑椒汁，肉质鲜嫩',
      image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=200&fit=crop',
      rating: 4.8
    },
    {
      id: '5',
      name: '意大利面',
      price: 32,
      category: '西式',
      description: '正宗意式风味，酱汁浓郁',
      image: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=300&h=200&fit=crop',
      rating: 4.5
    },
    {
      id: '6',
      name: '寿司拼盘',
      price: 48,
      category: '日式',
      description: '新鲜海鲜寿司，精致美观',
      image: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300&h=200&fit=crop',
      rating: 4.7
    },
    {
      id: '7',
      name: '拉面',
      price: 35,
      category: '日式',
      description: '浓郁豚骨汤底，配菜丰富',
      image: 'https://images.unsplash.com/photo-1543351611-58f69d42b146?w=300&h=200&fit=crop',
      rating: 4.6
    },
    {
      id: '8',
      name: '韩式烤肉',
      price: 58,
      category: '韩式',
      description: '正宗韩式烧烤，肉质鲜美',
      image: 'https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=300&h=200&fit=crop',
      rating: 4.8
    },
    {
      id: '9',
      name: '提拉米苏',
      price: 32,
      category: '甜品',
      description: '意式经典甜品，层次丰富',
      image: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=300&h=200&fit=crop',
      rating: 4.7
    },
    {
      id: '10',
      name: '珍珠奶茶',
      price: 18,
      category: '饮品',
      description: '经典台式风味，珍珠Q弹',
      image: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=300&h=200&fit=crop',
      rating: 4.5
    }
  ];

  // 检查是否已有数据
  db.get("SELECT COUNT(*) as count FROM foods", (err, row) => {
    if (err) {
      console.error('Error checking foods table:', err);
      return;
    }
    
    if (row.count === 0) {
      console.log('正在插入初始菜品数据...');
      
      const stmt = db.prepare("INSERT INTO foods (id, name, price, category, description, image, rating) VALUES (?, ?, ?, ?, ?, ?, ?)");
      
      initialFoods.forEach(food => {
        stmt.run(food.id, food.name, food.price, food.category, food.description, food.image, food.rating);
      });
      
      stmt.finalize();
      console.log('✅ 初始数据插入完成！');
    } else {
      console.log('✅ 数据库已有数据，跳过初始化。');
    }
  });
}

// 初始化数据库
function initDatabase() {
  createTables();
  insertInitialData();
}

// 如果直接运行此文件，则初始化数据库
if (require.main === module) {
  initDatabase();
}

module.exports = {
  initDatabase,
  db
};