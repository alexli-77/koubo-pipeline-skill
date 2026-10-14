#!/usr/bin/env bash
# koubo-pipeline 安装 / 更新脚本
#   ./install.sh          安装本 skill 及缺失的依赖
#   ./install.sh update   更新所有依赖（git 仓库 fast-forward）
set -euo pipefail

SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
SRC_DIR="${KOUBO_SRC_DIR:-$HOME/.local/share/koubo-pipeline}"
HERE="$(cd "$(dirname "$0")" && pwd)"

DBS_SKILLS="dbs-content dbs-title-cover-intro dbs-script-flow dbs-resonate dbs-ai-check dbs-content-risk-check"
# 名称|仓库|仓库内子路径（空 = 根目录）
STANDALONE="jianghushuo-oral-skill|https://github.com/read2017/jianghushuo-oral-skill|
humanizer|https://github.com/blader/humanizer|"

mkdir -p "$SKILLS_DIR" "$SRC_DIR"

clone() { [ -d "$SRC_DIR/$1" ] || git clone -q --depth 1 "$2" "$SRC_DIR/$1"; }

link() { # link <skill名> <源目录>
  if [ -e "$SKILLS_DIR/$1" ]; then echo "  已存在，跳过: $1"
  else ln -s "$2" "$SKILLS_DIR/$1"; echo "  已安装: $1"; fi
}

update_repo() { # 对 skill 所在 git 仓库做 fast-forward；有 upstream 远端时跟 upstream
  local dir top
  dir="$(cd "$1" 2>/dev/null && pwd -P)" || return 0
  top="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || { echo "  非 git 目录，跳过: $1"; return 0; }
  if git -C "$top" remote | grep -qx upstream; then
    git -C "$top" fetch -q upstream
    git -C "$top" merge -q --ff-only "upstream/$(git -C "$top" remote show upstream | sed -n 's/.*HEAD branch: //p')" \
      && echo "  已更新(upstream): $top" || echo "  无法 fast-forward，请手动处理: $top"
  else
    git -C "$top" pull -q --ff-only && echo "  已更新: $top" || echo "  无法 fast-forward，请手动处理: $top"
  fi
}

if [ "${1:-}" = "update" ]; then
  echo "更新依赖..."
  seen=""
  for s in koubo-pipeline $DBS_SKILLS jianghushuo-oral-skill humanizer stop-slop; do
    [ -e "$SKILLS_DIR/$s" ] || continue
    top="$(git -C "$(cd "$SKILLS_DIR/$s" && pwd -P)" rev-parse --show-toplevel 2>/dev/null || echo "$s")"
    case " $seen " in *" $top "*) continue;; esac
    seen="$seen $top"; update_repo "$SKILLS_DIR/$s"
  done
  exit 0
fi

echo "安装 koubo-pipeline -> $SKILLS_DIR"
link koubo-pipeline "$HERE"

echo "安装 dbskill 子集（CC BY-NC 4.0）"
for s in $DBS_SKILLS; do
  [ -e "$SKILLS_DIR/$s" ] || clone dbskill https://github.com/dontbesilent2025/dbskill
  link "$s" "$SRC_DIR/dbskill/skills/$s"
done

echo "安装其他依赖"
while IFS='|' read -r name repo sub; do
  [ -e "$SKILLS_DIR/$name" ] || clone "$name" "$repo"
  link "$name" "$SRC_DIR/$name${sub:+/$sub}"
done <<< "$STANDALONE"

echo "完成。新开一个 Claude Code 会话，说「写一条口播」即可触发。"
