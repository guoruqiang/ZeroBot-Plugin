#!/bin/bash

PROCESS_PATTERN="/tmp/go-build"  # 匹配进程路径的模式
SCRIPT_NAME="main"  # 可执行文件名

# 检查是否有符合模式的进程正在运行
if pgrep -f $PROCESS_PATTERN > /dev/null; then
    echo "检测到符合模式的进程已经在运行。"
    # 提示用户是否停止正在运行的实例
    read -p "是否需要停止正在运行的实例？(回答yes/y将停止实例，回答no/n将退出脚本): " answer
    case "$answer" in
        yes|y)
            # 杀死所有符合模式的实例
            pkill -f $PROCESS_PATTERN
            echo "已停止正在运行的实例。"
            # 在这里添加 exit 0 来结束脚本执行
            exit 0
            ;;
        no|n)
            echo "脚本终止。"
            exit 1
            ;;
        *)
            echo "无效的输入。脚本终止。"
            exit 1
            ;;
    esac
else
    echo "没有检测到符合模式的进程，将自动启动程序。"
fi

# 打印 Go 版本
if ! go version > /dev/null 2>&1; then
    echo "Go 语言环境未正确安装，请检查后重试。"
    exit 1
fi

# 设置 Go 环境变量
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GO111MODULE=auto

# 清理并验证依赖
if ! go mod tidy; then
    echo "依赖清理或验证失败，请检查 go.mod 文件。"
    exit 1
fi

# 编译项目（如果需要的话可以取消注释）
# if ! go build -ldflags="-s -w" -o ZeroBot-Plugin; then
#     echo "编译失败，请检查代码。"
#     exit 1
# fi

# 在后台运行程序
nohup go run main.go > /root/chatqq/logfile.log 2>&1 &

if [ $? -eq 0 ]; then
    echo "程序已在后台启动。日志文件位于 /root/chatqq/logfile.log"
else
    echo "程序启动失败，请检查脚本和代码。"
    exit 1
fi
