const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
    transpileDependencies: true,
    lintOnSave: false,
    devServer: {
        proxy: {
            '/api': {
                target: 'http://localhost:8081',   // 改成你后端 Spring Boot 的端口
                changeOrigin: true,
                pathRewrite: { '^/api': '/api' }
            }
        }
    }
})