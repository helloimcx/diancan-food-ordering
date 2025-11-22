export interface Food {
  id: string;
  name: string;
  price: number;
  category: string;
  description: string;
  image: string;
  rating: number;
}

export interface CartItem {
  food: Food;
  quantity: number;
}

export interface Order {
  id: string;
  items: CartItem[];
  total: number;
  date: string;
  status: 'pending' | 'confirmed' | 'delivered';
}

export type CategoryType = '全部' | '中式' | '西式' | '日式' | '韩式' | '甜品' | '饮品';