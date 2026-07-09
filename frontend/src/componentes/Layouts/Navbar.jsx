function Navbar() {
  return (
    <nav className="rounded-xl w-[250px] min-h-[880px] bg-yellow-500 text-white sticky top-0 p-4 m-4">
      {/* Logo o título */}
      <h2 className="text-xl font-bold mb-8">Despacho Dashboard</h2>

      {/* Menú de navegación */}
      <ul className="space-y-3">
        <li>
          <a
            href="#"
            className="block font-bold py-2 px-3 hover:bg-yellow-600 rounded"
          >
            Usuarios
          </a>
        </li>
        <li>
          <a
            href="#"
            className="block font-bold py-2 px-3 hover:bg-yellow-600 rounded"
          >
            Productos
          </a>
        </li>
        <li>
          <a
            href="#"
            className="block font-bold py-2 px-3 hover:bg-yellow-600 rounded"
          >
            Configuración
          </a>
        </li>
      </ul>
    </nav>
  );
}

export default Navbar;
