<template>
  <div>
    <h2 style="margin-bottom: 20px;">个人中心</h2>
    <el-card>
      <!-- 顶部编辑按钮 -->
      <div style="text-align: right;margin-bottom:10px">
        <el-button v-if="!isEdit" type="primary" @click="openEdit">编辑资料</el-button>
        <el-button v-if="isEdit" type="success" @click="saveUserInfo">保存资料</el-button>
        <el-button v-if="isEdit" @click="cancelEdit">取消</el-button>
      </div>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="用户名">
          {{ userInfo.username }}
        </el-descriptions-item>

        <el-descriptions-item label="真实姓名">
          <el-input v-if="isEdit" v-model="userInfo.realName" placeholder="请输入真实姓名"></el-input>
          <span v-else>{{ userInfo.realName || '未填写' }}</span>
        </el-descriptions-item>

        <el-descriptions-item label="手机号">
          <el-input v-if="isEdit" v-model="userInfo.phone" placeholder="请输入手机号"></el-input>
          <span v-else>{{ userInfo.phone || '未填写' }}</span>
        </el-descriptions-item>

        <el-descriptions-item label="角色">
          {{ roleText[userInfo.role] }}
        </el-descriptions-item>
      </el-descriptions>

      <el-divider></el-divider>

      <h3>修改密码</h3>
      <el-form :model="passwordForm" :rules="passwordRules" ref="passwordForm" label-width="100px" style="max-width: 400px; margin-top: 20px;">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input v-model="passwordForm.oldPassword" type="password" show-password></el-input>
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" show-password></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" show-password></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitPassword" :loading="isLoading">修改密码</el-button>
        </el-form-item>
      </el-form>
    </el-card>

  </div>
</template>

<script>
export default {
  name: 'Profile',
  data() {
    return {
      userInfo: {},
      // 缓存原始用户信息，取消编辑时回滚数据
      originUserInfo: {},
      // 编辑开关
      isEdit: false,
      roleText: ['普通用户', '快递员', '管理员'],
      passwordForm: {},
      isLoading: false,
      passwordRules: {
        oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
        newPassword: [
          { required: true, message: '请输入新密码', trigger: 'blur' },
          { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请确认新密码', trigger: 'blur' },
          {
            validator: (rule, value, callback) => {
              if (value !== this.passwordForm.newPassword) {
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
    this.getUserInfo()
  },
  methods: {
    async getUserInfo() {
      const res = await this.$http.get('/user/info')
      this.userInfo = res.data
      // 备份原始数据
      this.originUserInfo = JSON.parse(JSON.stringify(this.userInfo))
    },
    // 开启编辑
    openEdit() {
      this.isEdit = true
    },
    // 取消编辑，恢复原始数据
    cancelEdit() {
      this.isEdit = false
      this.userInfo = JSON.parse(JSON.stringify(this.originUserInfo))
    },
    // 保存个人信息
    async saveUserInfo() {
      try {
        await this.$http.put('/user/info/edit', this.userInfo)
        this.$message.success('个人信息修改成功')
        this.isEdit = false
        // 刷新最新用户信息
        this.getUserInfo()
      } catch (err) {
        this.$message.error(err.response?.data?.message || '修改信息失败')
      }
    },
    async submitPassword() {
      this.$refs.passwordForm.validate(async valid => {
        if (valid) {
          this.isLoading = true
          try {
            await this.$http.put('/user/password', null, {
              params: {
                oldPassword: this.passwordForm.oldPassword,
                newPassword: this.passwordForm.newPassword
              }
            })
            this.$message.success('密码修改成功，请重新登录')
            localStorage.clear()
            this.$router.push('/login')
          } catch (error) {
            this.$message.error(error.response?.data?.message || '密码修改失败')
          } finally {
            this.isLoading = false
          }
        }
      })
    }
  }
}
</script>