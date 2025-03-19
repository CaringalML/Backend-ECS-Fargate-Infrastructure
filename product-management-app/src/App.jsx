// src/App.jsx
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ProductProvider } from './context/ProductContext';
import ProductList from './components/ProductList';
import ProductDetails from './components/ProductDetails';
import ProductForm from './components/ProductForm';

function App() {
  return (
    <ProductProvider>
      <Router>
        <div className="min-h-screen bg-gray-50">
          <header className="bg-blue-600 text-white shadow-md">
            <div className="container mx-auto px-4 py-4">
              <h1 className="text-xl font-bold">Product Management System</h1>
            </div>
          </header>
          
          <main className="container mx-auto py-6">
            <Routes>
              <Route path="/products" element={<ProductList />} />
              <Route path="/products/:id" element={<ProductDetails />} />
              <Route path="/products/new" element={<ProductForm />} />
              <Route path="/products/edit/:id" element={<ProductForm />} />
              <Route path="/" element={<Navigate to="/products" replace />} />
              <Route path="*" element={<Navigate to="/products" replace />} />
            </Routes>
          </main>
          
          <footer className="bg-gray-200 py-4 mt-8">
            <div className="container mx-auto px-4 text-center text-gray-600">
              &copy; {new Date().getFullYear()} Product Management System
            </div>
          </footer>
        </div>
      </Router>
    </ProductProvider>
  );
}

export default App;