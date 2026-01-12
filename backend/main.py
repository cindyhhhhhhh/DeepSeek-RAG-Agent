from fastapi import FastAPI, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
import os
import pdfplumber
import requests  # 用来发请求给 DeepSeek

app = FastAPI()

# 1. 全局变量：临时存 PDF 里的字
GLOBAL_PDF_CONTENT = ""

# 2. 允许跨域（不用改）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. 上传接口（保持不变，负责存字）
@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    global GLOBAL_PDF_CONTENT
    
    # 建文件夹
    if not os.path.exists("uploads"):
        os.makedirs("uploads")
    
    # 保存文件
    file_path = os.path.join("uploads", file.filename)
    with open(file_path, "wb") as f:
        f.write(await file.read())
    
    # 提取文字
    text = ""
    with pdfplumber.open(file_path) as pdf:
        for page in pdf.pages:
            text += page.extract_text() or ""
    
    print(f"--> 提取成功！前200字: {text[:200]}")
    GLOBAL_PDF_CONTENT = text  # 存入全局变量
    
    return {
        "filename": file.filename,
        "status": "success",
        "summary": f"成功提取 {len(text)} 字"
    }

# 4. 分析接口（这是重头戏！已修复 422 错误）
@app.post("/analyze")
async def analyze_text(request: Request):
    print("--> 收到分析请求")
    
    try:
        # A. 万能解析：无论前端发什么，都接得住
        data = await request.json()
        print(f"--> 前端发来的原始数据: {data}")
        
        # 自动识别 query / question / user_input
        user_query = data.get("query") or data.get("question") or data.get("user_input") or data.get("text")
        
        if not user_query:
            return {"status": "error", "summary": "后端没收到问题，请检查前端发送的字段名"}

        print(f"--> 识别到的问题: {user_query}")
        print(f"--> 背景资料长度: {len(GLOBAL_PDF_CONTENT)}")

        if not GLOBAL_PDF_CONTENT:
            return {"status": "error", "summary": "请先上传 PDF 文档！现在内存是空的。"}

        # B. 真正的 DeepSeek 调用逻辑 (补全了这里)
        print("--> 正在呼叫 DeepSeek...")
        
        url = "https://api.deepseek.com/chat/completions"
        headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer your api"  # <--- 记得改这里！！！
        }
        
        payload = {
            "model": "deepseek-chat",
            "messages": [
                {"role": "system", "content": "你是一个专业的文档分析助手。请根据提供的背景资料回答用户问题。如果资料里没有答案，请直说。"},
                {"role": "user", "content": f"背景资料：\n{GLOBAL_PDF_CONTENT[:10000]}\n\n用户问题：{user_query}"}
            ],
            "stream": False
        }

        # 发送请求 (设置 60 秒超时，防止后端发呆)
        response = requests.post(url, headers=headers, json=payload, timeout=60)
        
        if response.status_code == 200:
            result = response.json()
            answer = result['choices'][0]['message']['content']
            print("--> DeepSeek 回答成功！")
            return {
                "status": "success",
                "summary": answer,
                "action_items": ["分析完成", "请查看上方摘要"]
            }
        else:
            print(f"!!! DeepSeek API 报错: {response.text}")
            return {"status": "error", "summary": f"AI 调用失败: {response.status_code}"}

    except Exception as e:
        print(f"!!! 发生代码错误: {e}")
        return {"status": "error", "summary": f"后端崩了: {str(e)}"}