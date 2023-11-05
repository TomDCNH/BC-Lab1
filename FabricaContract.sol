// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FabricaContract {
    uint public idDigits = 16;

    struct Producto {
        string nombre;
        uint id;
    } 

    // 1.4
    Producto[] public productos;

    // 1.5
    function _crearProducto(string memory _nombre, uint _id) private {
        Producto memory nuevoProducto = Producto(_nombre, _id);
        productos.push(nuevoProducto);
        // 1.8
        emit NuevoProducto(productos.length - 1, _nombre, _id);
    }

    // 1.6
    uint constant idModulus = 10**16;
    function _generarIdAleatorio(string memory _str) private pure returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % idModulus;
    }

    // 1.7
    function crearProductoAleatorio(string memory _nombre) public {
        uint randId = _generarIdAleatorio(_nombre);
        _crearProducto(_nombre, randId);
    }

    // 1.8
    event NuevoProducto(uint ArrayProductoId, string nombre, uint id);

    // 1.9
    mapping(uint => address) public productoAPropietario;
    mapping(address => uint) public propietarioProductos;

    // 1.10
    function Propiedad(uint productoId) public {
        // Update the mapping to store the caller's address for the given productId.
        productoAPropietario[productoId] = msg.sender;
        // Increase the count of products owned by the caller.
        propietarioProductos[msg.sender]++;
    }

    // 1.11
    function getProductosPorPropietario(address _propietario) external view returns (uint[] memory) {
        // Declare the array that will store the results
        uint[] memory resultado = new uint[](propietarioProductos[_propietario]);
        
        // Declare a counter variable to keep track of the result array index
        uint contador = 0;
        
        // Loop through all products
        for (uint i = 0; i < productos.length; i++) {
            // If the product's owner matches the provided address, add its ID to the result array
            if (productoAPropietario[productos[i].id] == _propietario) {
                resultado[contador] = productos[i].id;
                contador++;
            }
        }
        
        return resultado;
    }
}