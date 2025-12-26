// models/UserModel.ts
import preferences from '@ohos.data.preferences';
import http from '@ohos.net.http';


// 移除错误的导入
// import { Context } from '@ohos.abilityAccess.context';  // 这是错误的！


export interface LoginParams {
  mobile: string;
  password: string;
}

export interface LoginResult {
  success: boolean;
  message: string;
  userId?: string;
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

// 环境配置
class Config {
  static readonly API_BASE_URL = 'http://47.100.208.47:8081';
  static readonly TIMEOUT = 60000; // 60秒
}

export class UserModel {
  // 在ETS中，我们不需要在Model中存储context
  // 使用AppStorage进行数据存储，不需要context
  private httpRequest: http.HttpRequest;

  constructor() {
    this.httpRequest = http.createHttp();
    // 不需要context参数
  }

  // 用户登录
  async login(params: LoginParams): Promise<LoginResult> {
    try {
      // 使用 request 方法，指定 method 为 POST
      const url = `${Config.API_BASE_URL}/api/auth/login`;
      const response = await this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,  // 指定请求方法
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          extraData: JSON.stringify(params)  // 请求体数据
        }
      );

      // 检查响应状态码
      if (response.responseCode === 200) {
        // 解析响应数据
        const result = JSON.parse(response.result as string);

        return {
          success: true,
          message: result.message || '登录成功',
          userId: result.userId,
          token: result.token
        };
      } else {
        return {
          success: false,
          message: `请求失败，状态码: ${response.responseCode}`
        };
      }
    } catch (error) {
      console.error('Login error:', JSON.stringify(error));
      return {
        success: false,
        message: '网络请求失败'
      };
    }
  }

  // 模拟网络延迟
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // 保存登录信息到AppStorage
  saveLoginInfo(username: string, rememberMe: boolean): void {
    // 使用AppStorage存储数据，不需要context
    AppStorage.setOrCreate('username', username);
    AppStorage.setOrCreate('isLoggedIn', true);
    AppStorage.setOrCreate('rememberMe', rememberMe);
    AppStorage.setOrCreate('loginTime', new Date().toISOString());
  }

  // 从AppStorage获取登录信息
  getLoginInfo(): { username: string; isLoggedIn: boolean; rememberMe: boolean } {
    return {
      username: AppStorage.get('username') || '',
      isLoggedIn: AppStorage.get('isLoggedIn') || false,
      rememberMe: AppStorage.get('rememberMe') || false
    };
  }

  // 清除登录信息
  clearLoginInfo(): void {
    AppStorage.setOrCreate('username', '');
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('rememberMe', false);
  }
};
