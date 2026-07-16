<template>
  <div>
    <el-row :gutter="20" style="margin-bottom: 20px;">
      <el-col :span="16">
        <h2>订单管理</h2>
      </el-col>
      <el-col :span="8" style="text-align: right;">
        <el-button v-if="role === 0" type="primary" @click="$router.push('/create')">
          <i class="el-icon-edit"></i> 我要寄件
        </el-button>
      </el-col>
    </el-row>

    <!-- 搜索栏 -->
    <el-form :inline="true" :model="searchForm" style="margin-bottom: 20px;">
      <el-form-item label="搜索订单">
        <el-input
            v-model="searchForm.keyword"
            placeholder="请输入订单号/收件人姓名/收件人电话"
            style="width: 300px;"
            clearable
            @keyup.enter.native="handleSearch"
        ></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch" :loading="isLoading">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table
        :data="orderList"
        border
        stripe
        style="width: 100%;"
        empty-text="暂无订单数据"
        v-loading="isLoading"
    >
      <el-table-column prop="orderNo" label="订单编号" width="200"></el-table-column>
      <el-table-column prop="receiverName" label="收件人"></el-table-column>
      <el-table-column prop="receiverAddress" label="收件地址" width="300"></el-table-column>
      <el-table-column prop="freight" label="运费(元)" width="100">
        <template slot-scope="scope">
          ¥{{ scope.row.freight }}
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="120">
        <template slot-scope="scope">
          <el-tag :type="statusType[scope.row.status]">{{ statusText[scope.row.status] }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="下单时间" width="180">
        <template slot-scope="scope">
          {{ formatTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="250">
        <template slot-scope="scope">
          <el-button size="small" type="primary" @click="viewTrack(scope.row.id)">物流跟踪</el-button>

          <!-- 普通用户：只能取消待揽件订单 -->
          <el-button
              v-if="scope.row.status === 0 && role === 0"
              size="small"
              type="danger"
              @click="cancelOrder(scope.row.id)"
          >
            取消订单
          </el-button>

          <!-- 物流员：只能抢待揽件订单 -->
          <el-button
              v-if="scope.row.status === 0 && role === 1"
              size="small"
              type="success"
              @click="grabOrder(scope.row.id)"
          >
            抢单
          </el-button>

          <!-- 物流员：只能更新自己的订单状态 -->
          <el-button
              v-if="scope.row.courierId === userId && scope.row.status >= 1 && scope.row.status < 4"
              size="small"
              type="warning"
              @click="openUpdateStatusDialog(scope.row)"
          >
            更新状态
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页组件 -->
    <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="pageNum"
        :page-sizes="[5, 10, 20, 50]"
        :page-size="pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        style="text-align: right; margin-top: 20px;"
        v-show="total > 0"
    >
    </el-pagination>

    <!-- 更新状态对话框 -->
    <el-dialog
        title="更新订单状态"
        :visible.sync="updateDialogVisible"
        width="400px"
        :close-on-click-modal="false"
    >
      <el-form :model="statusForm" label-width="80px">
        <el-form-item label="当前状态">
          <el-tag :type="statusType[currentOrder.status]">{{ statusText[currentOrder.status] }}</el-tag>
        </el-form-item>
        <el-form-item label="下一状态">
          <el-tag :type="statusType[currentOrder.status + 1]">{{ statusText[currentOrder.status + 1] }}</el-tag>
        </el-form-item>
        <el-form-item label="当前位置" prop="location">
          <el-input
              v-model="statusForm.location"
              placeholder="请输入当前位置"
              clearable
          ></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="updateDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitUpdateStatus" :loading="isUpdating">确认更新</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'OrderList',
  data() {
    return {
      orderList: [],
      userId: parseInt(localStorage.getItem('userId')),
      role: parseInt(localStorage.getItem('role')),
      statusText: ['待揽件', '已揽件', '运输中', '派送中', '已签收', '已取消'],
      statusType: ['info', 'primary', 'warning', 'success', 'success', 'danger'],
      updateDialogVisible: false,
      currentOrder: {},
      statusForm: {
        location: ''
      },
      isLoading: false,
      isUpdating: false,
      // 分页和搜索相关
      pageNum: 1,
      pageSize: 10,
      total: 0,
      searchForm: {
        keyword: ''
      }
    }
  },
  created() {
    this.getOrderList()
  },
  methods: {
    async getOrderList() {
      this.isLoading = true
      try {
        const res = await this.$http.get('/order/my', {
          params: {
            pageNum: this.pageNum,
            pageSize: this.pageSize,
            keyword: this.searchForm.keyword
          }
        })

        // ✅ 100%匹配你的后端返回格式
        if (Array.isArray(res.data)) {
          // 不带分页参数时返回纯数组
          this.orderList = res.data
          this.total = res.data.length
        } else if (res.data.records) {
          // 带分页参数时返回分页对象
          this.orderList = res.data.records
          this.total = res.data.total
        } else {
          this.orderList = []
          this.total = 0
        }
      } catch (error) {
        this.$message.error('获取订单列表失败')
        this.orderList = []
        this.total = 0
      } finally {
        this.isLoading = false
      }
    },

    // 搜索
    handleSearch() {
      this.pageNum = 1 // 搜索时自动跳转到第一页
      this.getOrderList()
    },

    // 重置搜索
    handleReset() {
      this.searchForm.keyword = ''
      this.pageNum = 1
      this.getOrderList()
    },

    // 每页条数改变
    handleSizeChange(val) {
      this.pageSize = val
      this.pageNum = 1 // 切换每页条数时回到第一页
      this.getOrderList()
    },

    // 当前页改变
    handleCurrentChange(val) {
      this.pageNum = val
      this.getOrderList()
    },

    viewTrack(id) {
      this.$router.push(`/track/${id}`)
    },

    async cancelOrder(id) {
      try {
        await this.$confirm('确定要取消这个订单吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        await this.$http.post(`/order/cancel/${id}`)
        this.$message.success('订单取消成功')
        this.getOrderList()
      } catch (error) {
        if (error !== 'cancel') {
          this.$message.error('取消失败：' + (error.response?.data?.message || '未知错误'))
        }
      }
    },

    async grabOrder(id) {
      try {
        await this.$confirm('确定要抢这个订单吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        await this.$http.post(`/order/grab/${id}`)
        this.$message.success('抢单成功！')
        this.getOrderList()
      } catch (error) {
        if (error !== 'cancel') {
          this.$message.error('抢单失败：' + (error.response?.data?.message || '未知错误'))
        }
      }
    },

    openUpdateStatusDialog(row) {
      this.currentOrder = row
      this.statusForm.location = ''
      this.updateDialogVisible = true
    },

    async submitUpdateStatus() {
      if (!this.statusForm.location.trim()) {
        this.$message.error('请输入当前位置')
        return
      }

      this.isUpdating = true
      try {
        await this.$http.post(`/order/updateStatus/${this.currentOrder.id}`, null, {
          params: {
            status: this.currentOrder.status + 1,
            location: this.statusForm.location.trim()
          }
        })
        this.$message.success('状态更新成功')
        this.updateDialogVisible = false
        this.getOrderList()
      } catch (error) {
        this.$message.error('更新失败：' + (error.response?.data?.message || '未知错误'))
      } finally {
        this.isUpdating = false
      }
    },

    // 格式化时间
    formatTime(timeStr) {
      if (!timeStr) return ''
      const date = new Date(timeStr)
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>