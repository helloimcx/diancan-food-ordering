import React, { useState, useEffect } from 'react';
import apiService from './api';

// 定义数据类型
interface Food {
  id: string;
  name: string;
  price: number;
  category: string;
  description: string;
  image: string;
  rating: number;
}

interface OrderItem {
  id?: number;
  food_id: string;
  food_name?: string;
  food_image?: string;
  quantity: number;
  price: number;
  food?: Food; // 用于购物车
}

interface Order {
  id: string;
  total: number;
  status: 'pending' | 'confirmed' | 'delivered';
  customer_name: string;
  customer_phone: string;
  delivery_address: string;
  notes: string;
  created_at: string;
  items: OrderItem[];
}

type CategoryType = '全部' | '中式' | '西式' | '日式' | '韩式' | '甜品' | '饮品';

// 主应用组件
function App() {
  const [currentView, setCurrentView] = useState<'menu' | 'cart' | 'favorites' | 'history' | 'manage'>('menu');
  
  // 数据状态
  const [foodsData, setFoodsData] = useState<Food[]>([]);
  const [favorites, setFavorites] = useState<Food[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [cart, setCart] = useState<OrderItem[]>([]);
  
  // UI状态
  const [selectedCategory, setSelectedCategory] = useState<CategoryType>('全部');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [editingFood, setEditingFood] = useState<Food | null>(null);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);

  const categories: CategoryType[] = ['全部', '中式', '西式', '日式', '韩式', '甜品', '饮品'];

  // 加载数据
  const loadFoods = async (category?: CategoryType) => {
    try {
      setLoading(true);
      const foods = await apiService.getFoods(category);
      setFoodsData(foods);
      setError(null);
    } catch (err) {
      setError('加载菜品失败: ' + (err as Error).message);
    } finally {
      setLoading(false);
    }
  };

  const loadFavorites = async () => {
    try {
      const favoriteFoods = await apiService.getFavorites();
      setFavorites(favoriteFoods);
    } catch (err) {
      console.error('加载收藏失败:', err);
    }
  };

  const loadOrders = async () => {
    try {
      const orderList = await apiService.getOrders();
      setOrders(orderList);
    } catch (err) {
      console.error('加载订单失败:', err);
    }
  };

  // 初始化加载
  useEffect(() => {
    loadFoods();
    loadFavorites();
    loadOrders();
  }, []);

  // 当分类变化时重新加载菜品
  useEffect(() => {
    loadFoods(selectedCategory);
  }, [selectedCategory]);

  // 购物车相关函数
  const addToCart = async (food: Food) => {
    const existingItem = cart.find(item => item.food_id === food.id);
    if (existingItem) {
      setCart(cart.map(item =>
        item.food_id === food.id
          ? { ...item, quantity: item.quantity + 1 }
          : item
      ));
    } else {
      setCart([...cart, { 
        food_id: food.id, 
        food_name: food.name,
        food_image: food.image,
        quantity: 1, 
        price: food.price,
        food 
      }]);
    }
  };

  const toggleFavorite = async (foodId: string) => {
    const isFavorited = favorites.some(fav => fav.id === foodId);
    
    try {
      if (isFavorited) {
        await apiService.removeFavorite(foodId);
      } else {
        await apiService.addFavorite(foodId);
      }
      await loadFavorites();
    } catch (err) {
      console.error('收藏操作失败:', err);
      // 本地状态临时更新，不影响用户体验
      if (isFavorited) {
        setFavorites(favorites.filter(fav => fav.id !== foodId));
      } else {
        const food = foodsData.find(f => f.id === foodId);
        if (food) setFavorites([...favorites, food]);
      }
    }
  };

  const removeFromCart = (foodId: string) => {
    setCart(cart.filter(item => item.food_id !== foodId));
  };

  const updateQuantity = (foodId: string, quantity: number) => {
    if (quantity === 0) {
      removeFromCart(foodId);
    } else {
      setCart(cart.map(item =>
        item.food_id === foodId ? { ...item, quantity } : item
      ));
    }
  };

  // 菜品管理相关函数
  const addFood = async (foodData: Omit<Food, 'id'>) => {
    try {
      await apiService.createFood(foodData);
      setShowAddModal(false);
      await loadFoods(selectedCategory);
      setError(null);
    } catch (err) {
      setError('添加菜品失败: ' + (err as Error).message);
    }
  };

  const updateFood = async (foodData: Food) => {
    try {
      await apiService.updateFood(foodData.id, foodData);
      setShowEditModal(false);
      setEditingFood(null);
      await loadFoods(selectedCategory);
      setError(null);
    } catch (err) {
      setError('更新菜品失败: ' + (err as Error).message);
    }
  };

  const deleteFood = async (foodId: string) => {
    try {
      await apiService.deleteFood(foodId);
      // 清理本地数据
      setCart(cart.filter(item => item.food_id !== foodId));
      setFavorites(favorites.filter(fav => fav.id !== foodId));
      await loadFoods(selectedCategory);
      setError(null);
    } catch (err) {
      setError('删除菜品失败: ' + (err as Error).message);
    }
  };

  // 订单相关函数
  const placeOrder = async () => {
    if (cart.length === 0) return;

    try {
      const orderData = {
        items: cart,
        total: cart.reduce((sum, item) => sum + item.price * item.quantity, 0),
        customer_info: {
          name: '老婆',
          phone: '',
          address: '',
          note: ''
        }
      };

      await apiService.createOrder(orderData);
      setCart([]);
      setCurrentView('history');
      await loadOrders();
      setError(null);
    } catch (err) {
      setError('下单失败: ' + (err as Error).message);
    }
  };

  const filteredFoods = foodsData;

  const renderStars = (rating: number) => {
    return '⭐'.repeat(Math.floor(rating)) + (rating % 1 !== 0 ? '☆' : '');
  };

  // 菜品编辑表单组件
  const FoodEditForm: React.FC<{ 
    food?: Food; 
    onSave: (foodData: Omit<Food, 'id'> | Food) => void; 
    onCancel: () => void;
    title: string;
  }> = ({ food, onSave, onCancel, title }) => {
    const [formData, setFormData] = useState({
      name: food?.name || '',
      price: food?.price || 0,
      category: food?.category || '中式',
      description: food?.description || '',
      rating: food?.rating || 4.0,
      image: food?.image || ''
    });


    const handleImageChange = (event: React.ChangeEvent<HTMLInputElement>) => {
      const file = event.target.files?.[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
          setFormData({ ...formData, image: e.target?.result as string });
        };
        reader.readAsDataURL(file);
      }
    };

    const handleSubmit = (e: React.FormEvent) => {
      e.preventDefault();
      if (food) {
        onSave({ ...formData, id: food.id });
      } else {
        onSave(formData);
      }
    };

    return (
      <div style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0,0,0,0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000
      }}>
        <div style={{
          backgroundColor: 'white',
          padding: '30px',
          borderRadius: '15px',
          maxWidth: '500px',
          width: '90%',
          maxHeight: '90vh',
          overflow: 'auto'
        }}>
          <h2 style={{ color: '#ff6b9d', marginBottom: '20px', textAlign: 'center' }}>
            {title}
          </h2>
          
          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: '15px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>菜品名称</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                style={{
                  width: '100%',
                  padding: '10px',
                  border: '1px solid #ddd',
                  borderRadius: '8px'
                }}
                required
              />
            </div>

            <div style={{ marginBottom: '15px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>价格</label>
              <input
                type="number"
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) || 0 })}
                style={{
                  width: '100%',
                  padding: '10px',
                  border: '1px solid #ddd',
                  borderRadius: '8px'
                }}
                min="0"
                step="0.01"
                required
              />
            </div>

            <div style={{ marginBottom: '15px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>分类</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                style={{
                  width: '100%',
                  padding: '10px',
                  border: '1px solid #ddd',
                  borderRadius: '8px'
                }}
              >
                {categories.slice(1).map(category => (
                  <option key={category} value={category}>{category}</option>
                ))}
              </select>
            </div>

            <div style={{ marginBottom: '15px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>描述</label>
              <textarea
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                style={{
                  width: '100%',
                  padding: '10px',
                  border: '1px solid #ddd',
                  borderRadius: '8px',
                  minHeight: '80px'
                }}
                required
              />
            </div>

            <div style={{ marginBottom: '15px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>评分</label>
              <input
                type="number"
                value={formData.rating}
                onChange={(e) => setFormData({ ...formData, rating: parseFloat(e.target.value) || 0 })}
                style={{
                  width: '100%',
                  padding: '10px',
                  border: '1px solid #ddd',
                  borderRadius: '8px'
                }}
                min="0"
                max="5"
                step="0.1"
                required
              />
            </div>

            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>图片</label>
              <input
                type="file"
                accept="image/*"
                onChange={handleImageChange}
                style={{
                  width: '100%',
                  padding: '10px',
                  border: '1px solid #ddd',
                  borderRadius: '8px'
                }}
              />
              {formData.image && (
                <div style={{ marginTop: '10px' }}>
                  <img
                    src={formData.image}
                    alt="预览"
                    style={{
                      width: '100%',
                      maxHeight: '200px',
                      objectFit: 'cover',
                      borderRadius: '8px'
                    }}
                  />
                </div>
              )}
            </div>

            <div style={{ display: 'flex', gap: '10px', justifyContent: 'center' }}>
              <button
                type="button"
                onClick={onCancel}
                style={{
                  padding: '10px 20px',
                  backgroundColor: '#6c757d',
                  color: 'white',
                  border: 'none',
                  borderRadius: '20px',
                  cursor: 'pointer'
                }}
              >
                取消
              </button>
              <button
                type="submit"
                style={{
                  padding: '10px 20px',
                  backgroundColor: '#ff6b9d',
                  color: 'white',
                  border: 'none',
                  borderRadius: '20px',
                  cursor: 'pointer'
                }}
              >
                保存
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  };

  // 菜品管理页面
  const ManageView = () => (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ color: '#ff6b9d', marginBottom: '10px' }}>🔧 菜品管理</h1>
          <p style={{ color: '#6c757d' }}>新增、编辑和删除菜品</p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          style={{
            padding: '12px 24px',
            backgroundColor: '#28a745',
            color: 'white',
            border: 'none',
            borderRadius: '25px',
            cursor: 'pointer',
            fontSize: '16px'
          }}
        >
          ➕ 新增菜品
        </button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '50px' }}>
          <p>加载中...</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(350px, 1fr))', gap: '20px' }}>
          {foodsData.map(food => (
            <div
              key={food.id}
              style={{
                backgroundColor: 'white',
                borderRadius: '15px',
                boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
                overflow: 'hidden',
                position: 'relative'
              }}
            >
              <img
                src={food.image}
                alt={food.name}
                style={{ width: '100%', height: '200px', objectFit: 'cover' }}
                onError={(e) => {
                  (e.target as HTMLImageElement).src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjNGNEY2Ii8+CjxwYXRoIGQ9Ik0xMjUgMTAwSDE3NVYxMjVIMTI1VjEwMFoiIGZpbGw9IiM5Q0EzQUYiLz4KPHRleHQgeD0iMTUwIiB5PSIxNDAiIGZpbGw9IiM2QjczODAiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPtivtOespiDlj4rlmqHmnInlpb3lpLHotKU8L3RleHQ+Cjwvc3ZnPg==';
                }}
              />
              
              <div style={{ padding: '20px' }}>
                <h3 style={{ margin: '0 0 10px 0', color: '#333' }}>{food.name}</h3>
                <p style={{ color: '#666', fontSize: '14px', marginBottom: '10px', lineHeight: '1.4' }}>
                  {food.description}
                </p>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                  <span style={{ fontSize: '18px', fontWeight: 'bold', color: '#ff6b9d' }}>
                    ¥{food.price}
                  </span>
                  <span style={{ color: '#ffa500' }}>{renderStars(food.rating)}</span>
                </div>
                <div style={{ display: 'flex', gap: '10px' }}>
                  <button
                    onClick={() => {
                      setEditingFood(food);
                      setShowEditModal(true);
                    }}
                    style={{
                      flex: 1,
                      padding: '8px',
                      backgroundColor: '#007bff',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      cursor: 'pointer'
                    }}
                  >
                    ✏️ 编辑
                  </button>
                  <button
                    onClick={() => {
                      if (confirm('确定要删除这个菜品吗？')) {
                        deleteFood(food.id);
                      }
                    }}
                    style={{
                      flex: 1,
                      padding: '8px',
                      backgroundColor: '#dc3545',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      cursor: 'pointer'
                    }}
                  >
                    🗑️ 删除
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {foodsData.length === 0 && !loading && (
        <div style={{ textAlign: 'center', padding: '50px' }}>
          <div style={{ fontSize: '4rem', marginBottom: '20px' }}>🍽️</div>
          <p style={{ color: '#666' }}>暂无菜品</p>
          <button
            onClick={() => setShowAddModal(true)}
            style={{
              padding: '12px 24px',
              backgroundColor: '#28a745',
              color: 'white',
              border: 'none',
              borderRadius: '25px',
              cursor: 'pointer',
              marginTop: '15px'
            }}
          >
            立即添加第一个菜品
          </button>
        </div>
      )}
    </div>
  );

  // 菜单页面
  const MenuView = () => (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <div style={{ textAlign: 'center', marginBottom: '30px' }}>
        <h1 style={{ color: '#ff6b9d', marginBottom: '10px' }}>🍽️ 精选美食</h1>
        <p style={{ color: '#6c757d' }}>为老婆精心挑选的美味佳肴</p>
      </div>

      <div style={{ textAlign: 'center', marginBottom: '30px' }}>
        {categories.map(category => (
          <button
            key={category}
            onClick={() => setSelectedCategory(category)}
            style={{
              margin: '5px',
              padding: '8px 16px',
              backgroundColor: selectedCategory === category ? '#ff6b9d' : 'white',
              color: selectedCategory === category ? 'white' : '#ff6b9d',
              border: '1px solid #ff6b9d',
              borderRadius: '20px',
              cursor: 'pointer',
              transition: 'all 0.3s'
            }}
          >
            {category}
          </button>
        ))}
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '50px' }}>
          <p>加载中...</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
          {filteredFoods.map(food => (
            <div
              key={food.id}
              style={{
                backgroundColor: 'white',
                borderRadius: '15px',
                boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
                overflow: 'hidden',
                transition: 'transform 0.3s'
              }}
              onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-2px)'}
              onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
            >
              <div style={{ position: 'relative' }}>
                <img
                  src={food.image}
                  alt={food.name}
                  style={{ width: '100%', height: '200px', objectFit: 'cover' }}
                  onError={(e) => {
                    (e.target as HTMLImageElement).src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjNGNEY2Ii8+CjxwYXRoIGQ9Ik0xMjUgMTAwSDE3NVYxMjVIMTI1VjEwMFoiIGZpbGw9IiM5Q0EzQUYiLz4KPHRleHQgeD0iMTUwIiB5PSIxNDAiIGZpbGw9IiM2QjczODAiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPtivtOespiDlj4rlmqHmnInlpb3lpLHotKU8L3RleHQ+Cjwvc3ZnPg==';
                  }}
                />
                <button
                  onClick={() => toggleFavorite(food.id)}
                  style={{
                    position: 'absolute',
                    top: '10px',
                    right: '10px',
                    backgroundColor: 'rgba(255,255,255,0.9)',
                    border: 'none',
                    borderRadius: '50%',
                    width: '40px',
                    height: '40px',
                    cursor: 'pointer',
                    fontSize: '20px'
                  }}
                >
                  {favorites.some(fav => fav.id === food.id) ? '❤️' : '🤍'}
                </button>
                <div style={{
                  position: 'absolute',
                  bottom: '10px',
                  left: '10px',
                  backgroundColor: '#ff6b9d',
                  color: 'white',
                  padding: '4px 8px',
                  borderRadius: '12px',
                  fontSize: '12px'
                }}>
                  {food.category}
                </div>
              </div>
              
              <div style={{ padding: '20px' }}>
                <h3 style={{ margin: '0 0 10px 0', color: '#333' }}>{food.name}</h3>
                <p style={{ color: '#666', fontSize: '14px', marginBottom: '15px', lineHeight: '1.4' }}>
                  {food.description}
                </p>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                  <span style={{ fontSize: '20px', fontWeight: 'bold', color: '#ff6b9d' }}>
                    ¥{food.price}
                  </span>
                  <span style={{ color: '#ffa500' }}>{renderStars(food.rating)}</span>
                </div>
                <button
                  onClick={() => addToCart(food)}
                  style={{
                    width: '100%',
                    backgroundColor: '#ff6b9d',
                    color: 'white',
                    border: 'none',
                    padding: '12px',
                    borderRadius: '25px',
                    cursor: 'pointer',
                    fontSize: '16px'
                  }}
                >
                  加入购物车 🛒
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );

  // 购物车页面
  const CartView = () => (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <div style={{ textAlign: 'center', marginBottom: '30px' }}>
        <h1 style={{ color: '#ff6b9d', marginBottom: '10px' }}>🛒 购物车</h1>
        <p style={{ color: '#6c757d' }}>确认您的点餐信息</p>
      </div>

      {cart.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '50px' }}>
          <div style={{ fontSize: '4rem', marginBottom: '20px' }}>🛒</div>
          <p style={{ color: '#666' }}>购物车还是空的哦</p>
          <p style={{ color: '#666' }}>快去选择一些美食吧！</p>
        </div>
      ) : (
        <div>
          {cart.map(item => (
            <div
              key={item.food_id}
              style={{
                backgroundColor: 'white',
                padding: '20px',
                marginBottom: '15px',
                borderRadius: '10px',
                boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
                display: 'flex',
                alignItems: 'center',
                gap: '20px'
              }}
            >
              <img
                src={item.food_image || item.food?.image}
                alt={item.food_name || item.food?.name}
                style={{ width: '80px', height: '80px', objectFit: 'cover', borderRadius: '8px' }}
              />
              <div style={{ flex: 1 }}>
                <h3 style={{ margin: '0 0 5px 0' }}>{item.food_name || item.food?.name}</h3>
                <p style={{ color: '#666', margin: '0' }}>¥{item.price} x {item.quantity}</p>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <button
                  onClick={() => updateQuantity(item.food_id, item.quantity - 1)}
                  style={{
                    backgroundColor: '#dc3545',
                    color: 'white',
                    border: 'none',
                    borderRadius: '50%',
                    width: '30px',
                    height: '30px',
                    cursor: 'pointer'
                  }}
                >
                  -
                </button>
                <span>{item.quantity}</span>
                <button
                  onClick={() => updateQuantity(item.food_id, item.quantity + 1)}
                  style={{
                    backgroundColor: '#28a745',
                    color: 'white',
                    border: 'none',
                    borderRadius: '50%',
                    width: '30px',
                    height: '30px',
                    cursor: 'pointer'
                  }}
                >
                  +
                </button>
                <button
                  onClick={() => removeFromCart(item.food_id)}
                  style={{
                    backgroundColor: '#dc3545',
                    color: 'white',
                    border: 'none',
                    padding: '8px 12px',
                    borderRadius: '5px',
                    cursor: 'pointer'
                  }}
                >
                  删除
                </button>
              </div>
            </div>
          ))}
          
          <div style={{
            backgroundColor: 'white',
            padding: '20px',
            borderRadius: '10px',
            boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
            textAlign: 'center',
            marginTop: '20px'
          }}>
            <div style={{ fontSize: '18px', marginBottom: '10px' }}>
              共 <strong>{cart.reduce((sum, item) => sum + item.quantity, 0)}</strong> 件商品
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#ff6b9d', marginBottom: '20px' }}>
              总计: ¥{cart.reduce((sum, item) => sum + item.price * item.quantity, 0).toFixed(2)}
            </div>
            <button
              onClick={placeOrder}
              style={{
                backgroundColor: '#ff6b9d',
                color: 'white',
                border: 'none',
                padding: '15px 30px',
                borderRadius: '25px',
                cursor: 'pointer',
                fontSize: '18px'
              }}
              disabled={loading}
            >
              {loading ? '处理中...' : '立即下单 🚀'}
            </button>
          </div>
        </div>
      )}
    </div>
  );

  // 收藏夹页面
  const FavoritesView = () => (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <div style={{ textAlign: 'center', marginBottom: '30px' }}>
        <h1 style={{ color: '#ff6b9d', marginBottom: '10px' }}>❤️ 收藏夹</h1>
        <p style={{ color: '#6c757d' }}>您最爱的美食都在这里</p>
      </div>

      {favorites.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '50px' }}>
          <div style={{ fontSize: '4rem', marginBottom: '20px' }}>💔</div>
          <p style={{ color: '#666' }}>还没有收藏任何美食</p>
          <p style={{ color: '#666' }}>快去菜单页面收藏您喜欢的食物吧！</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
          {favorites.map(food => (
            <div
              key={food.id}
              style={{
                backgroundColor: 'white',
                borderRadius: '15px',
                boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
                padding: '20px'
              }}
            >
              <h3 style={{ margin: '0 0 10px 0' }}>{food.name}</h3>
              <p style={{ color: '#666', marginBottom: '15px' }}>{food.description}</p>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '20px', fontWeight: 'bold', color: '#ff6b9d' }}>¥{food.price}</span>
                <button
                  onClick={() => addToCart(food)}
                  style={{
                    backgroundColor: '#ff6b9d',
                    color: 'white',
                    border: 'none',
                    padding: '8px 16px',
                    borderRadius: '20px',
                    cursor: 'pointer'
                  }}
                >
                  加入购物车 🛒
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );

  // 历史订单页面
  const HistoryView = () => (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <div style={{ textAlign: 'center', marginBottom: '30px' }}>
        <h1 style={{ color: '#ff6b9d', marginBottom: '10px' }}>📋 历史订单</h1>
        <p style={{ color: '#6c757d' }}>回顾您的点餐历史</p>
      </div>

      {orders.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '50px' }}>
          <div style={{ fontSize: '4rem', marginBottom: '20px' }}>📝</div>
          <p style={{ color: '#666' }}>还没有任何订单记录</p>
          <p style={{ color: '#666' }}>快去点一些美食吧！</p>
        </div>
      ) : (
        <div>
          {orders.map(order => (
            <div
              key={order.id}
              style={{
                backgroundColor: 'white',
                padding: '20px',
                marginBottom: '15px',
                borderRadius: '10px',
                boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '15px' }}>
                <div>
                  <h4 style={{ margin: '0 0 5px 0' }}>订单号: {order.id}</h4>
                  <p style={{ color: '#666', margin: 0 }}>{new Date(order.created_at).toLocaleString('zh-CN')}</p>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{
                    backgroundColor: order.status === 'pending' ? '#ffc107' : '#28a745',
                    color: 'white',
                    padding: '4px 8px',
                    borderRadius: '12px',
                    fontSize: '12px',
                    marginBottom: '5px'
                  }}>
                    {order.status === 'pending' ? '待确认' : '已完成'}
                  </div>
                  <div style={{ fontSize: '20px', fontWeight: 'bold', color: '#ff6b9d' }}>
                    ¥{order.total.toFixed(2)}
                  </div>
                </div>
              </div>
              <div>
                <p style={{ margin: '0 0 10px 0', color: '#666' }}>
                  共 {order.items.reduce((sum, item) => sum + item.quantity, 0)} 件商品
                </p>
                {order.items.map(item => (
                  <div key={item.id || item.food_id} style={{ display: 'flex', justifyContent: 'space-between', padding: '5px 0' }}>
                    <span>{item.food_name} x {item.quantity}</span>
                    <span>¥{(item.price * item.quantity).toFixed(2)}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );

  return (
    <div style={{ 
      background: 'linear-gradient(135deg, #f8f9fa 0%, #fff5f8 50%, #f8f9fa 100%)',
      minHeight: '100vh'
    }}>
      {/* 错误提示 */}
      {error && (
        <div style={{
          position: 'fixed',
          top: '20px',
          right: '20px',
          backgroundColor: '#dc3545',
          color: 'white',
          padding: '10px 20px',
          borderRadius: '8px',
          zIndex: 2000,
          boxShadow: '0 4px 8px rgba(0,0,0,0.2)'
        }}>
          {error}
          <button
            onClick={() => setError(null)}
            style={{
              marginLeft: '10px',
              backgroundColor: 'transparent',
              border: 'none',
              color: 'white',
              cursor: 'pointer',
              fontWeight: 'bold'
            }}
          >
            ×
          </button>
        </div>
      )}

      {/* 导航栏 */}
      <nav style={{
        backgroundColor: 'white',
        padding: '15px 20px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
        position: 'sticky',
        top: 0,
        zIndex: 100
      }}>
        <div style={{ maxWidth: '1200px', margin: '0 auto', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2 style={{ 
            color: '#ff6b9d', 
            margin: 0,
            fontWeight: 'bold'
          }}>
            💕 老婆点餐
          </h2>
          
          <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
            {[
              { key: 'menu', label: '美食菜单', icon: '🍽️' },
              { key: 'cart', label: '购物车', icon: '🛒', count: cart.reduce((sum, item) => sum + item.quantity, 0) },
              { key: 'favorites', label: '收藏夹', icon: '❤️', count: favorites.length },
              { key: 'history', label: '历史订单', icon: '📋', count: orders.length },
              { key: 'manage', label: '菜品管理', icon: '🔧' }
            ].map(item => (
              <button
                key={item.key}
                onClick={() => setCurrentView(item.key as any)}
                style={{
                  backgroundColor: currentView === item.key ? '#ff6b9d' : 'transparent',
                  color: currentView === item.key ? 'white' : '#ff6b9d',
                  border: currentView === item.key ? 'none' : '1px solid #ff6b9d',
                  padding: '8px 12px',
                  borderRadius: '20px',
                  cursor: 'pointer',
                  transition: 'all 0.3s',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '5px',
                  fontSize: '14px',
                  whiteSpace: 'nowrap'
                }}
              >
                {item.icon} {item.label}
                {item.count !== undefined && item.count > 0 && (
                  <span style={{
                    backgroundColor: currentView === item.key ? 'white' : '#ff6b9d',
                    color: currentView === item.key ? '#ff6b9d' : 'white',
                    borderRadius: '50%',
                    width: '18px',
                    height: '18px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '10px',
                    minWidth: '18px'
                  }}>
                    {item.count > 99 ? '99+' : item.count}
                  </span>
                )}
              </button>
            ))}
          </div>
        </div>
      </nav>

      {/* 内容区域 */}
      <div>
        {currentView === 'menu' && <MenuView />}
        {currentView === 'cart' && <CartView />}
        {currentView === 'favorites' && <FavoritesView />}
        {currentView === 'history' && <HistoryView />}
        {currentView === 'manage' && <ManageView />}
      </div>

      {/* 编辑菜品模态框 */}
      {showEditModal && editingFood && (
        <FoodEditForm
          food={editingFood}
          onSave={updateFood}
          onCancel={() => {
            setShowEditModal(false);
            setEditingFood(null);
          }}
          title="编辑菜品"
        />
      )}

      {/* 新增菜品模态框 */}
      {showAddModal && (
        <FoodEditForm
          onSave={addFood}
          onCancel={() => setShowAddModal(false)}
          title="新增菜品"
        />
      )}
    </div>
  );
}

export default App;