# 快速拨号
一个简单的快速拨号软件，个人首个 flutter 练手项目。

## 为什么做这个

个人目前使用 iphone，由于系统自带的拨号软件无法快速找到联系人，以前一直在用某指拨号，鉴于某指拨号现在启动越来越慢还加了广告，特别影响拨号效率。最近刚好接触了 flutter，便有了这个练手项目。  
该应用已经在我的手机上暂时替代了某指拨号，很多功能还不完善，会慢慢完善的。


## 功能介绍
- 仅仅只是个拨号软件，根据拼音和数字排序通讯录实现快速拨号，目前功能还很弱鸡，满足个人使用和学习flutter所用
- 暂时只使用了系统通讯录权限，告别其他无用权限
- 无广告不联网😒😒

## 使用的插件
- fluro: "^1.6.3"
- provider: ^4.3.2
- permission_handler: ^5.0.1
- sqflite: ^1.3.1+1
- lpinyin: ^1.0.8  #latest version
- url_launcher: ^5.5.2  #latest version
- event_bus: ^1.1.1
- flutter_phone_state: ^0.5.8
- azlistview: ^1.0.1

## 平台支持

由于大部分 android 手机自带拨号软件都比较智能，所以目前该项目只支持 IOS 系统
| 平台 | 支持 |
|-|-|
|IOS| √|
|android| x|
|其他| x|

## ToDoList
- [ ] 新增/编辑联系人，目前只有页面没有功能
- [ ] ui优化

## 预览
![](https://raw.githubusercontent.com/bestv2/flutter_dial/master/screenshot/in_one.png)  
  
![](https://gitee.com/bestv2/flutter_dial/raw/master/screenshot/in_one.png)  


