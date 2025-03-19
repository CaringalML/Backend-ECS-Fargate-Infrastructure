// src/models/Product.js

// This is a class representation of our product data structure
class Product {
    constructor(id = null, name = "", description = "", price = 0, stockQuantity = 0) {
      this.id = id;
      this.name = name;
      this.description = description;
      this.price = price;
      this.stockQuantity = stockQuantity;
    }
  
    // Create a new Product instance from raw data (useful when receiving data from API)
    static fromJson(json) {
      return new Product(
        json.id,
        json.name,
        json.description,
        json.price,
        json.stockQuantity
      );
    }
  
    // For creating an empty product form
    static empty() {
      return new Product();
    }
  }
  
  export default Product;