# Clarity Health - Medical Clinic 3380, Group 10

Medical clinic web app: staff manage patients, appointments, payments, queries and reports;
patients sign up, book and cancel their own visits, and check their balance.

Live site: https://clinic3380-rm.azurewebsites.net (deploys automatically on every push to `main`).
The free hosting plan sleeps when idle, so the first load after a quiet spell can take up to a minute.

## What is in this submission

| File or folder | What it is |
| --- | --- |
| `database/MedicalClinic_dump.sql` | **SQL dump of the populated database**, taken from the live Azure database on Nov 15, 2026: 34 tables with all their rows (938), keys and indexes, 12 views, 14 stored procedures and the 13 triggers |
| `database/backup-azure.ps1` | The PowerShell script that made the dump (see "How the dump was made") |
| `database/*.sql` | The source scripts the database was built from: schema, triggers, views, seed data, queries, reports, migrations |
| `backend/` | ASP.NET Core API (C#, .NET 10) |
| `frontend/` | React website (Vite, React Router) |
| `deploy.ps1`, `setup-azure.ps1`, `.github/workflows/` | Azure hosting and automatic deploy |
| Project document (PDF, sent with this submission) | What the application does: data that can be added, modified and deleted; user roles; triggers; queries and reports |

## Test accounts

Sign in on the live site (or a local copy) with any account below. The password for every account is `Clinic2026!`.

| Role | Username | Person | What to try |
| --- | --- | --- | --- |
| Administrator | `admin` | Clinic administrator | Reports, Staff (add an employee), delete an appointment |
| Receptionist | `dmartinez` | Daniel Martinez | Patients, Appointments, Payments, Patient balance query |
| Nurse | `jlee` | Jessica Lee (Main Street office) | Visits: check in, record vitals and nursing notes |
| Nurse | `kthomas` | Kevin Thomas (Westheimer office) | Same as above, at the other office |
| Doctor (primary care) | `spatel` | Dr. Sarah Patel, Family Medicine | My visits, prescribe (severe-allergy trigger), Referrals |
| Doctor (primary care) | `pshah`, `dchen`, `rkim` | Dr. Priya Shah (Family Medicine), Dr. David Chen (Internal Medicine), Dr. Robert Kim (Pediatrics) | My visits, Referrals |
| Doctor (specialist) | `jwilson`, `anguyen`, `smartinez`, `dbrooks` | Dr. James Wilson and Dr. Angela Nguyen (Cardiology), Dr. Sophia Martinez (Dermatology), Dr. Daniel Brooks (Orthopedics) | My visits, Doctor's week query |
| Patient | `egarcia` | Emily Garcia | Book appointment (referral trigger: Dr. Nguyen is refused, Dr. Wilson is allowed) |
| Patient | `landerson`, `hadams` | Liam Anderson, Henry Adams | My balance: pay a bill (test card `4242 4242 4242 4242`, `12/30`, CVV `123`) |
| Patient | `odavis`, `mbrown` | Olivia Davis, Michael Brown | My appointments (including Request chart), Medical records |

Other sample patients use their first initial and last name as the username (for example, Henry Adams is `hadams`).

## Install and run it locally

### What you need

- **SQL Server 2019 or newer** (the free SQL Server Express is enough), with the classic `sqlcmd`
- **.NET 10 SDK** (for the API)
- **Node.js 22** (for the website)

### 1. Database: restore the dump (recommended)

From the repo root in PowerShell:

```powershell
$sql = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\Tools\Binn\SQLCMD.EXE"
& $sql -S localhost\SQLEXPRESS -E -C -Q "CREATE DATABASE MedicalClinic"
& $sql -S localhost\SQLEXPRESS -E -C -I -b -d MedicalClinic -i "database\MedicalClinic_dump.sql"
```

- The database must be named `MedicalClinic` on `localhost\SQLEXPRESS`: that is what the API's
  connection string in `backend/appsettings.json` points to. If you already have a `MedicalClinic`
  database, drop it first or restore into another name and change the connection string.
- `-I` turns on `QUOTED_IDENTIFIER` (needed by the filtered unique indexes); `-b` stops at the first error.
- The load takes a few seconds. The dump creates the tables and rows first and the triggers last,
  so the existing data loads without tripping the business rules.
- Check it: `& $sql -S localhost\SQLEXPRESS -E -C -d MedicalClinic -Q "SELECT COUNT(*) FROM sys.triggers"` prints 13.

**Or rebuild from the source scripts** (sample data only, not the live data):

```powershell
foreach ($f in "reset","schema","triggers","views","seed","queries","reports") {
    & $sql -S localhost\SQLEXPRESS -E -C -I -i "database\$f.sql"
}
```

### 2. Common sqlcmd problems

1. **SQL Server Express must be running.** If `sqlcmd` can't connect, start the service from an
   **admin** PowerShell: `Start-Service 'MSSQL$SQLEXPRESS'` (check with `Get-Service 'MSSQL$SQLEXPRESS'`).
2. Use the classic `sqlcmd` and always pass `-I`. Without it, loading fails with `Msg 1934` because of the
   filtered unique index on `Member.SSN`.
3. If `sqlcmd` says `Timed out waiting for pipe '\\.\pipe\SQLLocal\SQLEXPRESS'` while the service
   is running, you are using the newer go-sqlcmd (`C:\Program Files\SqlCmd\sqlcmd.exe`, often first
   in PATH). Use the classic path above. `Get-Command sqlcmd -All` lists every copy you have.

### 3. API

`dotnet run --project backend --launch-profile https` (listens on https://localhost:7216).
The warning `WebRootPath was not found` is normal locally; Vite serves the site.
Run `dotnet dev-certs https --trust` once if the browser rejects the local certificate.

### 4. Website

`cd frontend`, `npm install`, `npm run dev`, then open the address it prints (http://localhost:5173)
and sign in with a test account above.

## How the dump was made

`database/backup-azure.ps1` scripts the live Azure SQL database into one `.sql` file with SQL Server
Management Objects (the same library SSMS uses for "Generate Scripts", schema and data). It runs in four
passes: tables with keys and indexes, then every row, then views and procedures, then triggers.

```powershell
Install-Module SqlServer -Scope CurrentUser
az login --tenant <tenant id>
.\database\backup-azure.ps1 -OutFile "$PWD\database\MedicalClinic_dump.sql"
```

The Azure SQL firewall must allow your IP address first.

## Project structure

```
backend/                 ASP.NET Core API (.NET 10)
  Controllers/           HTTP endpoints (/api/...), one per area
  Services/              SQL for each area (called by the controllers)
  Models/
    Requests/            what the frontend sends (create, update, login, ...)
    Responses/           what the API sends back for single records
    Rows/                rows returned by queries, reports and dropdowns
  Data/                  database connection
  Program.cs             startup: auth, CSRF, serves the built website (and index.html for page addresses)

frontend/                React + Vite website (React Router for page addresses)
  src/
    main.jsx             entry point (wraps the app in the router)
    App.jsx              routes: which address shows which page, and who may open it
    api/client.js        every call to the backend goes through here
    components/          pieces shared by several pages (Layout, PublicHeader, SiteFooter, Icon)
    pages/auth/          Login, SignUp
    pages/staff/         StaffDashboard + Appointments, Patients, Payments, Queries, Reports, Referrals, Staff
    pages/doctor/        DoctorVisits (the doctor's own visits)
    pages/nurse/         NurseVisits (check-in, vitals, nursing notes)
    pages/patient/       PatientPortal + MyAppointments, BookAppointment, MyBalance, MedicalRecords, ChartRequests
    styles/              app-wide CSS: index.css (colors, fonts, spacing tokens), App.css

database/                SQL scripts
  MedicalClinic_dump.sql full copy of the live database (restore with step 1 above)
  backup-azure.ps1       makes that dump from Azure
  reset, schema, triggers, views, seed, queries, reports   full rebuild, in this order (local only)
  health-trends.sql      views and procedures for the Health trends report
  migrate-*.sql          changes to an existing database (safe to run more than once)
  seed-*.sql             extra sample data added to the live database

deploy.ps1               manual deploy to Azure
setup-azure.ps1          one-time Azure setup (WARNING: rebuilds the database)
.github/workflows/       auto-deploy to Azure on push to main
```

## Page addresses

| Address | Page | Who |
| --- | --- | --- |
| `/` | Sign in (signed-in users go to their home page) | everyone |
| `/signup` | Patient sign-up | not signed in |
| `/portal/<page>` | Patient portal: `appointments`, `book`, `balance`, `records` | patients |
| `/staff/<page>` | Staff workspace: `appointments`, `patients`, `payments`, `queries`, `reports`, `referrals`, `doctor-visits`, `nurse-visits`, `staff` | staff (each page lists its roles) |

Opening a protected page while signed out sends you to sign in, then back to that page.
Opening a page your role can't use sends you to your own home page.

**Adding a staff page:** one line in `SECTIONS` in `pages/staff/StaffDashboard.jsx`
(key, icon, label, roles, description) and one `case` in `renderPage()`. The address,
menu entry and home-page card come from that line.

## Working on the project

- Start every change from an up-to-date `main`: `git checkout main`, `git pull`, `git checkout -b my-change`.
- After every pull, run `npm install` in `frontend` (new packages, such as React Router, otherwise break the build).
- Run `npm run build` in `frontend` before pushing. A broken build stops the live deploy.
- If a merge shows conflicts in files you did not mean to change, keep the `main` version.

## Changing the live (Azure) database

The live database holds real test data, so it is **never rebuilt**:

- Only run `migrate-*.sql` and `triggers.sql` on Azure (both are safe to run more than once).
- **Never** run `reset.sql` or `setup-azure.ps1` against Azure: they delete everything.
- The dump is only for a new, empty database (a local copy); never load it into the live one.
- A schema change needs both: the change in `schema.sql` (for local rebuilds) and a `migrate-<name>.sql` (for Azure).
