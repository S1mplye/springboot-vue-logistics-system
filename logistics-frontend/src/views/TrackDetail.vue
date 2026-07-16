<template>
  <div>
    <el-row :gutter="20" style="margin-bottom: 20px;">
      <el-col :span="16">
        <h2>物流跟踪</h2>
      </el-col>
      <el-col :span="8" style="text-align: right;">
        <el-button @click="$router.push('/order')">返回订单列表</el-button>
      </el-col>
    </el-row>

    <el-card>
      <div slot="header" style="font-weight: bold; font-size: 16px;">
        订单号：{{ orderNo }}
      </div>

      <!-- 空数据提示 -->
      <div v-if="trackList.length === 0" style="text-align: center; padding: 40px 0; color: #999;">
        暂无物流信息
      </div>

      <!-- 物流时间线 -->
      <el-timeline v-else>
        <el-timeline-item
            v-for="(item, index) in trackList"
            :key="item.id"
            :timestamp="formatTime(item.createTime)"
            :type="index === trackList.length - 1 ? 'primary' : ''"
            :color="index === trackList.length - 1 ? '#409eff' : '#c0c4cc'"
        >
          <h4 style="margin: 0; font-size: 14px; font-weight: 500;">{{ item.statusDesc }}</h4>
          <p style="margin: 5px 0 0 0; color: #666; font-size: 13px;">
            位置：{{ item.location }}
          </p>
        </el-timeline-item>
      </el-timeline>
    </el-card>
  </div>
</template>

<script>
export default {
  name: 'TrackDetail',
  data() {
    return {
      orderNo: '',
      trackList: []
    }
  },
  created() {
    this.getTrackDetail()
  },
  methods: {
    async getTrackDetail() {
      const orderId = this.$route.params.id
      try {
        // 1. 获取物流轨迹（后端返回正序：最早的在前）
        const trackRes = await this.$http.get(`/track/${orderId}`)
        this.trackList = trackRes.data // 不需要reverse！后端已经按时间正序排好了

        // 2. 获取订单信息（显示订单号）
        const orderRes = await this.$http.get('/order/my')
        const order = orderRes.data.find(o => o.id == orderId)
        if (order) {
          this.orderNo = order.orderNo
        }
      } catch (error) {
        this.$message.error('获取物流信息失败，请稍后重试')
      }
    },

    // 统一格式化时间
    formatTime(timeStr) {
      if (!timeStr) return ''
      const date = new Date(timeStr)
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    }
  }
}
</script>

<style scoped>
/* 统一时间线样式 */
.el-timeline-item__timestamp {
  color: #909399 !important;
  font-size: 12px !important;
}

.el-timeline-item__content {
  padding-bottom: 20px !important;
}
</style>