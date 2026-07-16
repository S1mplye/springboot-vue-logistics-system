<template>
  <div>
    <el-row :gutter="20" style="margin-bottom: 20px;">
      <el-col :span="16">
        <h2>用户管理</h2>
      </el-col>
      <el-col :span="8" style="text-align: right;">
        <el-button type="primary" @click="openAddDialog">
          <i class="el-icon-plus"></i> 新增用户
        </el-button>
      </el-col>
    </el-row>

    <!--搜索区域-->
    <el-form :inline="true" :model="searchForm" style="margin-bottom:20px">
      <el-form-item label="搜索">
        <el-input v-model="searchForm.keyword" placeholder="用户名/姓名/手机号" clearable @keyup.enter="getUserList"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="getUserList">搜索</el-button>
        <el-button @click="resetSearch">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="userList" border stripe style="width: 100%;">
      <el-table-column prop="id" label="ID" width="80"></el-table-column>
      <el-table-column prop="username" label="用户名"></el-table-column>
      <el-table-column prop="realName" label="真实姓名"></el-table-column>
      <el-table-column prop="phone" label="手机号"></el-table-column>
      <el-table-column prop="role" label="角色" width="120">
        <template slot-scope="scope">
          <el-tag :type="roleType[scope.row.role]">{{ roleText[scope.row.role] }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === 0 ? 'success' : 'danger'">
            {{ scope.row.status === 0 ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="180">
        <template slot-scope="scope">
          {{ formatTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template slot-scope="scope">
          <el-button size="small" type="primary" @click="openEditDialog(scope.row)">编辑</el-button>
          <el-button
              size="small"
              type="danger"
              @click="deleteUser(scope.row.id)"
              :disabled="scope.row.id === userId"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!--分页-->
    <el-pagination
        style="margin-top:15px;text-align:right"
        :current-page="pageNum"
        :page-size="pageSize"
        :page-sizes="[5,10,20,50]"
        :total="total"
        layout="total,sizes,prev,pager,next,jumper"
        @size-change="sizeChange"
        @current-change="pageChange"
    ></el-pagination>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
        :title="dialogTitle"
        :visible.sync="dialogVisible"
        width="500px"
        :close-on-click-modal="false"
    >
      <el-form :model="userForm" :rules="userRules" ref="userForm" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" :disabled="isEdit"></el-input>
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="userForm.realName"></el-input>
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="userForm.phone"></el-input>
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role" style="width: 100%;">
            <el-option label="普通用户" :value="0"></el-option>
            <el-option label="快递员" :value="1"></el-option>
            <el-option label="管理员" :value="2"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="userForm.status" style="width: 100%;">
            <el-option label="正常" :value="0"></el-option>
            <el-option label="禁用" :value="1"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm" :loading="isSubmitting">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'UserManage',
  data() {
    return {
      userList: [],
      userId: parseInt(localStorage.getItem('userId')),
      dialogVisible: false,
      dialogTitle: '',
      isEdit: false,
      isSubmitting: false,
      userForm: {},
      userRules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' },
          { min: 3, max: 20, message: '用户名长度3-20位', trigger: 'blur' }
        ],
        realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
        phone: [
          { required: true, message: '请输入手机号', trigger: 'blur' },
          { pattern: /^1[3-9]\d{9}$/, message: '手机号格式错误', trigger: 'blur' }
        ],
        role: [{ required: true, message: '请选择角色', trigger: 'change' }]
      },
      roleText: ['普通用户', '快递员', '管理员'],
      roleType: ['info', 'primary', 'success'],

      //分页+搜索
      pageNum:1,
      pageSize:10,
      total:0,
      searchForm:{
        keyword:''
      }
    }
  },
  created() {
    this.getUserList()
  },
  methods: {
    //请求用户列表
    async getUserList() {
      const res = await this.$http.get('/user/list',{
        params:{
          pageNum:this.pageNum,
          pageSize:this.pageSize,
          keyword:this.searchForm.keyword
        }
      })
      //后端重启后data是分页对象
      this.userList = res.data.records
      this.total = res.data.total
    },

    //切换每页条数
    sizeChange(val){
      this.pageSize = val
      this.pageNum = 1
      this.getUserList()
    },
    //换页码
    pageChange(val){
      this.pageNum = val
      this.getUserList()
    },
    //重置搜索
    resetSearch(){
      this.searchForm.keyword=''
      this.pageNum=1
      this.getUserList()
    },

    openAddDialog() {
      this.isEdit = false
      this.dialogTitle = '新增用户'
      this.userForm = { role: 1, status: 0 }
      this.dialogVisible = true
      this.$nextTick(() => this.$refs.userForm.clearValidate())
    },

    openEditDialog(row) {
      this.isEdit = true
      this.dialogTitle = '编辑用户'
      this.userForm = { ...row }
      this.dialogVisible = true
      this.$nextTick(() => this.$refs.userForm.clearValidate())
    },

    async submitForm() {
      this.$refs.userForm.validate(async valid => {
        if (!valid) return
        this.isSubmitting = true
        try {
          if (this.isEdit) {
            await this.$http.put('/user/update', this.userForm)
            this.$message.success('用户信息修改成功')
          } else {
            await this.$http.post('/user/add', this.userForm)
            await this.$alert(`用户${this.userForm.username}添加成功！<br>默认密码：<strong style="color:#409eff">123456</strong>`, '创建成功', {dangerouslyUseHTMLString:true})
          }
          this.dialogVisible = false
          this.getUserList()
        } catch (err) {
          this.$message.error(err.response?.data?.message || '操作失败')
        } finally {
          this.isSubmitting = false
        }
      })
    },

    async deleteUser(id) {
      try {
        await this.$confirm('确定删除该用户？','提示',{type:'warning'})
        await this.$http.delete(`/user/delete/${id}`)
        this.$message.success('删除成功')
        this.getUserList()
      }catch(e){
        if(e!=='cancel') this.$message.error('删除失败')
      }
    },

    formatTime(timeStr) {
      if (!timeStr) return ''
      const date = new Date(timeStr)
      return date.toLocaleString('zh-CN', {
        year: 'numeric',month: '2-digit',day: '2-digit',hour: '2-digit',minute: '2-digit'
      })
    }
  }
}
</script>