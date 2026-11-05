# Clarity Health - Medical Clinic 3380, Group 10

Medical clinic web app: staff manage patients, appointments, payments, queries and reports;
patients sign up, book and cancel their own visits, and check their balance.

Live site: https://clinic3380-rm.azurewebsites.net (deploys automatically on every push to `main`).
The free hosting plan sleeps when idle, so the first load after a quiet spell can take up to a minute.

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
    pages/staff/         StaffDashboard + Appointments, Patients, Payments, Queries, Reports
    pages/patient/       PatientPortal + MyAppointments, BookAppointment, MyBalance
    styles/              app-wide CSS: index.css (colors, fonts, spacing tokens), App.css

database/                SQL scripts
  reset, schema, triggers, views, seed, queries, reports   full rebuild, in this order (local only)
  migrate-*.sql          changes to an existing database (safe to run more than once)

deploy.ps1               manual deploy to Azure
setup-azure.ps1          one-time Azure setup (WARNING: rebuilds the database)
.github/workflows/       auto-deploy to Azure on push to main
```

## Run it locally

1. **SQL Server Express must be running.** If `sqlcmd` can't connect, start the service from an
   **admin** PowerShell: `Start-Service 'MSSQL$SQLEXPRESS'` (check with `Get-Service 'MSSQL$SQLEXPRESS'`).
2. **Database**, from the repo root. Use the classic `sqlcmd` and always pass `-I`:
   ```powershell
   $sql = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\Tools\Binn\SQLCMD.EXE"
   foreach ($f in "reset","schema","triggers","views","seed","queries","reports") {
       & $sql -S localhost\SQLEXPRESS -E -C -I -i "database\$f.sql"
   }
   ```
   - `-I` turns on `QUOTED_IDENTIFIER`. Without it, `seed.sql` fails with `Msg 1934` because of the
     filtered unique index on `Member.SSN`.
   - If `sqlcmd` says `Timed out waiting for pipe '\\.\pipe\SQLLocal\SQLEXPRESS'` while the service
     is running, you are using the newer go-sqlcmd (`C:\Program Files\SqlCmd\sqlcmd.exe`, often first
     in PATH). Use the classic path above. `Get-Command sqlcmd -All` lists every copy you have.
   - Rebuild the database after pulling changes to any file in `database/`.
3. **API**: `dotnet run --project backend --launch-profile https` (listens on https://localhost:7216).
   The warning `WebRootPath was not found` is normal locally; Vite serves the site.
4. **Website**: `cd frontend`, `npm install`, `npm run dev`, then open the address it prints.

Test logins all use the password `Clinic2026!` (for example `admin`, `spatel` doctor,
`dmartinez` receptionist, `egarcia` patient).

## Page addresses

| Address | Page | Who |
| --- | --- | --- |
| `/` | Sign in (signed-in users go to their home page) | everyone |
| `/signup` | Patient sign-up | not signed in |
| `/portal/<page>` | Patient portal: `appointments`, `book`, `balance` | patients |
| `/staff/<page>` | Staff dashboard: `appointments`, `patients`, `payments`, `queries`, `reports` | staff (each page lists its roles) |

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
- A schema change needs both: the change in `schema.sql` (for local rebuilds) and a `migrate-<name>.sql` (for Azure).