#!/bin/bash

# 设置要操作的目录和reprepro的路径
DEB_DIR="$1"
REPO_DIR="$2"
DISTRIBUTION="$3" # 例如：polaris等

# 确保DEB_DIR存在
if [ ! -d "$DEB_DIR" ]; then
    echo "DEB目录不存在: $DEB_DIR"
    exit 1
fi

# 确保REPO_DIR存在
if [ ! -d "$REPO_DIR" ]; then
    echo "reprepro目录不存在: $REPO_DIR"
    exit 1
fi

# 遍历deb文件
for DEB_FILE in "$DEB_DIR"/*.deb; do
    if [ -f "$DEB_FILE" ]; then
        # 获取包名和版本号
        PACKAGE_NAME=$(dpkg-deb --show --showformat='${Package}\n' "$DEB_FILE")
        PACKAGE_VERSION=$(dpkg-deb --show --showformat='${Version}\n' "$DEB_FILE")
        
        # 检查包是否已存在
        if reprepro -b "$REPO_DIR" list "$DISTRIBUTION" | grep -q "$PACKAGE_NAME"; then
            echo "包已存在，删除: $PACKAGE_NAME"
            reprepro -b "$REPO_DIR" remove "$DISTRIBUTION" "$PACKAGE_NAME"
        fi

        # 添加新包
        echo "添加新包: $PACKAGE_NAME"
        reprepro -b "$REPO_DIR" includedeb "$DISTRIBUTION" "$DEB_FILE"

        # 删除源文件
        rm -f "$DEB_FILE"
        echo "已删除源文件: $DEB_FILE"
    else
        echo "没有找到deb文件在目录: $DEB_DIR"
    fi
done

echo "操作完成。"
