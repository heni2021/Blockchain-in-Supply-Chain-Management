// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChainManagement {
    address public admin;

    enum Role { Admin, Customer, DeliveryAgent }

    struct Product {
        string name;
        uint256 expirationDate;
        bool isOutForDelivery;
    }

    mapping(uint256 => Product) public products;
    uint256 public productCount = 0;
    mapping(address => Role) public userRoles;

    event ProductAdded(uint256 productId, string name, uint256 expirationDate);
    event ProductExpired(uint256 productId, string name);
    event ProductOutForDelivery(uint256 productId, address deliveryAgent, address customer);

    modifier onlyAdmin() {
        require(userRoles[msg.sender] == Role.Admin, "Only the admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
        userRoles[admin] = Role.Admin;
    }

    function addUser(address _user, Role _role) public onlyAdmin {
        userRoles[_user] = _role;
    }

    function addProduct(
        string memory _name,
        uint256 _expirationDate
    ) public onlyAdmin {
        // require(_expirationDate > block.timestamp, "Expiration date should be in the future");
        products[productCount] = Product(_name, _expirationDate, false);
        emit ProductAdded(productCount, _name, _expirationDate);
        productCount++;
    }

    function deleteProduct(uint256 _productId) public onlyAdmin {
        require(_productId < productCount, "Invalid product ID");
        delete products[_productId];
    }

    function checkExpiration(uint256 _productId) public {
        require(_productId < productCount, "Invalid product ID");
        Product storage product = products[_productId];
        if (block.timestamp >= product.expirationDate) {
            emit ProductExpired(_productId, product.name);
            if (product.isOutForDelivery) {
                emit ProductOutForDelivery(_productId, msg.sender, address(0));
            }
        }
    }

    function setOutForDelivery(uint256 _productId, address _customer) public onlyAdmin {
        require(_productId < productCount, "Invalid product ID");
        Product storage product = products[_productId];
        product.isOutForDelivery = true;
        emit ProductOutForDelivery(_productId, msg.sender, _customer);
    }
}
