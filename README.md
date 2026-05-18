# 我的数学课代表 (myAIMathsRep)

> AI-powered math learning assistant - 智能数学学习助手

## 项目介绍

我的数学课代表是一个基于 Flutter 开发的智能数学学习辅助应用，集成了大语言模型 (LLM) 技术，为教师提供一站式的教学管理、个性化练习生成、AI课件辅助等功能。

## 主要功能

### 📊 首页仪表板
- 教学数据概览与统计
- 快捷功能入口
- 实时消息通知

### 👥 学籍管理
- 学生信息管理
- 分组学习管理
- 学生筛选与查询

### 📈 学情诊断
- 学业风险评估
- 成绩趋势分析
- 能力维度诊断

### 📝 一人一练
- AI 个性化练习生成
- 根据学生错题和薄弱点定制
- 实时生成进度展示
- 练习记录管理
- 学生答题详情查看

### 📚 题库管理
- 题目库维护
- CSV 批量导入
- 知识点分类

### 🎓 课程研发
- AI 课件辅助生成
- Python 交互式演示课件
- 传统图文课件
- 视频讲稿脚本（60秒）

### 👨‍👩‍👧‍👦 小组导学
- 学习小组管理
- 组内学习情况
- 协作学习数据

### 📋 作业试卷
- 作业管理
- 批阅流程
- 统计分析

### 🎯 知识点
- 知识图谱
- 知识点梳理
- 学情关联

## 项目结构

```
myAIMathsRep/
├── lib/
│   ├── components/          # 可复用组件
│   │   ├── app_title_bar.dart
│   │   ├── ai_reply_bar.dart
│   │   ├── dashboard_cards.dart
│   │   ├── function_buttons.dart
│   │   ├── submenu_tabs.dart
│   │   └── ...
│   ├── data/                # 模拟数据
│   │   ├── fake_student_data.dart
│   │   ├── fake_practice_data.dart
│   │   ├── fake_curriculum_data.dart
│   │   └── fake_question_bank.dart
│   ├── database/            # 数据库模型
│   ├── models/              # 数据模型
│   ├── pages/               # 页面组件
│   │   ├── home_page.dart
│   │   ├── practice_page.dart
│   │   ├── courseware_page.dart
│   │   ├── student_management_page.dart
│   │   ├── diagnosis_page.dart
│   │   └── ...
│   ├── services/            # 服务层
│   │   ├── llm_service.dart
│   │   ├── practice_generator_service.dart
│   │   └── ...
│   └── main.dart
├── android/                 # Android 平台文件
├── ios/                     # iOS 平台文件
├── assets/                  # 资源文件
│   └── images/
├── build/                   # 构建输出目录
├── pubspec.yaml
└── README.md
```

## APK 打包与安装

### 📦 APK 输出位置

构建后的 APK 文件位于：

**推荐使用位置：**
```
build/app/outputs/flutter-apk/
├── app-debug.apk              # 调试版本
├── app-debug.apk.sha1         # 调试版本签名
├── app-release.apk            # 发布版本
└── app-release.apk.sha1       # 发布版本签名
```

**其他位置：**
```
build/app/outputs/apk/
├── debug/
│   └── app-debug.apk
└── release/
    └── app-release.apk
```

### 🔧 打包命令

在项目根目录下执行以下命令：

**生成调试版本（用于测试）：**
```bash
flutter build apk --debug
```

**生成发布版本（正式发布）：**
```bash
flutter build apk --release
```

**其他常用打包选项：**
```bash
# 同时生成所有 ABI 的优化版本
flutter build apk --split-per-abi

# 生成 App Bundle (Google Play 使用)
flutter build appbundle
```

### 📲 安装到设备

```bash
# 连接设备后直接安装
flutter install

# 或者使用 adb 安装
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 快速开始

### 环境要求

- Flutter SDK: ^3.11.5
- Dart: 兼容版本
- Android Studio / VS Code

### 本地运行

1. **克隆项目：**
```bash
cd /Volumes/Data/BaiduSyncdisk/reportLab/github/myAIMathsRep
```

2. **安装依赖：**
```bash
flutter pub get
```

3. **配置环境（如需要）：**
复制 `.env` 并配置 LLM API 密钥

4. **运行应用：**
```bash
# 连接设备或启动模拟器后
flutter run
```

## 核心提示语说明

### 一人一练提示语

**位置：** [`lib/pages/practice_page.dart`](file:///Volumes/Data/BaiduSyncdisk/reportLab/github/myAIMathsRep/lib/pages/practice_page.dart)

- **AI 练习题生成** (第243-275行)：根据学生错题和薄弱点生成个性化练习题

### AI课件生成提示语

**位置：** [`lib/pages/courseware_page.dart`](file:///Volumes/Data/BaiduSyncdisk/reportLab/github/myAIMathsRep/lib/pages/courseware_page.dart)

- **主提示语** (第64-112行)：三种课件类型的综合说明
- **Python交互课件** (第134-154行)：Jupyter Notebook 格式的演示课件
- **图文课件** (第156-176行)：Markdown 格式的传统课件
- **视频脚本** (第178-196行)：60秒视频讲稿

所有提示语均包含四大维度：
1. 历史渊源
2. 前置知识与原理
3. 核心公式与可视化
4. 生活应用案例

## 技术栈

| 技术 | 版本 | 用途 |
|-----|------|------|
| Flutter | ^3.11.5 | 跨平台 UI 框架 |
| SQLite (sqflite) | ^2.3.3 | 本地数据存储 |
| fl_chart | ^0.68.0 | 图表可视化 |
| http | ^1.2.1 | LLM API 调用 |
| flutter_quill | ^9.0.0 | 富文本编辑 |
| image_picker | ^1.1.2 | 图片选择 |
| video_player | ^2.8.6 | 视频播放 |

## 开发者信息

- 项目名称：myaimathsrep
- 描述："我的数学课代表 - AI-powered math learning assistant"
- 版本：1.0.0+1

## 许可证

本项目为内部开发项目。

---

*© 2026 我的数学课代表项目组*
