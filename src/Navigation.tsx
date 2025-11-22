import React from 'react';
import { Badge } from 'react-bootstrap';

interface NavigationProps {
  currentView: 'menu' | 'cart' | 'favorites' | 'history';
  setCurrentView: (view: 'menu' | 'cart' | 'favorites' | 'history') => void;
}

const Navigation: React.FC<NavigationProps> = ({ currentView, setCurrentView }) => {
  const navItems = [
    { key: 'menu', label: '美食菜单', icon: '🍽️', count: 0 },
    { key: 'cart', label: '购物车', icon: '🛒', count: 0 },
    { key: 'favorites', label: '收藏夹', icon: '❤️', count: 0 },
    { key: 'history', label: '历史订单', icon: '📋', count: 0 }
  ] as const;

  return (
    <nav className="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
      <div className="container">
        <a className="navbar-brand fw-bold text-primary" href="#">
          💕 老婆点餐
        </a>
        
        <div className="navbar-nav">
          {navItems.map((item) => (
            <button
              key={item.key}
              className={`nav-link btn ${currentView === item.key ? 'btn-primary text-white' : 'btn-link'}`}
              onClick={() => setCurrentView(item.key)}
            >
              {item.icon} {item.label}
              {item.count > 0 && (
                <Badge bg="danger" className="ms-1">
                  {item.count}
                </Badge>
              )}
            </button>
          ))}
        </div>
      </div>
    </nav>
  );
};

export default Navigation;