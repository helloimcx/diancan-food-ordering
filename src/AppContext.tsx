import React from 'react';

interface AppState {
  cart: any[];
  favorites: string[];
  orders: any[];
}

const AppContext = React.createContext<{
  state: AppState;
  dispatch: React.Dispatch<any>;
} | null>(null);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = React.useReducer((state: AppState, action: any) => {
    switch (action.type) {
      case 'ADD_TO_CART':
        return {
          ...state,
          cart: [...state.cart, action.payload]
        };
      default:
        return state;
    }
  }, {
    cart: [],
    favorites: [],
    orders: []
  });

  React.useEffect(() => {
    const savedData = localStorage.getItem('diancan-data');
    if (savedData) {
      try {
        const parsedData = JSON.parse(savedData);
        if (parsedData.favorites) {
          // Update state with saved data
        }
      } catch (error) {
        console.error('Failed to load saved data:', error);
      }
    }
  }, []);

  React.useEffect(() => {
    localStorage.setItem('diancan-data', JSON.stringify({
      favorites: state.favorites,
      orders: state.orders
    }));
  }, [state.favorites, state.orders]);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = React.useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};