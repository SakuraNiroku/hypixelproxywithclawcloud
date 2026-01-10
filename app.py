from flask import Flask, request, send_file, render_template, jsonify
import os, subprocess, requests

app = Flask(__name__)

IP = ""

proxies = {
    'http': 'socks5://127.0.0.1:25344',
    'https': 'socks5://127.0.0.1:25344'
}

def get_public_ip():
    url = 'https://api.ipify.org/'
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    
    try:
        response = requests.get(url, headers=headers,proxies=proxies)
        response.raise_for_status()
        return response.text.strip()
    except requests.exceptions.RequestException as e:
        return f"获取失败: {e}"

def my_startup_function():
    global IP
    IP = get_public_ip()
    subprocess.run(['python', 'restart.py'])

with app.app_context():
    my_startup_function()

# 配置文件路径
CONFIG_PATH = 'ZBProxy.json'
PASSWORD = os.getenv('MANAGER_PASSWORD', 'default_password')

@app.before_request
def check_precondition():
    if request.endpoint == 'index' or request.path == '/':
        return None

    user_token = request.headers.get('Authorization') or request.args.get('token')

    if user_token != PASSWORD:
        # 如果 Token 不匹配，直接中断请求
        return {"error": "Unauthorized", "message": "Invalid or missing token."}, 401

@app.route('/')
def index():
    return render_template('index.html',ip=IP)

# 下载 API
@app.route('/download', methods=['GET'])
def download_config():
    if os.path.exists(CONFIG_PATH):
        # as_attachment=True 会触发浏览器下载
        return send_file(CONFIG_PATH, as_attachment=True)
    return "Error: config.json file not found.", 404

# 上传 API
@app.route('/upload', methods=['POST'])
def upload_config():
    if 'file' not in request.files:
        return "No file part", 400
    
    file = request.files['file']
    
    if file.filename == '':
        return "No selected file", 400
    
    if file:
        # 保存上传的文件，覆盖原有的 config.json
        file.save(CONFIG_PATH)
        return 'File uploaded successfully! <a href="/">Back</a>', 200
    
@app.route('/restart', methods=['GET'])
def restart_proxy():
    subprocess.run(['python', 'restart.py'])

if __name__ == '__main__':
    app.run(debug=True, port=5000)