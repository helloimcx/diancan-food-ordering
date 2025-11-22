import React from 'react';
import { Card } from 'react-bootstrap';

const CartComponent: React.FC = () => {
  return (
    <div className="container mt-4">
      <div className="text-center mb-4">
        <h2 className="text-primary mb-3">🛒 购物车</h2>
        <p className="text-muted">确认您的点餐信息</p>
      </div>

      <div className="text-center py-5">
        <div className="mb-3">
          <span style={{ fontSize: '4rem' }}>🛒</span>
        </div>
        <p className="text-muted">购物车还是空的哦</p>
        <p className="text-muted">快去选择一些美食吧！</p>
      </div>
    </div>
  );
};

export default CartComponent;