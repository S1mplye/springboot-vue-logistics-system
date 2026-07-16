<template>
  <div class="login-container">
    <!-- 动态背景 -->
    <div class="background-animation"></div>

    <!-- 登录卡片（只保留一个） -->
    <el-card class="login-card">
      <div slot="header" class="login-header">
        <i class="el-icon-s-data"></i>
        <h2>智能物流管理系统</h2>
      </div>
      <el-form
          :model="loginForm"
          :rules="loginRules"
          ref="loginForm"
          label-width="0px"
          class="login-form"
          @keyup.enter.native="handleLogin"
      >
        <el-form-item prop="username">
          <el-input
              v-model="loginForm.username"
              placeholder="请输入用户名"
              prefix-icon="el-icon-user"
              class="input-with-icon"
          ></el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="请输入密码"
              prefix-icon="el-icon-lock"
              class="input-with-icon"
              show-password
          ></el-input>
        </el-form-item>

        <!-- 记住用户名 -->
        <el-form-item>
          <el-checkbox v-model="rememberMe">记住用户名</el-checkbox>
        </el-form-item>

        <el-form-item class="login-button-group">
          <el-button
              type="primary"
              @click="handleLogin"
              class="login-button"
              :loading="isLoading"
          >
            登录
          </el-button>

          <!-- 注册按钮 -->
          <el-button type="text" @click="openRegisterDialog" style="width: 100%; margin-top: 10px;">
            没有账号？点击注册
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 注册对话框（结构正确） -->
    <el-dialog
        title="用户注册"
        :visible.sync="registerDialogVisible"
        width="400px"
        :close-on-click-modal="false"
    >
      <el-form :model="registerForm" :rules="registerRules" ref="registerForm" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="registerForm.username"></el-input>
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="registerForm.realName"></el-input>
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="registerForm.phone"></el-input>
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="registerForm.password" type="password" show-password></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="registerForm.confirmPassword" type="password" show-password></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="registerDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitRegister" :loading="isRegisterLoading">注册</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'Login',
  data() {
    return {
      // 登录相关
      loginForm: {
        username: '',
        password: ''
      },
      loginRules: {
        username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
        password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
      },
      rememberMe: false,
      isLoading: false,

      // 注册相关
      registerDialogVisible: false,
      isRegisterLoading: false,
      registerForm: {},
      registerRules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' },
          { min: 3, max: 20, message: '用户名长度3-20位', trigger: 'blur' }
        ],
        realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
        phone: [
          { required: true, message: '请输入手机号', trigger: 'blur' },
          { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请确认密码', trigger: 'blur' },
          {
            validator: (rule, value, callback) => {
              if (value !== this.registerForm.password) {
                callback(new Error('两次输入密码不一致'))
              } else {
                callback()
              }
            },
            trigger: 'blur'
          }
        ]
      }
    }
  },
  created() {
    // 页面加载时，如果勾选了记住用户名，自动填充
    const savedUsername = localStorage.getItem('savedUsername')
    if (savedUsername) {
      this.loginForm.username = savedUsername
      this.rememberMe = true
    }
  },
  methods: {
    async handleLogin() {
      this.$refs.loginForm.validate(async valid => {
        if (valid) {
          this.isLoading = true
          try {
            const res = await this.$http.post('/user/login', null, {
              params: {
                username: this.loginForm.username,
                password: this.loginForm.password
              }
            })
            // 保存token和用户信息
            localStorage.setItem('token', res.data)
            const userInfo = await this.$http.get('/user/info')
            localStorage.setItem('userId', userInfo.data.id)
            localStorage.setItem('role', userInfo.data.role)
            localStorage.setItem('realName', userInfo.data.realName)

            // 记住用户名逻辑
            if (this.rememberMe) {
              localStorage.setItem('savedUsername', this.loginForm.username)
            } else {
              localStorage.removeItem('savedUsername')
            }

            this.$message.success('登录成功')
            this.$router.push('/')
          } catch (error) {
            // 错误已在axios拦截器中处理
          } finally {
            this.isLoading = false
          }
        }
      })
    },

    // 打开注册对话框
    openRegisterDialog() {
      this.registerForm = {}
      this.registerDialogVisible = true
      this.$nextTick(() => {
        this.$refs.registerForm.clearValidate()
      })
    },

    // 提交注册
    async submitRegister() {
      this.$refs.registerForm.validate(async valid => {
        if (valid) {
          this.isRegisterLoading = true
          try {
            await this.$http.post('/user/register', this.registerForm)
            this.$message.success('注册成功，请登录')
            this.registerDialogVisible = false
            // 自动填充用户名到登录框
            this.loginForm.username = this.registerForm.username
          } catch (error) {
            // 错误已在axios拦截器中处理
          } finally {
            this.isRegisterLoading = false
          }
        }
      })
    }
  }
}
</script>

<style scoped>
/* 最外层容器，全屏显示 */
.login-container {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  overflow: hidden;
}

/* 物流插画背景 */
.background-animation {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  /* 粘贴上面任意一条图片链接 */
  background-image: url('https://images.unsplash.com/photo-1595113022947-28b26e594d78?w=1920&q=75');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  /* 0.38透明度，柔和不暗沉，舒适最优参数 */
  background-color: antiquewhite;
  background-blend-mode: multiply;
  z-index: -1;
}

/* 登录卡片 */
.login-card {
  width: 420px;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(8px);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.login-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 36px rgba(0, 0, 0, 0.25);
}

/* 登录卡片头部 */
.login-header {
  text-align: center;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.login-header i {
  font-size: 24px;
  color: #409eff;
  margin-right: 8px;
  vertical-align: middle;
}

.login-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: bold;
  color: #333;
  display: inline-block;
  vertical-align: middle;
}

/* 登录表单 */
.login-form {
  padding: 20px 0;
}

/* 带图标的输入框 */
.input-with-icon {
  border-radius: 8px;
}

/* 登录按钮组 */
.login-button-group {
  margin-bottom: 0;
  text-align: center;
}

/* 登录按钮 */
.login-button {
  width: 100%;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.login-button:hover {
  transform: scale(1.02);
}
</style>