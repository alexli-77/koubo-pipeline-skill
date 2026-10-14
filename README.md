# koubo-pipeline

口播文案流水线 skill：输入一个选题，输出一份可以直接上提词器的逐字稿。

本仓库只包含编排逻辑（`SKILL.md`）和安装脚本。每一站的方法来自下面这些上游 skill，安装时从各自仓库拉取，不在这里复制。

## 流水线

| 站 | 做什么 | 用到的上游 skill |
|---|---|---|
| 1 | 核心主张、目标观众、形式判断 | [dbskill](https://github.com/dontbesilent2025/dbskill) `dbs-content` |
| 2 | 选结构模板，写初稿，过风格自检 → ⏸ 确认角度 | [jianghushuo-oral-skill](https://github.com/read2017/jianghushuo-oral-skill)（只借结构和句式，不扮演人设） |
| 3 | 3 版开头 + 文字标题 + 封面标题 | dbskill `dbs-title-cover-intro` |
| 4 | 找划走点，改高风险段 | dbskill `dbs-script-flow` |
| 5 | 共鸣断点删改（可选） | dbskill `dbs-resonate` |
| 6 | 去 AI 味，保留口语感 | dbskill `dbs-ai-check` + [humanizer](https://github.com/blader/humanizer) |
| 7 | 发布风险排查（可选） | dbskill `dbs-content-risk-check` |

成稿写到 `koubo/YYYY-MM-DD-<选题>.md`：一句一行，带【停顿】和重读标记，另附开头备选和每一站的修改记录。

## 安装

```bash
git clone https://github.com/alexli-77/koubo-pipeline-skill
cd koubo-pipeline-skill && ./install.sh
```

- 已经装过的同名 skill 会跳过，不会被覆盖
- 新拉取的依赖放在 `~/.local/share/koubo-pipeline/`，以软链接方式装进 `~/.claude/skills/`
- 可以用环境变量 `CLAUDE_SKILLS_DIR` 和 `KOUBO_SRC_DIR` 改这两个路径

## 更新依赖

```bash
./install.sh update
```

对每个依赖所在的 git 仓库执行 fast-forward。如果仓库配了 `upstream` 远端（比如你 fork 过 dbskill），就跟 upstream 同步。

## 使用

在 Claude Code 里说「写一条口播：<选题>」或「/koubo-pipeline」。

- 「快速」：只跑第 2、3、6 站，中途不暂停
- 「深度」：加跑第 5 站
- 「要发了」：加跑第 7 站

## License

本仓库：MIT。

依赖各自遵循自己的 license：dbskill 和 jianghushuo-oral-skill 是 CC BY-NC 4.0（不可商用），humanizer 是 MIT。
