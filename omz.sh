#!/bin/bash

# --- 1. 安装 Oh My Zsh 框架（官方脚本） ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo ">>> 1. 安装 Oh My Zsh..."
  # --unattended 参数实现静默安装
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo ">>> 1. Oh My Zsh 已安装，跳过。"
fi

# --- 2. 安装 Powerlevel10k 主题 ---
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
P10K_DIR="${ZSH_CUSTOM}/themes/powerlevel10k"
if [[ ! -d "${P10K_DIR}" ]]; then
  echo ">>> 2. 安装 Powerlevel10k 主题..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${P10K_DIR}"
else
  echo ">>> 2. Powerlevel10k 已安装，跳过。"
fi

# --- 3. 安装核心插件 ---
clone_plugin() {
  local repo_url="$1"
  local plugin_name="$2"
  local plugin_dir="${ZSH_CUSTOM}/plugins/${plugin_name}"
  if [[ -d "${plugin_dir}" ]]; then
    echo ">>> 3. 插件 ${plugin_name} 已安装，跳过。"
    return
  fi
  echo ">>> 3. 安装插件 ${plugin_name}..."
  git clone --depth=1 "${repo_url}" "${plugin_dir}"
}
clone_plugin https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting

# --- 4. 安装 Nerd Font (MesloLGS NF) ---
# 用于完整显示 P10k 的图标和符号
install_font() {
  local font_dir
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS 字体目录
    font_dir="$HOME/Library/Fonts"
  else
    # Linux 字体目录
    font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
  fi
  
  local font_file="$font_dir/MesloLGS NF Regular.ttf"
  if [[ ! -f "$font_file" ]]; then
    echo ">>> 4. 下载 MesloLGS NF Nerd Font..."
    curl -fLo "$font_file" \
      https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    # 刷新字体缓存（Linux）
    if [[ "$OSTYPE" != "darwin"* ]]; then
      fc-cache -fv > /dev/null 2>&1
    fi
  else
    echo ">>> 4. 字体已存在，跳过下载。"
  fi
}
install_font

# --- 5. 配置 .zshrc ---
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
  echo ">>> 5. 配置 .zshrc..."

  # 替换主题
  sed -i '' 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"

  # 替换插件列表（如果还是默认的 plugins=(git)）
  sed -i '' 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"

  echo "    已将主题设为 powerlevel10k，插件列表已更新。"
else
  echo ">>> 5. 未找到 ~/.zshrc，请手动配置。"
fi

echo ""
echo "=================================================="
echo ">>> 安装完成！"
echo "1. 请手动将终端字体更改为 MesloLGS NF 以显示完整图标。"
echo "2. 运行 'source ~/.zshrc' 生效，或重启终端。"
echo "3. 随后运行 'p10k configure' 进入配置向导。"
echo "=================================================="

