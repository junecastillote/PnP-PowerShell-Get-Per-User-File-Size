# Get-SPOLibraryFileSize.ps1

![PowerShell](https://img.shields.io/badge/PowerShell-7.4%2B-blue?logo=powershell)
![PnP.PowerShell](https://img.shields.io/badge/Requires-PnP.PowerShell-green)
![SharePoint Online](https://img.shields.io/badge/Target-SharePoint%20Online-orange)

## 📖 Overview

The **Get-SPOLibraryFileSize.ps1** script retrieves file size information from SharePoint Online document libraries.
It can generate a detailed report of all files or summarize storage usage per author.

This script excludes system libraries (`Style Library`, `Site Assets`, and `Form Templates`) to focus only on user-managed document libraries.

---

## ✨ Features

- Lists all files across document libraries in a SharePoint Online site.
- Shows detailed metadata: **Site, Author, Email, Library, Folder, File Name, Size (MB)**.
- Optionally summarizes file sizes **by author**, including file count and total MB usage.
- Supports both **user-authored** and **app-authored** files.
- Automatically rounds file sizes to 2 decimal places.

---

## 📦 Requirements

- **PowerShell 7.x** (cross-platform).
- **[PnP.PowerShell](https://pnp.github.io/powershell/)** module.

> NOTE: It is recommended to use app-only access with PnP PowerShell if targeting bulk SharePoint Online sites to avoid lack of permission issues. Refer to [Setting up access to your own Entra ID App for App Only Access](https://pnp.github.io/powershell/articles/registerapplication.html#setting-up-access-to-your-own-entra-id-app-for-app-only-access).

---

## ⚙️ Parameters

| Parameter            | Type   | Description                                                                  |
| -------------------- | ------ | ---------------------------------------------------------------------------- |
| `-SummarizeByAuthor` | Switch | Groups files by author and displays total size (MB) and file count per user. |

---

## 🚀 Usage

### 1. Get the script

Download the `Get-SPOLibraryFileSize.ps1` from the [GitHub repository](https://github.com/junecastillote/PnP-PowerShell-Get-Per-User-File-Size).

### 2. Connect to SharePoint Online

```powershell
# Interactive
Connect-PnPOnline -Url "https://<tenant>.sharepoint.com/sites/<yoursite>" -Interactive -Client "<client Id>"

# App-Only with certificate in Windows Certificate Store.
Connect-PnPOnline -Url "https://<tenant>.sharepoint.com/sites/<yoursite>" -Client "<client Id>" -Thumbprint "<certificate thumbprint>" -Tenant "<tenant>.onmicrosoft.com"

```

### 3. Run the script

#### Get detailed file list

```powershell
.\Get-SPOLibraryFileSize.ps1
```

Example output:

```PlainText
Site                        AuthorType Author      Email               Library   Folder                 FileName   SizeMB
----                        ---------- ------      -----               -------   ------                 --------   ------
https://contoso.sharepoint… User       Alice Wong  alice@contoso.com   Docs      /Docs/Reports          Q1.pdf     1.25
https://contoso.sharepoint… App        Flow        -                   Docs      /Docs/GeneratedFiles   Report.csv 0.85
```

#### Summarize by author

```powershell
.\Get-SPOLibraryFileSize.ps1 -SummarizeByAuthor
```

Example output:

```PlainText
Site                        Author      Email               AuthorType FileCount TotalMB
----                        ------      -----               ---------- --------- -------
https://contoso.sharepoint… Alice Wong  alice@contoso.com   User       57        482.14
https://contoso.sharepoint… Flow        -                   App        12        23.87
```

---

## 📊 Process Flow

```plaintext
Connect to SharePoint Online
            |
            v
      Get Site URL
            |
            v
 Retrieve Document Libraries
            |
            v
 Exclude System Libraries
            |
            v
  Fetch List Items (Files Only)
            |
            v
   Build Detailed Report
       /           \
      v             v
Detailed List   Summarize by Author

```

---

## 📋 Notes

- System libraries are excluded by default:
  - `Style Library`
  - `Site Assets`
  - `Form Templates`
- Only **files** are included in reports (folders are filtered out).
- File sizes are reported in **megabytes (MB)**.

---

## 🛠️ Error Handling

- If the **PnP.PowerShell** module is not available, the script will stop and display an error.
- If not connected to a SharePoint site, the script will prompt with an error message.

---

## 📜 License

MIT License - feel free to use and modify.

---

## ✍️ Author

**June Castillote**
💡 Contributions and feedback are welcome!
