# DeepSeek Mobile RAG Agent 🧠📱

这是一个基于 **Flutter（移动端）+ FastAPI（后端）+ DeepSeek V3（大模型）**  
构建的全栈垂直领域知识库助手，实现了 **RAG（Retrieval-Augmented Generation，检索增强生成）** 流程。

系统支持上传私有 **PDF 文档**，并基于文档上下文进行智能问答，适用于个人知识库、学习辅助与专业文档分析等场景。

---

## ✨ 核心功能

- **全栈架构**  
  独立完成从移动端 UI 到后端 API 的完整开发流程

- **RAG 引擎**  
  基于 DeepSeek V3 的长文本理解与上下文增强问答（In-Context Learning）

- **文档问答**  
  支持上传私有 PDF 文档并进行基于内容的智能问答

- **智能容错**  
  后端采用通用参数解析与内存处理策略，提升并发稳定性

- **极致体验**  
  针对 LLM 响应耗时，优化前端加载状态与网络超时处理

---

## 🛠️ 技术栈

- **Client（移动端）**
  - Flutter
  - Dart
  - Dio
  - Material Design

- **Server（后端）**
  - Python 3.10
  - FastAPI
  - Uvicorn
  - pdfplumber
  - python-multipart

- **AI 模型**
  - DeepSeek API（Chat Completions）

---

## 🚀 快速开始

### 1. 后端启动 
```bash
cd backend
pip install fastapi uvicorn requests pdfplumber python-multipart
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 2. 前端启动

进入前端（Flutter）项目目录后，先拉取依赖：
   ```bash
   flutter pub get
```
启动应用
   ```bash
   flutter run
```
---

-**项目截图**
<img width="459" height="934" alt="屏幕截图 2026-01-12 170152" src="https://github.com/user-attachments/assets/42befa01-01b9-4ee7-9c1c-30f9e641cef6" />
<img width="452" height="933" alt="屏幕截图 2026-01-12 170206" src="https://github.com/user-attachments/assets/77e5e7db-2d1e-46da-9477-0594cd48cdec" />
<img width="644" height="1314" alt="屏幕截图 2026-01-12 170445" src="https://github.com/user-attachments/assets/3fde4bbf-7361-4098-a7f3-7abdf74d209f" />
<img width="1631" height="788" alt="屏幕截图 2026-01-12 170502" src="https://github.com/user-attachments/assets/14ed5787-1ed3-47cf-8c26-9859888bab8b" />

