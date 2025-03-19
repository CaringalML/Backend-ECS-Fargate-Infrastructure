// src/components/ProductItem.jsx
import { Link } from 'react-router-dom';
import { useProducts } from '../context/ProductContext';

const ProductItem = ({ product }) => {
  const { removeProduct } = useProducts();
  
  const handleDelete = (e) => {
    e.preventDefault();
    e.stopPropagation();
    
    if (window.confirm(`Are you sure you want to delete ${product.name}?`)) {
      removeProduct(product.id);
    }
  };
  
  return (
    <div className="border rounded p-4 shadow-sm hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start">
        <h3 className="text-lg font-semibold">{product.name}</h3>
        <span className="font-bold text-green-600">${product.price.toFixed(2)}</span>
      </div>
      
      <p className="text-gray-600 mt-2 line-clamp-2">{product.description}</p>
      
      <div className="mt-3 flex items-center justify-between">
        <span className="text-sm text-gray-500">
          In stock: <span className={product.stockQuantity > 0 ? 'text-green-600' : 'text-red-600'}>
            {product.stockQuantity}
          </span>
        </span>
        
        <div className="flex space-x-2">
          <Link 
            to={`/products/${product.id}`}
            className="px-3 py-1 text-xs bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
          >
            View
          </Link>
          
          <Link 
            to={`/products/edit/${product.id}`}
            className="px-3 py-1 text-xs bg-yellow-100 text-yellow-700 rounded hover:bg-yellow-200"
          >
            Edit
          </Link>
          
          <button
            onClick={handleDelete}
            className="px-3 py-1 text-xs bg-red-100 text-red-700 rounded hover:bg-red-200"
          >
            Delete
          </button>
        </div>
      </div>
      
      {product.createdAt && (
        <div className="mt-2 text-xs text-gray-400">
          Created: {new Date(product.createdAt).toLocaleDateString()}
        </div>
      )}
    </div>
  );
};

export default ProductItem;