# Medical Clinic 3380 - Group 10

Medical clinic web app: staff manage patients, appointments, payments, queries and reports;
patients sign up, book and cancel their own visits, and check their balance.

Live site: https://clinic3380-rm.azurewebsites.net (deploys automatically on every push to `main`).

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
  Program.cs             startup: auth, CSRF, serves the built website

frontend/                React + Vite website
  src/
    main.jsx             entry point
    App.jsx              picks Login / Patient portal / Staff dashboard
    api/client.js        every call to the backend goes through here
    components/          pieces shared by several pages (Layout)
    pages/auth/          Login, SignUp
    pages/staff/         StaffDashboard + Appointments, Patients, Payments, Queries, Reports
    pages/patient/       PatientPortal + MyAppointments, BookAppointment, MyBalance
    styles/              app-wide CSS (a page's own CSS sits next to it)

database/                SQL scripts, run in this order:
                         reset, schema, triggers, views, seed, queries, reports

deploy.ps1               manual deploy to Azure
setup-azure.ps1          one-time Azure setup (WARNING: rebuilds the database)
.github/workflows/       auto-deploy to Azure on push to main
```

## Run it locally

1. **Database** (SQL Server Express), from the repo root:
   ```powershell
   foreach ($f in "reset","schema","triggers","views","seed","queries","reports") {
       sqlcmd -S localhost\SQLEXPRESS -E -C -i "database\$f.sql"
   }
   ```
2. **API**: `dotnet run --project backend --launch-profile https` (listens on https://localhost:7216)
3. **Website**: `cd frontend`, `npm install`, `npm run dev`, then open the address it prints.

Test logins all use the password `Clinic2026!` (for example `admin`, `spatel` doctor,
`dmartinez` receptionist, `egarcia` patient).

## Working on the project

- Start every change from an up-to-date `main`: `git checkout main`, `git pull`, `git checkout -b my-change`.
- Run `npm run build` in `frontend` before pushing. A broken build stops the live deploy.
- If a merge shows conflicts in files you did not mean to change, keep the `main` version.
