const baseVentas = import.meta.env.VITE_API_VENTAS_URL ?? "";
const baseDespachos = import.meta.env.VITE_API_DESPACHOS_URL ?? "";

export const API_VENTAS_URL = `${baseVentas}/api/v1/ventas`;
export const API_DESPACHOS_URL = `${baseDespachos}/api/v1/despachos`;

export const jsonHeaders = {
  "Content-Type": "application/json",
  Accept: "application/json",
};
