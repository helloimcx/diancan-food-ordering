const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const { initDatabase, db } = require('./database');

const app = express();
const PORT = process.env.PORT || 3001;

// 中间件
app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true }));

// 初始化数据库
initDatabase();

// 静态文件服务（如果需要）
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ==================== 菜品API ====================

// 获取所有菜品
app.get('/api/foods', (req, res) => {
  const { category } = req.query;
  
  let query = 'SELECT * FROM foods';
  const params = [];
  
  if (category && category !== '全部') {
    query += ' WHERE category = ?';
    params.push(category);
  }
  
  query += ' ORDER BY created_at DESC';
  
  db.all(query, params, (err, rows) => {
    if (err) {
      console.error('Error fetching foods:', err);
      return res.status(500).json({ error: '获取菜品失败' });
    }
    res.json(rows);
  });
});

// 获取单个菜品
app.get('/api/foods/:id', (req, res) => {
  const { id } = req.params;
  
  db.get('SELECT * FROM foods WHERE id = ?', [id], (err, row) => {
    if (err) {
      console.error('Error fetching food:', err);
      return res.status(500).json({ error: '获取菜品失败' });
    }
    if (!row) {
      return res.status(404).json({ error: '菜品不存在' });
    }
    res.json(row);
  });
});

// 新增菜品
app.post('/api/foods', (req, res) => {
  const { name, price, category, description, image, rating = 4.0 } = req.body;
  
  // 验证必填字段
  if (!name || !price || !category || !description) {
    return res.status(400).json({ error: '请填写完整信息' });
  }
  
  const id = Date.now().toString();
  
  db.run(
    'INSERT INTO foods (id, name, price, category, description, image, rating) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [id, name, price, category, description, image, rating],
    function(err) {
      if (err) {
        console.error('Error creating food:', err);
        return res.status(500).json({ error: '创建菜品失败' });
      }
      
      res.status(201).json({
        id,
        name,
        price,
        category,
        description,
        image,
        rating,
        message: '菜品创建成功'
      });
    }
  );
});

// 更新菜品
app.put('/api/foods/:id', (req, res) => {
  const { id } = req.params;
  const { name, price, category, description, image, rating } = req.body;
  
  // 验证菜品是否存在
  db.get('SELECT * FROM foods WHERE id = ?', [id], (err, row) => {
    if (err) {
      console.error('Error checking food existence:', err);
      return res.status(500).json({ error: '更新失败' });
    }
    if (!row) {
      return res.status(404).json({ error: '菜品不存在' });
    }
    
    // 更新菜品
    db.run(
      'UPDATE foods SET name = ?, price = ?, category = ?, description = ?, image = ?, rating = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [name, price, category, description, image, rating, id],
      function(err) {
        if (err) {
          console.error('Error updating food:', err);
          return res.status(500).json({ error: '更新菜品失败' });
        }
        
        res.json({
          id,
          name,
          price,
          category,
          description,
          image,
          rating,
          message: '菜品更新成功'
        });
      }
    );
  });
});

// 删除菜品
app.delete('/api/foods/:id', (req, res) => {
  const { id } = req.params;
  
  // 删除菜品及其相关数据
  db.serialize(() => {
    // 删除订单详情中的相关记录
    db.run('DELETE FROM order_items WHERE food_id = ?', [id], (err) => {
      if (err) console.error('Error deleting order items:', err);
    });
    
    // 删除收藏记录
    db.run('DELETE FROM favorites WHERE food_id = ?', [id], (err) => {
      if (err) console.error('Error deleting favorites:', err);
    });
    
    // 删除菜品
    db.run('DELETE FROM foods WHERE id = ?', [id], function(err) {
      if (err) {
        console.error('Error deleting food:', err);
        return res.status(500).json({ error: '删除菜品失败' });
      }
      
      if (this.changes === 0) {
        return res.status(404).json({ error: '菜品不存在' });
      }
      
      res.json({ message: '菜品删除成功' });
    });
  });
});

// ==================== 订单API ====================

// 获取所有订单
app.get('/api/orders', (req, res) => {
  db.all(
    'SELECT * FROM orders ORDER BY created_at DESC',
    (err, orders) => {
      if (err) {
        console.error('Error fetching orders:', err);
        return res.status(500).json({ error: '获取订单失败' });
      }
      
      // 获取每个订单的详情
      const ordersWithItems = [];
      let completed = 0;
      
      if (orders.length === 0) {
        return res.json([]);
      }
      
      orders.forEach((order, index) => {
        db.all(
          `SELECT oi.*, f.name as food_name, f.image as food_image 
           FROM order_items oi 
           JOIN foods f ON oi.food_id = f.id 
           WHERE oi.order_id = ?`,
          [order.id],
          (err, items) => {
            if (err) {
              console.error('Error fetching order items:', err);
              items = [];
            }
            
            ordersWithItems.push({
              ...order,
              items: items.map(item => ({
                id: item.id,
                food_id: item.food_id,
                quantity: item.quantity,
                price: item.price,
                food_name: item.food_name,
                food_image: item.food_image
              }))
            });
            
            completed++;
            if (completed === orders.length) {
              res.json(ordersWithItems);
            }
          }
        );
      });
    }
  );
});

// 创建订单
app.post('/api/orders', (req, res) => {
  const { items, total, customer_info = {} } = req.body;
  
  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: '订单不能为空' });
  }
  
  const orderId = Date.now().toString();
  
  db.serialize(() => {
    // 创建订单
    db.run(
      'INSERT INTO orders (id, total, customer_name, customer_phone, delivery_address, notes) VALUES (?, ?, ?, ?, ?, ?)',
      [
        orderId,
        total,
        customer_info.name || '老婆',
        customer_info.phone || '',
        customer_info.address || '',
        customer_info.note || ''
      ],
      function(err) {
        if (err) {
          console.error('Error creating order:', err);
          return res.status(500).json({ error: '创建订单失败' });
        }
        
        // 添加订单详情
        const stmt = db.prepare('INSERT INTO order_items (order_id, food_id, quantity, price) VALUES (?, ?, ?, ?)');
        
        items.forEach(item => {
          stmt.run(orderId, item.food.id, item.quantity, item.food.price);
        });
        
        stmt.finalize();
        
        res.status(201).json({
          id: orderId,
          total,
          items,
          customer_info,
          status: 'pending',
          message: '订单创建成功'
        });
      }
    );
  });
});

// 更新订单状态
app.put('/api/orders/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  const validStatuses = ['pending', 'confirmed', 'delivered'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: '无效的订单状态' });
  }
  
  db.run(
    'UPDATE orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [status, id],
    function(err) {
      if (err) {
        console.error('Error updating order status:', err);
        return res.status(500).json({ error: '更新订单状态失败' });
      }
      
      if (this.changes === 0) {
        return res.status(404).json({ error: '订单不存在' });
      }
      
      res.json({ message: '订单状态更新成功' });
    }
  );
});

// ==================== 收藏API ====================

// 获取收藏列表
app.get('/api/favorites', (req, res) => {
  db.all(
    `SELECT f.* FROM foods f 
     JOIN favorites fav ON f.id = fav.food_id 
     ORDER BY fav.created_at DESC`,
    (err, rows) => {
      if (err) {
        console.error('Error fetching favorites:', err);
        return res.status(500).json({ error: '获取收藏失败' });
      }
      res.json(rows);
    }
  );
});

// 添加收藏
app.post('/api/favorites', (req, res) => {
  const { food_id } = req.body;
  
  if (!food_id) {
    return res.status(400).json({ error: '菜品ID不能为空' });
  }
  
  // 检查是否已经收藏
  db.get('SELECT * FROM favorites WHERE food_id = ?', [food_id], (err, row) => {
    if (err) {
      console.error('Error checking favorite:', err);
      return res.status(500).json({ error: '添加收藏失败' });
    }
    
    if (row) {
      return res.status(400).json({ error: '已经收藏过该菜品' });
    }
    
    // 添加收藏
    db.run('INSERT INTO favorites (food_id) VALUES (?)', [food_id], function(err) {
      if (err) {
        console.error('Error adding favorite:', err);
        return res.status(500).json({ error: '添加收藏失败' });
      }
      
      res.status(201).json({ message: '收藏成功' });
    });
  });
});

// 取消收藏
app.delete('/api/favorites/:food_id', (req, res) => {
  const { food_id } = req.params;
  
  db.run('DELETE FROM favorites WHERE food_id = ?', [food_id], function(err) {
    if (err) {
      console.error('Error removing favorite:', err);
      return res.status(500).json({ error: '取消收藏失败' });
    }
    
    res.json({ message: '取消收藏成功' });
  });
});

// ==================== 统计API ====================

// 获取统计数据
app.get('/api/stats', (req, res) => {
  const stats = {};
  
  // 菜品总数
  db.get('SELECT COUNT(*) as count FROM foods', (err, row) => {
    stats.totalFoods = row ? row.count : 0;
    
    // 订单总数
    db.get('SELECT COUNT(*) as count FROM orders', (err, row) => {
      stats.totalOrders = row ? row.count : 0;
      
      // 收藏总数
      db.get('SELECT COUNT(*) as count FROM favorites', (err, row) => {
        stats.totalFavorites = row ? row.count : 0;
        
        // 总销售额
        db.get('SELECT SUM(total) as total FROM orders WHERE status != "pending"', (err, row) => {
          stats.totalRevenue = row && row.total ? row.total : 0;
          
          res.json(stats);
        });
      });
    });
  });
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: '点餐服务运行正常' });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`✅ 点餐后端服务启动成功！`);
  console.log(`📍 服务地址: http://localhost:${PORT}`);
  console.log(`📊 API文档: http://localhost:${PORT}/health`);
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到关闭信号，正在关闭服务器...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('收到中断信号，正在关闭服务器...');
  process.exit(0);
});

module.exports = app;