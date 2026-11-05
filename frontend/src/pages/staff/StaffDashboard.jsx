import { useState } from 'react'
import Icon from '../../components/Icon'
import Layout from '../../components/Layout'
import Appointments from './Appointments'
import Patients from './Patients'
import Payments from './Payments'
import Queries from './Queries'
import Reports from './Reports'
import { Navigate, useNavigate, useParams } from 'react-router'

// Every staff page, who may open it (same roles as the API), and what it is for.
// To add a page: add a line here and a case in renderPage().
const SECTIONS = [
  { key: 'home', icon: 'home', label: 'Home', roles: ['Admin', 'Receptionist', 'Doctor', 'Nurse'] },
  { key: 'appointments', icon: 'calendar', label: 'Appointments', roles: ['Admin', 'Receptionist', 'Doctor'],
    description: {
      Doctor: 'See your own visits and mark them completed.',
      default: 'Book, edit, cancel, and complete visits',
    }},
  { key: 'patients', icon: 'users', label: 'Patients', roles: ['Admin', 'Receptionist'],
    description: {default:'Add, edit and remove patient records.'} },
  { key: 'payments', icon: 'receipt', label: 'Payments', roles: ['Admin', 'Receptionist'],
    description: {default: 'Record payments for appointments.'} },
  { key: 'queries', icon: 'search', label: 'Queries', roles: ['Admin', 'Receptionist', 'Doctor'],
    description: {
      Doctor: 'Search patients and see our week',
      default:'Search patients, check balances, see a doctor\'s week.'} },
  { key: 'reports', icon: 'chart', label: 'Reports', roles: ['Admin'],
    description: {default: 'Revenue, appointment activity and patient health summaries.'} },
]

export default function StaffDashboard({ account, onLogout }) {
  
  const role = account.role
  const allowed = SECTIONS.filter((s) => s.roles.includes(role))

  // The page comes from the address: /staff -> home, /staff/patients -> patients
  const { section = 'home' } = useParams()
  const navigate = useNavigate()
  const setSection = (key) => navigate(key === 'home' ? '/staff' : `/staff/${key}`)

  // An address this role may not open (or a typo) -> back to the staff home
  if (!allowed.some((s) => s.key === section)) {
    return <Navigate to="/staff" replace />
  }

  function renderPage() {
    switch (section) {
      case 'appointments': return <Appointments role={role} />
      case 'patients': return <Patients />
      case 'payments': return <Payments />
      case 'queries': return <Queries role={role} />
      case 'reports': return <Reports role={role} />
      default: return <StaffHome account={account} sections={allowed} onOpen={setSection} />
    }
  }

  return (
    <Layout
      title="Staff workspace"
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

// "Good morning" / "Good afternoon" / "Good evening" from the current hour
function greeting() {
  const hour = new Date().getHours()
  if (hour < 12) return 'Good morning'
  if (hour < 17) return 'Good afternoon'
  return 'Good evening'
}

// Home page: a welcome banner, then one card per page this role can open
function StaffHome({ account, sections, onOpen }) {
  const role = account.role
  const pages = sections.filter((s) => s.key !== 'home')
  const today = new Date().toLocaleDateString([], { weekday: 'long', month: 'long', day: 'numeric' })

  return (
    <div className="home">
      <div className="welcome-banner">
        <div>
          <h2>{greeting()}, {account.username}</h2>
          <p>{today} · Signed in as {role}</p>
        </div>
      </div>

      {pages.length === 0 ? (
        <p className="home-empty">
          There are no pages for the {role} role yet. Please contact the clinic administrator.
        </p>
      ) : (
        <>
          <h3 className="home-section-title">What would you like to do?</h3>
          <div className="home-cards">
            {pages.map((s) => (
              <button key={s.key} type="button" className="home-card" onClick={() => onOpen(s.key)}>
                <span className="icon-circle"><Icon name={s.icon} size={24} /></span>
                <span className="home-card-title">{s.label}</span>
                <span className="home-card-text">{s.description[role] ?? s.description.default}</span>
                <span className="home-card-link">Open <Icon name="arrowRight" size={16} /></span>
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  )
}
