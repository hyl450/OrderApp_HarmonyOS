export interface LoginParams {
  mobile: string;
  password: string;
  deviceId: string;
  deviceType: string;
  isFirstLogin: boolean;
  loginCity: string;
}

export interface LoginResult {
  success: boolean;
  message: string;
  userId?: number;
  token?: string;
}

export interface LoginData {
  users: User;
  token: string;
}

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

export interface User {
  userId: number;
  userPhone: string;
  password: string;
  employeeId: string;
  userName: string;
  userRole: string;
  userLoginCity?: string;
  userBindImei?: string;
  token?: string;
}

export interface UploadResponse {
  url: string;
  fileName: string;
  fileSize: number;
  mimeType: string;
}

export interface BusinessErrorInfo {
  code: number;
  message: string;
  details?: string;
}
