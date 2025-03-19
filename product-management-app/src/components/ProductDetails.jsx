// src/components/ProductDetails.jsx
import { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { useProducts } from '../context/ProductContext';

const ProductDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { getProduct, removeProduct } = useProducts();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchProduct = async () => {
      try {
        setLoading(true);
        const productData = await getProduct(id);
        if (productData) {
          setProduct(productData);
        } else {
          navigate('/products');
        }
      } catch (error) {
        console.error('Error fetching product:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchProduct();
  }, [id, getProduct, navigate]);
  
  const handleDelete = () => {
    if (window.confirm(`Are you sure you want to delete ${product.name}?`)) {
      removeProduct(id);
      navigate('/products');
    }
  };
  
  if (loading) {
    return <div className="text-center py-10">Loading product details...</div>;
  }
  
  if (!product) {
    return <div className="text-center py-10 text-red-500">Product not found</div>;
  }
  
  return (
    <div className="max-w-3xl mx-auto p-4">
      <div className="mb-4">
        <Link to="/products" className="text-blue-500 hover:underline">
          ← Back to Products
        </Link>
      </div>
      
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex justify-between items-start">
          <h1 className="text-2xl font-bold mb-2">{product.name}</h1>
          <span className="text-2xl font-bold text-green-600">
            ${product.price.toFixed(2)}
          </span>
        </div>
        
        <div className="mt-6">
          <h2 className="text-lg font-semibold mb-2">Description</h2>
          <p className="text-gray-700">{product.description}</p>
        </div>
        
        <div className="mt-6">
          <h2 className="text-lg font-semibold mb-2">Stock Information</h2>
          <p className="flex items-center">
            <span className="mr-2">Available:</span>
            <span className={`font-bold ${product.stockQuantity > 0 ? 'text-green-600' : 'text-red-600'}`}>
              {product.stockQuantity} units
            </span>
          </p>
          
          <p className="text-sm text-gray-500 mt-2">
            {product.stockQuantity === 0 
              ? 'Out of stock' 
              : product.stockQuantity < 10 
                ? 'Low stock' 
                : 'In stock'}
          </p>
        </div>
        
        {product.createdAt && (
          <div className="mt-4 text-sm text-gray-500">
            <p>Created: {new Date(product.createdAt).toLocaleString()}</p>
            <p>Last Updated: {new Date(product.updatedAt).toLocaleString()}</p>
          </div>
        )}
        
        <div className="mt-8 flex space-x-4">
          <Link
            to={`/products/edit/${id}`}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Edit Product
          </Link>
          
          <button
            onClick={handleDelete}
            className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
          >
            Delete Product
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProductDetails;