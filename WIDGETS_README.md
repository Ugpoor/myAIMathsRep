# Flutter 高复用部件库

## 部件总览

### 1. AppTitleBar - 通用标题栏
**位置**: `lib/components/app_title_bar.dart`

**功能**: 应用顶部通用标题栏
- 高度: 屏幕高度 * 0.08
- 固定粉色背景 (Color(0xFFFF69B4))
- 底部圆角设计

**使用方法**:
```dart
AppTitleBar(
  title: '我的AI语言学习助理',
  showChatSuffix: false, // 可选，显示聊天后缀
)
```

---

### 2. AIReplyBar - AI信息栏（收起/展开）
**位置**: `lib/components/ai_reply_bar.dart`

**功能**: AI回复信息展示栏，支持下拉展开
- 收起高度: 100
- 展开高度: 200
- 支持手势滑动切换
- 包含AI头像和回复气泡

**使用方法**:
```dart
AIReplyBar(
  isExpanded: _isExpanded,
  onToggle: () {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  },
)
```

---

### 3. MenuGrid - 功能菜单网格
**位置**: `lib/components/menu_grid.dart`

**功能**: 6宫格功能菜单
- 3列布局
- 彩色背景 + 阴影效果
- 支持点击事件

**菜单包括**:
- 收件箱
- 错误本
- 知识点
- 习题集
- 作品集
- 技能库

**使用方法**:
```dart
const MenuGrid()
```

---

### 4. EfficiencySection - 效率展示区
**位置**: `lib/components/efficiency_section.dart`

**功能**: 用户效率数据展示
- 包含两个卡片：效率记录 + 日程安排
- 支持自定义内容

**使用方法**:
```dart
const EfficiencySection()
```

---

### 5. SubmenuTabs - 子菜单标签栏
**位置**: `lib/components/submenu_tabs.dart`

**功能**: 可滚动的横向标签栏
- 支持自定义标签列表
- 选中状态高亮显示
- 圆角设计 + 阴影效果

**使用方法**:
```dart
SubmenuTabs(
  tabs: ['收件箱', '错误本', '知识点'],
  selectedTab: _selectedTab,
  onTabSelected: (tab) {
    setState(() {
      _selectedTab = tab;
    });
  },
)
```

---

### 6. InputArea - 用户输入栏
**位置**: `lib/components/input_area.dart`

**功能**: 底部用户输入区域
- 用户头像
- 文本输入框
- Home快捷按钮
- 语音输入按钮

**使用方法**:
```dart
const InputArea()
```

---

### 7. ChatBubbleList - 聊天气泡列表
**位置**: `lib/components/chat_bubble_list.dart`

**功能**: 聊天消息列表展示
- AI消息靠左（绿色气泡）
- 用户消息靠右（白色气泡）
- 支持自定义头像
- 可滚动列表

**使用方法**:
```dart
ChatBubbleList(
  messages: [
    ChatMessage(sender: 'AI', text: '你好', isAI: true),
    ChatMessage(sender: '用户', text: '你好', isAI: false),
  ],
)
```

---

### 8. PullUpControl - 收起控制栏
**位置**: `lib/components/pull_up_control.dart`

**功能**: 聊天页面收起控制
- 小横条指示器
- 点击收起聊天
- 高度: 屏幕高度 * 0.05

**使用方法**:
```dart
PullUpControl(
  onPullUp: () {
    // 收起聊天
  },
  label: '收起聊天', // 可选
)
```

---

## 页面组件

### HomePage - 主页面
**位置**: `lib/pages/home_page.dart`

**功能**: 业务功能首页
- 标题栏
- AI信息栏
- 功能菜单
- 效率展示
- 底部输入栏

---

### ChatPage - 聊天页面
**位置**: `lib/pages/chat_page.dart`

**功能**: 聊天交互页面
- 聊天标题栏
- 聊天气泡列表
- 收起控制
- 筛选标签
- 底部输入栏

---

## 设计规范

### 颜色主题
- 主色调: Color(0xFFFF69B4) (粉色)
- 背景色: Color(0xFFFFE4E9) (浅粉色)
- AI气泡: Color(0xFF90EE90) (浅绿色)
- 白色: Colors.white

### 圆角规范
- 小控件: 12-16
- 卡片/容器: 16-20
- 头像: 14-20

### 阴影效果
- 标准阴影: blurRadius 5, spreadRadius 2
- 颜色使用: 主色调.withOpacity(0.3) 或 Colors.grey.withOpacity(0.2)

### 响应式比例
- 标题栏: 屏幕高度 * 0.08
- 收起控制栏: 屏幕高度 * 0.05
