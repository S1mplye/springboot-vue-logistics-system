import axios from 'axios'
import ElementUI from 'element-ui'

// 创建axios实例
const service = axios.create({
    baseURL: 'http://localhost:8081', // 后端地址，和你的端口一致
    timeout: 5000 // 请求超时时间
})

// 请求拦截器：自动添加token
service.interceptors.request.use(
    config => {
        const token = localStorage.getItem('token')
        if (token) {
            config.headers.token = token // 后端要求的请求头是token
        }
        return config
    },
    error => {
        return Promise.reject(error)
    }
)

// 响应拦截器：统一处理错误
service.interceptors.response.use(
    response => {
        const res = response.data
        if (res.code !== 200) {
            ElementUI.Message.error(res.msg || '请求失败')
            return Promise.reject(new Error(res.msg || '请求失败'))
        } else {
            return res
        }
    },
    error => {
        ElementUI.Message.error('网络错误，请稍后重试')
        return Promise.reject(error)
    }
)

export default service