// utils/logger.ts
import hilog from '@ohos.hilog';

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  FATAL = 4
}

export class Logger {
  private domain: number;
  private prefix: string;
  private logLevel: LogLevel;

  constructor(domain: number = 0xFF00, prefix: string = '', logLevel: LogLevel = LogLevel.DEBUG) {
    this.domain = domain;
    this.prefix = prefix;
    this.logLevel = logLevel;
  }

  // 基础日志方法
  private log(level: LogLevel, tag: string, format: string, ...args: (string | number | boolean | null | undefined)[]): void {
    if (this.logLevel <= level) {
      const logArgs = args.map(arg => {
        if (arg === null) return 'null';
        if (arg === undefined) return 'undefined';
        return String(arg);
      });

      switch (level) {
        case LogLevel.DEBUG:
          hilog.debug(this.domain, this.prefix + tag, format, logArgs);
          break;
        case LogLevel.INFO:
          hilog.info(this.domain, this.prefix + tag, format, logArgs);
          break;
        case LogLevel.WARN:
          hilog.warn(this.domain, this.prefix + tag, format, logArgs);
          break;
        case LogLevel.ERROR:
          hilog.error(this.domain, this.prefix + tag, format, logArgs);
          break;
        case LogLevel.FATAL:
          hilog.fatal(this.domain, this.prefix + tag, format, logArgs);
          break;
      }
    }
  }

  // 记录对象（JSON序列化）
  private logObject(level: LogLevel, tag: string, message: string, obj: Record<string, string>): void {
    try {
      const jsonString = JSON.stringify(obj, null, 2);
      this.log(level, tag, '%s: %s', message, jsonString);
    } catch (error) {
      this.log(level, tag, '%s: [Object cannot be serialized]', message);
    }
  }

  // 调试日志
  debug(tag: string, format: string, ...args: (string | number | boolean | null | undefined)[]): void {
    this.log(LogLevel.DEBUG, tag, format, ...args);
  }

  debugObject(tag: string, message: string, obj: Record<string, string>): void {
    this.logObject(LogLevel.DEBUG, tag, message, obj);
  }

  // 信息日志
  info(tag: string, format: string, ...args: (string | number | boolean | null | undefined)[]): void {
    this.log(LogLevel.INFO, tag, format, ...args);
  }

  infoObject(tag: string, message: string, obj: Record<string, string>): void {
    this.logObject(LogLevel.INFO, tag, message, obj);
  }

  // 警告日志
  warn(tag: string, format: string, ...args: (string | number | boolean | null | undefined)[]): void {
    this.log(LogLevel.WARN, tag, format, ...args);
  }

  warnObject(tag: string, message: string, obj: Record<string, string>): void {
    this.logObject(LogLevel.WARN, tag, message, obj);
  }

  // 错误日志
  error(tag: string, format: string, ...args: (string | number | boolean | null | undefined)[]): void {
    this.log(LogLevel.ERROR, tag, format, ...args);
  }

  errorObject(tag: string, message: string, obj: Record<string, string>): void {
    this.logObject(LogLevel.ERROR, tag, message, obj);
  }

  // 设置日志级别
  setLogLevel(level: LogLevel): void {
    this.logLevel = level;
  }
}

// 创建默认 Logger 实例
export const defaultLogger = new Logger(0xFF00, '[MyApp]', LogLevel.DEBUG);