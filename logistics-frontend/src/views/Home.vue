Home.vue
<template>
  <el-container style="height: 100vh;">
    <el-aside width="200px" style="background-color: #2d3748;">
      <!-- 系统标题 -->
      <div style="text-align: center; padding: 20px 0; color: white; font-size: 18px; font-weight: bold; border-bottom: 1px solid #4a5568;">
        智能物流管理系统
      </div>

      <el-menu
          default-active="$route.path"
          class="el-menu-vertical-demo"
          background-color="#2d3748"
          text-color="#fff"
          active-text-color="#409eff"
          router
          unique-opened
      >
        <el-menu-item index="/order">
          <i class="el-icon-s-order"></i>
          <span slot="title">订单管理</span>
        </el-menu-item>
        <el-menu-item index="/create" v-if="role === 0">
          <i class="el-icon-edit"></i>
          <span slot="title">我要寄件</span>
        </el-menu-item>
        <el-menu-item index="/user" v-if="role === 2">
          <i class="el-icon-user"></i>
          <span slot="title">用户管理</span>
        </el-menu-item>
        <!-- 新增：个人中心入口，所有用户可见 -->
        <el-menu-item index="/profile">
          <i class="el-icon-user-solid"></i>
          <span slot="title">个人中心</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header style="text-align: right; padding: 0 20px; line-height: 60px; background-color: #fff; border-bottom: 1px solid #eee;">
        <span>欢迎您，{{ realName }}</span>
        <el-button type="text" @click="logout" style="margin-left: 20px;">退出登录</el-button>
      </el-header>
      <el-main style="background-color: #f5f5f5;">
        <router-view></router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
export default {
  name: 'Home',
  data() {
    return {
      role: 0,
      realName: ''
    }
  },
  created() {
    // ✅ 修复：从后端获取用户信息，而不是直接读localStorage
    this.getUserInfo()
  },
  methods: {
    async getUserInfo() {
      try {
        const res = await this.$http.get('/user/info')
        this.role = res.data.role
        this.realName = res.data.realName
        // 同时更新localStorage，保持同步
        localStorage.setItem('role', res.data.role)
        localStorage.setItem('realName', res.data.realName)
      } catch (error) {
        // 如果获取用户信息失败，说明token过期，直接跳转到登录页
        this.$message.error('登录已过期，请重新登录')
        localStorage.clear()
        this.$router.push('/login')
      }
    },

    async logout() {
      // ✅ 修复：添加退出登录确认
      await this.$confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      localStorage.clear()
      this.$router.push('/login')
      this.$message.success('退出成功')
    }
  }
}
</script>