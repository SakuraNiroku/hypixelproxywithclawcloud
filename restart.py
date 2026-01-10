import os
import subprocess
import psutil

# 要运行的目标程序路径，这里需要替换成你实际的程序路径
TARGET_PROGRAM = "./zbproxy"
PID_FILE = "pid.txt"

def is_process_running(pid):
    """
    检查指定 PID 的进程是否正在运行
    :param pid: 进程 ID
    :return: 如果进程正在运行返回 True，否则返回 False
    """
    try:
        process = psutil.Process(pid)
        return process.is_running()
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        return False


def restart_program():
    """
    重启目标程序并保存新的 PID 到文件
    """
    try:
        # 启动新的进程
        process = subprocess.Popen(TARGET_PROGRAM)
        new_pid = process.pid
        # 将新的 PID 保存到文件
        with open(PID_FILE, 'w') as f:
            f.write(str(new_pid))
        print(f"程序已重启，新的 PID 是 {new_pid}")
    except Exception as e:
        print(f"启动程序时出错: {e}")


if __name__ == "__main__":
    if os.path.exists(PID_FILE):
        with open(PID_FILE, 'r') as f:
            try:
                pid = int(f.read().strip())
                if is_process_running(pid):
                    print(f"程序 (PID: {pid}) 正在运行，准备重启...")
                    # 先尝试终止正在运行的进程
                    try:
                        process = psutil.Process(pid)
                        process.terminate()
                        # 等待进程终止
                        _, alive = psutil.wait_procs([process], timeout=5)
                        if alive:
                            process.kill()
                    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                        pass
                else:
                    print(f"程序 (PID: {pid}) 未运行，准备启动...")
            except ValueError:
                print("PID 文件内容无效，准备启动新程序...")
    else:
        print("PID 文件不存在，准备启动新程序...")

    restart_program()