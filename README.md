# springboot-vue-logistics-system

## 项目简介
基于 Spring Boot + MyBatis-Plus + Vue2 的前后端分离智能物流管理系统，实现多角色权限校验、订单全生命周期流转、物流轨迹追溯等核心功能，为本科软件工程综合实训项目。

## 技术栈
### 后端
- 核心框架：Spring Boot 2.7.x
- 持久层：MyBatis-Plus 3.5.x
- 数据库：MySQL 8.0
- 权限认证：JWT + 自定义拦截器
- 构建工具：Maven

### 前端
- 核心框架：Vue 2.6.x
- UI 组件库：Element UI
- HTTP 工具：Axios
- 构建工具：Vue CLI

## 核心功能模块
1.  **用户认证与权限管控**：JWT 统一鉴权，拦截器全局校验，支持管理员/快递员/普通用户三类角色的接口级权限控制
2.  **订单全生命周期管理**：订单多条件查询、分页展示、状态流转管控，覆盖待接单到签收/异常的完整业务流程
3.  **系统用户管理**：管理员对全量用户账号的增删改查、角色分配与状态管理
4.  **个人中心管理**：个人信息编辑、密码自主修改


## 项目结构
├── logistics-backend # Spring Boot 后端服务
├── logistics-frontend # Vue2 前端项目
└── sql # MySQL 建表脚本


## 本地运行说明
### 后端启动
1.  新建 MySQL 数据库，导入 `sql/logistics_system.sql` 建表脚本
2.  修改 `logistics-backend/src/main/resources/application.yml` 中的数据库连接地址、账号密码
3.  IDEA 打开 backend 目录，启动主类 `LogisticsSystemApplication`

### 前端启动
1.  进入 `logistics-frontend` 目录
2.  执行 `npm install` 安装依赖
3.  执行 `npm run serve` 启动前端服务

