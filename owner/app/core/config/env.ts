const getEnv = (key: string, defaultValue?: string): string => {
  if (typeof process !== 'undefined' && process.env) {
    return process.env[key] ?? defaultValue ?? '';
  }
  if (typeof import.meta !== 'undefined' && import.meta.env) {
    return (import.meta.env as Record<string, string>)[key] ?? defaultValue ?? '';
  }
  return defaultValue ?? '';
};

export const env = {
  apiUrl: getEnv('VITE_API_URL', 'http://localhost:3000/api/v1'),
};
