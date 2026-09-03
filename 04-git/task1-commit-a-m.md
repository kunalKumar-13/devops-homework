# Git Task 1 — `git commit -a -m` vs `git commit -m`

## The three places a change can live

```
  working directory  →  staging area (index)  →  repository (commits)
        (edit)               (git add)              (git commit)
```

`git commit` only ever commits what is in the **staging area**.

## The difference in one table

| | `git commit -m "msg"` | `git commit -a -m "msg"` |
|---|---|---|
| What it commits | **only what has already been `git add`-ed** | staged changes **plus** all modified *tracked* files |
| Modified tracked file, not added | ignored | **automatically staged and committed** |
| Deleted tracked file | ignored | **automatically staged and committed** |
| **New untracked file** | ignored | **still ignored** — `-a` never adds new files |
| Effectively | `commit` | `git add -u` + `commit` |
| Control over what goes in | full — you choose file by file | none — everything tracked and modified goes in |

**The one sentence to remember:** `-a` stands for *all tracked files*, not *all files*.
A brand-new file always needs an explicit `git add`.

## Commands

```bash
git add file.txt              # stage one file
git add .                     # stage everything in this directory, new files included
git add -u                    # stage modifications and deletions of TRACKED files only
git commit -m "message"       # commit whatever is staged
git commit -a -m "message"    # stage tracked modifications, then commit
git commit -am "message"      # same thing, flags combined
git status                    # what is staged, modified, untracked
git status --short            # compact:  M = modified   A = added   ?? = untracked
git diff                      # working directory vs staging area
git diff --staged             # staging area vs last commit
```

Reading `git status --short`: the **first column** is the staging area, the **second**
is the working directory. So ` M` = modified but not staged, `M ` = staged, `MM` = both,
`??` = untracked.

## Practical session — testing both commands (real output)

```console
########## Setup ##########
$ git init -b main
Initialized empty Git repository in /private/tmp/claude-501/-Users-kunalpronto/0332cd7a-0af6-48b7-aa4e-7cc18035375b/scratchpad/gitlab1/.git/

$ git config user.name 'Kunal Kumar'

$ git config user.email 'kunalsain0324@gmail.com'

$ echo 'first line' > file1.txt

$ git add file1.txt

$ git commit -m 'Initial commit: add file1.txt'
[main (root-commit) 7f995ad] Initial commit: add file1.txt
 1 file changed, 1 insertion(+)
 create mode 100644 file1.txt

$ git log --oneline
7f995ad Initial commit: add file1.txt

########## A. git commit -m  (WITHOUT -a) ##########
Modify a tracked file and create a brand new untracked file, then try to commit.
$ echo 'second line' >> file1.txt

$ echo 'I am new' > file2.txt

$ git status --short
 M file1.txt
?? file2.txt

Legend:  ' M' = tracked file modified but NOT staged   '??' = untracked

$ git commit -m 'Try to commit without -a'
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   file1.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	file2.txt

no changes added to commit (use "git add" and/or "git commit -a")
(exit code: 1)

>>> Nothing was committed: git commit -m only commits what is already in the STAGING AREA,
>>> and we never ran 'git add'.

$ git log --oneline
7f995ad Initial commit: add file1.txt

########## B. git commit -a -m ##########
$ git commit -a -m 'Commit with -a: picks up the modified tracked file'
[main 49fceb3] Commit with -a: picks up the modified tracked file
 1 file changed, 1 insertion(+)

$ git log --oneline
49fceb3 Commit with -a: picks up the modified tracked file
7f995ad Initial commit: add file1.txt

$ git status --short
?? file2.txt

>>> file1.txt (TRACKED + modified) was staged automatically and committed.
>>> file2.txt is still untracked — '-a' does NOT add new files.

########## C. Untracked files still need git add ##########
$ git add file2.txt

$ git commit -m 'Add file2.txt explicitly with git add + git commit -m'
[main 5e4e762] Add file2.txt explicitly with git add + git commit -m
 1 file changed, 1 insertion(+)
 create mode 100644 file2.txt

$ git log --oneline
5e4e762 Add file2.txt explicitly with git add + git commit -m
49fceb3 Commit with -a: picks up the modified tracked file
7f995ad Initial commit: add file1.txt

$ git status
On branch main
nothing to commit, working tree clean

########## D. Same change, both ways, side by side ##########
$ echo 'third line' >> file1.txt

$ git status --short
 M file1.txt

Way 1 — two steps:   git add file1.txt  &&  git commit -m 'msg'
Way 2 — one step:    git commit -a -m 'msg'          (identical result for tracked files)
$ git commit -a -m 'Third line added using git commit -a -m'
[main 114c0c2] Third line added using git commit -a -m
 1 file changed, 1 insertion(+)

$ git log --oneline --stat | head -n 12
114c0c2 Third line added using git commit -a -m
 file1.txt | 1 +
 1 file changed, 1 insertion(+)
5e4e762 Add file2.txt explicitly with git add + git commit -m
 file2.txt | 1 +
 1 file changed, 1 insertion(+)
49fceb3 Commit with -a: picks up the modified tracked file
 file1.txt | 1 +
 1 file changed, 1 insertion(+)
7f995ad Initial commit: add file1.txt
 file1.txt | 1 +
 1 file changed, 1 insertion(+)

```

## What the run proves

1. **`git commit -m` with nothing staged committed nothing.** Git replied
   *"no changes added to commit (use "git add" and/or "git commit -a")"* and exited
   non-zero. `git log` was unchanged.
2. **`git commit -a -m` worked without any `git add`.** It picked up the modification to
   `file1.txt` — a **tracked** file — and committed it.
3. **`file2.txt` was still untracked afterwards.** `-a` did not add it. It only got into
   the repository after an explicit `git add file2.txt`.
4. The last step showed the two routes are equivalent for tracked files:
   `git add file1.txt && git commit -m "msg"` produces exactly the same commit as
   `git commit -a -m "msg"`.

## When to use which

* **`git commit -m`** when the change should be reviewed and split — stage precisely
  what belongs in this commit (`git add -p` is even better) and leave the rest for the
  next one. This is the habit that produces a clean, reviewable history.
* **`git commit -a -m`** for quick work where everything modified belongs together — a
  typo fix, a small refactor, a WIP commit on your own branch.

**The trap:** `-a` quietly sweeps in every modified tracked file, including a debug
`print()` left in another file. Running `git status` before committing costs one second
and avoids it.

## Interview answers

**Q. What does `-a` do in `git commit -a -m`?**
It automatically stages all **modified and deleted tracked** files before committing, so
you skip `git add`. It does **not** stage new untracked files.

**Q. So `git commit -am` is the same as `git add . && git commit -m`?**
No — and that is the classic trap. `git add .` stages new files too. `-a` is equivalent
to `git add -u`.

**Q. You ran `git commit -m` and got "no changes added to commit". Why?**
The files were modified but never staged. Either `git add <file>` first, or use
`git commit -a -m`.
