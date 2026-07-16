<template>
  <el-card>
    <h2 slot="header">我要寄件</h2>
    <el-form :model="orderForm" :rules="orderRules" ref="orderForm" label-width="100px" style="max-width: 600px;">
      <el-form-item label="寄件人姓名" prop="senderName">
        <el-input v-model="orderForm.senderName"></el-input>
      </el-form-item>
      <el-form-item label="寄件人电话" prop="senderPhone">
        <el-input v-model="orderForm.senderPhone"></el-input>
      </el-form-item>
      <el-form-item label="寄件人地址" prop="senderAddress">
        <el-input v-model="orderForm.senderAddress" type="textarea" rows="2"></el-input>
      </el-form-item>
      <el-form-item label="收件人姓名" prop="receiverName">
        <el-input v-model="orderForm.receiverName"></el-input>
      </el-form-item>
      <el-form-item label="收件人电话" prop="receiverPhone">
        <el-input v-model="orderForm.receiverPhone"></el-input>
      </el-form-item>
      <el-form-item label="收件人地址" prop="receiverAddress">
        <el-input v-model="orderForm.receiverAddress" type="textarea" rows="2"></el-input>
      </el-form-item>
      <el-form-item label="货物描述" prop="goodsDesc">
        <el-input v-model="orderForm.goodsDesc"></el-input>
      </el-form-item>
      <el-form-item label="货物重量(kg)" prop="weight">
        <el-input v-model.number="orderForm.weight" type="number" min="0.1"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitOrder">提交订单</el-button>
        <el-button @click="$router.push('/order')">取消</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script>
export default {
  name: 'CreateOrder',
  data() {
    return {
      orderForm: {
        senderName: '',
        senderPhone: '',
        senderAddress: '',
        receiverName: '',
        receiverPhone: '',
        receiverAddress: '',
        goodsDesc: '',
        weight: 1
      },
      orderRules: {
        senderName: [{ required: true, message: '请输入寄件人姓名', trigger: 'blur' }],
        senderPhone: [{ required: true, message: '请输入寄件人电话', trigger: 'blur' }],
        senderAddress: [{ required: true, message: '请输入寄件人地址', trigger: 'blur' }],
        receiverName: [{ required: true, message: '请输入收件人姓名', trigger: 'blur' }],
        receiverPhone: [{ required: true, message: '请输入收件人电话', trigger: 'blur' }],
        receiverAddress: [{ required: true, message: '请输入收件人地址', trigger: 'blur' }],
        weight: [{ required: true, message: '请输入货物重量', trigger: 'blur' }]
      }
    }
  },
  methods: {
    async submitOrder() {
      this.$refs.orderForm.validate(async valid => {
        if (valid) {
          const res = await this.$http.post('/order/create', this.orderForm)
          this.$message.success(`订单创建成功，订单号：${res.data}`)
          this.$router.push('/order')
        }
      })
    }
  }
}
</script>