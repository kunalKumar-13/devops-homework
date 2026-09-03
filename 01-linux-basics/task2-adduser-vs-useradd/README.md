# Task 2 — `adduser` vs `useradd`

Run on **Ubuntu 26.04 LTS**. All output below is real terminal output.

---

## 1. The short answer

| | `useradd` | `adduser` |
|---|---|---|
| What it is | a **low-level binary** from the `shadow-utils` package | a **Perl script** that wraps `useradd` |
| Where it exists | every Linux distribution | Debian/Ubuntu (on RHEL/CentOS `adduser` is just a symlink to `useradd`) |
| Behaviour | does exactly what you ask, nothing more | interactive, asks questions, applies sane defaults |
| Home directory | **not** created unless you pass `-m` | created automatically from `/etc/skel` |
| Shell | whatever `/etc/default/useradd` says (often `/bin/sh`) | `/bin/bash` |
| Password | not set — account is locked | prompts for one and sets it |
| User group | depends on config | creates a matching group, adds to `users` |
| GECOS info | `-c` flag only | prompts for Full Name, Room Number, Phone… |
| Config file | `/etc/default/useradd`, `/etc/login.defs` | `/etc/adduser.conf` |
| Best for | **scripts and automation** (predictable, portable) | **typing by hand** on Ubuntu |

> `adduser` is a friendly front-end. Under the hood it calls `useradd`, `passwd`,
> `chfn` and copies `/etc/skel` for you.

## 2. Which is preferred on Ubuntu, and why?

**`adduser` is the recommended command on Ubuntu/Debian for creating a user by hand.**

Ubuntu's own `useradd(8)` man page says it plainly:

> *"useradd is a low level utility for adding users. On Debian, administrators should
> usually use adduser(8) instead."*

Reasons:

1. It creates and populates the **home directory** from `/etc/skel` — with `useradd`
   you must remember `-m`, and a user with no home directory breaks login, `ssh`,
   `sudo -i` and most shell tooling.
2. It **prompts for and sets a password**, so the account is usable immediately.
   A bare `useradd` account is left locked (`passwd -S` shows `L`).
3. It gives a sensible **login shell** (`/bin/bash`) instead of `/bin/sh`.
4. It sets up the **user's own group** and correct home-directory permissions.
5. It follows the policy in `/etc/adduser.conf`, so every account on the machine ends
   up consistent.

The flip side: because it is interactive and Debian-specific, **`useradd` is the right
choice inside scripts, Dockerfiles and Ansible/cloud-init** — it is non-interactive and
present on every distribution.

---

## 3. Proving the difference (real output)

```console
########## 0. What are these two commands? ##########
$ which adduser useradd
/usr/sbin/adduser
/usr/sbin/useradd

$ file $(which adduser)
/usr/sbin/adduser: Perl script text executable

$ file $(which useradd)
/usr/sbin/useradd: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=31fe1aa87190c2a7aa258cf32fe14b9564aa37db, for GNU/Linux 3.7.0, stripped

adduser is a Perl SCRIPT (a friendly front-end); useradd is a low-level BINARY.

########## 1. Create a user the LOW-LEVEL way: useradd ##########
$ sudo useradd testuser_low

$ grep testuser_low /etc/passwd
testuser_low:x:1000:1001::/home/testuser_low:/bin/sh

$ sudo ls -la /home | grep testuser_low || echo '(no home directory was created)'
(no home directory was created)

$ sudo passwd -S testuser_low
testuser_low L 2026-09-03 0 99999 7 -1

Bare useradd: no home directory, no shell set to bash, password locked.

########## 2. Create a user the RECOMMENDED way on Ubuntu: adduser ##########
Interactive form (what you would type by hand):
    sudo adduser testuser
It then prompts for password, Full Name, Room Number, Work Phone, Home Phone, Other.
Here it is run non-interactively so the output can be captured:
$ sudo adduser --disabled-password --gecos 'Test User,,,,' testuser

$ grep testuser /etc/passwd
testuser_low:x:1000:1001::/home/testuser_low:/bin/sh
testuser:x:1002:1002:Test User,,,,:/home/testuser:/bin/bash

$ sudo ls -la /home/testuser
total 20
drwxr-x---  2 testuser testuser 4096 Sep  3 20:52 .
drwxr-xr-x  4 root     root     4096 Sep  3 20:52 ..
-rw-r--r--  1 testuser testuser  220 Sep  3 20:52 .bash_logout
-rw-r--r--  1 testuser testuser 3771 Sep  3 20:52 .bashrc
-rw-r--r--  1 testuser testuser  807 Sep  3 20:52 .profile

$ id testuser
uid=1002(testuser) gid=1002(testuser) groups=1002(testuser),100(users)

$ groups testuser
testuser : testuser users


########## 3. Set a password for the new user ##########
$ echo 'testuser:StrongPassw0rd!' | sudo chpasswd

$ sudo passwd -S testuser
testuser P 2026-09-03 0 99999 7 -1


########## 4. Compare the two accounts side by side ##########
$ grep -E 'testuser(_low)?:' /etc/passwd
testuser_low:x:1000:1001::/home/testuser_low:/bin/sh
testuser:x:1002:1002:Test User,,,,:/home/testuser:/bin/bash

$ sudo ls /home
kunalpronto.guest
kunalpronto.linux
testuser


########## 5. Clean up ##########
$ sudo deluser --remove-home testuser

$ sudo userdel -r testuser_low 2>&1 | cat
userdel: testuser_low mail spool (/var/mail/testuser_low) not found
userdel: testuser_low home directory (/home/testuser_low) not found

$ grep -E 'testuser' /etc/passwd || echo '(both users removed)'
(both users removed)

```

### What that shows

* `file` confirms it: `adduser` is a **Perl script**, `useradd` is an **ELF binary**.
* `useradd testuser_low` produced `testuser_low:x:1000:1001::/home/testuser_low:/bin/sh`
  — note the **empty GECOS field**, the shell `/bin/sh`, and **no home directory was
  actually created** even though `/etc/passwd` names one. `passwd -S` returned `L`
  (locked, unusable).
* `adduser testuser` produced `testuser:x:1002:1002:Test User,,,,:/home/testuser:/bin/bash`
  — GECOS filled in, `/bin/bash` shell, `/home/testuser` created and populated with
  `.bashrc`, `.profile` and `.bash_logout` from `/etc/skel`, and the user placed in its
  own group plus `users`. After `chpasswd`, `passwd -S` returned `P` (usable password).

---

## 4. Creating the test user with the recommended command

```console
########## Creating the test user with the recommended command ##########
Typed interactively this is simply:  sudo adduser testuser
(it then prompts for the password twice and for the optional GECOS fields).
Run here with those answers supplied on the command line so the session is reproducible:

$ sudo adduser --gecos 'Test User,,,,' --disabled-password testuser

$ echo 'testuser:StrongPassw0rd!' | sudo chpasswd && echo 'password set'
password set

########## Proof the account is fully set up ##########
$ id testuser
uid=1001(testuser) gid=1001(testuser) groups=1001(testuser),100(users)

$ grep '^testuser:' /etc/passwd
testuser:x:1001:1001:Test User,,,,:/home/testuser:/bin/bash

$ sudo passwd -S testuser
testuser P 2026-09-03 0 99999 7 -1

$ sudo ls -la /home/testuser
total 20
drwxr-x---  2 testuser testuser 4096 Sep  3 21:04 .
drwxr-xr-x  4 root     root     4096 Sep  3 21:04 ..
-rw-r--r--  1 testuser testuser  220 Sep  3 21:04 .bash_logout
-rw-r--r--  1 testuser testuser 3771 Sep  3 21:04 .bashrc
-rw-r--r--  1 testuser testuser  807 Sep  3 21:04 .profile

$ sudo su - testuser -c 'whoami; pwd; echo $SHELL'
testuser
/home/testuser
/bin/bash

$ sudo lslogins testuser 2>/dev/null | head -n 12
Username:                           testuser                            
UID:                                1001                                
Gecos field:                        Test User,,,,                       
Home directory:                     /home/testuser                      
Shell:                              /bin/bash                           
No login:                           no                                  
Password is locked:                 no                                  
Password not required (empty):      no                                  
Login by password disabled:         no                                  
Password encryption method:         yescrypt                            
GID:                                1001                                
Supplementary groups:               users                               

```

The account **`testuser` exists and is fully working** — `sudo su - testuser` logs in,
lands in `/home/testuser`, and gets `/bin/bash`.

Typed by hand, the whole thing is just:

```bash
sudo adduser testuser
```

and the interactive session looks like the transcript below. *(This block is
illustrative — the capture above was produced non-interactively so it could be
scripted; everything else in this file is real captured output.)*

```text
Adding user `testuser' ...
Adding new group `testuser' (1001) ...
Adding new user `testuser' (1001) with group `testuser (1001)' ...
Creating home directory `/home/testuser' ...
Copying files from `/etc/skel' ...
New password:
Retype new password:
passwd: password updated successfully
Changing the user information for testuser
Enter the new value, or press ENTER for the default
        Full Name []: Test User
        Room Number []:
        Work Phone []:
        Home Phone []:
        Other []:
Is the information correct? [Y/n] Y
Adding new user `testuser' to supplemental / extra groups `users' ...
Adding user `testuser' to group `users' ...
```

---

## 5. Command reference

```bash
# --- adduser (Ubuntu/Debian, interactive) ---
sudo adduser testuser                      # create a normal user, prompts for everything
sudo adduser --disabled-password testuser  # no password prompt (for key-only/service accounts)
sudo adduser testuser sudo                 # add an EXISTING user to the sudo group
sudo adduser --system --group svcapp       # create a system account
sudo deluser --remove-home testuser        # delete the user and the home directory

# --- useradd (low level, portable, scriptable) ---
sudo useradd testuser                              # bare minimum: no home, locked, /bin/sh
sudo useradd -m -s /bin/bash -c "Test User" testuser   # equivalent of what adduser does
sudo useradd -m -G sudo,docker -s /bin/bash testuser   # with extra groups
sudo passwd testuser                               # set the password separately
echo 'testuser:StrongPassw0rd!' | sudo chpasswd    # set it non-interactively
sudo userdel -r testuser                           # delete the user and the home directory

# --- inspecting ---
id testuser
grep '^testuser:' /etc/passwd
sudo passwd -S testuser        # P = usable password, L = locked, NP = no password
sudo lslogins testuser
getent passwd testuser
groups testuser
cat /etc/default/useradd
cat /etc/adduser.conf
```

---

## 6. Interview answers

**Q. `adduser` vs `useradd` — which do you use?**
`adduser` when I am on Ubuntu/Debian and creating an account by hand, because it does
the whole job: home directory from `/etc/skel`, bash shell, password prompt, matching
group. `useradd` inside scripts, Dockerfiles and configuration management, because it
is non-interactive, deterministic, and exists on every distribution.

**Q. Is `adduser` available everywhere?**
No. It is a Debian/Ubuntu Perl wrapper. On RHEL/CentOS/Fedora `adduser` is just a
**symlink to `useradd`**, so it behaves completely differently there — another reason
scripts should call `useradd` explicitly.

**Q. Why did my `useradd` account fail to log in?**
Because a bare `useradd` leaves the password locked and creates no home directory. Fix
it with `useradd -m`, then `passwd <user>` — or just use `adduser`.
