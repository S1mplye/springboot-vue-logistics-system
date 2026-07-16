import Vue from 'vue'
import Router from 'vue-router'
import Login from '../views/Login.vue'
import Home from '../views/Home.vue'
import OrderList from '../views/OrderList.vue'
import CreateOrder from '../views/CreateOrder.vue'
import TrackDetail from '../views/TrackDetail.vue'
import UserManage from "../views/UserManage.vue";
import Profile from "../views/Profile.vue"; // 新增：导入个人中心页面

Vue.use(Router)

const router = new Router({
    mode: 'hash',
    base: process.env.BASE_URL,
    routes: [
        {
            path: '/login',
            name: 'Login',
            component: Login
        },
        {
            path: '/',
            name: 'Home',
            component: Home,
            redirect: '/order',
            children: [
                { path: 'order', name: 'OrderList', component: OrderList },
                { path: 'create', name: 'CreateOrder', component: CreateOrder },
                { path: 'track/:id', name: 'TrackDetail', component: TrackDetail },
                { path: 'user', name: 'UserManage', component: UserManage },
                { path: 'profile', name: 'Profile', component: Profile } // 新增：个人中心路由
            ]
        },
        // 新增：404页面，匹配所有不存在的路径
        {
            path: '*',
            redirect: '/order'
        }
    ]
})

// 修正后的路由守卫
router.beforeEach((to, from, next) => {
    const token = localStorage.getItem('token')
    const role = parseInt(localStorage.getItem('role'))

    // 1. 如果访问登录页
    if (to.path === '/login') {
        if (token) {
            // 已登录，自动跳转到首页
            next('/order')
        } else {
            // 未登录，放行
            next()
        }
        return // 必须加return，终止函数执行
    }

    // 2. 如果没有token，跳转到登录页
    if (!token) {
        next('/login')
        return
    }

    // 3. 权限校验：只有管理员能访问用户管理页面
    if (to.path === '/user' && role !== 2) {
        next('/order')
        return
    }

    // 4. 其他情况，正常放行
    next()
})

// 解决重复点击导航报错的问题
const originalPush = Router.prototype.push
Router.prototype.push = function push(location) {
    return originalPush.call(this, location).catch(err => err)
}

export default router