import { env } from "~/core/config/env";

const logger = {
  styles: {
    info: "color: #00bcd4; font-weight: bold;",
    success: "color: #4caf50; font-weight: bold;",
    error: "color: #f44336; font-weight: bold;",
    warn: "color: #ff9800; font-weight: bold;",
    dim: "color: #888;",
  },

  request(method: string, path: string, body?: unknown) {
    console.group(`%c[API] %c${method} %c${path}`, this.styles.info, "color: #fff; background: #2196f3; padding: 2px 6px; border-radius: 3px;", this.styles.dim);
    if (body) console.log("%cRequest Body:", this.styles.dim, body);
    console.groupEnd();
  },

  response<T>(method: string, path: string, status: number, data: T) {
    const statusStyle = status >= 200 && status < 300 ? this.styles.success : status >= 400 ? this.styles.error : this.styles.warn;
    console.group(`%c[API] %c${method} %c${path} %c${status}`, this.styles.info, "color: #fff; background: #2196f3; padding: 2px 6px; border-radius: 3px;", this.styles.dim, statusStyle);
    console.log("%cResponse:", this.styles.dim, data);
    console.groupEnd();
  },

  error(method: string, path: string, err: unknown) {
    console.group(`%c[API] %c${method} %c${path} %cERROR`, this.styles.info, "color: #fff; background: #f44336; padding: 2px 6px; border-radius: 3px;", this.styles.dim, this.styles.error);
    console.error("%cError:", this.styles.dim, err);
    console.groupEnd();
  },
};

export class ApiClient {
  private baseUrl: string;

  constructor(baseUrl = env.apiUrl) {
    this.baseUrl = baseUrl;
  }

  async post<T>(path: string, body?: unknown, token?: string): Promise<T> {
    const method = "POST";
    logger.request(method, path, body);

    try {
      const headers: Record<string, string> = {
        "Content-Type": "application/json",
      };
      if (token) headers["Authorization"] = `Bearer ${token}`;

      const res = await fetch(`${this.baseUrl}${path}`, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined,
      });

      const data = await res.json();
      logger.response(method, path, res.status, data);

      if (!res.ok) {
        throw new ApiError(res.status, data.message ?? "Request failed");
      }
      return data;
    } catch (error) {
      logger.error(method, path, error);
      throw error;
    }
  }

  async get<T>(path: string, token: string): Promise<T> {
    const method = "GET";
    logger.request(method, path);

    try {
      const res = await fetch(`${this.baseUrl}${path}`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      const data = await res.json();
      logger.response(method, path, res.status, data);

      if (!res.ok) throw new ApiError(res.status, data.message ?? "Request failed");
      return data;
    } catch (error) {
      logger.error(method, path, error);
      throw error;
    }
  }

  async patch<T>(path: string, body: unknown, token: string): Promise<T> {
    const method = "PATCH";
    logger.request(method, path, body);

    try {
      const res = await fetch(`${this.baseUrl}${path}`, {
        method,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      });

      const data = await res.json();
      logger.response(method, path, res.status, data);

      if (!res.ok) throw new ApiError(res.status, data.message ?? "Request failed");
      return data;
    } catch (error) {
      logger.error(method, path, error);
      throw error;
    }
  }

  async put<T>(path: string, body: unknown, token: string): Promise<T> {
    const method = "PUT";
    logger.request(method, path, body);

    try {
      const res = await fetch(`${this.baseUrl}${path}`, {
        method,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      });

      const data = await res.json();
      logger.response(method, path, res.status, data);

      if (!res.ok) throw new ApiError(res.status, data.message ?? "Request failed");
      return data;
    } catch (error) {
      logger.error(method, path, error);
      throw error;
    }
  }
}

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

export const apiClient = new ApiClient(
  env.apiUrl
);
