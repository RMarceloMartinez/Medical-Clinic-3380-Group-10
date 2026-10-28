import { useState } from 'react'
import Layout from '../../components/Layout'
import Appointments from './Appointments'
import Patients from './Patients'
import Payments from './Payments'
import Queries from './Queries'
import Reports from './Reports'

// Every staff page, who may open it (same roles as the API), and what it is for.
// To add a page: add a line here and a case in renderPage().
const SECTIONS = [
  { key: 'home', label: 'Home', roles: ['Admin', 'Receptionist', 'Doctor', 'Nurse'] },
  { key: 'appointments', label: 'Appointments', roles: ['Admin', 'Receptionist', 'Doctor'],
    description: 'Book, edit, cancel and complete visits.' },
  { key: 'patients', label: 'Patients', roles: ['Admin', 'Receptionist'],
    description: 'Add, edit and remove patient records.' },
  { key: 'payments', label: 'Payments', roles: ['Admin', 'Receptionist'],
    description: 'Record payments for appointments.' },
  { key: 'queries', label: 'Queries', roles: ['Admin', 'Receptionist', 'Doctor'],
    description: 'Search patients, check balances, see a doctor\'s week.' },
  { key: 'reports', label: 'Reports', roles: ['Admin'],
    description: 'Revenue, appointment activity and patient health summaries.' },
]

export default function StaffDashboard({ account, onLogout }) {
  const [section, setSection] = useState('home')
  const role = account.role

  const allowed = SECTIONS.filter((s) => s.roles.includes(role))

  function renderPage() {
    switch (section) {
      case 'appointments': return <Appointments role={role} />
      case 'patients': return <Patients />
      case 'payments': return <Payments />
      case 'queries': return <Queries role={role} />
      case 'reports': return <Reports role={role} />
      default: return <StaffHome role={role} sections={allowed} onOpen={setSection} />
    }
  }

  return (
    <Layout
      title="Medical Clinic – Staff"
      account={account}
      items={allowed}
      current={section}
      onSelect={setSection}
      onLogout={onLogout}
    >
      {/* key = section: each visit to a page starts fresh and reloads its data */}
      <div key={section}>{renderPage()}</div>
    </Layout>
  )
}

// Home page: one card per page this role can open
function StaffHome({ role, sections, onOpen }) {
  const pages = sections.filter((s) => s.key !== 'home')

  return (
    <div className="home">
      <h2>Welcome</h2>
      {pages.length === 0 ? (
        <p className="home-empty">
          There are no pages for the {role} role yet. Please contact the clinic administrator.
        </p>
      ) : (
        <>
          <p>Choose what you want to do.</p>
          <div className="home-cards">
            {pages.map((s) => (
              <button key={s.key} type="button" className="home-card" onClick={() => onOpen(s.key)}>
                <span className="home-card-title">{s.label}</span>
                <span className="home-card-text">{s.description}</span>
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  )
}
