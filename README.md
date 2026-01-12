# DeepSeek Mobile RAG Agent 🧠📱

这是一个基于 **Flutter** (移动端) + **FastAPI** (后端) + **DeepSeek V3** (AI模型) 的全栈垂直领域知识库助手。
实现了 RAG (检索增强生成) 流程，支持上传私有 PDF 文档并进行基于上下文的智能问答。

## ✨ 核心功能
- **全栈架构**：独立完成从移动端 UI 到后端 API 的完整开发。
- **RAG 引擎**：基于 DeepSeek 实现长文本理解与问答 (In-Context Learning)。
- **智能容错**：后端采用万能参数解析与内存处理方案，确保高并发下的稳定性。
- **极致体验**：针对 LLM 生成耗时，优化了前端网络超时策略与加载交互。

## 🛠️ 技术栈
- **Client**: Flutter, Dart, Dio, Material Design
- **Server**: Python 3.10, FastAPI, Uvicorn, pdfplumber
- **AI**: DeepSeek API (Chat Completions)

## 🚀 快速开始

### 1. 后端启动
```bash
cd backend
pip install fastapi uvicorn requests pdfplumber python-multipart
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
### 2. 移动端启动
flutter pub get
flutter run