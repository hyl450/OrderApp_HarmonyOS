// services/auth-service.ts
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { defaultLogger as logger } from '../utils/Logger';
import {
  LoginParams,
  LoginResult,
  ApiResponse,
  LoginData,
  UploadResponse,
  BusinessErrorInfo
} from '../types/auth-types';

const TAG = 'AuthService';

// 环境配置
class Config {
  static readonly API_BASE_URL = 'http://47.100.208.47:8081/api';
  static readonly TIMEOUT = 60000; // 60秒
}

// 文件上传参数接口
interface FileUploadParams {
  filename: string;
  type: string;
  uri: string;
}

export class AuthService {
  private httpRequest: http.HttpRequest;

  constructor() {
    this.httpRequest = http.createHttp();
    this.setupInterceptors();
  }

  private setupInterceptors(): void {
    // 请求拦截器
    this.httpRequest.on('headersReceive', (header: Object) => {
      const headerStr = JSON.stringify(header);
      logger.info(TAG, 'Response headers: %s', headerStr);
    });

  }

  async login(username: string, password: string): Promise<LoginResult> {
    const url = `${Config.API_BASE_URL}/auth/login`;

    try {
      logger.info(TAG, 'Login request to %s', url);

      const params: LoginParams = {
        mobile: username,
        password: password,
        deviceId: "23423",
        deviceType: "ANDROID",
        isFirstLogin: true,
        loginCity: "合肥"
      };

      const response = await this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'HarmonyOS App'
          },
          extraData: JSON.stringify(params),
          readTimeout: Config.TIMEOUT,
          connectTimeout: Config.TIMEOUT
        }
      );

      logger.info(TAG, 'Response code: %d', response.responseCode);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ApiResponse<LoginData>;

        // 验证响应数据结构
        if (result && result.code == 200) {
          const loginResult: LoginResult = {
            success: true,
            message: (result.message as string) || '',
            userId: result.data.users.userId,
            token: result.data.token as string
          };

          return loginResult;
        } else {
          //logger.errorObject(TAG, result.message, null);
          return {
            success: false,
            message: result?.message ?? '服务器响应格式错误'
          };
        }
      } else if (response.responseCode === 401) {
        return {
          success: false,
          message: '用户名或密码错误'
        };
      } else if (response.responseCode === 400) {
        return {
          success: false,
          message: '请求参数错误'
        };
      } else {
        logger.error(TAG, 'Server error: %d', response.responseCode);
        return {
          success: false,
          message: `服务器错误 (${response.responseCode})`
        };
      }
    } catch (error) {
      const err = error as BusinessError;
      logger.error(TAG, 'Login error code: %d, message: %s', err.code, err.message);

      return {
        success: false,
        message: this.getErrorMessage(err)
      };
    }
  }

  private getErrorMessage(error: BusinessError): string {
    // 根据错误码返回友好的错误信息
    switch (error.code) {
      case 13900001: // 通用错误
        return '网络请求失败';
      case 13900002: // 超时
        return '请求超时，请检查网络连接';
      case 13900003: // 协议错误
        return '协议错误';
      case 13900004: // 网络不可用
        return '网络不可用，请检查网络设置';
      case 13900005: // 消息过大
        return '数据过大';
      default:
        return '登录失败，请稍后重试';
    }
  }

  // 上传文件示例 - 返回具体类型
  // async uploadFile(fileUri: string): Promise<UploadResponse> {
  //   const url = `${Config.API_BASE_URL}/upload`;
  //
  //   try {
  //     const fileParams: FileUploadParams = {
  //       filename: 'avatar.jpg',
  //       type: 'image/jpeg',
  //       uri: fileUri
  //     };
  //
  //     const response = await this.httpRequest.request(
  //       url,
  //       {
  //         method: http.RequestMethod.POST,
  //         header: {
  //           'Content-Type': 'multipart/form-data'
  //         },
  //         extraData: {
  //           file: fileParams
  //         }
  //       }
  //     );
  //
  //     if (response.responseCode === 200) {
  //       const result = JSON.parse(response.result as string) as UploadResponse;
  //       Logger.infoObject(TAG, 'File uploaded successfully', result);
  //       return result;
  //     } else {
  //       throw new Error(`Upload failed with status: ${response.responseCode}`);
  //     }
  //   } catch (error) {
  //     const err = error as BusinessError;
  //     Logger.error(TAG, 'Upload error: %s', err.message);
  //     //throw error;
  //   }
  // }

  // 下载文件示例 - 返回具体的成功状态
  // async downloadFile(url: string, filePath: string): Promise<boolean> {
  //   try {
  //     Logger.info(TAG, 'Downloading file from %s to %s', url, filePath);
  //
  //     // const response = await this.httpRequest.request(
  //     //   url,
  //     //   {
  //     //     method: http.RequestMethod.GET,
  //     //     filePath: filePath
  //     //   }
  //     // );
  //     //
  //     // if (response.responseCode === 200) {
  //     //   Logger.info(TAG, 'File downloaded successfully to %s', filePath);
  //     //   return true;
  //     // } else {
  //     //   Logger.error(TAG, 'Download failed with status: %d', response.responseCode);
  //     //   throw new Error(`Download failed: ${response.responseCode}`);
  //     // }
  //   } catch (error) {
  //     const err = error as BusinessError;
  //     Logger.error(TAG, 'Download error: %s', err.message);
  //     //throw error;
  //   }
  // }

  // 验证 Token
  async validateToken(token: string): Promise<boolean> {
    const url = `${Config.API_BASE_URL}/auth/validate`;

    try {
      const response = await this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({ token: token })
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as Record<string, Object>;
        return result.valid as boolean === true;
      }
      return false;
    } catch (error) {
      logger.error(TAG, 'Token validation error');
      return false;
    }
  }

  // 注销登录
  async logout(token: string): Promise<boolean> {
    const url = `${Config.API_BASE_URL}/auth/logout`;

    try {
      const response = await this.httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({ token: token })
        }
      );

      return response.responseCode === 200;
    } catch (error) {
      logger.error(TAG, 'Logout error');
      return false;
    }
  }

  // 取消请求
  cancelRequest(): void {
    this.httpRequest.off('headersReceive');
    // 注意：不同 API 版本可能有不同的取消方法
    // 这里调用 destroy 来取消所有请求
    this.httpRequest.destroy();
  }

  // 销毁资源
  destroy(): void {
    this.cancelRequest();
  }
}