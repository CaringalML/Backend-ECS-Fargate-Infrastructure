// src/context/ProductContext.jsx
import { createContext, useState, useEffect, useContext } from 'react';
import * as productService from '../services/productService';

// Create context
const ProductContext = createContext();

// Context provider component
export const ProductProvider = ({ children }) => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Load all products on component mount
  useEffect(() => {
    fetchProducts();
  }, []);

  // Get all products
  const fetchProducts = async () => {
    try {
      setLoading(true);
      const data = await productService.getAllProducts();
      console.log('Fetched products:', data);
      setProducts(Array.isArray(data) ? data : []);
      setError(null);
    } catch (err) {
      console.error('Error fetching products:', err);
      setError('Failed to fetch products: ' + (err.message || 'Unknown error'));
      setProducts([]);
    } finally {
      setLoading(false);
    }
  };

  // Get a single product
  const getProduct = async (id) => {
    try {
      return await productService.getProductById(id);
    } catch (err) {
      setError(`Failed to fetch product with ID ${id}`);
      console.error(err);
      return null;
    }
  };

  // Add a new product
  const addProduct = async (product) => {
    try {
      const newProduct = productService.createProduct(product);
      setProducts([...products, newProduct]);
      return newProduct;
    } catch (err) {
      setError('Failed to add product');
      console.error(err);
      return null;
    }
  };

  // Update an existing product
  const updateProduct = async (id, product) => {
    try {
      const updatedProduct = productService.updateProduct(id, product);
      if (updatedProduct) {
        setProducts(
          products.map((item) => (item.id === id ? updatedProduct : item))
        );
      }
      return updatedProduct;
    } catch (err) {
      setError('Failed to update product');
      console.error(err);
      return null;
    }
  };

  // Delete a product
  const removeProduct = async (id) => {
    try {
      const success = productService.deleteProduct(id);
      if (success) {
        setProducts(products.filter((product) => product.id !== id));
      }
      return success;
    } catch (err) {
      setError('Failed to delete product');
      console.error(err);
      return false;
    }
  };

  // Context value
  const value = {
    products,
    loading,
    error,
    fetchProducts,
    getProduct,
    addProduct,
    updateProduct,
    removeProduct
  };

  return (
    <ProductContext.Provider value={value}>
      {children}
    </ProductContext.Provider>
  );
};

// Custom hook to use the product context
export const useProducts = () => {
  const context = useContext(ProductContext);
  if (!context) {
    throw new Error('useProducts must be used within a ProductProvider');
  }
  return context;
};

export default ProductContext;