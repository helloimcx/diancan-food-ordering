import React from 'react';

const FavoritesComponent: React.FC = () => {
  return (
    <div className="container mt-4">
      <div className="text-center mb-4">
        <h2 className="text-primary mb-3">❤️ 收藏夹</h2>
        <p className="text-muted">您最爱的美食都在这里</p>
      </div>

      <div className="text-center py-5">
        <div className="mb-3">
          <span style={{ fontSize: '4rem' }}>💔</span>
        </div>
        <p className="text-muted">还没有收藏任何美食</p>
        <p className="text-muted">快去菜单页面收藏您喜欢的食物吧！</p>
      </div>
    </div>
  );
};

export default FavoritesComponent;