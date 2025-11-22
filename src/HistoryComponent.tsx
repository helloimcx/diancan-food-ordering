import React from 'react';

const HistoryComponent: React.FC = () => {
  return (
    <div className="container mt-4">
      <div className="text-center mb-4">
        <h2 className="text-primary mb-3">📋 历史订单</h2>
        <p className="text-muted">回顾您的点餐历史</p>
      </div>

      <div className="text-center py-5">
        <div className="mb-3">
          <span style={{ fontSize: '4rem' }}>📝</span>
        </div>
        <p className="text-muted">还没有任何订单记录</p>
        <p className="text-muted">快去点一些美食吧！</p>
      </div>
    </div>
  );
};

export default HistoryComponent;