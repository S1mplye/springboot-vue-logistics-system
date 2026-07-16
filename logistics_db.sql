/*
Navicat MySQL Data Transfer

Source Server         : we
Source Server Version : 50744
Source Host           : localhost:3306
Source Database       : logistics_db

Target Server Type    : MYSQL
Target Server Version : 50744
File Encoding         : 65001

Date: 2026-06-10 09:25:03
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `logistics_order`
-- ----------------------------
DROP TABLE IF EXISTS `logistics_order`;
CREATE TABLE `logistics_order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_no` varchar(32) NOT NULL COMMENT '订单编号',
  `user_id` bigint(20) NOT NULL COMMENT '下单用户ID',
  `courier_id` bigint(20) DEFAULT NULL COMMENT '接单物流员ID',
  `sender_name` varchar(32) NOT NULL COMMENT '寄件人姓名',
  `sender_phone` varchar(11) NOT NULL COMMENT '寄件人电话',
  `sender_address` varchar(255) NOT NULL COMMENT '寄件人地址',
  `receiver_name` varchar(32) NOT NULL COMMENT '收件人姓名',
  `receiver_phone` varchar(11) NOT NULL COMMENT '收件人电话',
  `receiver_address` varchar(255) NOT NULL COMMENT '收件人地址',
  `goods_desc` varchar(128) DEFAULT NULL COMMENT '货物描述',
  `weight` decimal(5,2) NOT NULL COMMENT '货物重量(kg)',
  `freight` decimal(8,2) NOT NULL COMMENT '运费',
  `status` int(11) DEFAULT '0' COMMENT '0-待揽件,1-已揽件,2-运输中,3-派送中,4-已签收,5-已取消',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int(11) DEFAULT '0' COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of logistics_order
-- ----------------------------
INSERT INTO `logistics_order` VALUES ('1', 'LD17803840739053464', '3', '2', '张三', '13800138000', '东莞市南城区XX路XX号', '李四', '13900139000', '广州市天河区XX路XX号', '衣服', '2.50', '17.50', '2', '2026-06-02 15:07:53', '2026-06-02 15:07:53', '0');
INSERT INTO `logistics_order` VALUES ('2', 'LD17804788820725052', '5', '2', '陈', '15326346112', '广东省东莞市万江', '吴y', '13567867835', '广东省东莞市长安镇', '衣物', '2.10', '15.50', '3', '2026-06-03 17:28:02', '2026-06-03 17:28:02', '3');
INSERT INTO `logistics_order` VALUES ('3', 'LD17805396638067562', '4', null, '李用户', '14325243463', '福建省厦门', '陈', '15667857667', '广东省东莞市', '萨达', '1.00', '10.00', '5', '2026-06-04 10:21:03', '2026-06-04 10:21:03', '1');
INSERT INTO `logistics_order` VALUES ('4', 'LD17805405437727587', '4', '2', '李用户', '15436576876', '福建省厦门', '风1', '21234575686', '东北', '1111111', '2.00', '15.00', '1', '2026-06-04 10:35:43', '2026-06-04 10:35:43', '1');
INSERT INTO `logistics_order` VALUES ('5', 'LD17805433360453926', '5', '7', '陈', '15326346112', '广东省东莞市万江', '吴', '13567867835', '广东省东莞市长安镇', '丝织品', '2.10', '15.50', '1', '2026-06-04 11:22:16', '2026-06-04 11:22:16', '1');
INSERT INTO `logistics_order` VALUES ('6', 'LD17806241900344194', '4', null, '李用户', '15784574845', '广东省深圳市', '吴ue', '15688677961', '广东省东莞市长安镇', 'ueww', '5.00', '30.00', '0', '2026-06-05 09:49:50', '2026-06-05 09:49:50', '0');

-- ----------------------------
-- Table structure for `logistics_track`
-- ----------------------------
DROP TABLE IF EXISTS `logistics_track`;
CREATE TABLE `logistics_track` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) NOT NULL COMMENT '关联订单ID',
  `status` int(11) NOT NULL COMMENT '对应订单状态',
  `status_desc` varchar(128) NOT NULL COMMENT '状态描述',
  `location` varchar(128) NOT NULL COMMENT '当前位置',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of logistics_track
-- ----------------------------
INSERT INTO `logistics_track` VALUES ('1', '1', '1', '快递员已揽件', '东莞市南城区XX路XX号', '2026-06-02 15:41:16');
INSERT INTO `logistics_track` VALUES ('2', '1', '2', '货物运输中', '东莞', '2026-06-02 15:41:30');
INSERT INTO `logistics_track` VALUES ('3', '3', '5', '订单已取消', '系统', '2026-06-04 10:26:47');
INSERT INTO `logistics_track` VALUES ('4', '2', '2', '货物运输中', '广东省东莞市长安镇', '2026-06-04 10:36:49');
INSERT INTO `logistics_track` VALUES ('5', '2', '3', '正在派送中', '广东省东莞市长安镇厦边', '2026-06-04 10:46:58');
INSERT INTO `logistics_track` VALUES ('6', '4', '1', '快递员已揽件', '福建省厦门', '2026-06-04 11:04:22');
INSERT INTO `logistics_track` VALUES ('7', '5', '1', '快递员已揽件', '广东省东莞市万江', '2026-06-04 11:23:18');

-- ----------------------------
-- Table structure for `sys_user`
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL COMMENT '用户名/手机号',
  `password` varchar(128) NOT NULL COMMENT '密码(MD5加密)',
  `real_name` varchar(32) DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(11) DEFAULT NULL COMMENT '联系电话',
  `role` int(11) DEFAULT '0' COMMENT '0-普通用户,1-物流员,2-管理员',
  `status` int(11) DEFAULT '0' COMMENT '0-正常,1-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of sys_user
-- password:123456
-- ----------------------------
INSERT INTO `sys_user` VALUES ('1', 'admin', 'e10adc3949ba59abbe56e057f20f883e', '管理员', null, '2', '0', '2026-06-02 09:38:15', '2026-06-02 09:38:15');
INSERT INTO `sys_user` VALUES ('2', 'courier1', 'e10adc3949ba59abbe56e057f20f883e', '张快递', '13567457472', '1', '0', '2026-06-02 09:38:15', '2026-06-04 20:34:46');
INSERT INTO `sys_user` VALUES ('4', 'user1', 'e10adc3949ba59abbe56e057f20f883e', '李用户', null, '0', '0', '2026-06-03 16:07:27', '2026-06-03 16:07:27');
INSERT INTO `sys_user` VALUES ('5', 'wheuw', 'e10adc3949ba59abbe56e057f20f883e', '陈', '15326346112', '0', '0', '2026-06-03 17:10:55', '2026-06-03 17:10:55');
INSERT INTO `sys_user` VALUES ('7', 'courier2', 'e10adc3949ba59abbe56e057f20f883e', '高快递员', '15468865856', '1', '0', '2026-06-04 11:13:34', '2026-06-04 11:13:34');
INSERT INTO `sys_user` VALUES ('8', 'courier3', 'e10adc3949ba59abbe56e057f20f883e', '徐快递', '15688796695', '1', '0', '2026-06-04 11:30:17', '2026-06-04 11:30:17');
INSERT INTO `sys_user` VALUES ('9', 'qw1', 'e10adc3949ba59abbe56e057f20f883e', 'donk', '15685685812', '0', '0', '2026-06-04 11:34:08', '2026-06-04 11:34:08');
