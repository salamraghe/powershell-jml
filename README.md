# PowerShell Joiner-Mover-Leaver Automation (Active Directory)

Hands-on lab, October 2026 (done Oct 19). This automates what I did by hand in my [AD user lifecycle lab](https://github.com/salamraghe/ad-user-lifecycle) on Sep 18.

## What this is and why it matters

I automated the three everyday access tickets in Active Directory: a **joiner** (new hire), a **mover** (role change) and a **leaver** (offboarding). HR-style CSV files go in, and PowerShell builds, moves or disables the accounts.

In my own words: with a script, HR passes me a CSV once, I run it, and every user is built the same way without clicking, in a couple of minutes. It's faster, has fewer mistakes, and every user is set up the same way.

For the mover and leaver: my script moved Jane by taking her out of Finance, so she has no more access there, and putting her in her new role's Lab-Access-Group. For Mike, I took him out of Lab-Access-Group and disabled his account, because he left the company, might have had a breach, or is on a 3–4 month break. The old group is removed first so access doesn't pile up (privilege creep) and least privilege holds.

## Environment

| Item | Value |
| --- | --- |
| Domain controller | ADDC01 (Windows Server VM in VirtualBox) |
| Domain | `lab.local` |
| OU | `LabUsers` |
| Tool | Windows PowerShell ISE (Administrator), ActiveDirectory module |
| Groups | `Finance-Users`, `Lab-Access-Group` |
| Users | Jane Smith (`jsmith`), Mike Lee (`mlee`) |

## Steps

### 1. Open PowerShell ISE as Administrator on the DC

![ISE open](screenshots/01-ise-admin-open.png)

### 2. Joiner CSV (what HR would send)

[`scripts/joiners.csv`](scripts/joiners.csv)

![joiners.csv](screenshots/02-joiners-csv.png)

### 3. Joiner script

For each row: prompt for a temp password (as a secure string, never typed into the file), create the user in `OU=LabUsers`, add them to their group, print a result.

![Joiner script](screenshots/03-joiner-script.png)

### 4. First run failed (see "What broke" below)

![First run error](screenshots/04-first-run-error-a.png)
![First run error, continued](screenshots/05-first-run-error-b.png)

### 5. Fixed run: both users created and grouped

`Created jsmith and added to Finance-Users` / `Created mlee and added to Lab-Access-Group`

![Joiner success](screenshots/06-joiner-success.png)

Checked in ADUC: Jane is in Finance-Users, and both users are in LabUsers.

![jsmith Member Of](screenshots/07-jsmith-memberof.png)
![LabUsers list](screenshots/08-labusers-list.png)

### 6. Mover / leaver CSV

[`scripts/changes.csv`](scripts/changes.csv): `jsmith` moves from Finance-Users to Lab-Access-Group; `mlee` leaves.

![changes.csv](screenshots/09-changes-csv.png)

### 7. Mover / leaver script and output

[`scripts/mover-leaver.ps1`](scripts/mover-leaver.ps1): remove the old group first, then add the new group (Move) or disable the account (Leave).

Output: `Moved jsmith to Lab-Access-Group` / `Disabled mlee`

![Mover/leaver script and output](screenshots/10-mover-leaver-script-and-output.png)

### 8. Verified in ADUC

![LabUsers after](screenshots/11-labusers-mlee-disabled.png)

Jane after the move: only Domain Users + Lab-Access-Group (Finance-Users gone).

![jsmith after move](screenshots/13-jsmith-memberof-after-move.png)

Mike (`mlee`) after leaving: removed from Lab-Access-Group (only Domain Users left) and the account disabled.

![mlee after leave](screenshots/14-mlee-memberof-after-leave.png)

## What broke and how I fixed it

- **Typo `$u.uName`** in the script. Fixed the property name.
- **Missing `-SamAccountName` value**: `New-ADUser : Missing an argument for parameter 'SamAccountName'`, so `Add-ADGroupMember` then couldn't find `jsmith` / `mlee`. Added `$u.SamAccountName`.
- **Typed the PS prompt as a command** (`C:\Users\Administrator>` is not recognized). Ran the script path on its own.
- **`$c.NewGroup` instead of `$c.OldGroup`** on the Remove line. Caught it in review before running.
- **Lesson:** `Write-Host` printed "Created" even when `New-ADUser` failed. A success message in a script isn't proof, so I always verify in ADUC.

## Skills shown

- **IAM Support:** joiner/mover/leaver tickets in Active Directory, group-based access, disabling leavers
- **IAM Engineer:** bulk provisioning with PowerShell + CSV, repeatable and consistent account builds
- **PAM / least privilege:** removing old access on role change to stop privilege creep; no passwords stored in scripts or files
- Troubleshooting PowerShell errors and verifying results in ADUC

## Notes

- Screenshot #12 is only a numbering gap; nothing is missing.
- The joiner script is shown in the screenshots only; line 5 is cut off on screen, so I didn't retype it as a file.
- Some screenshots show the VM's taskbar clock; nothing was edited onto them. A background browser bar was blacked out in one shot (07).
