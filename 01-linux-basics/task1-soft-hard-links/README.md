# Task 1 — Soft Link & Hard Link

Everything below was run on **Ubuntu 26.04 LTS** (aarch64) and the output is copied
straight out of the terminal.

---

## 1. What a link actually is

On Linux a file has two separate parts:

| Part | What it holds |
|---|---|
| **inode** | the real file — its data blocks, size, permissions, owner, timestamps, and a **link count** |
| **directory entry (the name)** | a label in a folder that points at an inode |

A *name* is not the file. The inode is the file. Both kinds of link play with that
distinction in different ways.

---

## 2. Hard link vs soft link

| | **Hard link** (`ln`) | **Soft / symbolic link** (`ln -s`) |
|---|---|---|
| What it points to | the **inode** (the data itself) | the **path/name** of another file |
| Inode number | **same** as the original | its **own**, different inode |
| Link count | increases the original's link count | does not change it |
| Delete the original | link still works, data survives | link **breaks** (dangling) |
| Across filesystems / partitions | **not allowed** | allowed |
| Link to a directory | **not allowed** (except `.` and `..`) | allowed |
| `ls -l` shows | a normal file | `link -> target` and type `l` |
| Size | same as the file | length of the target path string |
| Permissions | shared with the original (one inode) | always `lrwxrwxrwx`; the target's permissions apply |

**One-line version:** a hard link is another *name* for the same file; a soft link
is a *shortcut* that stores a path.

---

## 3. Commands

```bash
# Hard link
ln  original.txt  hardlink.txt

# Soft (symbolic) link
ln -s  original.txt  softlink.txt

# Soft link with an absolute target (safer when it will be moved)
ln -s /full/path/to/original.txt  /some/other/place/softlink.txt

# Inspect
ls -li                      # -i shows the inode number
stat  original.txt
readlink  softlink.txt      # what a soft link points at
readlink -f softlink.txt    # fully resolved final target
find . -inum <inode>        # find every hard link to one inode
find . -type l              # list all symlinks
find . -xtype l             # list only BROKEN symlinks

# Delete
rm  softlink.txt            # removes just the link
unlink  softlink.txt        # same thing
rm  hardlink.txt            # decrements the link count; data lives while count > 0
```

---

## 4. Full practical session (real output)

```console
########## 1. Create the original file ##########
$ echo 'Hello, this is the original file.' > original.txt

$ cat original.txt
Hello, this is the original file.

$ ls -li
total 4
524415 -rw-rw-r-- 1 kunalpronto kunalpronto 34 Sep  3 20:52 original.txt

########## 2. Create a HARD link ##########
$ ln original.txt hardlink.txt

$ ls -li
total 8
524415 -rw-rw-r-- 2 kunalpronto kunalpronto 34 Sep  3 20:52 hardlink.txt
524415 -rw-rw-r-- 2 kunalpronto kunalpronto 34 Sep  3 20:52 original.txt

Note: original.txt and hardlink.txt share the SAME inode number and the link count is now 2.

########## 3. Create a SOFT (symbolic) link ##########
$ ln -s original.txt softlink.txt

$ ls -li
total 8
524415 -rw-rw-r-- 2 kunalpronto kunalpronto 34 Sep  3 20:52 hardlink.txt
524415 -rw-rw-r-- 2 kunalpronto kunalpronto 34 Sep  3 20:52 original.txt
524416 lrwxrwxrwx 1 kunalpronto kunalpronto 12 Sep  3 20:52 softlink.txt -> original.txt

Note: softlink.txt has its OWN inode and is shown as 'softlink.txt -> original.txt'.

########## 4. All three show the same content ##########
$ cat original.txt
Hello, this is the original file.

$ cat hardlink.txt
Hello, this is the original file.

$ cat softlink.txt
Hello, this is the original file.

########## 5. Edit through the links — the data is shared ##########
$ echo 'Line added through the hard link.' >> hardlink.txt

$ cat original.txt
Hello, this is the original file.
Line added through the hard link.

########## 6. Inspect the links ##########
$ stat original.txt | head -n 5
  File: original.txt
  size: 68        	Blocks: 8          IO Block: 4096   regular file
Device: 253,1	Inode: 524415      Links: 2
Access: (0664/-rw-rw-r--)  Uid: (  501/kunalpronto)   Gid: ( 1000/kunalpronto)
Access: 2026-09-03 20:52:02.531645978 +0530

$ stat softlink.txt | head -n 5
  File: 'softlink.txt' -> 'original.txt'
  size: 12        	Blocks: 0          IO Block: 4096   symbolic link
Device: 253,1	Inode: 524416      Links: 1
Access: (0777/lrwxrwxrwx)  Uid: (  501/kunalpronto)   Gid: ( 1000/kunalpronto)
Access: 2026-09-03 20:52:02.527645977 +0530

$ readlink softlink.txt
original.txt

$ find . -inum $(stat -c %i original.txt)
./original.txt
./hardlink.txt

########## 7. DELETE the original file ##########
$ rm original.txt

$ ls -li
total 4
524415 -rw-rw-r-- 1 kunalpronto kunalpronto 68 Sep  3 20:52 hardlink.txt
524416 lrwxrwxrwx 1 kunalpronto kunalpronto 12 Sep  3 20:52 softlink.txt -> original.txt

--- hard link still works (data still has one name pointing at the inode) ---
$ cat hardlink.txt
Hello, this is the original file.
Line added through the hard link.

--- soft link is now BROKEN (dangling), it pointed at a NAME that is gone ---
$ cat softlink.txt
cat: softlink.txt: No such file or directory
(exit code: 1)

$ ls -l softlink.txt
lrwxrwxrwx 1 kunalpronto kunalpronto 12 Sep  3 20:52 softlink.txt -> original.txt

########## 8. Restore the name and the soft link works again ##########
$ ln hardlink.txt original.txt

$ cat softlink.txt
Hello, this is the original file.
Line added through the hard link.

########## 9. Hard links cannot cross filesystems or point at directories ##########
$ ln /tmp ~/linklab/dirlink
ln: /tmp: hard link not allowed for directory
(exit code: 1)

$ ln -s /tmp dirsoftlink

$ ls -l dirsoftlink
lrwxrwxrwx 1 kunalpronto kunalpronto 4 Sep  3 20:52 dirsoftlink -> /tmp

########## 10. Deleting links ##########
$ rm softlink.txt

$ unlink dirsoftlink

$ rm hardlink.txt

$ ls -li
total 4
524415 -rw-rw-r-- 1 kunalpronto kunalpronto 68 Sep  3 20:52 original.txt

The file survives as original.txt — removing a hard link only decrements the link count.
$ rm original.txt

$ ls -la
total 8
drwxrwxr-x 2 kunalpronto kunalpronto 4096 Sep  3 20:52 .
drwxr-x--- 7 kunalpronto kunalpronto 4096 Sep  3 20:52 ..

Link count reached 0, so the data is finally freed.
```

---

## 5. What the output proves

1. **Same inode** — `original.txt` and `hardlink.txt` both show inode `524415`, and
   the link count in `ls -li` column 3 went from `1` to `2`.
2. **Different inode** — `softlink.txt` got its own inode `524416`, is type `l`, and
   is displayed as `softlink.txt -> original.txt`. Its size is `12` bytes, which is
   exactly the length of the string `original.txt`.
3. **Shared data** — appending through `hardlink.txt` changed what `cat original.txt`
   prints, because there is only one inode.
4. **Deleting the original**
   - `cat hardlink.txt` still worked — the inode still had one name pointing at it.
   - `cat softlink.txt` failed with *No such file or directory* — it was pointing at
     the **name** `original.txt`, which no longer existed. `ls -l` showed it as a
     dangling link.
5. **Recreating the name** with `ln hardlink.txt original.txt` made the soft link
   work again immediately — proof that a symlink resolves the path at access time.
6. **Hard link limits** — `ln /tmp ~/linklab/dirlink` was refused
   (*hard link not allowed for directory*), while `ln -s /tmp dirsoftlink` was fine.
7. **Deleting links** only removed names. The data was freed only when the link
   count reached `0`.

---

## 6. Interview answers

**Q. What is the difference between a hard link and a soft link?**
A hard link is an additional directory entry pointing at the *same inode*, so it is
indistinguishable from the original file — same inode number, same data, same
permissions. A soft link is a small separate file whose content is the *path* of the
target; it has its own inode and is resolved at access time.

**Q. What happens to each if the original file is deleted?**
The hard link keeps working — deleting a name only decrements the inode's link count,
and the data is freed only when that count hits zero. The soft link becomes a
*dangling* link and any access fails with `No such file or directory`.

**Q. Can you hard link across filesystems? Why not?**
No. Inode numbers are only unique within a single filesystem, so a directory entry on
filesystem A cannot reference an inode on filesystem B. Soft links can cross
filesystems because they store a path string, not an inode number.

**Q. Can you hard link a directory?**
Not as a normal user — it is blocked because it would allow loops in the directory
tree that would break tools like `find` and `fsck`. The only directory hard links are
`.` and `..`, created by the kernel.

**Q. How do you tell them apart?**
`ls -li`: same inode number and a link count above 1 means hard links; a leading `l`
in the permissions and a `->` arrow means a symlink. `stat` and `readlink` confirm it.

**Q. Which one would you use in practice?**
Soft links, almost always — `/usr/bin/python3 -> python3.12`, versioned release
directories, config files pointing into `/etc/alternatives`. They can cross
filesystems, can point at directories, and it is obvious from `ls -l` that they are
links. Hard links are used for de-duplication and snapshot-style backups (e.g.
`rsync --link-dest`, `cp -al`), where multiple names for one inode save disk space.

**Q. Does a symlink store the target's permissions?**
No. A symlink is always `lrwxrwxrwx`; access is decided by the permissions of the
*target*.
