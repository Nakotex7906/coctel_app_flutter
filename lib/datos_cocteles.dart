// Puedes poner esto en lib/main.dart arriba de la clase MyApp
// o en un archivo separado e importarlo.

import 'coctel.dart'; // Asegúrate de importar tu modelo

final List<Coctel> coctelesDeEjemplo = [
  Coctel(
    id: 'c1',
    nombre: 'Mojito',
    imagenUrl: 'https://www.example.com/mojito.jpg', // Reemplaza con una URL real
    ingredientes: [
      Ingrediente(nombre: 'Ron Blanco', cantidad: '50 ml'),
      Ingrediente(nombre: 'Zumo de Lima Fresco', cantidad: '25 ml'),
      Ingrediente(nombre: 'Hojas de Menta Fresca', cantidad: '8-10'),
      Ingrediente(nombre: 'Azúcar Blanca', cantidad: '2 cucharaditas'),
      Ingrediente(nombre: 'Agua con Gas (Soda)', cantidad: 'Completar'),
    ],
    instrucciones: [
      'En un vaso alto, añade las hojas de menta y el azúcar.',
      'Machaca suavemente la menta y el azúcar con un mortero (sin romper demasiado las hojas).',
      'Añade el zumo de lima y el ron.',
      'Llena el vaso con hielo picado.',
      'Completa con agua con gas.',
      'Remueve suavemente y decora con una ramita de menta y una rodaja de lima.',
    ],
  ),
  Coctel(
    id: 'c2',
    nombre: 'Margarita',
    imagenUrl: 'https://www.example.com/margarita.jpg', // Reemplaza con una URL real
    ingredientes: [
      Ingrediente(nombre: 'Tequila', cantidad: '50 ml'),
      Ingrediente(nombre: 'Licor de Naranja (Cointreau o Triple Sec)', cantidad: '25 ml'),
      Ingrediente(nombre: 'Zumo de Lima Fresco', cantidad: '25 ml'),
      Ingrediente(nombre: 'Sal', cantidad: 'Para el borde del vaso'),
    ],
    instrucciones: [
      'Prepara el vaso: humedece el borde con una rodaja de lima y luego pásalo por sal.',
      'En una coctelera con hielo, añade el tequila, el licor de naranja y el zumo de lima.',
      'Agita bien hasta que la coctelera esté muy fría.',
      'Cuela la mezcla en el vaso preparado.',
      'Decora con una rodaja de lima (opcional).',
    ],
  ),
  // Añade más cócteles aquí
];
