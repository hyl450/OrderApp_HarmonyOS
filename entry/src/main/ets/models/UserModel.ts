// models/UserModel.ts
import preferences from '@ohos.data.preferences';
import http from '@ohos.net.http';

// 移除错误的导入
// import { Context } from '@ohos.abilityAccess.context';  // 这是错误的！

export interface LoginParams {
  username: string;
  password: string;
}

export interface LoginResult {
  success: boolean;
  message: string;
  userId?: string;
  token?: string;
}

export class UserModel {
  // 在ETS中，我们不需要在Model中存储context
  // 使用AppStorage进行数据存储，不需要context

  constructor() {
    // 不需要context参数
  }

  // 用户登录
  async login(params: LoginParams): Promise<LoginResult> {
    try {
      // 模拟网络延迟
      await this.sleep(1500);

      // 简单的验证逻辑
      if (params.username && params.password.length >= 6) {
        return {
          success: true,
          message: '登录成功',
          userId: 'user_' + Math.random().toString(36).substr(2, 9),
          token: 'token_' + Date.now()
        };
      } else {
        return {
          success: false,
          message: '用户名或密码错误'
        };
      }
    } catch (error) {
      console.error('Login error:', error);
      return {
        success: false,
        message: '登录失败，请重试'
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
}