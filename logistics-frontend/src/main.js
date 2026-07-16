import Vue from 'vue'
import App from './App.vue'
import router from './router'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import request from './utils/request'

// 全局挂载axios，所有组件都能通过this.$http调用
Vue.prototype.$http = request

Vue.use(ElementUI)
Vue.config.productionTip = false

console.log(router); // 看看控制台输出的 router 对象是否正常

new Vue({
    router,
    render: h => h(App)
}).$mount('#app')
