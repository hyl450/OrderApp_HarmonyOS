// LoginPage.ets
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { UserModel } from '../models/UserModel';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct LoginPage {
  // 响应式状态管理
  @State username: string = '';
  @State password: string = '';
  @State showPassword: boolean = false;
  @State rememberMe: boolean = false;
  @State isLoading: boolean = false;

  // 获取UI上下文
  private context = getContext(this) as common.UIAbilityContext;

  build() {
    Column() {
      // 顶部Logo区域
      this.buildLogoSection()

      // 登录表单
      this.buildLoginForm()

      // 操作区域
      this.buildActionSection()

      // 底部链接
      this.buildBottomLinks()
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor('#F5F7FA')
  }

  // Logo区域
  @Builder
  buildLogoSection() {
    Column() {
      Image($r('app.media.app_logo'))
        .width(120)
        .height(120)
        .margin({ top: 80, bottom: 40 })

      Text('订单管理系统')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ bottom: 60 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // 登录表单
  @Builder
  buildLoginForm() {
    Column() {
      // 用户名输入
      TextInput({ placeholder: '请输入用户名/手机号', text: this.username })
        .width('100%')
        .height(56)
        .fontSize(16)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .onChange((value: string) => {
          this.username = value;
        })
        .margin({ bottom: 20 })

      // 密码输入
      Row() {
        // 正确的方式：使用inputType属性方法而不是构造函数参数
        TextInput({
          placeholder: '请输入密码',
          text: this.password
        })
          .width('95%')
          .height('100%')
          .fontSize(16)
          .padding({ left: 16 })
          .backgroundColor('#FFFFFF')
          .border({ width: 0 })
          .onChange((value: string) => {
            this.password = value;
          })
          .type(this.showPassword ? InputType.Normal : InputType.Password)  // 正确方式
          //.showPasswordIcon(false)  // 禁止显示系统默认的密码图标

        // 切换密码显示/隐藏
        // Column()
        //   .width(40)
        //   .height('100%')  // 使用100%高度
        //   .justifyContent(FlexAlign.Center)  // 垂直居中
        //   .alignItems(HorizontalAlign.Center)  // 水平居中
        //   .onClick(() => {
        //     this.showPassword = !this.showPassword;
        //   })
          //.overlay(this.overlayEyeIcon(this.showPassword))

        // Image(this.showPassword ? $r('app.media.ic_visibility') : $r('app.media.ic_visibility_off'))
        //   .width(24)
        //   .height(24)
        //   .margin({ left: 12 })
        //   .onClick(() => {
        //     this.showPassword = !this.showPassword;
        //   })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding({ right: 16 })
      .alignItems(VerticalAlign.Center)  // 添加垂直对齐
      .margin({ bottom: 16 })

      // 记住密码和忘记密码
      Row() {
        Checkbox({ name: 'remember', group: 'login' })
          .select(this.rememberMe)
          .onChange((value: boolean) => {
            this.rememberMe = value;
          })
          .margin({ right: 8 })

        Text('记住密码')
          .fontSize(14)
          .fontColor('#666666')
          .onClick(() => {
            this.rememberMe = !this.rememberMe;
          })

        Blank()

        Text('忘记密码?')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            this.navigateToForgotPassword();
          })
      }
      .width('100%')
      .height(40)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 40 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 16, color: '#1A1A1A1A', offsetX: 0, offsetY: 4 })
  }

  @Builder
  overlayEyeIcon(showPassword: boolean) {
    Text(showPassword ? '👁️' : '👁️‍🗨️')
      .fontSize(20)
      .fontColor(showPassword ? '#007DFF' : '#999999')
  }

  // 操作按钮区域
  @Builder
  buildActionSection() {
    Column() {
      // 登录按钮
      Button('登录', { type: ButtonType.Capsule })
        .width('100%')
        .height(56)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .stateEffect(true)
        .onClick(() => {
          this.handleLogin();
        })
        .opacity(this.isLoading ? 0.7 : 1)
        .enabled(!this.isLoading)

      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .color('#FFFFFF')
          .margin({ top: 8 })
      }

    }
    .width('100%')
    .margin({ top: 40 })
    .alignItems(HorizontalAlign.Center)
  }

  // 底部链接
  @Builder
  buildBottomLinks() {
    Column() {
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#666666')

        Text('立即注册')
          .fontSize(14)
          .fontColor('#007DFF')
          .fontWeight(FontWeight.Medium)
          .margin({ left: 4 })
          .onClick(() => {
            this.navigateToRegister();
          })
      }
      .margin({ top: 40, bottom: 20 })

      Text('《用户协议》 | 《隐私政策》')
        .fontSize(12)
        .fontColor('#999999')
        .onClick(() => {
          this.showAgreement();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 40 })
  }

  // 登录逻辑
  private async handleLogin() {
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;

    try {
      const userModel = new UserModel();
      const result = await userModel.login({
        username: this.username,
        password: this.password
      });

      if (result.success) {
        // 保存登录状态
        await userModel.saveLoginInfo(this.username, this.rememberMe);

        // 跳转到主页面
        router.replaceUrl({
          url: 'pages/HomePage',
          params: { userId: result.userId }
        });
      } else {
        this.showToast('登录失败: ' + result.message);
      }
    } catch (error) {
      this.showToast('网络异常，请稍后重试');
    } finally {
      this.isLoading = false;
    }
  }

  // 输入验证
  private validateInput(): boolean {
    if (!this.username.trim()) {
      this.showToast('请输入用户名');
      return false;
    }

    if (!this.password) {
      this.showToast('请输入密码');
      return false;
    }

    if (this.password.length < 6) {
      this.showToast('密码长度至少6位');
      return false;
    }

    return true;
  }

  // 显示Toast提示
  private showToast(message: string) {
    prompt.showToast({
      message: message,
      duration: 2000,
      bottom: 200
    });
  }

  // 页面跳转方法
  private navigateToForgotPassword() {
    router.pushUrl({
      url: 'pages/ForgotPasswordPage'
    });
  }

  private navigateToRegister() {
    router.pushUrl({
      url: 'pages/RegisterPage'
    });
  }

  private wechatLogin() {
    // 微信登录逻辑
    // 需要集成微信SDK
  }

  private alipayLogin() {
    // 支付宝登录逻辑
    // 需要集成支付宝SDK
  }

  private showAgreement() {
    router.pushUrl({
      url: 'pages/AgreementPage',
      params: { type: 'user' }
    });
  }
}