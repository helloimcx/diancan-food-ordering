import type { Food } from './index';

export const foodsData: Food[] = [
  // 中式
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
    name: '蒸蛋羹',
    price: 12,
    category: '中式',
    description: '嫩滑如布丁，营养丰富',
    image: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=300&h=200&fit=crop',
    rating: 4.6
  },
  // 西式
  {
    id: '5',
    name: '黑椒牛排',
    price: 68,
    category: '西式',
    description: '进口牛排配黑椒汁，肉质鲜嫩',
    image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=200&fit=crop',
    rating: 4.8
  },
  {
    id: '6',
    name: '意大利面',
    price: 32,
    category: '西式',
    description: '正宗意式风味，酱汁浓郁',
    image: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=300&h=200&fit=crop',
    rating: 4.5
  },
  {
    id: '7',
    name: '凯撒沙拉',
    price: 26,
    category: '西式',
    description: '新鲜蔬菜配凯撒酱，清爽健康',
    image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&h=200&fit=crop',
    rating: 4.4
  },
  // 日式
  {
    id: '8',
    name: '寿司拼盘',
    price: 48,
    category: '日式',
    description: '新鲜海鲜寿司，精致美观',
    image: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300&h=200&fit=crop',
    rating: 4.7
  },
  {
    id: '9',
    name: '拉面',
    price: 35,
    category: '日式',
    description: '浓郁豚骨汤底，配菜丰富',
    image: 'https://images.unsplash.com/photo-1543351611-58f69d42b146?w=300&h=200&fit=crop',
    rating: 4.6
  },
  // 韩式
  {
    id: '10',
    name: '韩式烤肉',
    price: 58,
    category: '韩式',
    description: '正宗韩式烧烤，肉质鲜美',
    image: 'https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=300&h=200&fit=crop',
    rating: 4.8
  },
  {
    id: '11',
    name: '石锅拌饭',
    price: 28,
    category: '韩式',
    description: '营养丰富，口感层次分明',
    image: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=300&h=200&fit=crop',
    rating: 4.5
  },
  // 甜品
  {
    id: '12',
    name: '提拉米苏',
    price: 32,
    category: '甜品',
    description: '意式经典甜品，层次丰富',
    image: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=300&h=200&fit=crop',
    rating: 4.7
  },
  {
    id: '13',
    name: '芒果布丁',
    price: 22,
    category: '甜品',
    description: '香滑布丁配新鲜芒果',
    image: 'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=300&h=200&fit=crop',
    rating: 4.6
  },
  // 饮品
  {
    id: '14',
    name: '珍珠奶茶',
    price: 18,
    category: '饮品',
    description: '经典台式风味，珍珠Q弹',
    image: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=300&h=200&fit=crop',
    rating: 4.5
  },
  {
    id: '15',
    name: '鲜榨橙汁',
    price: 15,
    category: '饮品',
    description: '新鲜橙子现榨，维C丰富',
    image: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=300&h=200&fit=crop',
    rating: 4.4
  }
];